import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:kairete/config/api_paths.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/utils/media_upload_kind.dart';
import 'package:http_parser/http_parser.dart';
import 'package:kairete/core/services/reaction_service.dart';
import 'package:kairete/features/media/models/media_album_profile.dart';
import 'package:kairete/features/media/models/media_comment.dart';
import 'package:kairete/features/media/models/media_item.dart';

class MediaService {
  XenforoApi get _api => AppApi.instance.xenforo;
  final ReactionService _reactions = ReactionService();

  Future<List<MediaItem>> fetchMedia({
    int? albumId,
    int? categoryId,
    int? userId,
    int page = 1,
    int limit = 20,
  }) async {
    await AppApi.instance.applySession();
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
      'with': 'Album,Category,User',
    };
    if (albumId != null) query['album_id'] = albumId;
    if (categoryId != null) query['category_id'] = categoryId;
    if (userId != null) query['user_id'] = userId;

    final json = await _api.get(ApiPaths.media, query: query);
    _throwIfError(json);
    return _parseMediaList(json);
  }

  Future<MediaItem> fetchMediaItem(int mediaId) async {
    await AppApi.instance.applySession();
    var json = await _api.get(
      '${ApiPaths.media}$mediaId/',
      query: {'with': 'Album,Category,User'},
    );
    _throwIfError(json);

    final direct = json['media'];
    if (direct is Map<String, dynamic>) {
      return MediaItem.fromJson(direct);
    }

    json = await _api.get(ApiPaths.media, query: {'media_id': mediaId});
    _throwIfError(json);
    final list = _parseMediaList(json);
    for (final item in list) {
      if (item.mediaId == mediaId) return item;
    }
    throw MediaException('Media non trovato.');
  }

  Future<List<MediaAlbum>> fetchAlbums({int? userId}) async {
    await AppApi.instance.applySession();
    final query = <String, dynamic>{'with': 'Category'};
    if (userId != null) query['user_id'] = userId;

    final json = await _api.get(ApiPaths.mediaAlbums, query: query);
    _throwIfError(json);
    final raw = json['albums'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => MediaAlbum.fromJson(Map<String, dynamic>.from(e)))
        .where((a) => a.albumId > 0)
        .toList();
  }

  Future<List<MediaCategory>> fetchCategories() async {
    await AppApi.instance.applySession();
    final json = await _api.get(ApiPaths.mediaCategories);
    _throwIfError(json);
    final raw = json['categories'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => MediaCategory.fromJson(Map<String, dynamic>.from(e)))
        .where((c) => c.categoryId > 0)
        .toList();
  }

  Future<MediaAlbumProfile> fetchAlbumProfile(int albumId) async {
    await AppApi.instance.applySession();
    final json = await _api.get(
      '${ApiPaths.mediaAlbums}$albumId/',
      query: {'with': 'User,LastMedia'},
    );
    _throwIfError(json);
    final album = json['album'];
    if (album is! Map<String, dynamic>) {
      throw MediaException('Album non trovato.');
    }
    var profile = MediaAlbumProfile.fromJson(album);
    if (!profile.hasCover) {
      final media = await fetchMedia(albumId: albumId, limit: 1);
      final thumb = media.isNotEmpty ? media.first.heroImageUrl : null;
      if (thumb != null && thumb.isNotEmpty) {
        profile = profile.copyWith(coverUrl: thumb);
      }
    }
    return profile;
  }

  Future<bool> watchAlbum(int albumId, {required bool stop}) async {
    await AppApi.instance.applySession();
    try {
      final json = await _api.post(
        ApiPaths.newsfeedAlbumWatch,
        body: {
          'album_id': albumId,
          if (stop) 'stop': true,
        },
      );
      if (XenforoApi.firstErrorMessage(json) == null) {
        if (json['is_watched'] is bool) {
          return json['is_watched'] as bool;
        }
        if (json['is_watching'] is bool) {
          return json['is_watching'] as bool;
        }
        return !stop;
      }
    } on MediaException {
      rethrow;
    } catch (_) {}

    final json = await _api.post(
      '${ApiPaths.mediaAlbums}$albumId/watch/',
      body: stop ? {'stop': true} : {},
    );
    _throwIfError(json);
    if (json['is_watched'] is bool) {
      return json['is_watched'] as bool;
    }
    if (json['is_watching'] is bool) {
      return json['is_watching'] as bool;
    }
    final action = json['action']?.toString();
    if (action == 'watch') return true;
    if (action == 'unwatch') return false;
    return !stop;
  }

  Future<MediaCommentsPage> fetchComments(int mediaId) async {
    await AppApi.instance.applySession();
    final json = await _api.get('${ApiPaths.media}$mediaId/comments');
    _throwIfError(json);
    return MediaCommentsPage.fromJson(json);
  }

  Future<void> postComment({
    required int mediaId,
    required String message,
  }) async {
    await AppApi.instance.applySession();
    final json = await _api.post(
      ApiPaths.mediaComments,
      body: {
        'media_id': mediaId,
        'message': message,
      },
    );
    _throwIfError(json);
  }

  Future<String> react({
    required int mediaId,
    int? authorUserId,
    int reactionId = 1,
  }) async {
    try {
      return await _reactions.reactMedia(
        mediaId,
        authorUserId: authorUserId,
        reactionId: reactionId,
      );
    } on ReactionException catch (e) {
      throw MediaException(e.message);
    }
  }

  Future<MediaItem> createMedia({
    required String title,
    required String description,
    required int albumId,
    int categoryId = 0,
    String tags = '',
    required String filePath,
    required String filename,
  }) async {
    await AppApi.instance.applySession();
    if (!File(filePath).existsSync()) {
      throw MediaException(
        'File allegato non trovato. Seleziona di nuovo foto, video o audio.',
      );
    }

    final kind = mediaUploadKindFromSources(
      filename: filename,
      filePath: filePath,
    );
    final fields = _uploadFields(
      title: title,
      description: description,
      albumId: albumId,
      categoryId: categoryId,
      tags: tags,
    );

    // Solo API nativa XFMG: OmniFeed media-upload resta rotto finché non si
    // installa 1.7.76+ sul forum; evitiamo di passarci sopra.
    final result = await _attemptUpload(
      ApiPaths.media,
      fields,
      filePath,
      filename,
      kind: kind,
      nativeFileOnly: true,
    );
    final createdId = _extractCreatedMediaId(result.json);
    if (createdId != null) {
      return fetchMediaItem(createdId);
    }

    final lastErr = result.error;
    if (lastErr != null && lastErr.isNotEmpty) {
      throw MediaException(_mapUploadError(lastErr, kind));
    }
    if (result.json != null) {
      _throwIfError(result.json!, uploadKind: kind);
    }
    throw MediaException('Media creato ma risposta non valida.');
  }

  Future<({Map<String, dynamic>? json, String? error})> _attemptUpload(
    String path,
    Map<String, dynamic> fields,
    String filePath,
    String filename, {
    required MediaUploadKind kind,
    bool nativeFileOnly = false,
  }) async {
    var json = await _postUploadMultipart(
      path,
      fields,
      filePath,
      filename,
      kind: kind,
      nativeFileOnly: nativeFileOnly,
    );
    if (_extractCreatedMediaId(json) != null) {
      return (json: json, error: null);
    }

    var err = XenforoApi.firstErrorMessage(json);
    if (_isMissingUploadError(json, err)) {
      json = await _postUploadBase64(
        path,
        fields,
        filePath,
        filename,
        kind: kind,
      );
      if (_extractCreatedMediaId(json) != null) {
        return (json: json, error: null);
      }
      err = XenforoApi.firstErrorMessage(json) ?? err;
    }

    return (json: json, error: err);
  }

  int? _extractCreatedMediaId(Map<String, dynamic>? json) {
    if (json == null) return null;
    final item = _parseCreatedMedia(json);
    if (item != null) return item.mediaId;
    final directId = json['media_id'];
    if (directId is int && directId > 0) return directId;
    if (directId is String) {
      final parsed = int.tryParse(directId);
      if (parsed != null && parsed > 0) return parsed;
    }
    return null;
  }

  Map<String, dynamic> _uploadFields({
    required String title,
    required String description,
    required int albumId,
    int categoryId = 0,
    required String tags,
  }) {
    final fields = <String, dynamic>{
      'title': title.trim(),
      'description': description.trim(),
      'album_id': albumId,
    };
    if (categoryId > 0) {
      fields['category_id'] = categoryId;
    }
    if (tags.trim().isNotEmpty) {
      for (final tag in _splitTags(tags)) {
        fields['tags[]'] = tag;
      }
    }
    return fields;
  }

  Future<Map<String, dynamic>> _postUploadMultipart(
    String path,
    Map<String, dynamic> fields,
    String filePath,
    String filename, {
    required MediaUploadKind kind,
    bool nativeFileOnly = false,
  }) async {
    try {
      final file = _buildUploadFile(filePath, filename, kind);
      final files = nativeFileOnly
          ? {'file': file}
          : {
              'file': file,
              'attachment': _buildUploadFile(filePath, filename, kind),
            };
      return await _api.postMultipart(
        path,
        fields: fields,
        files: files,
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      throw MediaException(XenforoApi.connectionMessage(e));
    }
  }

  Future<Map<String, dynamic>> _postUploadBase64(
    String path,
    Map<String, dynamic> fields,
    String filePath,
    String filename, {
    required MediaUploadKind kind,
  }) async {
    const maxBytes = 25 * 1024 * 1024;
    final bytes = await File(filePath).readAsBytes();
    if (bytes.length > maxBytes) {
      throw MediaException(
        'Video troppo grande (${(bytes.length / (1024 * 1024)).toStringAsFixed(1)} MB). '
        'Chiedi all\'hosting di aumentare upload_max_filesize e post_max_size in PHP '
        '(consigliato almeno 128M).',
      );
    }
    final safeName = _safeUploadFilename(filename, kind);
    final mime = mediaUploadMimeTypeForKind(kind, safeName) ?? 'application/octet-stream';
    try {
      return await _api.post(
        path,
        body: {
          ...fields,
          'file_base64': base64Encode(bytes),
          'file_name': safeName,
          'file_mime': mime,
        },
      );
    } on DioException catch (e) {
      throw MediaException(XenforoApi.connectionMessage(e));
    }
  }

  MultipartFile _buildUploadFile(
    String filePath,
    String filename,
    MediaUploadKind kind,
  ) {
    final safeName = _safeUploadFilename(filename, kind);
    final mime = mediaUploadMimeTypeForKind(kind, safeName);
    final contentType = mime == null ? null : MediaType.parse(mime);
    return MultipartFile.fromFileSync(
      filePath,
      filename: safeName,
      contentType: contentType,
    );
  }

  bool _isMissingUploadError(Map<String, dynamic> json, String? message) {
    final lower = message?.toLowerCase() ?? '';
    if (lower.contains('file mancante') ||
        lower.contains('required input missing') ||
        (lower.contains('embed') && lower.contains('file'))) {
      return true;
    }
    final errors = json['errors'];
    if (errors is! List) return false;
    for (final err in errors) {
      if (err is! Map) continue;
      final missing = err['params'];
      if (missing is Map && missing['missing'] is List) {
        final list = (missing['missing'] as List).map((e) => e.toString()).toList();
        if (list.contains('file') || list.contains('embed_url')) return true;
      }
    }
    return false;
  }

  String _safeUploadFilename(String filename, MediaUploadKind kind) {
    var trimmed = filename.trim();
    if (trimmed.isEmpty) trimmed = 'upload';
    if (!trimmed.contains('.')) {
      switch (kind) {
        case MediaUploadKind.video:
          trimmed = '$trimmed.mp4';
        case MediaUploadKind.audio:
          trimmed = '$trimmed.m4a';
        case MediaUploadKind.image:
          trimmed = '$trimmed.jpg';
        case MediaUploadKind.unknown:
          trimmed = '$trimmed.bin';
      }
    }
    return trimmed;
  }

  MediaItem? _parseCreatedMedia(Map<String, dynamic> json) {
    final media = json['media'];
    if (media is! Map) return null;
    final item = MediaItem.fromJson(Map<String, dynamic>.from(media));
    return item.mediaId > 0 ? item : null;
  }

  Future<MediaAlbum> createAlbum({
    required String title,
    required String description,
    required String viewPrivacy,
  }) async {
    await AppApi.instance.applySession();
    final fields = <String, dynamic>{
      'title': title.trim(),
      'description': description.trim(),
      'view_privacy': viewPrivacy,
    };

    final json = await _api.postMultipart(
      ApiPaths.mediaAlbums,
      fields: fields,
    );
    _throwIfError(json);

    final album = json['album'];
    if (album is Map<String, dynamic>) {
      return MediaAlbum.fromJson(album);
    }
    throw MediaException('Album creato ma risposta non valida.');
  }

  List<MediaItem> _parseMediaList(Map<String, dynamic> json) {
    final raw = json['media'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => MediaItem.fromJson(Map<String, dynamic>.from(e)))
        .where((m) => m.mediaId > 0)
        .toList();
  }

  List<String> _splitTags(String raw) {
    return raw
        .split(RegExp(r'[,\s]+'))
        .map((t) => t.trim().replaceAll('#', ''))
        .where((t) => t.isNotEmpty)
        .toList();
  }

  void _throwIfError(
    Map<String, dynamic> json, {
    MediaUploadKind uploadKind = MediaUploadKind.unknown,
  }) {
    final err = XenforoApi.firstErrorMessage(json);
    if (err == null) return;
    throw MediaException(_mapUploadError(err, uploadKind));
  }

  String _mapUploadError(String message, MediaUploadKind kind) {
    final lower = message.toLowerCase();

    if (lower.contains('mediatemp') ||
        (lower.contains('media\\creator') && lower.contains('album'))) {
      return 'OmniFeed sul forum non è aggiornato (bug MediaTemp/Album). '
          'In ACP installa OmniFeed 1.7.76, oppure aggiorna l\'app a fix38 che '
          'usa solo l\'API nativa XFMG.\n\nDettaglio tecnico: $message';
    }

    if (lower.contains('unexpected error') ||
        lower.contains('unexpected_error') ||
        lower.contains('errore imprevisto')) {
      return 'Errore sul server durante l\'upload. Aggiorna OmniFeed 1.7.74 e fix34. '
          'Se persiste: verifica permessi video XFMG, categoria con «Video upload» abilitato, '
          'e limiti PHP upload_max_filesize (128M). Dettaglio: $message';
    }
    if (lower.contains('embed_url') ||
        lower.contains('embed url') ||
        (lower.contains('embed') && lower.contains('file')) ||
        lower.contains('required input missing')) {
      return 'Il file non è arrivato al server. Prova fix34, verifica i limiti PHP '
          '(upload_max_filesize / post_max_size) e che il video sia .mp4/.mov.';
    }

    if (lower.contains('file mancante')) {
      return 'Il file non è arrivato al server. Aggiorna l\'app a fix34. '
          'Se persiste, aumenta upload_max_filesize in PHP (consigliato 128M o più).';
    }

    if ((lower.contains('url') && (lower.contains('valid') || lower.contains('valido'))) ||
        lower.contains('cannot be embedded') ||
        lower.contains('incorporat')) {
      return 'Il server ha interpretato il video come embed (link YouTube) invece che come file .mp4. '
          'Non incollare link nel titolo/descrizione: seleziona il file video dal telefono. '
          'Aggiorna OmniFeed 1.7.72 e fix32.';
    }

    // Messaggio già specifico dal server: non sostituirlo con l'hint generico ACP.
    if (lower.contains('carica video') ||
        lower.contains('carica audio') ||
        lower.contains('aggiungere media') ||
        lower.contains('proprietario') ||
        lower.contains('categoria') ||
        lower.contains('album owner') ||
        lower.contains('allowed_types') ||
        lower.contains('non consentiti')) {
      return message;
    }

    const generic = [
      'you do not have permission',
      'do not have permission to view',
      'no_permission',
      'requested_page_not_found',
    ];
    if (generic.any((p) => lower.contains(p))) {
      if (kind != MediaUploadKind.unknown) {
        return mediaUploadPermissionHint(kind);
      }
      return 'Non hai i permessi per caricare questo file nell\'album.';
    }

    if (lower.contains('permission') ||
        lower.contains('permess') ||
        lower.contains('no_permission')) {
      if (kind != MediaUploadKind.unknown) {
        return '$message\n\n${mediaUploadPermissionHint(kind)}';
      }
      return message;
    }
    return message;
  }
}

class MediaException implements Exception {
  MediaException(this.message);
  final String message;

  @override
  String toString() => message;
}

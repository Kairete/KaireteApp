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
    final kind = mediaUploadKindFromFilename(filename);
    final fields = <String, dynamic>{
      'title': title.trim(),
      'description': description.trim(),
      'album_id': albumId,
      'media_type': mediaUploadTypeField(kind),
    };
    if (categoryId > 0) {
      fields['category_id'] = categoryId;
    }
    if (tags.trim().isNotEmpty) {
      for (final tag in _splitTags(tags)) {
        fields['tags[]'] = tag;
      }
    }

    final mime = mediaUploadMimeType(filename);
    final file = await MultipartFile.fromFile(
      filePath,
      filename: filename,
      contentType: mime == null ? null : MediaType.parse(mime),
    );

    Map<String, dynamic> json;
    try {
      json = await _api.postMultipart(
        ApiPaths.newsfeedMediaUpload,
        fields: fields,
        files: {'file': file},
      );
      if (XenforoApi.firstErrorMessage(json) == null && json['media'] is Map) {
        return MediaItem.fromJson(
          Map<String, dynamic>.from(json['media'] as Map),
        );
      }
    } on MediaException {
      rethrow;
    } catch (_) {}

    json = await _api.postMultipart(
      ApiPaths.media,
      fields: fields,
      files: {'file': file},
    );
    _throwIfError(json, uploadKind: kind);

    final media = json['media'];
    if (media is Map<String, dynamic>) {
      return MediaItem.fromJson(media);
    }
    throw MediaException('Media creato ma risposta non valida.');
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
    if (lower.contains('permission') ||
        lower.contains('permess') ||
        lower.contains('no_permission')) {
      if (kind != MediaUploadKind.unknown) {
        return mediaUploadPermissionHint(kind);
      }
      return 'Non hai i permessi per caricare questo file nell\'album.';
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

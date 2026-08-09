import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:kairete/config/api_paths.dart';
import 'package:kairete/config/app_config.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/utils/media_upload_kind.dart';
import 'package:http_parser/http_parser.dart';
import 'package:kairete/core/services/reaction_service.dart';
import 'package:kairete/core/tenant/tenant_scope.dart';
import 'package:kairete/core/tenant/tenant_scope_filter.dart';
import 'package:kairete/core/tenant/tenant_service.dart';
import 'package:kairete/features/feed/utils/feed_comment_parent.dart';
import 'package:kairete/features/media/models/media_album_profile.dart';
import 'package:kairete/features/media/models/media_comment.dart';
import 'package:kairete/features/media/utils/media_comment_ui.dart';
import 'package:kairete/features/media/utils/media_quote_bbcode.dart';
import 'package:kairete/features/media/models/media_item.dart';
import 'package:kairete/features/omnifeed/services/omnifeed_service.dart';

class MediaService {
  XenforoApi get _api => AppApi.instance.xenforo;
  final ReactionService _reactions = ReactionService();

  /// Fallback base64 solo per immagini piccole se multipart non accetta il file.
  static const _base64FallbackMaxBytes = 10 * 1024 * 1024;

  Future<List<MediaItem>> fetchMedia({
    int? albumId,
    int? categoryId,
    int? userId,
    int page = 1,
    int limit = 20,
  }) async {
    if (albumId != null && userId == null) {
      return fetchAlbumMedia(albumId: albumId, page: page, limit: limit);
    }

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
    final items = await enrichMediaItemAlbumHeaders(_parseMediaList(json));
    return _pinHighlightedMedia(items, albumId: albumId);
  }

  /// Tutti i media in un album (qualsiasi autore), non solo quelli dell'utente loggato.
  Future<List<MediaItem>> fetchAlbumMedia({
    required int albumId,
    int page = 1,
    int limit = 50,
  }) async {
    await AppApi.instance.applySession();
    final json = await _api.get(
      '${ApiPaths.mediaAlbums}$albumId/media',
      query: {
        'page': page,
        'limit': limit,
        'with': 'Album,Category,User',
      },
    );
    _throwIfError(json);
    final items = await enrichMediaItemAlbumHeaders(_parseMediaList(json));
    return _pinHighlightedMedia(items, albumId: albumId);
  }

  Future<List<MediaItem>> _pinHighlightedMedia(
    List<MediaItem> items, {
    int? albumId,
  }) async {
    try {
      final contentIds = <int>{};
      final admin = await OmnifeedService().fetchHighlights('admin:media');
      contentIds.addAll(admin.contentIds);
      if (albumId != null && albumId > 0) {
        final owner =
            await OmnifeedService().fetchHighlights('owner:album:$albumId');
        contentIds.addAll(owner.contentIds);
      }
      if (contentIds.isEmpty) return items;
      return OmnifeedService.pinByContentIds(
        items: items,
        highlightedContentIds: contentIds,
        contentIdOf: (m) => m.mediaId,
      );
    } catch (_) {
      return items;
    }
  }
  Future<List<MediaItem>> fetchTenantMappedMedia({int limit = 50}) async {
    await AppApi.instance.applySession();
    await TenantService().ensureTenantReady();

    final albumIds = await _collectMappedAlbumIds();
    if (albumIds.isEmpty) {
      throw MediaException('Nessun album mappato per questa community.');
    }

    final futures = albumIds
        .map((albumId) => fetchAlbumMedia(albumId: albumId, limit: limit));
    final merged = <MediaItem>[];
    final seen = <int>{};
    for (final batch in await Future.wait(futures)) {
      for (final item in batch) {
        if (item.mediaId <= 0 || seen.contains(item.mediaId)) continue;
        seen.add(item.mediaId);
        merged.add(item);
      }
    }

    merged.sort(
      (a, b) => (b.mediaDate ?? 0).compareTo(a.mediaDate ?? 0),
    );
    final filtered = TenantScopeFilter.filterMediaItems(merged);
    return enrichMediaItemAlbumHeaders(filtered);
  }

  /// Unione album mappati in ACP + album delle categorie mappate.
  Future<Set<int>> _collectMappedAlbumIds() async {
    final albumIds = TenantScope.mediaAlbumIds.toSet();
    final categoryIds = TenantScope.mediaCategoryIds.toSet();
    if (categoryIds.isEmpty) {
      return albumIds.where((id) => id > 0).toSet();
    }

    final fromList = await fetchAlbums();
    final fromCategories =
        await _fetchAlbumsForMappedCategories(categoryIds, fromList);
    albumIds.addAll(fromCategories.map((a) => a.albumId));

    return albumIds.where((id) => id > 0).toSet();
  }

  /// Titolo album mancante nell'header feed (`nickname > album`).
  Future<List<MediaItem>> enrichMediaItemAlbumHeaders(
    List<MediaItem> items, {
    int maxLookups = 20,
  }) async {
    if (items.isEmpty) return items;

    final titles = <int, String>{};
    for (final item in items) {
      final albumId = item.album?.albumId ?? 0;
      if (albumId <= 0) continue;
      final title = item.album?.title.trim() ?? '';
      if (title.isNotEmpty) titles[albumId] = title;
    }

    try {
      final albums = await fetchAlbums();
      for (final album in albums) {
        final id = album.albumId;
        final title = album.title.trim();
        if (id > 0 && title.isNotEmpty) {
          titles.putIfAbsent(id, () => title);
        }
      }
    } catch (_) {}

    final missingAlbumIds = <int>{};
    for (final item in items) {
      final albumId = item.album?.albumId ?? 0;
      if (albumId <= 0 || titles.containsKey(albumId)) continue;
      missingAlbumIds.add(albumId);
    }

    var lookups = 0;
    for (final albumId in missingAlbumIds) {
      if (lookups >= maxLookups) break;
      lookups++;
      try {
        final fetched = await _fetchAlbumById(albumId);
        final title = fetched?.title.trim() ?? '';
        if (title.isNotEmpty) {
          titles[albumId] = title;
          continue;
        }
      } catch (_) {}
      try {
        final profile = await fetchAlbumProfile(albumId);
        if (profile.title.trim().isNotEmpty) {
          titles[albumId] = profile.title.trim();
        }
      } catch (_) {}
    }

    return items.map((item) {
      final albumId = item.album?.albumId ?? 0;
      if (albumId <= 0) return item;
      final current = item.album?.title.trim() ?? '';
      if (current.isNotEmpty) return item;
      final resolved = titles[albumId];
      if (resolved != null && resolved.isNotEmpty) {
        return item.withAlbumTitle(resolved);
      }
      return item;
    }).toList();
  }

  /// Album XFMG in cui gli iscritti tenant possono caricare media.
  Future<List<MediaAlbum>> fetchTenantUploadAlbums() async {
    await AppApi.instance.applySession();
    await TenantService().ensureTenantReady();

    final albumIds = TenantScope.mediaAlbumIds.toSet();
    final categoryIds = TenantScope.mediaCategoryIds.toSet();
    if (albumIds.isEmpty && categoryIds.isEmpty) {
      throw MediaException('Nessun album mappato per questa community.');
    }

    final all = await fetchAlbums();
    var mapped = <MediaAlbum>[];

    if (albumIds.isNotEmpty) {
      mapped = await _fetchMappedAlbumsById(albumIds, all);
    }
    if (mapped.isEmpty && categoryIds.isNotEmpty) {
      mapped = await _fetchAlbumsForMappedCategories(categoryIds, all);
    }

    return _enrichAlbumsWithCategory(mapped);
  }

  Future<String> describeTenantUploadMappingIssue() async {
    await TenantService().ensureTenantReady();
    final albumIds = TenantScope.mediaAlbumIds;
    final categoryIds = TenantScope.mediaCategoryIds;
    return 'Nessun album disponibile per il caricamento.\n'
        'Mapping ACP: album=${albumIds.isEmpty ? "—" : albumIds.join(", ")}, '
        'categorie=${categoryIds.isEmpty ? "—" : categoryIds.join(", ")}.\n'
        'In Multisite mappa almeno un album XFMG con permesso "aggiungi media" per gli iscritti.';
  }

  Future<List<MediaAlbum>> _fetchAlbumsForMappedCategories(
    Set<int> categoryIds,
    List<MediaAlbum> fromList,
  ) async {
    final byId = <int, MediaAlbum>{
      for (final album in fromList)
        if (categoryIds.contains(album.categoryId)) album.albumId: album,
    };

    for (final catId in categoryIds) {
      try {
        final json = await _api.get(
          ApiPaths.mediaAlbums,
          query: {'category_id': catId, 'with': 'Category'},
        );
        _throwIfError(json);
        final raw = json['albums'];
        if (raw is List) {
          for (final item in raw.whereType<Map>()) {
            final album =
                MediaAlbum.fromJson(Map<String, dynamic>.from(item));
            if (album.albumId > 0) byId[album.albumId] = album;
          }
        }
      } catch (_) {}

      try {
        final items = await fetchMedia(categoryId: catId, limit: 25);
        for (final item in items) {
          final aid = item.album?.albumId ?? 0;
          if (aid <= 0) continue;
          byId.putIfAbsent(
            aid,
            () => MediaAlbum(
              albumId: aid,
              title: item.album?.title ?? 'Album #$aid',
              categoryId: item.category?.categoryId ?? catId,
            ),
          );
        }
      } catch (_) {}
    }

    return byId.values.toList();
  }

  /// Carica ogni album mappato per ID: la lista generica spesso non include
  /// album condivisi/community e può omettere category_id.
  Future<List<MediaAlbum>> _fetchMappedAlbumsById(
    Set<int> albumIds,
    List<MediaAlbum> fromList,
  ) async {
    final byId = <int, MediaAlbum>{
      for (final album in fromList)
        if (albumIds.contains(album.albumId)) album.albumId: album,
    };

    for (final id in albumIds) {
      if (byId.containsKey(id) && byId[id]!.categoryId > 0) continue;
      final fetched = await _fetchAlbumById(id);
      if (fetched != null) {
        byId[id] = fetched;
      } else if (!byId.containsKey(id)) {
        byId[id] = MediaAlbum(albumId: id, title: 'Album #$id');
      }
    }

    return albumIds.map((id) => byId[id]).whereType<MediaAlbum>().toList();
  }

  Future<MediaAlbum?> _fetchAlbumById(int albumId) async {
    try {
      final json = await _api.get(
        '${ApiPaths.mediaAlbums}$albumId/',
        query: {'with': 'Category'},
      );
      _throwIfError(json);
      final raw = json['album'];
      if (raw is Map<String, dynamic>) {
        final album = MediaAlbum.fromJson(raw);
        return album.albumId > 0 ? album : null;
      }
    } catch (_) {}
    return null;
  }

  /// Categorie XFMG per upload tenant. [uploadAlbums] evita un secondo fetch
  /// album quando già caricati dal compose controller.
  Future<List<MediaCategory>> fetchTenantUploadCategories({
    List<MediaAlbum>? uploadAlbums,
  }) async {
    await AppApi.instance.applySession();
    await TenantService().ensureTenantReady();

    final neededIds = TenantScope.mediaCategoryIds.toSet();
    if (neededIds.isEmpty) {
      final albums = uploadAlbums ?? await fetchTenantUploadAlbums();
      neededIds.addAll(
        albums.map((a) => a.categoryId).where((id) => id > 0),
      );
    }
    if (neededIds.isEmpty) return const [];
    return _resolveCategories(neededIds);
  }

  Future<List<MediaAlbum>> _enrichAlbumsWithCategory(
    List<MediaAlbum> albums,
  ) async {
    if (albums.every((a) => a.categoryId > 0)) return albums;

    final enriched = <MediaAlbum>[];
    for (final album in albums) {
      if (album.categoryId > 0) {
        enriched.add(album);
        continue;
      }

      var resolved = album;
      final fetched = await _fetchAlbumById(album.albumId);
      if (fetched != null && fetched.categoryId > 0) {
        resolved = fetched;
      } else {
        resolved = await _resolveAlbumCategoryFromMedia(album);
      }
      enriched.add(resolved);
    }
    return enriched;
  }

  Future<MediaAlbum> _resolveAlbumCategoryFromMedia(MediaAlbum album) async {
    if (album.categoryId > 0) return album;
    try {
      final items = await fetchMedia(albumId: album.albumId, limit: 1);
      final categoryId = items.isNotEmpty
          ? (items.first.category?.categoryId ?? 0)
          : 0;
      if (categoryId > 0) {
        return MediaAlbum(
          albumId: album.albumId,
          title: album.title,
          categoryId: categoryId,
        );
      }
    } catch (_) {}
    return album;
  }

  Future<List<MediaCategory>> _resolveCategories(Set<int> neededIds) async {
    final all = await fetchCategories();
    final result = <MediaCategory>[];
    final resolved = <int>{};

    for (final category in all) {
      if (neededIds.contains(category.categoryId)) {
        result.add(category);
        resolved.add(category.categoryId);
      }
    }

    for (final id in neededIds) {
      if (resolved.contains(id)) continue;
      final fetched = await _fetchCategoryById(id);
      if (fetched != null) {
        result.add(fetched);
        resolved.add(id);
      }
    }

    for (final id in neededIds) {
      if (resolved.contains(id)) continue;
      result.add(MediaCategory(categoryId: id, title: 'Categoria'));
    }

    return result;
  }

  Future<MediaCategory?> _fetchCategoryById(int categoryId) async {
    try {
      final json = await _api.get('${ApiPaths.mediaCategories}$categoryId/');
      _throwIfError(json);
      final raw = json['category'];
      if (raw is Map<String, dynamic>) {
        final category = MediaCategory.fromJson(raw);
        return category.categoryId > 0 ? category : null;
      }
    } catch (_) {}
    return null;
  }

  Future<MediaItem> fetchMediaItem(int mediaId) async {
    await AppApi.instance.applySession();
    var json = await _api.get(
      '${ApiPaths.media}$mediaId/',
      query: {'with': 'Album,Category,User'},
    );
    _throwIfError(json);

    MediaItem? item;
    final direct = json['media'];
    if (direct is Map<String, dynamic>) {
      item = MediaItem.fromJson(direct);
    } else {
      json = await _api.get(ApiPaths.media, query: {'media_id': mediaId});
      _throwIfError(json);
      for (final parsed in _parseMediaList(json)) {
        if (parsed.mediaId == mediaId) {
          item = parsed;
          break;
        }
      }
    }
    if (item == null) throw MediaException('Media non trovato.');
    final enriched = await enrichMediaItemAlbumHeaders([item], maxLookups: 1);
    return enriched.first;
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

    MediaCommentsPage? kairetePage;
    Object? primaryError;
    for (final path in [
      '${ApiPaths.kaireteMedia}$mediaId/comments',
      '${ApiPaths.kaireteMedia}$mediaId/comments/',
    ]) {
      try {
        final json = await _api.get(path);
        _throwIfError(json);
        final parsed = MediaCommentsPage.fromJson(json);
        if (parsed.comments.isNotEmpty) {
          kairetePage = parsed;
          break;
        }
        kairetePage ??= parsed;
      } catch (e) {
        primaryError ??= e;
      }
    }

    MediaCommentsPage page;
    if (kairetePage != null && kairetePage.comments.isNotEmpty) {
      page = kairetePage;
    } else {
      try {
        page = await _fetchNativeCommentsFallback(mediaId);
      } catch (e) {
        if (kairetePage != null) {
          page = kairetePage;
        } else if (primaryError is MediaException) {
          throw primaryError;
        } else {
          rethrow;
        }
      }
    }

    if (page.comments.isEmpty && primaryError is MediaException) {
      throw primaryError;
    }

    var comments = page.comments;
    if (!_hasNestedComments(comments)) {
      comments = await _applyParentMap(comments, mediaId);
    }
    if (!_hasNestedComments(comments)) {
      comments = _enrichCommentParentsFromQuotes(comments);
    }
    comments = _enrichCommentParentsFromDepth(comments);

    return MediaCommentsPage(comments: comments);
  }

  List<MediaComment> _enrichCommentParentsFromQuotes(List<MediaComment> comments) {
    if (comments.isEmpty) return comments;

    final ids = comments.map((c) => c.commentId).toList();
    final parents = comments.map((c) => c.parentCommentId).toList();
    final messages = comments
        .map(
          (c) => c.messageRaw ?? c.messageParsed ?? c.messagePlainText,
        )
        .toList();

    final enriched = FeedCommentParent.enrichParentIds(
      ids: ids,
      parentIds: parents,
      messages: messages,
    );

    final out = <MediaComment>[];
    for (var i = 0; i < comments.length; i++) {
      final parent = enriched[i];
      out.add(
        parent != comments[i].parentCommentId
            ? comments[i].withParentCommentId(parent)
            : comments[i],
      );
    }
    return out;
  }

  List<MediaComment> _enrichCommentParentsFromDepth(List<MediaComment> comments) {
    if (comments.isEmpty) return comments;

    final ids = comments.map((c) => c.commentId).toList();
    final parents = comments.map((c) => c.parentCommentId).toList();
    final depths = comments.map((c) => c.depth).toList();

    var enriched = FeedCommentParent.inferParentsFromDepth(
      ids: ids,
      parentIds: parents,
      depths: depths,
    );

    final depthById = _depthByCommentId(ids, enriched);

    final out = <MediaComment>[];
    for (var i = 0; i < comments.length; i++) {
      final parent = enriched[i];
      var comment = comments[i];
      if (parent != comment.parentCommentId) {
        comment = comment.withParentCommentId(parent);
      }
      final depth = comment.depth > 0
          ? comment.depth
          : (depthById[comment.commentId] ?? 0);
      if (depth != comment.depth) {
        comment = comment.withDepth(depth);
      }
      out.add(comment);
    }
    return out;
  }

  bool _hasNestedComments(List<MediaComment> comments) {
    return comments.any((c) => c.parentCommentId > 0 || c.depth > 0);
  }

  Future<MediaCommentsPage> _fetchNativeCommentsFallback(int mediaId) async {
    final json = await _api.get('${ApiPaths.media}$mediaId/comments');
    _throwIfError(json);
    return MediaCommentsPage.fromJson(json);
  }

  Future<Map<int, int>> _fetchMediaCommentParentMap(int mediaId) async {
    for (final path in [
      '${ApiPaths.kaireteMedia}$mediaId/comment-parents',
      '${ApiPaths.kaireteMedia}$mediaId/comment-parents/',
    ]) {
      try {
        final json = await _api.get(path);
        _throwIfError(json);
        final map = parseMediaCommentParentMap(json);
        if (map.isNotEmpty) return map;
      } catch (_) {}
    }
    return const {};
  }

  List<MediaComment> _enrichCommentParents(List<MediaComment> comments) {
    return _enrichCommentParentsFromDepth(
      _enrichCommentParentsFromQuotes(comments),
    );
  }

  Map<int, int> _depthByCommentId(List<int> ids, List<int> parentIds) {
    final children = <int, List<int>>{};
    for (var i = 0; i < ids.length; i++) {
      final id = ids[i];
      final parent = parentIds[i];
      if (id <= 0) continue;
      if (parent > 0 && parent != id) {
        children.putIfAbsent(parent, () => []).add(id);
      }
    }

    final depthById = <int, int>{};
    void walk(int id, int depth) {
      depthById[id] = depth;
      for (final child in children[id] ?? const []) {
        walk(child, depth + 1);
      }
    }

    for (var i = 0; i < ids.length; i++) {
      final id = ids[i];
      final parent = parentIds[i];
      if (id <= 0 || depthById.containsKey(id)) continue;
      if (parent <= 0 || parent == id || !ids.contains(parent)) {
        walk(id, 0);
      }
    }
    return depthById;
  }

  Future<List<MediaComment>> _applyParentMap(
    List<MediaComment> comments,
    int mediaId,
  ) async {
    final parentMap = await _fetchMediaCommentParentMap(mediaId);
    if (parentMap.isEmpty) return comments;

    return comments
        .map(
          (c) => c.withParentCommentId(
            parentMap[c.commentId] ?? c.parentCommentId,
          ),
        )
        .toList();
  }

  Future<void> postComment({
    required int mediaId,
    required String message,
    int parentCommentId = 0,
    String? quotedAuthorName,
    int quotedAuthorUserId = 0,
  }) async {
    await AppApi.instance.applySession();
    final body = <String, dynamic>{'message': message.trim()};
    if (parentCommentId > 0) {
      body['parent_media_comment_id'] = parentCommentId;
      body['parent_comment_id'] = parentCommentId;
    }

    try {
      final json = await _api.post(
        '${ApiPaths.kaireteMedia}$mediaId/comments',
        body: body,
      );
      _throwIfError(json);
      return;
    } catch (_) {}

    var text = message.trim();
    if (parentCommentId > 0) {
      text = prependMediaQuoteBbCode(
            commentId: parentCommentId,
            authorName: quotedAuthorName ?? '',
            authorUserId: quotedAuthorUserId,
          ) +
          text;
    }
    final fallbackBody = <String, dynamic>{
      'media_id': mediaId,
      'message': text,
    };
    final json = await _api.post(
      ApiPaths.mediaComments,
      body: fallbackBody,
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
    final fileSize = await File(filePath).length();
    final uploadTimeout = _uploadTimeoutForBytes(fileSize);

    var json = await _postUploadMultipart(
      path,
      fields,
      filePath,
      filename,
      kind: kind,
      nativeFileOnly: nativeFileOnly,
      uploadTimeout: uploadTimeout,
    );
    if (_extractCreatedMediaId(json) != null) {
      return (json: json, error: null);
    }

    var err = XenforoApi.firstErrorMessage(json);
    if (_isMissingUploadError(json, err) &&
        kind == MediaUploadKind.image &&
        fileSize <= _base64FallbackMaxBytes) {
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

  Duration _uploadTimeoutForBytes(int bytes) {
    if (bytes >= 100 * 1024 * 1024) return const Duration(minutes: 45);
    if (bytes >= 50 * 1024 * 1024) return const Duration(minutes: 30);
    if (bytes >= 10 * 1024 * 1024) return const Duration(minutes: 15);
    return const Duration(minutes: 5);
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
    Duration uploadTimeout = const Duration(minutes: 5),
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
        sendTimeout: uploadTimeout,
        receiveTimeout: uploadTimeout,
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
    final bytes = await File(filePath).readAsBytes();
    if (bytes.length > _base64FallbackMaxBytes) {
      throw MediaException(
        'File troppo grande per il fallback base64 '
        '(${(bytes.length / (1024 * 1024)).toStringAsFixed(1)} MB). '
        'Usa solo upload multipart.',
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
    required String addPrivacy,
    String viewUsers = '',
    String addUsers = '',
    int categoryId = 0,
  }) async {
    await AppApi.instance.applySession();
    final fields = <String, dynamic>{
      'title': title.trim(),
      'description': description.trim(),
      'view_privacy': viewPrivacy,
      'add_privacy': addPrivacy,
    };
    if (categoryId > 0) {
      fields['category_id'] = categoryId;
    }
    if (viewPrivacy == 'shared' && viewUsers.trim().isNotEmpty) {
      fields['view_users'] = viewUsers.trim();
    }
    if (addPrivacy == 'shared' && addUsers.trim().isNotEmpty) {
      fields['add_users'] = addUsers.trim();
    }

    final json = await _api.postMultipart(
      ApiPaths.mediaAlbums,
      fields: fields,
    );
    _throwIfError(json);

    final album = json['album'];
    if (album is Map<String, dynamic>) {
      final created = MediaAlbum.fromJson(album);
      if (AppConfig.isTenantApp && created.albumId > 0) {
        await TenantService().registerContentMapping(
          contentId: created.albumId,
          serverContentType: TenantService.tenantMapAlbum,
        );
      }
      return created;
    }
    throw MediaException('Album creato ma risposta non valida.');
  }

  Future<int> resolveDefaultMediaCategoryId() async {
    await AppApi.instance.applySession();
    if (AppConfig.isTenantApp) {
      await TenantService().ensureTenantReady();
      final scoped = TenantScope.mediaCategoryIds;
      if (scoped.isNotEmpty) return scoped.first;
      try {
        final uploadCats = await fetchTenantUploadCategories();
        if (uploadCats.isNotEmpty) return uploadCats.first.categoryId;
      } catch (_) {}
    }
    final all = await fetchCategories();
    return all.isNotEmpty ? all.first.categoryId : 0;
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

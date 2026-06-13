import 'package:dio/dio.dart';
import 'package:kairete/config/app_config.dart';
import 'package:kairete/config/api_paths.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/services/reaction_service.dart';
import 'package:kairete/core/tenant/tenant_api_helpers.dart';
import 'package:kairete/core/tenant/tenant_feed_merge.dart';
import 'package:kairete/core/tenant/tenant_scope.dart';
import 'package:kairete/core/tenant/tenant_service.dart';
import 'package:kairete/features/groups/services/groups_service.dart';
import 'package:kairete/features/media/services/media_service.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_comment.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_media_enrichment.dart';

class OmnifeedService {
  XenforoApi get _api => AppApi.instance.xenforo;
  final ReactionService _reactions = ReactionService();

  Future<OmnifeedFeed> fetchFeed({
    String mode = 'network',
    String sort = 'post_date',
    int page = 1,
  }) async {
    await AppApi.instance.applySession();

    if (AppConfig.isTenantApp &&
        AppConfig.tenantId > 0 &&
        mode == 'tenant_group') {
      return _fetchTenantCommunityFeed(sort: sort, page: page);
    }

    final json = await _api.get(
      ApiPaths.newsfeed,
      query: {
        'mode': mode,
        'sort': sort,
        'page': page,
        if (AppConfig.isTenantApp && AppConfig.tenantId > 0)
          'tenant_id': AppConfig.tenantId,
      },
    );
    _throwIfError(json);
    var items = OmnifeedFeed.fromJson(json).items;

    if (!AppConfig.isTenantApp) {
      final userId = await AppApi.instance.sessionUserId ?? 0;
      if (userId > 0) {
        try {
          final ownMedia =
              await MediaService().fetchMedia(userId: userId, limit: 30);
          items = _mergeFeedItems(
            items,
            ownMedia.map(OmnifeedItem.fromMediaItem).toList(),
          );
        } catch (_) {}
      }
    }

    items = await enrichMediaAlbumHeaders(items);

    return OmnifeedFeed(items: items);
  }

  Future<OmnifeedFeed> _fetchTenantCommunityFeed({
    required String sort,
    required int page,
  }) async {
    await TenantService().ensureTenantReady();
    final tenantId = AppConfig.tenantId;
    Object? lastError;

    final loaders = <Future<OmnifeedFeed> Function()>[
      () => _loadTenantFeedFromMultisite(tenantId, sort: sort, page: page),
      () => _loadTenantFeedFromOmniFeed(sort: sort, page: page),
      () => _loadTenantFeedFromClientMerge(page: page),
      if (TenantScope.groupId > 0)
        () => _loadTenantFeedFromGroupOnly(page: page),
    ];

    for (final loader in loaders) {
      try {
        final feed = await loader();
        if (feed.items.isNotEmpty) return feed;
      } on OmnifeedException catch (e) {
        if (!TenantApiHelpers.isMissingEndpoint(e.message) &&
            !e.message.contains('non configurato')) {
          lastError = e;
        } else {
          lastError ??= e;
        }
      } on DioException catch (e) {
        lastError = e;
      } catch (e) {
        lastError = e;
      }
    }

    if (lastError is OmnifeedException) throw lastError;
    if (lastError is DioException) {
      throw OmnifeedException(XenforoApi.connectionMessage(lastError));
    }
    throw OmnifeedException(
      'Feed non disponibile. Verifica connessione o aggiorna Multisite su kairete.it.',
    );
  }

  Future<OmnifeedFeed> _loadTenantFeedFromClientMerge({required int page}) async {
    var items = await TenantFeedMergeService().buildCommunityItems(
      page: page,
      limit: 20,
    );
    if (items.isEmpty) {
      throw OmnifeedException('Nessun contenuto mappato disponibile.');
    }
    items = await enrichMediaAlbumHeaders(items);
    return OmnifeedFeed(items: items);
  }

  Future<OmnifeedFeed> _loadTenantFeedFromMultisite(
    int tenantId, {
    required String sort,
    required int page,
  }) async {
    final json = await _api.get(
      ApiPaths.msTenantCommunityFeed(tenantId),
      query: {
        'tenant_id': tenantId,
        'sort': sort,
        'page': page,
        'limit': 20,
      },
    );
    final err = XenforoApi.firstErrorMessage(json);
    if (err != null && TenantApiHelpers.isMissingEndpoint(err)) {
      throw OmnifeedException(err);
    }
    _throwIfError(json);
    var items = OmnifeedFeed.fromJson(json).items;
    items = await enrichMediaAlbumHeaders(items);
    return OmnifeedFeed(items: items);
  }

  Future<OmnifeedFeed> _loadTenantFeedFromOmniFeed({
    required String sort,
    required int page,
  }) async {
    final json = await _api.get(
      ApiPaths.newsfeed,
      query: {
        'mode': 'tenant_group',
        'sort': sort,
        'page': page,
        'tenant_id': AppConfig.tenantId,
      },
    );
    _throwIfError(json);
    var items = OmnifeedFeed.fromJson(json).items;
    items = await enrichMediaAlbumHeaders(items);
    return OmnifeedFeed(items: items);
  }

  Future<OmnifeedFeed> _loadTenantFeedFromGroupOnly({required int page}) async {
    final groupId = TenantScope.groupId;
    if (groupId <= 0) {
      throw OmnifeedException('Gruppo community non configurato nel bootstrap.');
    }
    final postsPage = await GroupsService().fetchPosts(groupId, page: page);
    final items = postsPage.posts
        .map(
          (post) => OmnifeedItem.fromGroupPostApi({
            'group_post_id': post.groupPostId,
            'group_id': post.groupId,
            'message_plain_text': post.messagePlainText,
            'post_date': post.postDate,
            'comment_count': post.commentCount,
            'reaction_score': post.reactionScore,
            if (post.author != null)
              'User': {
                'user_id': post.author!.userId,
                'username': post.author!.username,
              },
          }),
        )
        .toList();
    return OmnifeedFeed(items: items);
  }

  List<OmnifeedItem> _mergeFeedItems(
    List<OmnifeedItem> primary,
    List<OmnifeedItem> extra,
  ) {
    return mergeOmnifeedItemLists([primary, extra]);
  }

  Future<OmnifeedItem> fetchItemDetail(int itemId) async {
    await AppApi.instance.applySession();
    final json = await _api.get('${ApiPaths.newsfeedItems}$itemId');
    _throwIfError(json);
    final raw = json['newsfeedItem'] as Map<String, dynamic>? ?? json;
    return OmnifeedItem.fromJson(raw);
  }

  Future<OmnifeedCommentsPage> fetchComments(int itemId) async {
    await AppApi.instance.applySession();
    final json = await _api.get('${ApiPaths.newsfeedComments}$itemId/comments');
    _throwIfError(json);
    return OmnifeedCommentsPage.fromJson(json);
  }

  Future<void> createProfilePost({
    required String message,
    String attachmentKey = '',
    String attachmentHash = '',
  }) async {
    await AppApi.instance.applySession();
    if ((await AppApi.instance.sessionUserId ?? 0) <= 0) {
      throw OmnifeedException('Sessione non valida.');
    }

    final body = <String, dynamic>{'message': message.trim()};
    if (attachmentKey.isNotEmpty) {
      body['attachment_key'] = attachmentKey;
    } else if (attachmentHash.isNotEmpty) {
      body['attachment_hash'] = attachmentHash;
    }

    final json = await _api.post(ApiPaths.newsfeedPost, body: body);
    _throwIfError(json);
  }

  Future<void> deleteItem(int itemId) async {
    await AppApi.instance.applySession();
    final json = await _api.delete('${ApiPaths.newsfeedItems}$itemId');
    _throwIfError(json);
  }

  Future<void> updateItem({
    required int itemId,
    String? title,
    required String message,
  }) async {
    await AppApi.instance.applySession();
    final body = <String, dynamic>{
      'id': itemId,
      'message': message.trim(),
    };
    if (title != null && title.trim().isNotEmpty) {
      body['title'] = title.trim();
    }
    final json = await _api.post('${ApiPaths.newsfeedItems}$itemId', body: body);
    _throwIfError(json);
  }

  Future<void> createBlogPost({
    required int blogId,
    required String title,
    required String message,
    int categoryId = 0,
    String tags = '',
    String attachmentKey = '',
    String attachmentHash = '',
  }) async {
    await AppApi.instance.applySession();
    final body = <String, dynamic>{
      'blog_id': blogId,
      'title': title.trim(),
      'message': message.trim(),
    };
    if (categoryId > 0) body['category_id'] = categoryId;
    if (tags.trim().isNotEmpty) body['tags'] = tags.trim();
    final attach = attachmentKey.isNotEmpty ? attachmentKey : attachmentHash;
    if (attach.isNotEmpty) {
      body['attachment_key'] = attach;
      body['attachment_hash'] = attach;
    }

    final json = await _api.post(ApiPaths.newsfeedBlogPost, body: body);
    _throwIfError(json);
  }

  Future<void> postComment({
    required int itemId,
    required String message,
  }) async {
    await AppApi.instance.applySession();
    final json = await _api.post(
      '${ApiPaths.newsfeedComments}$itemId/comments',
      body: {'message': message},
    );
    _throwIfError(json);
  }

  Future<String> reactToItem({
    required OmnifeedItem item,
    int reactionId = 1,
  }) async {
    try {
      return await _reactions.reactOmnifeedItem(item, reactionId: reactionId);
    } on ReactionException catch (e) {
      throw OmnifeedException(e.message);
    }
  }

  void _throwIfError(Map<String, dynamic> json) {
    final err = XenforoApi.firstErrorMessage(json);
    if (err != null) throw OmnifeedException(err);
  }
}

class OmnifeedException implements Exception {
  OmnifeedException(this.message);
  final String message;

  @override
  String toString() => message;
}

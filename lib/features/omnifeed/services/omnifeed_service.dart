import 'package:dio/dio.dart';
import 'package:kairete/config/app_config.dart';
import 'package:kairete/config/api_paths.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/services/reaction_service.dart';
import 'package:kairete/core/tenant/tenant_api_helpers.dart';
import 'package:kairete/core/tenant/tenant_feed_merge.dart';
import 'package:kairete/core/tenant/tenant_scope.dart';
import 'package:kairete/core/tenant/tenant_scope_filter.dart';
import 'package:kairete/core/tenant/tenant_service.dart';
import 'package:kairete/features/blog/services/blog_service.dart';
import 'package:kairete/features/feed/utils/feed_comment_parent.dart';
import 'package:kairete/features/groups/services/groups_service.dart';
import 'package:kairete/features/media/services/media_service.dart';
import 'package:kairete/core/utils/json_parse.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_comment.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_tab.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_media_enrichment.dart';

class OmnifeedService {
  XenforoApi get _api => AppApi.instance.xenforo;
  final ReactionService _reactions = ReactionService();

  /// Ultima versione addon letta da api/newsfeed/tabs (per diagnostica UI).
  String? lastOmnifeedVersion;

  /// Tab ACP attivi. Ritorna lista vuota se non ce ne sono.
  /// Lancia se l'endpoint risponde con errore XF / rete.
  Future<List<OmnifeedTab>> fetchTabs() async {
    await AppApi.instance.applySession();
    final json = await _api.get(ApiPaths.newsfeedTabs);
    _throwIfError(json);
    final ver = (json['omnifeed_version'] as String?)?.trim();
    if (ver != null && ver.isNotEmpty) {
      lastOmnifeedVersion = ver;
    }
    final list = json['tabs'];
    if (list is! List) {
      throw OmnifeedException('Risposta tab newsfeed non valida.');
    }
    return list
        .whereType<Map>()
        .map((e) => OmnifeedTab.fromJson(Map<String, dynamic>.from(e)))
        .where((t) => t.tabKey.isNotEmpty)
        .toList();
  }

  Future<OmnifeedFeed> fetchFeed({
    String mode = 'network',
    String sort = 'post_date',
    String feedFilter = 'all',
    int page = 1,
    int limit = 40,
    OmnifeedTab? acpTab,
  }) async {
    await AppApi.instance.applySession();

    if (AppConfig.isTenantApp &&
        AppConfig.tenantId > 0 &&
        mode == 'tenant_group') {
      return _fetchTenantCommunityFeed(
        sort: sort,
        page: page,
        feedFilter: feedFilter,
      );
    }

    final json = await _api.get(
      ApiPaths.newsfeed,
      query: {
        'mode': mode,
        'sort': sort,
        'page': page,
        'limit': limit,
        if (AppConfig.isTenantApp && AppConfig.tenantId > 0)
          'tenant_id': AppConfig.tenantId,
      },
    );
    _throwIfError(json);
    final parsed = OmnifeedFeed.fromJson(json);
    if (parsed.omnifeedVersion != null) {
      lastOmnifeedVersion = parsed.omnifeedVersion;
    }
    var items = parsed.items;
    var criteriaDebug = Map<String, dynamic>.from(parsed.criteriaDebug);
    final tab = acpTab ?? parsed.tab;
    final effectiveSort = (tab?.sortMode.isNotEmpty == true)
        ? tab!.sortMode
        : (parsed.sort ?? sort);

    // Hub: sort del tab ACP. Nessun hardcode per tab_key — ACP → API → app.
    if (!AppConfig.isTenantApp) {
      // Se OmniFeed non restituisce blog, li integra da api/blog-entries.
      items = await _mergeHubBlogPostsIfMissing(items);
      items = await _ensureActivityDates(items, effectiveSort);
      items = sortHubItems(items, effectiveSort);
      if (items.length > limit) {
        items = items.sublist(0, limit);
      }
    }

    if (AppConfig.isTenantApp) {
      final userId = await AppApi.instance.sessionUserId ?? 0;
      if (userId > 0) {
        try {
          final ownMedia =
              await MediaService().fetchMedia(userId: userId, limit: 30);
          items = mergeOmnifeedItemLists(
            [items, ownMedia.map(OmnifeedItem.fromMediaItem).toList()],
            sortByItemDate: sort == 'post_date' || sort.isEmpty,
          );
        } catch (_) {}
      }
      // Anche sui tenant i fissati restano in cima.
      items = sortHubItems(items, effectiveSort);
    }

    items = await enrichFeedItemHeaders(items);
    // Dopo enrich: riapplica pin (l'ordine non deve dipendere solo dal payload).
    items = sortHubItems(items, effectiveSort);

    return _resolvedFeed(
      items,
      currentPage: parsed.currentPage,
      lastPage: parsed.lastPage,
      total: items.length,
      mode: parsed.mode ?? mode,
      sort: effectiveSort,
      tab: tab,
      criteriaDebug: criteriaDebug,
      omnifeedVersion: parsed.omnifeedVersion ?? lastOmnifeedVersion,
    );
  }

  /// Fissati (`isHighlighted`) sempre in cima; sotto l'ordine del sort tab.
  static List<OmnifeedItem> sortHubItems(List<OmnifeedItem> items, String sort) {
    final normalized = sort.trim().toLowerCase();
    final copy = List<OmnifeedItem>.from(items);
    int key(OmnifeedItem i) {
      switch (normalized) {
        case 'last_comment':
        case 'last_activity':
          return i.activityDate ?? i.itemDate ?? 0;
        case 'last_like':
          return i.activityDate ?? i.itemDate ?? 0;
        case 'author_reaction_score':
          return i.reactionScore;
        default:
          return i.itemDate ?? 0;
      }
    }

    copy.sort((a, b) {
      final ap = a.isHighlighted ? 1 : 0;
      final bp = b.isHighlighted ? 1 : 0;
      if (ap != bp) return bp.compareTo(ap);
      final cmp = key(b).compareTo(key(a));
      if (cmp != 0) return cmp;
      return (b.itemDate ?? 0).compareTo(a.itemDate ?? 0);
    });
    return copy;
  }

  /// Porta in cima gli item_id in rilievo (ordine lista = highlight_date desc).
  static List<OmnifeedItem> pinByItemIds(
    List<OmnifeedItem> items,
    List<int> pinnedItemIds,
  ) {
    if (items.isEmpty || pinnedItemIds.isEmpty) return items;
    final byId = <int, OmnifeedItem>{
      for (final item in items)
        if (item.itemId > 0) item.itemId: item,
    };
    final pinned = <OmnifeedItem>[];
    final seen = <int>{};
    for (final id in pinnedItemIds) {
      final item = byId[id];
      if (item == null || !seen.add(id)) continue;
      pinned.add(item.copyWith(isHighlighted: true));
    }
    final rest = <OmnifeedItem>[];
    for (final item in items) {
      if (item.itemId > 0 && seen.contains(item.itemId)) continue;
      rest.add(item);
    }
    return [...pinned, ...rest];
  }

  /// Se il tab è “ultimo commento” e manca activity_date, lo ricava dai commenti.
  Future<List<OmnifeedItem>> _ensureActivityDates(
    List<OmnifeedItem> items,
    String sort,
  ) async {
    final normalized = sort.trim().toLowerCase();
    final needsActivity = normalized == 'last_comment' ||
        normalized == 'last_activity' ||
        normalized == 'last_like';
    if (!needsActivity) return items;

    final targets = items
        .where((i) {
          if (i.commentCount <= 0) return false;
          final act = i.activityDate;
          final posted = i.itemDate ?? 0;
          // Manca o è uguale alla sola data post → probabile non valorizzata.
          return act == null || act <= posted;
        })
        .take(15)
        .toList();
    if (targets.isEmpty) return items;

    final dates = <int, int>{};
    await Future.wait(
      targets.map((item) async {
        if (item.itemId <= 0) return;
        try {
          final page = await fetchComments(
            item.itemId,
            profilePostId: item.contentType == 'profile_post'
                ? item.contentId
                : null,
          );
          var latest = 0;
          for (final c in page.comments) {
            final d = c.commentDate ?? 0;
            if (d > latest) latest = d;
          }
          if (latest > 0) {
            dates[item.itemId] = latest;
          }
        } catch (_) {}
      }),
    );
    if (dates.isEmpty) return items;

    return items.map((item) {
      final latest = dates[item.itemId];
      if (latest == null) return item;
      final posted = item.itemDate ?? 0;
      final current = item.activityDate ?? 0;
      final next = latest > current ? latest : current;
      final act = next > posted ? next : (current > 0 ? current : posted);
      if (act == item.activityDate) return item;
      return item.copyWith(activityDate: act);
    }).toList();
  }

  Future<OmnifeedFeed> _fetchTenantCommunityFeed({
    required String sort,
    required int page,
    required String feedFilter,
  }) async {
    await TenantService().ensureTenantReady();
    // Scope fresco: include blog collegati ai forum (kb_forum_blog_id).
    try {
      await TenantService().syncScopeFromServer();
    } catch (_) {}
    final tenantId = AppConfig.tenantId;
    Object? lastError;

    final loaders = <Future<OmnifeedFeed> Function()>[
      () => _loadTenantFeedFromMultisite(
        tenantId,
        sort: sort,
        page: page,
        feedFilter: feedFilter,
      ),
      () => _loadTenantFeedFromOmniFeed(
        sort: sort,
        page: page,
        feedFilter: feedFilter,
      ),
      () => _loadTenantFeedFromClientMerge(page: page, feedFilter: feedFilter),
      if (TenantScope.groupId > 0)
        () => _loadTenantFeedFromGroupOnly(
          page: page,
          feedFilter: feedFilter,
        ),
    ];

    OmnifeedFeed? best;
    for (final loader in loaders) {
      try {
        final feed = _filterTenantFeed(await loader());
        if (feed.items.isEmpty) continue;
        best = feed;
        // Se mancano i blog, non accettare subito: prova anche il merge client.
        final hasBlog = feed.items.any((i) => i.contentType == 'ubs_blog_entry');
        if (hasBlog || feedFilter == 'following') break;
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

    if (best != null) {
      return _mergeTenantBlogPostsIntoFeed(best, feedFilter: feedFilter);
    }

    if (lastError is OmnifeedException) throw lastError;
    if (lastError is DioException) {
      throw OmnifeedException(XenforoApi.connectionMessage(lastError));
    }
    throw OmnifeedException(
      'Feed non disponibile. Verifica connessione o aggiorna Multisite su kairete.it.',
    );
  }

  /// Hub: se il newsfeed non ha articoli blog, mescola i recenti da Blog API.
  /// Così i post si vedono anche con OmniFeed server non aggiornato.
  Future<List<OmnifeedItem>> _mergeHubBlogPostsIfMissing(
    List<OmnifeedItem> items,
  ) async {
    if (items.any((i) => i.contentType == 'ubs_blog_entry')) {
      return items;
    }
    try {
      final entries = await BlogService().fetchEntries();
      if (entries.isEmpty) return items;
      final blogItems = entries
          .take(25)
          .map(OmnifeedItem.fromBlogEntry)
          .toList(growable: false);
      return mergeOmnifeedItemLists([items, blogItems]);
    } catch (_) {
      return items;
    }
  }

  /// Il community-feed a volte torna pieno di post gruppo/thread ma senza blog:
  /// integra sempre gli articoli dei blog mappati/collegati ai forum.
  Future<OmnifeedFeed> _mergeTenantBlogPostsIntoFeed(
    OmnifeedFeed feed, {
    required String feedFilter,
  }) async {
    if (feedFilter == 'following') return feed;
    final alreadyHasBlog =
        feed.items.any((i) => i.contentType == 'ubs_blog_entry');
    if (alreadyHasBlog) return feed;
    try {
      final blogItems = await TenantFeedMergeService().buildBlogFeedItems();
      if (blogItems.isEmpty) return feed;
      final merged = mergeOmnifeedItemLists([feed.items, blogItems]);
      return _resolvedFeed(
        TenantScopeFilter.filterFeedItems(merged),
        mode: feed.mode,
        sort: feed.sort,
        omnifeedVersion: feed.omnifeedVersion,
      );
    } catch (_) {
      return feed;
    }
  }

  OmnifeedFeed _filterTenantFeed(OmnifeedFeed feed) {
    return _resolvedFeed(TenantScopeFilter.filterFeedItems(feed.items));
  }

  Future<OmnifeedFeed> _loadTenantFeedFromClientMerge({
    required int page,
    required String feedFilter,
  }) async {
    var items = await TenantFeedMergeService().buildCommunityItems(
      page: page,
      limit: 20,
      feedFilter: feedFilter,
    );
    if (items.isEmpty) {
      throw OmnifeedException('Nessun contenuto mappato disponibile.');
    }
    items = await enrichFeedItemHeaders(items);
    return _resolvedFeed(items);
  }

  Future<OmnifeedFeed> _loadTenantFeedFromMultisite(
    int tenantId, {
    required String sort,
    required int page,
    required String feedFilter,
  }) async {
    final json = await _api.get(
      ApiPaths.msTenantCommunityFeed(tenantId),
      query: {
        'tenant_id': tenantId,
        'sort': sort,
        'page': page,
        'limit': 20,
        if (feedFilter != 'all') 'feed_filter': feedFilter,
      },
    );
    final err = XenforoApi.firstErrorMessage(json);
    if (err != null && TenantApiHelpers.isMissingEndpoint(err)) {
      throw OmnifeedException(err);
    }
    _throwIfError(json);
    var items = OmnifeedFeed.fromJson(json).items;
    items = await enrichFeedItemHeaders(items);
    return _resolvedFeed(items);
  }

  Future<OmnifeedFeed> _loadTenantFeedFromOmniFeed({
    required String sort,
    required int page,
    required String feedFilter,
  }) async {
    final json = await _api.get(
      ApiPaths.newsfeed,
      query: {
        'mode': 'tenant_group',
        'sort': sort,
        'page': page,
        'tenant_id': AppConfig.tenantId,
        if (feedFilter != 'all') 'feed_filter': feedFilter,
      },
    );
    _throwIfError(json);
    var items = OmnifeedFeed.fromJson(json).items;
    items = await enrichFeedItemHeaders(items);
    return _resolvedFeed(items);
  }

  Future<OmnifeedFeed> _loadTenantFeedFromGroupOnly({
    required int page,
    required String feedFilter,
  }) async {
    if (feedFilter == 'following') {
      throw OmnifeedException('Filtro Seguiti non disponibile in fallback locale.');
    }
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
    return _resolvedFeed(items);
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
    final raw = json['newsfeedItem'];
    if (raw is! Map) {
      throw OmnifeedException('Dettaglio non disponibile.');
    }
    return OmnifeedItem.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<OmnifeedCommentsPage> fetchSocialNewsArticleComments(int articleId) async {
    return _fetchSocialNewsComments(articleId);
  }

  Future<OmnifeedCommentsPage> fetchComments(
    int itemId, {
    int? profilePostId,
  }) async {
    await AppApi.instance.applySession();

    OmnifeedCommentsPage? page;
    Object? primaryError;
    for (final path in [
      '${ApiPaths.newsfeedComments}$itemId/comments',
      '${ApiPaths.newsfeedComments}$itemId/comments/',
    ]) {
      try {
        final json = await _api.get(path);
        _throwIfError(json);
        page = OmnifeedCommentsPage.fromJson(json);
        if (page.comments.isNotEmpty) break;
      } catch (e) {
        primaryError ??= e;
        page = null;
      }
    }

    if (page == null || page.comments.isEmpty) {
      final articleId = _socialNewsArticleIdFromItemId(itemId);
      if (articleId != null) {
        try {
          page = await _fetchSocialNewsComments(articleId);
        } catch (e) {
          primaryError ??= e;
        }
      }
    }

    if (page == null || page.comments.isEmpty) {
      try {
        final fallback = await _fetchProfilePostCommentsFallback(
          itemId,
          profilePostId: profilePostId,
        );
        if (fallback.comments.isNotEmpty) {
          page = fallback;
        }
      } catch (e) {
        primaryError ??= e;
        page ??= OmnifeedCommentsPage(comments: const []);
      }
    }

    page ??= OmnifeedCommentsPage(comments: const []);

    if (page.comments.isEmpty && primaryError is OmnifeedException) {
      throw primaryError;
    }

    if (!_hasNestedComments(page)) {
      page = await _enrichCommentsWithParentMap(
        itemId,
        page,
        profilePostId: profilePostId,
      );
    }
    if (!_hasNestedComments(page)) {
      page = _enrichCommentsFromQuotes(page);
    }
    page = _enrichCommentsFromDepth(page);

    return page;
  }

  bool _hasNestedComments(OmnifeedCommentsPage page) {
    return page.comments.any(
      (c) => c.parentCommentId > 0 || c.depth > 0,
    );
  }

  Future<OmnifeedCommentsPage> _enrichCommentsWithParentMap(
    int itemId,
    OmnifeedCommentsPage page, {
    int? profilePostId,
  }) async {
    var parentMap = await _fetchCommentParentMap(itemId);
    if (parentMap.isEmpty && profilePostId != null && profilePostId > 0) {
      final encoded = OmnifeedItemId.encode(
        OmnifeedItemId.typeProfilePost,
        profilePostId,
      );
      if (encoded != itemId) {
        parentMap = await _fetchCommentParentMap(encoded);
      }
    }
    if (parentMap.isEmpty) return page;

    return OmnifeedCommentsPage(
      comments: page.comments
          .map(
            (c) => c.withParentCommentId(
              parentMap[c.commentId] ?? c.parentCommentId,
            ),
          )
          .toList(),
    );
  }

  OmnifeedCommentsPage _enrichCommentsFromQuotes(OmnifeedCommentsPage page) {
    final comments = page.comments;
    if (comments.isEmpty) return page;

    final ids = comments.map((c) => c.commentId).toList();
    final parents = comments.map((c) => c.parentCommentId).toList();
    final messages = comments
        .map((c) => c.messageRaw ?? c.messagePlainText)
        .toList();
    final enriched = FeedCommentParent.enrichParentIds(
      ids: ids,
      parentIds: parents,
      messages: messages,
    );

    final out = <OmnifeedComment>[];
    for (var i = 0; i < comments.length; i++) {
      final parent = enriched[i];
      out.add(
        parent != comments[i].parentCommentId
            ? comments[i].withParentCommentId(parent)
            : comments[i],
      );
    }
    return OmnifeedCommentsPage(comments: out);
  }

  OmnifeedCommentsPage _enrichCommentsFromDepth(OmnifeedCommentsPage page) {
    final comments = page.comments;
    if (comments.isEmpty) return page;

    final ids = comments.map((c) => c.commentId).toList();
    final parents = comments.map((c) => c.parentCommentId).toList();
    final depths = comments.map((c) => c.depth).toList();
    final enriched = FeedCommentParent.inferParentsFromDepth(
      ids: ids,
      parentIds: parents,
      depths: depths,
    );

    var changed = false;
    final out = <OmnifeedComment>[];
    for (var i = 0; i < comments.length; i++) {
      final parent = enriched[i];
      if (parent != comments[i].parentCommentId) {
        changed = true;
        out.add(comments[i].withParentCommentId(parent));
      } else {
        out.add(comments[i]);
      }
    }
    return changed ? OmnifeedCommentsPage(comments: out) : page;
  }

  Future<Map<int, int>> _fetchCommentParentMap(int itemId) async {
    for (final path in [
      '${ApiPaths.newsfeedItems}$itemId/comment-parents',
      '${ApiPaths.newsfeedComments}$itemId/comment-parents',
    ]) {
      try {
        final json = await _api.get(path);
        _throwIfError(json);
        final map = _parseCommentParentMap(json);
        if (map.isNotEmpty) return map;
      } catch (_) {}
    }
    return const {};
  }

  Map<int, int> _parseCommentParentMap(Map<String, dynamic> json) {
    final raw = json['parents'];
    if (raw is! Map) return const {};

    final map = <int, int>{};
    raw.forEach((key, value) {
      final commentId = JsonParse.intValue(key);
      final parentId = JsonParse.intValue(value);
      if (commentId > 0 && parentId > 0 && parentId != commentId) {
        map[commentId] = parentId;
      }
    });
    return map;
  }

  Future<OmnifeedCommentsPage> _fetchProfilePostCommentsFallback(
    int itemId, {
    int? profilePostId,
  }) async {
    final postId = profilePostId ?? _profilePostIdFromItemId(itemId);
    if (postId == null || postId <= 0) {
      throw OmnifeedException('Commenti non disponibili per questo contenuto.');
    }
    final json =
        await _api.get('${ApiPaths.profilePosts}/$postId/comments');
    _throwIfError(json);
    var page = OmnifeedCommentsPage.fromJson(json);
    if (page.comments.isEmpty) {
      final alt = await _api.get('${ApiPaths.profilePosts}/$postId/comments/');
      _throwIfError(alt);
      page = OmnifeedCommentsPage.fromJson(alt);
    }
    return page;
  }

  int? _profilePostIdFromItemId(int itemId) {
    if (OmnifeedItemId.decodeType(itemId) != OmnifeedItemId.typeProfilePost) {
      return null;
    }
    final postId = OmnifeedItemId.decodeNativeId(itemId);
    return postId > 0 ? postId : null;
  }

  int? _socialNewsArticleIdFromItemId(int itemId) {
    if (OmnifeedItemId.decodeType(itemId) !=
        OmnifeedItemId.typeSocialNewsArticle) {
      return null;
    }
    final articleId = OmnifeedItemId.decodeNativeId(itemId);
    return articleId > 0 ? articleId : null;
  }

  Future<OmnifeedCommentsPage> _fetchSocialNewsComments(int articleId) async {
    for (final path in [
      ApiPaths.socialNewsArticleComments(articleId),
      '${ApiPaths.socialNewsArticleComments(articleId)}/',
    ]) {
      try {
        final json = await _api.get(path);
        _throwIfError(json);
        return OmnifeedCommentsPage.fromJson(json);
      } catch (_) {
        continue;
      }
    }
    throw OmnifeedException('Commenti Social News non disponibili.');
  }

  Future<void> _postSocialNewsComment({
    required int articleId,
    required String message,
    int parentCommentId = 0,
  }) async {
    final body = <String, dynamic>{'message': message.trim()};
    if (parentCommentId > 0) {
      body['parent_comment_id'] = parentCommentId;
      body['parent_profile_post_comment_id'] = parentCommentId;
    }
    Object? lastError;
    for (final path in [
      ApiPaths.socialNewsArticleComments(articleId),
      '${ApiPaths.socialNewsArticleComments(articleId)}/',
    ]) {
      try {
        final json = await _api.post(path, body: body);
        _throwIfError(json);
        return;
      } catch (e) {
        lastError = e;
      }
    }
    if (lastError is OmnifeedException) {
      throw lastError;
    }
    throw OmnifeedException('Impossibile inviare il commento.');
  }

  Future<OmnifeedItem?> createProfilePost({
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
    return _parseCreatedFeedItem(json);
  }

  OmnifeedItem? _parseCreatedFeedItem(Map<String, dynamic> json) {
    final raw = json['newsfeedItem'];
    if (raw is Map) {
      final item = OmnifeedItem.fromFeedJson(Map<String, dynamic>.from(raw));
      if (item.itemId > 0) return item;
    }

    final postId = JsonParse.intValue(json['profile_post_id']);
    if (postId <= 0) return null;

    final encodedId = OmnifeedItemId.encode(
      OmnifeedItemId.typeProfilePost,
      postId,
    );
    final userId = JsonParse.intValue(json['user_id']);
    return OmnifeedItem(
      itemId: encodedId,
      contentType: 'profile_post',
      contentId: postId,
      messagePlainText: json['message']?.toString(),
      itemDate: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      author: userId > 0
          ? OmnifeedAuthor(userId: userId, username: '')
          : null,
    );
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
    int parentCommentId = 0,
  }) async {
    await AppApi.instance.applySession();
    final body = <String, dynamic>{'message': message};
    if (parentCommentId > 0) {
      body['parent_profile_post_comment_id'] = parentCommentId;
      body['parent_comment_id'] = parentCommentId;
    }
    try {
      final json = await _api.post(
        '${ApiPaths.newsfeedComments}$itemId/comments',
        body: body,
      );
      _throwIfError(json);
      return;
    } on DioException catch (e) {
      final articleId = _socialNewsArticleIdFromItemId(itemId);
      if (articleId != null) {
        await _postSocialNewsComment(
          articleId: articleId,
          message: message,
          parentCommentId: parentCommentId,
        );
        return;
      }
      if (_profilePostIdFromItemId(itemId) == null) {
        throw OmnifeedException(XenforoApi.connectionMessage(e));
      }
      await _postProfilePostCommentFallback(
        itemId: itemId,
        message: message,
        parentCommentId: parentCommentId,
      );
    } on OmnifeedException {
      final articleId = _socialNewsArticleIdFromItemId(itemId);
      if (articleId != null) {
        await _postSocialNewsComment(
          articleId: articleId,
          message: message,
          parentCommentId: parentCommentId,
        );
        return;
      }
      if (_profilePostIdFromItemId(itemId) == null) {
        rethrow;
      }
      await _postProfilePostCommentFallback(
        itemId: itemId,
        message: message,
        parentCommentId: parentCommentId,
      );
    }
  }

  Future<void> _postProfilePostCommentFallback({
    required int itemId,
    required String message,
    int parentCommentId = 0,
  }) async {
    final postId = _profilePostIdFromItemId(itemId);
    if (postId == null) {
      throw OmnifeedException('Impossibile inviare il commento.');
    }
    final body = <String, dynamic>{
      'profile_post_id': postId,
      'message': message.trim(),
    };
    if (parentCommentId > 0) {
      body['parent_profile_post_comment_id'] = parentCommentId;
      body['parent_comment_id'] = parentCommentId;
    }
    final json = await _api.post(ApiPaths.profilePostComments, body: body);
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

  /// Salva/rimuovi un contenuto dai salvati (toggle). Se l'endpoint non è
  /// ancora disponibile sul server, solleva un errore comprensibile: la
  /// funzione verrà completata lato app non appena l'add-on OmniFeed viene
  /// aggiornato.
  Future<bool> toggleBookmark(OmnifeedItem item) async {
    await AppApi.instance.applySession();
    if ((await AppApi.instance.sessionUserId ?? 0) <= 0) {
      throw OmnifeedException('Accedi per salvare i contenuti.');
    }
    if (item.itemId <= 0) {
      throw OmnifeedException('Contenuto non disponibile.');
    }

    final json = await _api.post('${ApiPaths.newsfeedItems}${item.itemId}/bookmark');
    final err = XenforoApi.firstErrorMessage(json);
    if (err != null) {
      if (TenantApiHelpers.isMissingEndpoint(err)) {
        throw OmnifeedException(
          'Salvataggio non ancora disponibile. Aggiorna l\'add-on OmniFeed sul server.',
        );
      }
      throw OmnifeedException(err);
    }

    return json['is_bookmarked'] == true || json['action'] == 'insert';
  }

  /// Metti/togli in rilievo per uno scope (admin o owner). Condiviso con il web.
  Future<bool> toggleHighlight(
    OmnifeedItem item, {
    String? scopeKey,
  }) async {
    await AppApi.instance.applySession();
    if ((await AppApi.instance.sessionUserId ?? 0) <= 0) {
      throw OmnifeedException('Accedi per mettere in rilievo.');
    }
    if (item.itemId <= 0) {
      throw OmnifeedException('Contenuto non disponibile.');
    }
    final scope = (scopeKey ?? item.highlightScope ?? '').trim();
    if (scope.isEmpty) {
      throw OmnifeedException('Ambito rilievo non disponibile.');
    }

    final json = await _api.post(
      '${ApiPaths.newsfeedItems}${item.itemId}/highlight',
      body: {'scope_key': scope},
    );
    final err = XenforoApi.firstErrorMessage(json);
    if (err != null) {
      if (TenantApiHelpers.isMissingEndpoint(err)) {
        throw OmnifeedException(
          'Rilievo non ancora disponibile. Aggiorna l\'add-on OmniFeed sul server.',
        );
      }
      throw OmnifeedException(err);
    }

    return JsonParse.boolValue(json['is_highlighted']) ||
        JsonParse.boolValue(json['isHighlighted']) ||
        json['action']?.toString() == 'insert';
  }

  /// Elenco item_id / content_id in rilievo per uno scope.
  Future<OmnifeedHighlightsPage> fetchHighlights(String scopeKey) async {
    await AppApi.instance.applySession();
    final scope = scopeKey.trim();
    if (scope.isEmpty) {
      return const OmnifeedHighlightsPage();
    }
    final json = await _api.get(
      ApiPaths.newsfeedHighlights,
      query: {'scope_key': scope, 'limit': 200},
    );
    final err = XenforoApi.firstErrorMessage(json);
    if (err != null) {
      if (TenantApiHelpers.isMissingEndpoint(err)) {
        return const OmnifeedHighlightsPage();
      }
      throw OmnifeedException(err);
    }
    return OmnifeedHighlightsPage.fromJson(json);
  }

  /// Porta in cima gli item il cui contentId è in rilievo.
  static List<T> pinByContentIds<T>({
    required List<T> items,
    required Set<int> highlightedContentIds,
    required int Function(T item) contentIdOf,
  }) {
    if (items.isEmpty || highlightedContentIds.isEmpty) return items;
    final pinned = <T>[];
    final rest = <T>[];
    final seen = <int>{};
    // Ordine pin = ordine set (già dal server highlight_date desc se costruito così).
    for (final id in highlightedContentIds) {
      for (final item in items) {
        final cid = contentIdOf(item);
        if (cid == id && seen.add(cid)) {
          pinned.add(item);
        }
      }
    }
    for (final item in items) {
      final cid = contentIdOf(item);
      if (!highlightedContentIds.contains(cid)) {
        rest.add(item);
      }
    }
    return [...pinned, ...rest];
  }

  /// Condivisione esterna: registra il conteggio lato server.
  Future<int> shareExternal(int itemId) async {
    return _share(itemId, kind: 'external');
  }

  /// Condivisione interna sulla bacheca del visitatore.
  Future<FeedShareApiResult> shareInternal(
    int itemId, {
    String message = '',
  }) async {
    final json = await _shareRaw(itemId, kind: 'internal', message: message);
    OmnifeedItem? created;
    final rawItem = json['newsfeedItem'];
    if (rawItem is Map) {
      created = OmnifeedItem.fromFeedJson(Map<String, dynamic>.from(rawItem));
    }
    return FeedShareApiResult(
      shareCount: JsonParse.intValue(json['share_count']),
      createdItem: created,
    );
  }

  Future<int> _share(
    int itemId, {
    required String kind,
    String message = '',
  }) async {
    final json = await _shareRaw(itemId, kind: kind, message: message);
    return JsonParse.intValue(json['share_count']);
  }

  Future<Map<String, dynamic>> _shareRaw(
    int itemId, {
    required String kind,
    String message = '',
  }) async {
    await AppApi.instance.applySession();
    if ((await AppApi.instance.sessionUserId ?? 0) <= 0) {
      throw OmnifeedException('Accedi per condividere.');
    }
    if (itemId <= 0) {
      throw OmnifeedException('Contenuto non disponibile.');
    }

    final json = await _api.post(
      '${ApiPaths.newsfeedItems}$itemId/share',
      body: {
        'kind': kind,
        if (message.trim().isNotEmpty) 'message': message.trim(),
      },
    );
    final err = XenforoApi.firstErrorMessage(json);
    if (err != null) {
      if (TenantApiHelpers.isMissingEndpoint(err)) {
        throw OmnifeedException(
          'Condivisione non ancora disponibile. Aggiorna l\'add-on OmniFeed sul server.',
        );
      }
      throw OmnifeedException(err);
    }
    return json;
  }

  OmnifeedFeed _resolvedFeed(
    List<OmnifeedItem> items, {
    int currentPage = 1,
    int lastPage = 1,
    int total = 0,
    String? mode,
    String? sort,
    OmnifeedTab? tab,
    Map<String, dynamic> criteriaDebug = const {},
    String? omnifeedVersion,
  }) {
    return OmnifeedFeed(
      items: items.map((item) => item.withResolvedItemId()).toList(),
      currentPage: currentPage,
      lastPage: lastPage,
      total: total,
      mode: mode,
      sort: sort,
      tab: tab,
      criteriaDebug: criteriaDebug,
      omnifeedVersion: omnifeedVersion,
    );
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

class OmnifeedHighlightsPage {
  const OmnifeedHighlightsPage({
    this.scopeKey,
    this.canManage = false,
    this.itemIds = const [],
    this.contentIds = const [],
  });

  final String? scopeKey;
  final bool canManage;
  final List<int> itemIds;
  final List<int> contentIds;

  factory OmnifeedHighlightsPage.fromJson(Map<String, dynamic> json) {
    final itemIds = <int>[];
    final contentIds = <int>[];
    final rawIds = json['item_ids'];
    if (rawIds is List) {
      for (final v in rawIds) {
        final id = JsonParse.intValue(v);
        if (id > 0) itemIds.add(id);
      }
    }
    final raw = json['highlights'];
    if (raw is List) {
      for (final row in raw) {
        if (row is! Map) continue;
        final map = Map<String, dynamic>.from(row);
        final itemId = JsonParse.intValue(map['item_id']);
        final contentId = JsonParse.intValue(map['content_id']);
        if (itemId > 0 && !itemIds.contains(itemId)) itemIds.add(itemId);
        if (contentId > 0) contentIds.add(contentId);
      }
    }
    return OmnifeedHighlightsPage(
      scopeKey: json['scope_key']?.toString(),
      canManage: JsonParse.boolValue(json['can_manage']),
      itemIds: itemIds,
      contentIds: contentIds,
    );
  }
}

class FeedShareApiResult {
  FeedShareApiResult({
    required this.shareCount,
    this.createdItem,
  });

  final int shareCount;
  final OmnifeedItem? createdItem;
}

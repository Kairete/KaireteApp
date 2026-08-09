import 'package:dio/dio.dart';
import 'package:kairete/config/app_config.dart';
import 'package:kairete/config/api_paths.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/services/reaction_service.dart';
import 'package:kairete/core/tenant/tenant_api_helpers.dart';
import 'package:kairete/core/tenant/tenant_scope.dart';
import 'package:kairete/core/tenant/tenant_service.dart';
import 'package:kairete/features/blog/services/blog_service.dart';
import 'package:kairete/features/forum/models/forum_feed_item.dart';
import 'package:kairete/features/forum/models/forum_node.dart';
import 'package:kairete/features/forum/models/forum_thread.dart';
import 'package:kairete/features/forum/utils/forum_quote_bbcode.dart';
import 'package:kairete/features/feed/widgets/feed_link_preview.dart';
import 'package:kairete/features/omnifeed/services/omnifeed_service.dart';

class ForumService {
  XenforoApi get _api => AppApi.instance.xenforo;
  final ReactionService _reactions = ReactionService();

  Future<List<ForumNodeGroup>> fetchForumGroups() async {
    await AppApi.instance.applySession();
    if (AppConfig.isTenantApp && AppConfig.tenantId > 0) {
      return _fetchTenantMappedForums();
    }
    final json = await _api.get(ApiPaths.nodes, query: {'limit': 100});
    _throwIfError(json);
    return ForumNodesPage.fromJson(json).groups;
  }

  Future<List<ForumNodeGroup>> _fetchTenantMappedForums() async {
    await TenantService().syncScopeFromServer();
    await TenantService().ensureTenantReady();
    try {
      final json = await _api.get(
        ApiPaths.msTenantMappedForums(AppConfig.tenantId),
        query: {'tenant_id': AppConfig.tenantId},
      );
      final err = XenforoApi.firstErrorMessage(json);
      if (err != null && TenantApiHelpers.isMissingEndpoint(err)) {
        return _fetchScopedForumGroups();
      }
      _throwIfError(json);
      // Stesso raggruppamento hub: categorie come header + forum sotto tree_map.
      return ForumNodesPage.fromJson(json).groups;
    } on DioException catch (e) {
      final apiMsg = e.response?.data is Map<String, dynamic>
          ? XenforoApi.firstErrorMessage(
              e.response!.data as Map<String, dynamic>,
            )
          : null;
      if (TenantApiHelpers.isMissingEndpoint(apiMsg)) {
        return _fetchScopedForumGroups();
      }
      rethrow;
    }
  }

  Future<List<ForumNodeGroup>> _fetchScopedForumGroups() async {
    final allowedRoots = TenantScope.forumNodeIds.toSet();
    if (allowedRoots.isEmpty) {
      throw ForumException('Nessun forum mappato per questa community.');
    }

    final json = await _api.get(ApiPaths.nodes, query: {'limit': 500});
    _throwIfError(json);
    final allNodes = <ForumNode>[];
    if (json['nodes'] is List) {
      for (final raw in json['nodes'] as List) {
        if (raw is Map) {
          allNodes.add(ForumNode.fromJson(Map<String, dynamic>.from(raw)));
        }
      }
    }
    final byId = {for (final n in allNodes) n.nodeId: n};

    bool underMappedRoot(ForumNode node) {
      if (allowedRoots.contains(node.nodeId)) return true;
      var parentId = node.parentNodeId;
      final seen = <int>{};
      while (parentId > 0 && seen.add(parentId)) {
        if (allowedRoots.contains(parentId)) return true;
        parentId = byId[parentId]?.parentNodeId ?? 0;
      }
      return false;
    }

    // Solo i contenitori mappati (hanno figli Category/Forum) restano fuori lista,
    // come il root "Juve Social". I forum foglia mappati devono restare visibili.
    final containerRoots = allowedRoots.where((id) {
      return allNodes.any(
        (n) =>
            n.parentNodeId == id &&
            (n.isCategory || n.isForum) &&
            n.nodeId != id,
      );
    }).toSet();

    // Forum nello scope (anche se lo scope ACP ha solo ID forum espansi).
    final scopedForums = allNodes
        .where((n) => n.isForum && underMappedRoot(n) && !containerRoots.contains(n.nodeId))
        .toList();
    if (scopedForums.isEmpty) {
      throw ForumException(
        'Nessun forum/categoria sotto i nodi mappati. '
        'Verifica il mapping in ACP e Multisite 1.9.177+.',
      );
    }

    // Riporta le Category antenate (es. "Juventus Forum") anche se non sono in forumNodeIds.
    final byNodeId = <int, ForumNode>{
      for (final f in scopedForums) f.nodeId: f,
    };
    for (final forum in scopedForums) {
      var parentId = forum.parentNodeId;
      final seen = <int>{};
      while (parentId > 0 && seen.add(parentId)) {
        if (containerRoots.contains(parentId)) break;
        final parent = byId[parentId];
        if (parent == null) break;
        // Forum antenato non in lista = contenitore (es. root "Juve Social"): stop.
        if (parent.isForum && !byNodeId.containsKey(parentId)) {
          break;
        }
        if (parent.isCategory) {
          byNodeId[parentId] = parent;
        }
        parentId = parent.parentNodeId;
      }
    }

    final scoped = byNodeId.values.toList();
    final scopedIds = byNodeId.keys.toSet();
    final treeMap = <String, List<int>>{'0': []};
    for (final n in scoped) {
      final parentInScope =
          scopedIds.contains(n.parentNodeId) ? n.parentNodeId : 0;
      treeMap.putIfAbsent('$parentInScope', () => []).add(n.nodeId);
    }

    return ForumNodesPage.fromJson({
      'nodes': scoped
          .map(
            (n) => {
              'node_id': n.nodeId,
              'title': n.title,
              'node_type_id': n.nodeTypeId,
              'parent_node_id': n.parentNodeId,
              'display_order': n.displayOrder,
              'description': n.description,
              'view_url': n.viewUrl,
              'type_data': {
                'discussion_count': n.typeData?.discussionCount ?? 0,
                'message_count': n.typeData?.messageCount ?? 0,
                'last_post_date': n.typeData?.lastPostDate,
                'last_thread_title': n.typeData?.lastThreadTitle,
                'last_post_username': n.typeData?.lastPostUsername,
              },
            },
          )
          .toList(),
      'tree_map': treeMap,
    }).groups;
  }

  Future<List<ForumThread>> fetchThreads(int forumId) async {
    await AppApi.instance.applySession();
    final json = await _api.get(
      '${ApiPaths.forums}$forumId/threads',
      query: {
        'limit': 50,
        'order': 'last_post_date',
        'direction': 'desc',
        'with': 'FirstPost',
      },
    );
    _throwIfError(json);
    final threads = ForumThreadsPage.fromJson(json).threads;
    final hydrated = await _hydrateFirstPostPreviews(threads);
    final withPreviews = await _hydrateLinkPreviews(hydrated);
    return _pinHighlightedThreads(withPreviews);
  }

  /// Blog collegato al forum (se configurato dall'admin nelle impostazioni blog).
  Future<({int blogId, String title})?> fetchLinkedBlog(int forumId) async {
    await AppApi.instance.applySession();
    try {
      final json = await _api.get(
        ApiPaths.blogsForumLink,
        query: {'node_id': forumId},
      );
      if (XenforoApi.firstErrorMessage(json) != null) return null;
      if (json['linked'] != true) return null;
      final blog = json['blog'];
      if (blog is! Map) return null;
      final blogId = blog['blog_id'] as int? ?? 0;
      if (blogId <= 0) return null;
      return (
        blogId: blogId,
        title: blog['title']?.toString() ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  /// Discussioni forum + articoli del blog collegato, ordinati per data.
  Future<List<ForumFeedItem>> fetchForumFeed(int forumId) async {
    final threadsFuture = fetchThreads(forumId);
    final linkedFuture = fetchLinkedBlog(forumId);

    final threads = await threadsFuture;
    final linked = await linkedFuture;

    final items = <ForumFeedItem>[
      for (final t in threads) ForumFeedItem.thread(t),
    ];

    if (linked != null) {
      try {
        final entries = await BlogService().fetchEntries(blogId: linked.blogId);
        for (final entry in entries) {
          items.add(ForumFeedItem.blog(entry));
        }
      } catch (_) {
        // Lista forum resta utilizzabile anche se il merge blog fallisce.
      }
    }

    items.sort((a, b) => b.sortDate.compareTo(a.sortDate));
    return items;
  }

  Future<List<ForumThread>> _pinHighlightedThreads(
    List<ForumThread> threads,
  ) async {
    try {
      final page = await OmnifeedService().fetchHighlights('admin:forum');
      if (page.contentIds.isEmpty) return threads;
      return OmnifeedService.pinByContentIds(
        items: threads,
        highlightedContentIds: page.contentIds.toSet(),
        contentIdOf: (t) => t.threadId,
      );
    } catch (_) {
      return threads;
    }
  }

  Future<List<ForumThread>> _hydrateFirstPostPreviews(
    List<ForumThread> threads,
  ) async {
    final results = await Future.wait(
      threads.map((thread) async {
        if (thread.previewBody.isNotEmpty) return thread;
        final postId = thread.firstPostId;
        if (postId == null || postId <= 0) return thread;

        try {
          final json = await _api.get('${ApiPaths.posts}$postId');
          if (XenforoApi.firstErrorMessage(json) != null) return thread;
          final post = json['post'] as Map<String, dynamic>? ?? json;
          return thread.copyWith(
            messagePlainText: post['message']?.toString(),
            messageParsed: post['message_parsed']?.toString(),
            firstPostReactionScore:
                post['reaction_score'] as int? ?? thread.firstPostReactionScore,
            attachments: ForumThread.parseAttachments(post['Attachments']),
            canEdit: post['can_edit'] as bool? ?? thread.canEdit,
            canDelete: post['can_delete'] as bool? ??
                post['can_soft_delete'] as bool? ??
                thread.canDelete,
          );
        } catch (_) {
          return thread;
        }
      }),
    );
    return results;
  }

  Future<List<ForumThread>> _hydrateLinkPreviews(
    List<ForumThread> threads,
  ) async {
    final messages = threads
        .map((t) => t.messagePlainText?.trim().isNotEmpty == true
            ? t.messagePlainText!.trim()
            : t.previewBody)
        .toList(growable: false);
    final batches = await _fetchLinkPreviewBatches(messages);
    if (batches.isEmpty) return threads;
    return [
      for (var i = 0; i < threads.length; i++)
        threads[i].copyWith(
          linkPreviews: i < batches.length ? batches[i] : const [],
        ),
    ];
  }

  Future<List<ForumPost>> _hydratePostLinkPreviews(List<ForumPost> posts) async {
    final messages = posts
        .map((p) =>
            (p.messagePlainText ?? p.messageParsed ?? '').trim())
        .toList(growable: false);
    final batches = await _fetchLinkPreviewBatches(messages);
    if (batches.isEmpty) return posts;
    return [
      for (var i = 0; i < posts.length; i++)
        posts[i].copyWith(
          linkPreviews: i < batches.length ? batches[i] : const [],
        ),
    ];
  }

  Future<List<List<FeedLinkPreviewData>>> _fetchLinkPreviewBatches(
    List<String> messages,
  ) async {
    if (messages.every((m) => !m.contains(RegExp(r'https?://', caseSensitive: false)))) {
      return List.generate(messages.length, (_) => const <FeedLinkPreviewData>[]);
    }
    try {
      final json = await _api.post(
        ApiPaths.newsfeedLinkPreview,
        body: {'messages': messages},
      );
      if (XenforoApi.firstErrorMessage(json) != null) {
        return const [];
      }
      final rawBatches = json['link_preview_batches'];
      if (rawBatches is! List) {
        final single = FeedLinkPreviewData.listFromJson(json['link_previews']);
        if (messages.length == 1) return [single];
        return const [];
      }
      return rawBatches
          .map((raw) => FeedLinkPreviewData.listFromJson(raw))
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<ForumThread> fetchThread(
    int threadId, {
    String? forumTitle,
    ForumPostsPage? postsPage,
  }) async {
    await AppApi.instance.applySession();
    final json = await _api.get('${ApiPaths.threads}/$threadId');
    _throwIfError(json);
    final raw = json['thread'] as Map<String, dynamic>? ?? json;
    var thread = ForumThread.fromJson(raw);
    if (forumTitle != null && forumTitle.isNotEmpty) {
      thread = thread.copyWith(forumTitle: forumTitle);
    }

    final page = postsPage ?? await fetchPostsPage(threadId, page: 1);
    final first = page.posts.isNotEmpty ? page.posts.first : null;
    if (first != null) {
      thread = thread.copyWith(
        messagePlainText: first.messagePlainText,
        messageParsed: first.messageParsed,
        canReact: first.canReact,
        firstPostReactionScore: first.reactionScore,
        attachments: first.attachments,
        linkPreviews: first.linkPreviews,
        canEdit: first.canEdit,
        canDelete: first.canDelete,
      );
    }
    return thread;
  }

  Future<List<ForumPost>> fetchPosts(int threadId) async {
    final page = await fetchPostsPage(threadId, page: 1);
    return page.posts;
  }

  Future<ForumPostsPage> fetchPostsPage(
    int threadId, {
    int page = 1,
    int limit = 20,
  }) async {
    await AppApi.instance.applySession();
    final json = await _api.get(
      '${ApiPaths.threads}/$threadId/posts',
      query: {'page': page, 'limit': limit},
    );
    _throwIfError(json);
    final parsed = ForumPostsPage.fromJson(json);
    final posts = await _hydratePostLinkPreviews(parsed.posts);
    return ForumPostsPage(posts: posts, pagination: parsed.pagination);
  }

  Future<String> reactToPost({required int postId, int reactionId = 1}) async {
    try {
      return await _reactions.reactToPost(postId, reactionId: reactionId);
    } on ReactionException catch (e) {
      throw ForumException(e.message);
    }
  }

  Future<ForumThread> createThread({
    required int forumId,
    required String title,
    required String message,
    String tags = '',
    String attachmentKey = '',
  }) async {
    await AppApi.instance.applySession();
    final body = <String, dynamic>{
      'node_id': forumId,
      'title': title,
      'message': message,
    };
    // XF API richiede str[] (array), non una stringa CSV.
    final tagList = splitTagInput(tags);
    if (tagList.isNotEmpty) {
      body['tags'] = tagList;
    }
    if (attachmentKey.isNotEmpty) body['attachment_key'] = attachmentKey;

    final json = await _api.post(
      ApiPaths.threads,
      body: body,
    );
    _throwIfError(json);
    final raw = json['thread'];
    final map = raw is Map
        ? Map<String, dynamic>.from(raw)
        : Map<String, dynamic>.from(json);
    return ForumThread.fromJson(map);
  }

  /// Tag da input utente (virgola/spazio/#).
  static List<String> splitTagInput(String raw) {
    return raw
        .split(RegExp(r'[,;]+'))
        .expand((part) => part.trim().split(RegExp(r'\s+')))
        .map((tag) => tag.trim().replaceFirst(RegExp(r'^#'), ''))
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  Future<void> deleteThread(int threadId) async {
    await AppApi.instance.applySession();
    final json = await _api.delete('${ApiPaths.threads}/$threadId');
    _throwIfError(json);
  }

  Future<ForumThread> updateThread({
    required ForumThread thread,
    required String title,
    required String message,
  }) async {
    await AppApi.instance.applySession();
    final threadJson = await _api.post(
      '${ApiPaths.threads}/${thread.threadId}',
      body: {'title': title.trim()},
    );
    _throwIfError(threadJson);
    final postId = thread.firstPostId;
    if (postId != null && postId > 0) {
      final postJson = await _api.post(
        '${ApiPaths.posts}$postId',
        body: {'message': message.trim()},
      );
      _throwIfError(postJson);
    }
    return fetchThread(thread.threadId, forumTitle: thread.forumTitle);
  }

  Future<ForumPost> postReply({
    required int threadId,
    required String message,
    int parentPostId = 0,
    ForumPost? quotedPost,
  }) async {
    await AppApi.instance.applySession();
    var bodyMessage = message;
    if (parentPostId > 0 && quotedPost != null) {
      bodyMessage = '${prependForumQuoteBbCode(quotedPost)}\n\n$message';
    }
    final json = await _api.post(
      ApiPaths.posts,
      body: {
        'thread_id': threadId,
        'message': bodyMessage,
      },
    );
    _throwIfError(json);
    final raw = json['post'] as Map<String, dynamic>? ?? json;
    return ForumPost.fromJson(raw);
  }

  Future<ForumWatchState> fetchForumWatchState(int forumId) async {
    await AppApi.instance.applySession();
    try {
      final json = await _api.get(
        ApiPaths.newsfeedForumWatch,
        query: {'forum_id': forumId},
      );
      if (XenforoApi.firstErrorMessage(json) == null) {
        return ForumWatchState(
          isWatched: json['is_watched'] == true,
          canWatch: json['can_watch'] != false,
        );
      }
    } catch (_) {}

    final json = await _api.get('${ApiPaths.forums}$forumId');
    _throwIfError(json);
    final forum = json['forum'] as Map<String, dynamic>? ?? json;
    final watched = forum['is_watched'] == true ||
        forum['visitor_is_watched'] == true;
    return ForumWatchState(isWatched: watched);
  }

  Future<bool> watchForum(int forumId, {required bool stop}) async {
    await AppApi.instance.applySession();
    try {
      final json = await _api.post(
        ApiPaths.newsfeedForumWatch,
        body: {
          'forum_id': forumId,
          if (stop) 'stop': true,
        },
      );
      if (XenforoApi.firstErrorMessage(json) == null) {
        if (json['is_watched'] is bool) {
          return json['is_watched'] as bool;
        }
        return !stop;
      }
    } on ForumException {
      rethrow;
    } catch (_) {}

    final json = await _api.post(
      '${ApiPaths.forums}$forumId/watch',
      body: stop ? {'stop': true} : {},
    );
    _throwIfError(json);
    return !stop;
  }

  void _throwIfError(Map<String, dynamic> json) {
    final err = XenforoApi.firstErrorMessage(json);
    if (err != null) throw ForumException(err);
  }
}

class ForumWatchState {
  const ForumWatchState({
    required this.isWatched,
    this.canWatch = true,
  });

  final bool isWatched;
  final bool canWatch;
}

class ForumException implements Exception {
  ForumException(this.message);
  final String message;

  @override
  String toString() => message;
}

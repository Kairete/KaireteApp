import 'package:dio/dio.dart';
import 'package:kairete/config/app_config.dart';
import 'package:kairete/config/api_paths.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/services/reaction_service.dart';
import 'package:kairete/core/tenant/tenant_api_helpers.dart';
import 'package:kairete/core/tenant/tenant_scope.dart';
import 'package:kairete/core/tenant/tenant_service.dart';
import 'package:kairete/features/forum/models/forum_node.dart';
import 'package:kairete/features/forum/models/forum_thread.dart';

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
      return _forumGroupsFromNodes(json['nodes']);
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

  List<ForumNodeGroup> _forumGroupsFromNodes(dynamic rawNodes) {
    final nodes = rawNodes as List<dynamic>? ?? [];
    final forums = nodes
        .whereType<Map<String, dynamic>>()
        .map(ForumNode.fromJson)
        .where((n) => n.nodeTypeId == 'Forum')
        .toList();
    if (forums.isEmpty) return [];
    return [ForumNodeGroup(categoryId: 0, title: 'Forum', forums: forums)];
  }

  Future<List<ForumNodeGroup>> _fetchScopedForumGroups() async {
    final allowed = TenantScope.forumNodeIds.toSet();
    if (allowed.isEmpty) {
      throw ForumException('Nessun forum mappato per questa community.');
    }

    final json = await _api.get(ApiPaths.nodes, query: {'limit': 200});
    _throwIfError(json);
    final groups = ForumNodesPage.fromJson(json).groups;
    final forums = <ForumNode>[];
    for (final group in groups) {
      for (final forum in group.forums) {
        if (allowed.contains(forum.nodeId)) forums.add(forum);
      }
    }
    if (forums.isEmpty) return [];
    return [ForumNodeGroup(categoryId: 0, title: 'Forum', forums: forums)];
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
    return _hydrateFirstPostPreviews(threads);
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
    return ForumPostsPage.fromJson(json);
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
    if (tags.trim().isNotEmpty) body['tags'] = tags.trim();
    if (attachmentKey.isNotEmpty) body['attachment_key'] = attachmentKey;

    final json = await _api.post(
      ApiPaths.threads,
      body: body,
    );
    _throwIfError(json);
    final raw = json['thread'] as Map<String, dynamic>? ?? json;
    return ForumThread.fromJson(raw);
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
  }) async {
    await AppApi.instance.applySession();
    final json = await _api.post(
      ApiPaths.posts,
      body: {
        'thread_id': threadId,
        'message': message,
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

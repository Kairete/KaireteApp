import 'package:kairete/config/api_paths.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/services/reaction_service.dart';
import 'package:kairete/features/forum/models/forum_node.dart';
import 'package:kairete/features/forum/models/forum_thread.dart';

class ForumService {
  XenforoApi get _api => AppApi.instance.xenforo;
  final ReactionService _reactions = ReactionService();

  Future<List<ForumNodeGroup>> fetchForumGroups() async {
    await AppApi.instance.applySession();
    final json = await _api.get(ApiPaths.nodes, query: {'limit': 100});
    _throwIfError(json);
    return ForumNodesPage.fromJson(json).groups;
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
    return ForumThreadsPage.fromJson(json).threads;
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
  }) async {
    await AppApi.instance.applySession();
    final json = await _api.post(
      ApiPaths.threads,
      body: {
        'node_id': forumId,
        'title': title,
        'message': message,
      },
    );
    _throwIfError(json);
    final raw = json['thread'] as Map<String, dynamic>? ?? json;
    return ForumThread.fromJson(raw);
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
    final json = await _api.get('${ApiPaths.forums}$forumId');
    _throwIfError(json);
    final forum = json['forum'] as Map<String, dynamic>? ?? json;
    final watched = forum['is_watched'] == true ||
        forum['visitor_is_watched'] == true;
    return ForumWatchState(isWatched: watched);
  }

  Future<bool> watchForum(int forumId, {required bool stop}) async {
    await AppApi.instance.applySession();
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
  const ForumWatchState({required this.isWatched});

  final bool isWatched;
}

class ForumException implements Exception {
  ForumException(this.message);
  final String message;

  @override
  String toString() => message;
}

import 'package:kairete/config/api_paths.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/services/reaction_service.dart';
import 'package:kairete/features/blog/models/blog_comment.dart';
import 'package:kairete/features/blog/models/blog_entry.dart';

class BlogService {
  XenforoApi get _api => AppApi.instance.xenforo;
  final ReactionService _reactions = ReactionService();

  Future<List<BlogEntry>> fetchEntries({
    int? blogId,
    int? categoryId,
  }) async {
    await AppApi.instance.applySession();
    final query = <String, dynamic>{};
    if (blogId != null) query['blog_ids[]'] = blogId;
    if (categoryId != null) query['category_ids[]'] = categoryId;

    final json = await _api.get(ApiPaths.blogEntries, query: query);
    _throwIfError(json);
    return BlogEntriesPage.fromJson(json).entries;
  }

  Future<BlogEntry> fetchEntry(int blogEntryId) async {
    await AppApi.instance.applySession();

    // Query param works even when the path route is missing on the server.
    var json = await _api.get(
      ApiPaths.blogEntries,
      query: {'blog_entry_id': blogEntryId},
    );
    final fromQuery = json['blogEntry'];
    if (fromQuery is Map<String, dynamic>) {
      return BlogEntry.fromJson(fromQuery);
    }
    if (XenforoApi.firstErrorMessage(json) == null) {
      for (final entry in BlogEntriesPage.fromJson(json).entries) {
        if (entry.blogEntryId == blogEntryId) return entry;
      }
    }

    json = await _api.get('${ApiPaths.blogEntries}/$blogEntryId/');
    _throwIfError(json);

    final direct = json['blogEntry'];
    if (direct is Map<String, dynamic>) {
      return BlogEntry.fromJson(direct);
    }

    throw BlogException('Articolo blog non trovato.');
  }

  Future<String> react({
    required int blogEntryId,
    int? authorUserId,
    int reactionId = 1,
  }) async {
    try {
      return await _reactions.reactBlogEntry(
        blogEntryId,
        authorUserId: authorUserId,
        reactionId: reactionId,
      );
    } on ReactionException catch (e) {
      throw BlogException(e.message);
    }
  }

  Future<BlogCommentsPage> fetchComments(int blogEntryId) async {
    await AppApi.instance.applySession();
    final json = await _api.get(
      '${ApiPaths.blogEntries}/$blogEntryId/comments/',
    );
    _throwIfError(json);
    return BlogCommentsPage.fromJson(json);
  }

  Future<void> postComment({
    required int blogEntryId,
    required String message,
  }) async {
    await AppApi.instance.applySession();
    final json = await _api.post(
      '${ApiPaths.blogEntries}/$blogEntryId/comments/',
      body: {'message': message},
    );
    _throwIfError(json);
  }

  Future<String> reactToComment({
    required int commentId,
    int? authorUserId,
    int reactionId = 1,
  }) async {
    try {
      return await _reactions.reactBlogComment(
        commentId,
        authorUserId: authorUserId,
        reactionId: reactionId,
      );
    } on ReactionException catch (e) {
      throw BlogException(e.message);
    }
  }

  Future<BlogWatchState> fetchBlogWatchState(int blogId) async {
    await AppApi.instance.applySession();
    final json = await _api.get('${ApiPaths.blogs}$blogId/');
    _throwIfError(json);
    final blog = json['blog'] as Map<String, dynamic>? ?? json;
    return BlogWatchState(
      isWatched: blog['is_watched'] == true,
      canWatch: blog['can_watch'] != false,
    );
  }

  Future<bool> watchBlog(int blogId, {required bool stop}) async {
    await AppApi.instance.applySession();
    final json = await _api.post(
      '${ApiPaths.blogs}$blogId/watch/',
      body: stop ? {'stop': true} : {},
    );
    _throwIfError(json);
    if (json['is_watched'] is bool) {
      return json['is_watched'] as bool;
    }
    return !stop;
  }

  void _throwIfError(Map<String, dynamic> json) {
    final err = XenforoApi.firstErrorMessage(json);
    if (err != null) throw BlogException(err);
  }
}

class BlogException implements Exception {
  BlogException(this.message);
  final String message;

  @override
  String toString() => message;
}

class BlogWatchState {
  const BlogWatchState({
    required this.isWatched,
    this.canWatch = true,
  });

  final bool isWatched;
  final bool canWatch;
}

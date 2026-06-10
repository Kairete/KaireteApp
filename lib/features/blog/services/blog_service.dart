import 'dart:io';

import 'package:dio/dio.dart';
import 'package:kairete/config/api_paths.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/services/reaction_service.dart';
import 'package:kairete/features/blog/models/blog_comment.dart';
import 'package:kairete/features/blog/models/blog_compose_options.dart';
import 'package:kairete/features/blog/models/blog_entry.dart';
import 'package:kairete/features/blog/models/blog_profile.dart';

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

  Future<BlogProfile> fetchBlogProfile(int blogId) async {
    await AppApi.instance.applySession();
    final json = await _api.get('${ApiPaths.blogs}$blogId/');
    _throwIfError(json);
    final blog = json['blog'] as Map<String, dynamic>? ?? json;
    return BlogProfile.fromJson(blog);
  }

  Future<BlogWatchState> fetchBlogWatchState(int blogId) async {
    final profile = await fetchBlogProfile(blogId);
    return BlogWatchState(
      isWatched: profile.isWatched,
      canWatch: profile.canWatch,
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

  Future<List<WritableBlog>> fetchWritableBlogs() async {
    await AppApi.instance.applySession();
    final json = await _api.get(ApiPaths.blogs);
    _throwIfError(json);
    final raw = json['blogs'];
    if (raw is! List) return [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(WritableBlog.fromJson)
        .where((blog) => blog.blogId > 0)
        .toList();
  }

  Future<List<BlogCategoryOption>> fetchCategories() async {
    await AppApi.instance.applySession();
    final json = await _api.get(ApiPaths.blogCategories);
    _throwIfError(json);
    final raw = json['categories'];
    if (raw is! List) return [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(BlogCategoryOption.fromJson)
        .where((cat) => cat.categoryId > 0)
        .toList();
  }

  Future<CreatedBlog> createBlog({
    required String title,
    String slug = '',
    String description = '',
    bool isCommunity = false,
    String communityMembers = '',
    String? coverPath,
  }) async {
    await AppApi.instance.applySession();
    final body = <String, dynamic>{
      'title': title,
      'description': description,
      'is_community': isCommunity ? 1 : 0,
    };
    if (slug.isNotEmpty) body['slug'] = slug;
    if (communityMembers.isNotEmpty) body['community_members'] = communityMembers;

    final Map<String, dynamic> json;
    if (coverPath != null &&
        coverPath.isNotEmpty &&
        File(coverPath).existsSync()) {
      json = await _api.postMultipart(
        ApiPaths.blogs,
        fields: body,
        files: {
          'cover': MultipartFile.fromFileSync(
            coverPath,
            filename: _fileNameFromPath(coverPath),
          ),
        },
      );
    } else {
      json = await _api.post(ApiPaths.blogs, body: body);
    }
    _throwIfError(json);

    final blog = json['blog'];
    if (blog is Map<String, dynamic>) {
      return CreatedBlog.fromJson(blog);
    }
    throw BlogException('Blog creato ma risposta non valida.');
  }

  String _fileNameFromPath(String path) {
    final parts = path.split(RegExp(r'[/\\]'));
    return parts.isNotEmpty ? parts.last : 'cover.jpg';
  }

  Future<BlogEntry> updateEntry({
    required int blogEntryId,
    required String title,
    required String message,
    int categoryId = 0,
    String tags = '',
    String attachmentHash = '',
    String attachmentKey = '',
  }) async {
    await AppApi.instance.applySession();
    final body = <String, dynamic>{
      'title': title,
      'message': message,
      'category_id': categoryId,
      'tags': tags,
    };
    final attach = attachmentKey.isNotEmpty ? attachmentKey : attachmentHash;
    if (attach.isNotEmpty) {
      body['attachment_hash'] = attach;
      body['attachment_key'] = attach;
    }

    final json = await _api.post('${ApiPaths.blogEntries}/$blogEntryId/', body: body);
    _throwIfError(json);

    final direct = json['blogEntry'];
    if (direct is Map<String, dynamic>) {
      return BlogEntry.fromJson(direct);
    }

    throw BlogException('Articolo aggiornato ma risposta non valida.');
  }

  Future<void> deleteEntry(int blogEntryId) async {
    await AppApi.instance.applySession();
    final json = await _api.delete('${ApiPaths.blogEntries}/$blogEntryId/');
    _throwIfError(json);
  }

  Future<BlogEntry> createEntry({
    required int blogId,
    required String title,
    required String message,
    int categoryId = 0,
    String tags = '',
    String attachmentHash = '',
    String attachmentKey = '',
  }) async {
    await AppApi.instance.applySession();
    final body = <String, dynamic>{
      'blog_id': blogId,
      'title': title,
      'message': message,
    };
    if (categoryId > 0) body['category_id'] = categoryId;
    if (tags.isNotEmpty) body['tags'] = tags;
    final attach = attachmentKey.isNotEmpty ? attachmentKey : attachmentHash;
    if (attach.isNotEmpty) {
      body['attachment_hash'] = attach;
      body['attachment_key'] = attach;
    }

    final json = await _api.post('${ApiPaths.blogEntries}/', body: body);
    _throwIfError(json);

    final direct = json['blogEntry'];
    if (direct is Map<String, dynamic>) {
      return BlogEntry.fromJson(direct);
    }

    throw BlogException('Articolo creato ma risposta non valida.');
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

class CreatedBlog {
  const CreatedBlog({
    required this.blogId,
    required this.title,
    required this.slug,
    this.coverUrl,
  });

  final int blogId;
  final String title;
  final String slug;
  final String? coverUrl;

  factory CreatedBlog.fromJson(Map<String, dynamic> json) {
    return CreatedBlog(
      blogId: json['blog_id'] as int? ?? 0,
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      coverUrl: json['cover_url']?.toString(),
    );
  }
}

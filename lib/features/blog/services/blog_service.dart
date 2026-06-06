import 'package:kairete/config/api_paths.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/features/blog/models/blog_entry.dart';

class BlogService {
  XenforoApi get _api => AppApi.instance.xenforo;

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
    final json = await _api.get('${ApiPaths.blogEntries}/$blogEntryId');
    _throwIfError(json);
    final raw = json['blogEntry'] as Map<String, dynamic>? ?? json;
    return BlogEntry.fromJson(raw);
  }

  Future<void> react({required int blogEntryId, int reactionId = 1}) async {
    await AppApi.instance.applySession();
    final json = await _api.post(
      '${ApiPaths.blogEntries}/$blogEntryId/react',
      body: {'reaction_id': reactionId},
    );
    _throwIfError(json);
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

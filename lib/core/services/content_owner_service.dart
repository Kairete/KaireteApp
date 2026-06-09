import 'package:kairete/config/api_paths.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';

/// Modifica ed eliminazione contenuti dell'autore (feed, blog, forum, gruppi).
class ContentOwnerService {
  XenforoApi get _api => AppApi.instance.xenforo;

  Future<void> deleteItem(OmnifeedItem item) async {
    await AppApi.instance.applySession();
    final id = item.contentId ?? 0;
    if (id <= 0) throw ContentOwnerException('Contenuto non valido.');

    try {
      final json = await _api.delete('${ApiPaths.newsfeedItems}$item.itemId');
      if (XenforoApi.firstErrorMessage(json) == null) return;
    } catch (_) {}

    switch (item.contentType) {
      case 'profile_post':
        await _delete('${ApiPaths.profilePosts}/$id');
      case 'thread':
        await _delete('${ApiPaths.threads}/$id');
      case 'ubs_blog_entry':
        await _delete('${ApiPaths.blogEntries}/$id');
      case 'tl_group_post':
        await _delete('${ApiPaths.groupPosts}$id');
      default:
        throw ContentOwnerException('Eliminazione non supportata.');
    }
  }

  Future<void> updateProfilePost({
    required int profilePostId,
    required String message,
  }) async {
    await _update(
      '${ApiPaths.profilePosts}/$profilePostId',
      {'message': message.trim()},
    );
  }

  Future<void> updateThread({
    required int threadId,
    required String title,
    required String message,
    required int firstPostId,
  }) async {
    await _update(
      '${ApiPaths.threads}/$threadId',
      {'title': title.trim()},
    );
    if (firstPostId > 0) {
      await _update(
        '${ApiPaths.posts}$firstPostId',
        {'message': message.trim()},
      );
    }
  }

  Future<void> updateBlogEntry({
    required int blogEntryId,
    required String title,
    required String message,
  }) async {
    await _update(
      '${ApiPaths.blogEntries}/$blogEntryId',
      {
        'title': title.trim(),
        'message': message.trim(),
      },
    );
  }

  Future<void> updateGroupPost({
    required int groupPostId,
    required String message,
  }) async {
    await _update(
      '${ApiPaths.groupPosts}$groupPostId',
      {'message': message.trim()},
    );
  }

  Future<void> updateItem({
    required OmnifeedItem item,
    String? title,
    required String message,
    int firstPostId = 0,
  }) async {
    final id = item.contentId ?? 0;
    if (id <= 0) throw ContentOwnerException('Contenuto non valido.');

    try {
      final body = <String, dynamic>{
        'id': item.itemId,
        'message': message.trim(),
      };
      if (title != null && title.trim().isNotEmpty) {
        body['title'] = title.trim();
      }
      final json = await _api.post(
        '${ApiPaths.newsfeedItems}${item.itemId}',
        body: body,
      );
      if (XenforoApi.firstErrorMessage(json) == null) return;
    } catch (_) {}

    switch (item.contentType) {
      case 'profile_post':
        await updateProfilePost(profilePostId: id, message: message);
      case 'thread':
        await updateThread(
          threadId: id,
          title: title ?? item.contentTitle ?? '',
          message: message,
          firstPostId: firstPostId,
        );
      case 'ubs_blog_entry':
        await updateBlogEntry(
          blogEntryId: id,
          title: title ?? item.contentTitle ?? '',
          message: message,
        );
      case 'tl_group_post':
        await updateGroupPost(groupPostId: id, message: message);
      default:
        throw ContentOwnerException('Modifica non supportata.');
    }
  }

  Future<void> _delete(String path) async {
    final json = await _api.delete(path);
    _throwIfError(json);
  }

  Future<void> _update(String path, Map<String, dynamic> body) async {
    final json = await _api.post(path, body: body);
    _throwIfError(json);
  }

  void _throwIfError(Map<String, dynamic> json) {
    final err = XenforoApi.firstErrorMessage(json);
    if (err != null) throw ContentOwnerException(err);
  }
}

class ContentOwnerException implements Exception {
  ContentOwnerException(this.message);
  final String message;

  @override
  String toString() => message;
}

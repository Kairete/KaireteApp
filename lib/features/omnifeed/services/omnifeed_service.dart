import 'package:kairete/config/api_paths.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/services/reaction_service.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_comment.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';

class OmnifeedService {
  XenforoApi get _api => AppApi.instance.xenforo;
  final ReactionService _reactions = ReactionService();

  Future<OmnifeedFeed> fetchFeed({
    String mode = 'network',
    String sort = 'post_date',
    int page = 1,
  }) async {
    await AppApi.instance.applySession();
    final json = await _api.get(
      ApiPaths.newsfeed,
      query: {
        'mode': mode,
        'sort': sort,
        'page': page,
      },
    );
    _throwIfError(json);
    return OmnifeedFeed.fromJson(json);
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

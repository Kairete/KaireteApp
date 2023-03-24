import 'package:get/get.dart';
import 'package:kairete/features/newsfeed/models/comment_model/comment.dart';
import 'package:kairete/features/newsfeed/models/comment_model/comment_model.dart';
import 'package:kairete/features/newsfeed/models/newsfeed_model.dart';
import 'package:kairete/features/newsfeed/usecase/newsfeed_usecase.dart';

class ReplyController extends GetxController {
  NewsFeedUsecase usecase = INewsFeedUsecase();
  NewsfeedModel? item;

  CommentModel? comment;
  var items = <Comment>[].obs;

  @override
  void onInit() {
    item = Get.arguments['item'];
    fetchItems();
    super.onInit();
  }

  void fetchItems() async {
    if (item == null) {
      return;
    }
    String path = '';
    final id = item!.contentId;
    switch (item!.type) {
      case ContentTypeNewFeed.thread:
        path = 'threads/$id/posts';
        break;
      case ContentTypeNewFeed.profilePost:
        path = 'profile-posts/$id/comments';
        break;
      case ContentTypeNewFeed.tlGroupPost:
        path = 'group-posts/$id/comments';
        break;
      case ContentTypeNewFeed.media:
        path = 'media/$id/comments';
        break;
      case ContentTypeNewFeed.album:
        path = 'media-albums/$id/comments';
        break;
      case ContentTypeNewFeed.blogEntry:
        path = 'blog-entries/$id/comments';
        break;
      case ContentTypeNewFeed.article:
        path = 'articles/$id/comments';
        break;
      default:
    }
    final json = await usecase.comments(body: null, path: path);
    comment = CommentModel.fromJson(json);
    items.value = comment?.comments ?? [];
  }
}

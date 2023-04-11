import 'package:get/get.dart';
import 'package:kairete/features/blogs/screens/blog_detail_screen.dart';
import 'package:kairete/features/blogs/usecase/blog_usecase.dart';

import '../../../components/kairete_popup.dart';
import '../../newsfeed/models/newsfeed_model.dart';
import '../models/blog_model.dart';
import '../screens/blog_comment_screen.dart';

class BlogFilterController extends GetxController {
  BlogUsecase usecase = IBlogUsecase();
  Category? cate;
  int? blogId;
  var items = <BlogEntryItem>[].obs;

  @override
  void onInit() {
    if (Get.arguments != null) {
      if (Get.arguments['blogId'] != null) {
        blogId = Get.arguments['blogId'];
      }
      if (Get.arguments['category'] != null) {
        cate = Get.arguments['category'];
      }
    }
    fetchItems();
    super.onInit();
  }

  void fetchItems() async {
    Map<String, dynamic> body = {};
    if (blogId != null) {
      body['blog_ids[]'] = blogId;
    }
    if (cate != null) {
      body['category_ids[]'] = cate?.categoryId;
    }
    final json = await usecase.fetchItemsFromCate(body: body);
    final item = BlogModel.fromJson(json);
    items.value = item.blogEntryItems ?? [];
  }

  void toDetail({required BlogEntryItem item}) {
    Get.to(() => BlogDetailScreen(), arguments: {'item': item});
  }

  void showReactions({required int blogId}) {
    showReactionsPopup(
      onBack: (reactionId) {
        onReaction(
          reactionId: reactionId,
          blogId: blogId,
        );
      },
    );
  }

  void onReaction({required int reactionId, required int blogId}) async {
    final body = {
      'id': blogId,
      'reaction_id': reactionId,
    };
    final json = await usecase.reactions(body: body);
    if (json != null) {
      fetchItems();
    }
  }

  void toComment({required BlogEntryItem item}) {
    Get.to(() => BlogCommentScreen(), arguments: {
      'item': item,
    });
  }
}

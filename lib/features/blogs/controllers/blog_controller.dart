import 'package:get/get.dart';
import 'package:kairete/features/blogs/screens/blog_comment_screen.dart';
import 'package:kairete/features/blogs/screens/blog_detail_screen.dart';
import 'package:kairete/features/blogs/usecase/blog_usecase.dart';
import '../../../components/kairete_popup.dart';
import '../../newsfeed/models/newsfeed_model.dart';
import '../models/blog_model.dart';
import '../screens/blog_filter_screen.dart';

class BlogController extends GetxController {
  BlogUsecase usecase = IBlogUsecase();
  var items = <BlogEntryItem>[].obs;

  @override
  void onInit() {
    fetchItems();
    super.onInit();
  }

  void fetchItems() async {
    final json = await usecase.fetItems();
    final item = BlogModel.fromJson(json);
    items.value = item.blogEntryItems ?? [];
  }

  void toDetail({required BlogEntryItem item}) {
    Get.to(() => BlogDetailScreen(), arguments: {'item': item});
  }

  void toFilterWithTitle({required BlogEntryItem item}) {
    Get.to(() => BlogFilterScreen(), arguments: {
      'blogId': item.blog?.blogId,
    });
  }

  void toCate({required BlogEntryItem item}) {
    Get.to(() => BlogFilterScreen(), arguments: {'category': item.category});
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

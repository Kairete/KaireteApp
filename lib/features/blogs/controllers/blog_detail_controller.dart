import 'package:get/get.dart';
import 'package:kairete/features/blogs/controllers/blog_controller.dart';

import '../../../components/kairete_popup.dart';
import '../../../local/master_data.dart';
import '../../newsfeed/models/newsfeed_model.dart';
import '../screens/blog_comment_screen.dart';
import '../screens/blog_filter_screen.dart';
import '../usecase/blog_usecase.dart';

class BlogsDetailController extends GetxController {
  var item = BlogEntryItem().obs;
  BlogUsecase usecase = IBlogUsecase();

  @override
  void onInit() {
    fetchItem();
    super.onInit();
  }

  void fetchItem() async {
    final data = Get.arguments['item'];
    final body = {'id': data.blogEntryId.toString()};
    final json = await usecase.blogDetail(body: body);
    item.value = BlogEntryItem.fromJson(json['blogEntry']);
  }

  void toCate() {
    Get.to(() => BlogFilterScreen(),
        arguments: {'category': item.value.category});
  }

  void toFilterWithTitle() {
    Get.to(() => BlogFilterScreen(), arguments: {
      'blogId': item.value.blog?.blogId,
    });
  }

  void showReactions() {
    showReactionsPopup(
      onBack: (reactionId) {
        onReaction(
          reactionId: reactionId,
          blogId: item.value.blogEntryId ?? 0,
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
      final path = MasterDataManager.instance.reactionIcons
          .firstWhere((element) => element.reactionId == reactionId)
          .imageUrl;
      item.value.reactionIconUrl = path;
      item.refresh();
      Get.find<BlogController>().fetchItems();
    }
  }

  void toComment() {
    Get.to(() => BlogCommentScreen(), arguments: {
      'item': item.value,
    });
  }
}

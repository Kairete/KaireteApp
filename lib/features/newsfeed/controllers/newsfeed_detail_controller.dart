import 'package:get/get.dart';
import 'package:kairete/features/newsfeed/controllers/newsfeed_controller.dart';

import '../../../components/kairete_popup.dart';
import '../../../local/master_data.dart';
import '../../blogs/screens/blog_filter_screen.dart';
import '../models/newsfeed_model.dart';
import '../screens/reply_screen.dart';
import '../usecase/newsfeed_usecase.dart';

class NewsfeedDetailController extends GetxController {
  var item = NewsfeedModel().obs;
  NewsFeedUsecase usecase = INewsFeedUsecase();

  @override
  void onInit() {
    item.value = Get.arguments['item'];
    super.onInit();
  }

  void toCate() {
    Get.to(() => BlogFilterScreen(),
        arguments: {'category': item.value.blogEntryItem?.category});
  }

  void onReactions({required int postId, required int reactionId}) async {
    final body = {
      'id': postId,
      'reaction_id': reactionId,
    };
    final json = await usecase.reactions(body: body);
    if (json['success'] == true) {
      final path = MasterDataManager.instance.reactionIcons
          .firstWhere((element) => element.reactionId == reactionId)
          .imageUrl;
      item.value.reactionIconUrl = path;
      item.refresh();
      Get.find<NewsFeedController>().fechItems();
    }
  }

  void showReactionPopup() {
    showReactionsPopup(
      onBack: (reactionId) {
        onReactions(postId: item.value.itemId ?? 0, reactionId: reactionId);
      },
    );
  }

  void toReplies() {
    Get.to(() => ReplyScreen(), arguments: {'item': item.value});
  }
}

import 'package:get/get.dart';
import 'package:kairete/features/forum/controllers/forum_detail_controller.dart';

import '../../../components/kairete_popup.dart';
import '../../../local/master_data.dart';
import '../models/forum_detail_model.dart';
import '../screens/thread_comment_screen.dart';
import '../usecase/forum_usecase.dart';

class ThreadDetailController extends GetxController {
  var item = Threads().obs;
  ForumUsecase usecase = IForumUsecase();

  @override
  void onInit() {
    item.value = Get.arguments['item'];
    super.onInit();
  }

  void showReactionPopup() {
    showReactionsPopup(
      onBack: (reactionId) {
        onReactions(
            postId: item.value.firstPostId ?? 0, reactionId: reactionId);
      },
    );
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

      Get.find<ForumDetailController>().fetchItems();
    }
  }

  void toComment() {
    Get.to(() => ThreadCommentScreen(), arguments: {
      'item': item.value,
    });
  }
}

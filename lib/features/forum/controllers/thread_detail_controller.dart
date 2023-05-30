import 'package:get/get.dart';
import 'package:kairete/features/forum/controllers/forum_detail_controller.dart';
import 'package:kairete/features/forum/usecase/thread_usecase.dart';

import '../../../components/kairete_popup.dart';
import '../../../local/master_data.dart';
import '../models/forum_detail_model.dart';
import '../screens/thread_comment_screen.dart';
import '../usecase/forum_usecase.dart';

class ThreadDetailController extends GetxController {
  var item = Threads().obs;
  ForumUsecase usecase = IForumUsecase();
  ThreadUsecase threadUsecase = IThreadUsecase();

  @override
  void onInit() {
    fetchItem();
    super.onInit();
  }

  void fetchItem() async {
    Threads data = Get.arguments['item'];
    if (data.message != null) {
      item.value = data;
    } else {
      final body = {'id': data.firstPostId?.toString()};
      final json = await threadUsecase.fetchItem(body: body);
      item.value = Threads.fromJson(json['post']['Thread']);
    }
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

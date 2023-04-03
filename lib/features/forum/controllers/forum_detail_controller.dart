import 'package:get/get.dart';
import 'package:kairete/features/forum/models/forum_model.dart';
import 'package:kairete/features/forum/screens/thread_comment_screen.dart';
import 'package:kairete/features/forum/screens/thread_create_screen.dart';
import 'package:kairete/features/forum/usecase/forum_usecase.dart';

import '../../../components/kairete_popup.dart';
import '../models/forum_detail_model.dart';

class ForumDetailController extends GetxController {
  ForumUsecase usecase = IForumUsecase();
  Nodes? item;
  var items = <Threads>[].obs;

  @override
  void onInit() {
    item = Get.arguments['item'];
    super.onInit();
    fetchItems();
  }

  void fetchItems() async {
    final body = {'id': item?.nodeId};
    final json = await usecase.nodeDetail(body: body);
    final data = ForumDetailModel.fromJson(json);
    items.value = data.threads ?? [];
  }

  void toCreate() {
    Get.to(
      () => ThredCreateScreen(),
      arguments: {'item': item},
    );
  }

  void showReactionPopup({required Threads item}) {
    showReactionsPopup(
      onBack: (reactionId) {
        onReactions(postId: item.firstPostId ?? 0, reactionId: reactionId);
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
      fetchItems();
    }
  }

  void toComment({required Threads item}) {
    Get.to(() => ThreadCommentScreen(), arguments: {
      'item': item,
    });
  }
}

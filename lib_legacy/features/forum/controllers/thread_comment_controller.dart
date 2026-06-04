import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/features/forum/models/forum_detail_model.dart';
import 'package:kairete/features/forum/screens/thread_reply_screen.dart';
import 'package:kairete/features/forum/usecase/thread_usecase.dart';

import '../../../components/kairete_popup.dart';
import '../../newsfeed/models/comment_model/comment.dart';
import '../../newsfeed/models/comment_model/comment_model.dart';
import '../usecase/forum_usecase.dart';

class ThreadCommentController extends GetxController {
  TextEditingController textEditingController = TextEditingController();

  CommentModel? comment;
  var items = <Comment>[].obs;
  var isEnable = false.obs;
  Threads? item;

  ThreadUsecase usecase = IThreadUsecase();
  ForumUsecase forumUsecase = IForumUsecase();

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
    final body = {'id': item?.threadId};
    final json = await usecase.commentLv1(
      body: body,
    );
    comment = CommentModel.fromJson(json);
    final data = comment?.comments ?? [];
    items.value = data;
  }

  void toSubReply({required Comment item}) {
    Get.to(() => ThreadReplyScreen(), arguments: {
      'item': item,
    });
  }

  void textOnChanged({required text}) {
    isEnable.value = text.isNotEmpty;
  }

  void postComent() async {
    if (textEditingController.text.isEmpty) {
      return;
    }
    final body = {
      'message': textEditingController.text,
      'thread_id': item!.threadId,
    };
    final json = await usecase.postCommentLv1(body: body);
    if (json != null) {
      fetchItems();
    }
  }

  void showReactions({required int commentId}) {
    showReactionsPopup(
      onBack: (reactionId) {
        onReaction(
          reactionId: reactionId,
          commentId: commentId,
        );
      },
    );
  }

  void onReaction({required int reactionId, required int commentId}) async {
    final body = {
      'id': commentId,
      'reaction_id': reactionId,
    };
    final json = await forumUsecase.reactions(body: body);
    if (json != null) {
      fetchItems();
    }
  }
}

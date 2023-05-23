import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/features/newsfeed/controllers/newsfeed_controller.dart';
import 'package:kairete/features/newsfeed/models/comment_model/comment.dart';
import 'package:kairete/features/newsfeed/models/comment_model/comment_model.dart';
import 'package:kairete/features/newsfeed/models/newsfeed_model.dart';
import 'package:kairete/features/newsfeed/usecase/newsfeed_usecase.dart';

import '../../../components/kairete_popup.dart';
import '../screens/sub_reply_screen.dart';

class ReplyController extends GetxController {
  NewsFeedUsecase usecase = INewsFeedUsecase();
  NewsfeedModel? item;

  TextEditingController textEditingController = TextEditingController();

  CommentModel? comment;
  var items = <Comment>[].obs;
  var isEnable = false.obs;
  var isUpdate = false;

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
    final json = await usecase.comments(
      body: null,
      id: item!.itemId ?? 0,
    );
    comment = CommentModel.fromJson(json);
    final data = comment?.comments ?? [];
    items.value = data;
  }

  void toSubReply({required Comment item}) {
    Get.to(() => SubReplyScreen(), arguments: {
      'item': item,
      'type': this.item?.contentType,
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
      'id': item!.itemId,
    };
    final json = await usecase.postCommentsLv1(body: body);
    if (json != null) {
      isUpdate = true;
      Get.find<NewsFeedController>().fechItems();
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
      'content_type': item!.contentType,
    };
    final json = await usecase.reactionsComment(body: body);
    if (json != null) {
      fetchItems();
    }
  }
}

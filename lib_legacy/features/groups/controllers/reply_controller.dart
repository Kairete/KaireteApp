import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/features/groups/controllers/group_feed_controller.dart';
import 'package:kairete/features/groups/model/group_detail_model/post.dart';
import 'package:kairete/features/groups/usecase/create_group_usecase.dart';
import 'package:kairete/features/newsfeed/models/comment_model/comment.dart';
import 'package:kairete/features/newsfeed/models/comment_model/comment_model.dart';
import 'package:kairete/features/newsfeed/usecase/newsfeed_usecase.dart';

import '../../../components/kairete_popup.dart';

class ReplyController extends GetxController {
  NewsFeedUsecase usecase = IGroupNormalUsecaseImpl();
  Post? item;

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
    final body = {
      'id': item?.postId,
    };
    final json = await usecase.fetchItems(body: body);
    comment = CommentModel.fromJson(json);
    final data = comment?.comments ?? [];
    items.value = data;
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
      'id': item!.postId,
    };
    final json = await usecase.postCommentsLv1(body: body);
    if (json != null) {
      isUpdate = true;
      Get.find<GroupFeedController>().fechItems();
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
    final json = await usecase.reactionsComment(body: body);
    if (json != null) {
      fetchItems();
    }
  }
}

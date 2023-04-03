import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/kairete_popup.dart';
import '../models/comment_model/comment.dart';
import '../models/comment_model/comment_model.dart';
import '../usecase/newsfeed_usecase.dart';

class SubreplyController extends GetxController {
  var items = <Comment>[].obs;
  var isEnable = false.obs;
  NewsFeedUsecase usecase = INewsFeedUsecase();
  Comment? item;
  String? type;

  TextEditingController textEditingController = TextEditingController();

  @override
  void onInit() {
    item = Get.arguments['item'];
    type = Get.arguments['type'];
    fetchItems();
    super.onInit();
  }

  void fetchItems() async {
    if (item == null) {
      return;
    }
    final body = {
      'id': item!.commentId ?? 0,
      'content_type': type,
    };
    final json = await usecase.commentsLv2(
      body: body,
    );
    final comment = CommentModel.fromJson(json);
    items.value = comment.comments ?? [];
  }

  void postComent() async {
    final body = {
      'message': textEditingController.text,
      'id': item!.commentId ?? 0,
      'content_type': type,
    };
    final json = await usecase.postComments(body: body);
    if (json != null) {
      fetchItems();
    }
  }

  void textOnChanged({required text}) {
    isEnable.value = text.isNotEmpty;
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
      'content_type': type,
    };
    final json = await usecase.reactionsComment(body: body);
    if (json != null) {
      fetchItems();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/features/blogs/usecase/blog_comment_usecase.dart';

import '../../../components/kairete_popup.dart';
import '../../newsfeed/models/comment_model/comment.dart';
import '../../newsfeed/models/comment_model/comment_model.dart';

class BlogReplyController extends GetxController {
  var items = <Comment>[].obs;
  var isEnable = false.obs;

  BlogCommentUsecase usecase = IBlogCommentUsecase();

  Comment? item;
  String? type;

  TextEditingController textEditingController = TextEditingController();

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
      'id': item!.commentId ?? 0,
    };
    final json = await usecase.commentLv2(
      body: body,
    );
    final comment = CommentModel.fromJson(json);
    items.value = comment.comments ?? [];
  }

  void postComent() async {
    final body = {
      'message': textEditingController.text,
      'id': item!.commentId ?? 0,
    };
    final json = await usecase.postCommentLv2(body: body);
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
    };
    final json = await usecase.reactions(body: body);
    if (json != null) {
      fetchItems();
    }
  }
}

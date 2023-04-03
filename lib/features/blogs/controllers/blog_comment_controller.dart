import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/features/blogs/screens/blog_reply_screen.dart';
import 'package:kairete/features/blogs/usecase/blog_comment_usecase.dart';
import 'package:kairete/features/newsfeed/models/newsfeed_model.dart';

import '../../../components/kairete_popup.dart';
import '../../newsfeed/models/comment_model/comment.dart';
import '../../newsfeed/models/comment_model/comment_model.dart';

class BlogCommentController extends GetxController {
  BlogCommentUsecase usecase = IBlogCommentUsecase();
  BlogEntryItem? item;

  TextEditingController textEditingController = TextEditingController();

  CommentModel? comment;
  var items = <Comment>[].obs;
  var isEnable = false.obs;

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
    final body = {'id': item?.blogEntryId};
    final json = await usecase.commentLv1(
      body: body,
    );
    comment = CommentModel.fromJson(json);
    final data = comment?.comments ?? [];
    items.value = data;
  }

  void toSubReply({required Comment item}) {
    Get.to(() => BlogReplyScreen(), arguments: {
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
      'id': item!.blogEntryId,
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
    final json = await usecase.reactions(body: body);
    if (json != null) {
      fetchItems();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/components/kairete_popup.dart';
import 'package:kairete/features/media/models/media_model.dart';
import 'package:kairete/features/media/usecase/media_uscase.dart';
import 'package:kairete/features/newsfeed/models/comment_model/comment.dart';

class MediaReplyController extends GetxController {
  TextEditingController textEditingController = TextEditingController();
  MediaUsecase usecase = IMediaUsecase();
  var items = <Comment>[].obs;

  MediaModel? item;

  @override
  void onInit() {
    if (Get.arguments['item'] != null) {
      item = Get.arguments['item'];
      fetchItems();
    }
    super.onInit();
  }

  void fetchItems() async {
    final json = await usecase.getComments(id: item?.mediaId ?? 0);
    items.value =
        json['comments'].map<Comment>((e) => Comment.fromJson(e)).toList();
  }

  void postComent() async {
    final body = {
      'media_id': item?.mediaId,
      'message': textEditingController.text,
    };
    print(body);
    final json = await usecase.comments(body: body);
    if (json != null) {
      fetchItems();
    }
  }

  void onReactions({required int reactionId, required MediaModel item}) async {
    final body = {
      'reaction_id': reactionId,
    };
    final json = await usecase.reactions(
      id: item.mediaId ?? 0,
      body: body,
    );
    if (json['success'] == true) {
      fetchItems();
    }
  }

  void showReactionPopup({required MediaModel item}) async {
    showReactionsPopup(
      onBack: (reactionId) {
        onReactions(reactionId: reactionId, item: item);
      },
    );
  }
}

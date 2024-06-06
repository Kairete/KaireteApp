import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hashtagable/functions.dart';

import 'package:kairete/components/kairete_popup.dart';
import 'package:kairete/features/forum/controllers/forum_detail_controller.dart';

import '../models/forum_model.dart';
import '../usecase/forum_usecase.dart';

class ThredCreateController extends GetxController {
  ForumUsecase usecase = IForumUsecase();
  TextEditingController textController = TextEditingController();
  TextEditingController titleController = TextEditingController();

  var isEnable = false.obs;
  var paths = [].obs;
  Nodes? item;
  var tags = '';

  @override
  void onInit() {
    item = Get.arguments['item'];
    super.onInit();
  }

  void textOnChanged() {
    isEnable.value =
        textController.text.isNotEmpty && titleController.text.isNotEmpty;
  }

  void onCreate() async {
    final tag =
        extractHashTags(tags).map((e) => e.replaceAll('#', '')).toList();

    final body = {
      'node_id': item?.nodeId,
      'title': titleController.text,
      'message': textController.text,
      'tags[]': tag,
    };
    final json = await usecase.createThread(body: body);
    if (json != null) {
      showKairetePopup(
        onTapDone: () {
          final forumControler = Get.find<ForumDetailController>();
          forumControler.fetchItems();
          Get.back();
        },
        content: 'Create successfuly',
      );
    }
  }
}

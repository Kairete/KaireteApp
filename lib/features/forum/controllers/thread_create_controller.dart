import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:kairete/components/kairete_popup.dart';
import 'package:kairete/features/forum/controllers/forum_detail_controller.dart';
import 'package:kairete/features/newsfeed/controllers/newsfeed_controller.dart';
import 'package:kairete/features/newsfeed/usecase/newsfeed_usecase.dart';

import '../models/forum_model.dart';
import '../usecase/forum_usecase.dart';

class ThredCreateController extends GetxController {
  ForumUsecase usecase = IForumUsecase();
  TextEditingController textController = TextEditingController();
  TextEditingController titleController = TextEditingController();

  var isEnable = false.obs;
  var paths = [].obs;
  Nodes? item;

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
    final body = {
      'node_id': item?.nodeId,
      'title': titleController.text,
      'message': textController.text,
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

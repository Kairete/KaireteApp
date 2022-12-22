import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/components/kairete_popup.dart';
import 'package:kairete/features/newsfeed/controllers/newsfeed_controller.dart';
import 'package:kairete/features/newsfeed/usecase/newsfeed_usecase.dart';
import 'package:kairete/helper/user.dart';

class CreateNewsfeedController extends GetxController {
  NewsFeedUsecase usecase = INewsFeedUsecase();
  TextEditingController textController = TextEditingController();
  var isEnable = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  void textOnChanged({required String text}) {
    isEnable.value = text.isNotEmpty;
  }

  void onCreate() async {
    final body = {
      'user_id': UserManager.instance.user?.user?.userId,
      'message': textController.text,
    };
    final json = await usecase.create(body: body);
    if (json != null) {
      showKairetePopup(
        onTapDone: () {
          final newFeedController = Get.find<NewsFeedController>();
          newFeedController.fechItems();
          Get.back();
        },
        content: 'Create successfuly',
      );
    }
  }
}

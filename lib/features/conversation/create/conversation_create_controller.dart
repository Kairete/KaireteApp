import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/components/kairete_popup.dart';
import 'package:kairete/features/conversation/conversation_usecase.dart';

class ConversationCreateController extends GetxController {
  TextEditingController textController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  ConversationUsecase usecase = IConversationUsecase();

  var isEnable = false.obs;
  int? userId;

  @override
  void onInit() {
    userId = Get.arguments['id'];
    super.onInit();
  }

  void onCreate() async {
    final body = {
      'recipient_ids[]': ['$userId'],
      'title': titleController.text,
      'message': textController.text,
    };
    final json = await usecase.post(body: body);
    if (json != null) {
      showKairetePopup(
        onTapDone: () {
          Get.back(result: true);
        },
        content: 'Create successfuly',
      );
    }
  }

  void textOnChanged({required String text}) {
    isEnable.value = (text != '' && titleController.text.isNotEmpty);
  }

  void titleOnChanged({required String text}) {
    isEnable.value = (text != '' && textController.text.isNotEmpty);
  }
}

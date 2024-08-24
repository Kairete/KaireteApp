import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/features/conversation/conversation_usecase.dart';
import 'package:kairete/features/conversation/message/message_model.dart';

class MessageController extends GetxController {
  ConversationUsecase usecase = IConversationUsecase();
  TextEditingController textEditingController = TextEditingController();

  int? id;
  var conversations = <MessageModel>[].obs;

  @override
  void onInit() {
    id = Get.arguments['id'];
    super.onInit();
    fetchItems();
  }

  void fetchItems() async {
    final body = {'id': id};
    final json = await usecase.message(body: body);
    conversations.value = json['messages']
        .map<MessageModel>((e) => MessageModel.fromJson(e))
        .toList();
  }

  void postMessage({required String message}) async {
    final body = {
      'message': message,
      'id': id,
    };
    final json = await usecase.postMessage(body: body);
    if (json != null) {
      fetchItems();
    }
  }
}

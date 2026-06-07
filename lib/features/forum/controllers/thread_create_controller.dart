import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/features/forum/pages/thread_detail_page.dart';
import 'package:kairete/features/forum/services/forum_service.dart';

class ThreadCreateController extends GetxController {
  ThreadCreateController({
    required this.forumId,
    required this.forumTitle,
  });

  final int forumId;
  final String forumTitle;
  final ForumService _service = ForumService();

  final titleCtrl = TextEditingController();
  final messageCtrl = TextEditingController();
  final canSend = false.obs;
  final isSending = false.obs;

  @override
  void onClose() {
    titleCtrl.dispose();
    messageCtrl.dispose();
    super.onClose();
  }

  void validate() {
    canSend.value = titleCtrl.text.trim().isNotEmpty &&
        messageCtrl.text.trim().isNotEmpty;
  }

  Future<void> publish() async {
    if (!canSend.value || isSending.value) return;
    isSending.value = true;
    try {
      final thread = await _service.createThread(
        forumId: forumId,
        title: titleCtrl.text.trim(),
        message: messageCtrl.text.trim(),
      );
      Get.back(result: true);
      Get.to(
        () => ThreadDetailPage(
          threadId: thread.threadId,
          forumTitle: forumTitle,
        ),
      );
    } on ForumException catch (e) {
      Get.snackbar('Errore', e.message);
    } finally {
      isSending.value = false;
    }
  }
}

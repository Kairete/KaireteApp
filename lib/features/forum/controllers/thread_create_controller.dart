import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/services/attachment_service.dart';
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
  final AttachmentService _attachments = AttachmentService();

  final titleCtrl = TextEditingController();
  final messageCtrl = TextEditingController();
  final tagsCtrl = TextEditingController();
  final canSend = false.obs;
  final isSending = false.obs;
  final pendingAttachments = <String>[].obs;
  final _attachmentPaths = <String, String>{};

  @override
  void onClose() {
    titleCtrl.dispose();
    messageCtrl.dispose();
    tagsCtrl.dispose();
    super.onClose();
  }

  void validate() {
    canSend.value = titleCtrl.text.trim().isNotEmpty &&
        messageCtrl.text.trim().isNotEmpty;
  }

  void addAttachment(String path, String displayName) {
    _attachmentPaths[displayName] = path;
    if (!pendingAttachments.contains(displayName)) {
      pendingAttachments.add(displayName);
    }
  }

  void removeAttachment(String displayName) {
    pendingAttachments.remove(displayName);
    _attachmentPaths.remove(displayName);
  }

  Future<void> pickAttachments() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return;
    for (final file in result.files) {
      final path = file.path;
      if (path != null) {
        addAttachment(path, file.name);
      }
    }
  }

  Future<void> publish() async {
    if (!canSend.value || isSending.value) return;
    isSending.value = true;
    try {
      String attachmentKey = '';
      if (pendingAttachments.isNotEmpty) {
        final session =
            await _attachments.createForumPostSession(nodeId: forumId);
        for (final name in pendingAttachments) {
          final path = _attachmentPaths[name];
          if (path != null) {
            await _attachments.uploadFile(
              session: session,
              filePath: path,
              filename: name,
            );
          }
        }
        attachmentKey = session.key;
      }

      final thread = await _service.createThread(
        forumId: forumId,
        title: titleCtrl.text.trim(),
        message: messageCtrl.text.trim(),
        tags: tagsCtrl.text.trim(),
        attachmentKey: attachmentKey,
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
    } on AttachmentException catch (e) {
      Get.snackbar('Errore allegati', e.message);
    } finally {
      isSending.value = false;
    }
  }
}

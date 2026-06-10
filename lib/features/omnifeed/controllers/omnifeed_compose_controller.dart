import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/services/attachment_service.dart';
import 'package:kairete/core/utils/attachment_picker.dart' as attach_pick;
import 'package:kairete/features/auth/controllers/auth_flow_controller.dart';
import 'package:kairete/features/omnifeed/services/omnifeed_service.dart';

class OmnifeedComposeController extends GetxController {
  final OmnifeedService _service = OmnifeedService();
  final AttachmentService _attachments = AttachmentService();
  final messageCtrl = TextEditingController();

  final isSending = false.obs;
  final canSend = false.obs;
  final pendingAttachments = <String>[].obs;
  final _attachmentPaths = <String, String>{};

  int? get _profileUserId {
    if (!Get.isRegistered<AuthFlowController>()) return null;
    return Get.find<AuthFlowController>().currentUser.value?.userId;
  }

  @override
  void onInit() {
    super.onInit();
    messageCtrl.addListener(_onTextChanged);
  }

  @override
  void onClose() {
    messageCtrl.dispose();
    super.onClose();
  }

  void _onTextChanged() {
    canSend.value =
        messageCtrl.text.trim().isNotEmpty || pendingAttachments.isNotEmpty;
  }

  void addAttachment(String path, String displayName) {
    _attachmentPaths[displayName] = path;
    if (!pendingAttachments.contains(displayName)) {
      pendingAttachments.add(displayName);
    }
    _onTextChanged();
  }

  void removeAttachment(String displayName) {
    pendingAttachments.remove(displayName);
    _attachmentPaths.remove(displayName);
    _onTextChanged();
  }

  Future<void> pickAttachments() async {
    final files = await attach_pick.pickAttachments(allowMultiple: true);
    for (final file in files) {
      addAttachment(file.path, file.displayName);
    }
  }

  Future<void> publish() async {
    final text = messageCtrl.text.trim();
    if (text.isEmpty && pendingAttachments.isEmpty) return;

    isSending.value = true;
    try {
      String attachmentKey = '';
      String attachmentHash = '';
      final userId = _profileUserId;
      if (pendingAttachments.isNotEmpty && userId != null && userId > 0) {
        final uploads = <({String path, String filename})>[];
        for (final name in pendingAttachments) {
          final path = _attachmentPaths[name];
          if (path != null) {
            uploads.add((path: path, filename: name));
          }
        }
        final session = await _attachments.uploadProfileFiles(
          profileUserId: userId,
          files: uploads,
        );
        attachmentKey = session.key;
        attachmentHash = session.hash;
      }

      await _service.createProfilePost(
        message: text.isEmpty ? ' ' : text,
        attachmentKey: attachmentKey,
        attachmentHash: attachmentHash,
      );
      Get.back(result: true);
    } on OmnifeedException catch (e) {
      Get.snackbar('Errore', e.message);
    } on AttachmentException catch (e) {
      Get.snackbar('Errore allegati', e.message);
    } catch (_) {
      Get.snackbar('Errore', 'Pubblicazione non riuscita.');
    } finally {
      isSending.value = false;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/features/omnifeed/services/omnifeed_service.dart';

class OmnifeedComposeController extends GetxController {
  final OmnifeedService _service = OmnifeedService();
  final messageCtrl = TextEditingController();

  final isSending = false.obs;
  final canSend = false.obs;

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
    canSend.value = messageCtrl.text.trim().isNotEmpty;
  }

  Future<void> publish() async {
    final text = messageCtrl.text.trim();
    if (text.isEmpty) return;
    isSending.value = true;
    try {
      await _service.createProfilePost(message: text);
      Get.back(result: true);
    } on OmnifeedException catch (e) {
      Get.snackbar('Errore', e.message);
    } catch (_) {
      Get.snackbar('Errore', 'Pubblicazione non riuscita.');
    } finally {
      isSending.value = false;
    }
  }
}

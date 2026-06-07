import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/utils/app_toast.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_comment.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/features/omnifeed/services/omnifeed_service.dart';

class OmnifeedDetailController extends GetxController {
  OmnifeedDetailController({required this.initialItem});

  final OmnifeedItem initialItem;
  final OmnifeedService _service = OmnifeedService();
  final commentCtrl = TextEditingController();

  final item = Rxn<OmnifeedItem>();
  final comments = <OmnifeedComment>[].obs;
  final isLoading = false.obs;
  final isSending = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    item.value = initialItem;
    _load();
  }

  @override
  void onClose() {
    commentCtrl.dispose();
    super.onClose();
  }

  Future<void> _load() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final detail = await _service.fetchItemDetail(initialItem.itemId);
      item.value = detail;
      final page = await _service.fetchComments(initialItem.itemId);
      comments.value = page.comments;
    } on OmnifeedException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = 'Dettaglio non disponibile.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendComment() async {
    final text = commentCtrl.text.trim();
    if (text.isEmpty) return;
    isSending.value = true;
    try {
      await _service.postComment(itemId: initialItem.itemId, message: text);
      commentCtrl.clear();
      await _load();
    } on OmnifeedException catch (e) {
      AppToast.error(e.message);
    } finally {
      isSending.value = false;
    }
  }

  Future<void> react({int reactionId = 1}) async {
    final current = item.value ?? initialItem;
    try {
      final action = await _service.reactToItem(item: current, reactionId: reactionId);
      final delta = action == 'delete' ? -1 : 1;
      final score = current.reactionScore + delta;
      item.value = current.copyWith(reactionScore: score < 0 ? 0 : score);
      AppToast.success(
        action == 'delete' ? 'Reazione rimossa.' : 'Reazione inviata.',
      );
      await _load();
    } on OmnifeedException catch (e) {
      AppToast.error(AppToast.mapApiError(e.message));
    }
  }
}

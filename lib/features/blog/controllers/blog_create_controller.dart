import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/features/blog/services/blog_service.dart';

class BlogCreateController extends GetxController {
  final BlogService _service = BlogService();

  final titleCtrl = TextEditingController();
  final slugCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final membersCtrl = TextEditingController();

  final isCommunity = false.obs;
  final isSaving = false.obs;
  final canSave = false.obs;

  @override
  void onInit() {
    super.onInit();
    titleCtrl.addListener(_validate);
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    slugCtrl.dispose();
    descriptionCtrl.dispose();
    membersCtrl.dispose();
    super.onClose();
  }

  void _validate() {
    canSave.value = titleCtrl.text.trim().isNotEmpty;
  }

  void setCommunity(bool value) {
    isCommunity.value = value;
  }

  Future<void> save() async {
    if (!canSave.value || isSaving.value) return;
    isSaving.value = true;
    try {
      await _service.createBlog(
        title: titleCtrl.text.trim(),
        slug: slugCtrl.text.trim(),
        description: descriptionCtrl.text.trim(),
        isCommunity: isCommunity.value,
        communityMembers: membersCtrl.text.trim(),
      );
      Get.back(result: true);
    } on BlogException catch (e) {
      Get.snackbar('Errore', e.message);
    } catch (_) {
      Get.snackbar('Errore', 'Impossibile creare il blog.');
    } finally {
      isSaving.value = false;
    }
  }
}

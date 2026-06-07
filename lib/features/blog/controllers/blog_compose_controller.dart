import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/features/blog/models/blog_compose_options.dart';
import 'package:kairete/features/blog/services/blog_service.dart';

class BlogComposeController extends GetxController {
  final BlogService _service = BlogService();

  final titleCtrl = TextEditingController();
  final messageCtrl = TextEditingController();
  final tagsCtrl = TextEditingController();

  final blogs = <WritableBlog>[].obs;
  final categories = <BlogCategoryOption>[].obs;
  final selectedBlogId = RxnInt();
  final selectedCategoryId = RxnInt();

  final isLoading = true.obs;
  final isSending = false.obs;
  final canSend = false.obs;
  final loadError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    titleCtrl.addListener(_onFieldsChanged);
    messageCtrl.addListener(_onFieldsChanged);
    _loadOptions();
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    messageCtrl.dispose();
    tagsCtrl.dispose();
    super.onClose();
  }

  void _onFieldsChanged() {
    canSend.value = titleCtrl.text.trim().isNotEmpty &&
        messageCtrl.text.trim().isNotEmpty &&
        (selectedBlogId.value ?? 0) > 0;
  }

  Future<void> _loadOptions() async {
    isLoading.value = true;
    loadError.value = '';
    try {
      final results = await Future.wait([
        _service.fetchWritableBlogs(),
        _service.fetchCategories(),
      ]);
      blogs.value = results[0] as List<WritableBlog>;
      categories.value = results[1] as List<BlogCategoryOption>;
      if (blogs.isNotEmpty) {
        selectedBlogId.value = blogs.first.blogId;
      }
      _onFieldsChanged();
    } on BlogException catch (e) {
      loadError.value = e.message;
    } catch (_) {
      loadError.value = 'Impossibile caricare i blog.';
    } finally {
      isLoading.value = false;
    }
  }

  void setBlogId(int? blogId) {
    selectedBlogId.value = blogId;
    _onFieldsChanged();
  }

  void setCategoryId(int? categoryId) {
    selectedCategoryId.value = categoryId;
  }

  Future<void> reload() => _loadOptions();

  Future<void> publish() async {
    if (!canSend.value || isSending.value) return;
    final blogId = selectedBlogId.value;
    if (blogId == null || blogId <= 0) {
      Get.snackbar('Errore', 'Seleziona un blog.');
      return;
    }

    isSending.value = true;
    try {
      await _service.createEntry(
        blogId: blogId,
        title: titleCtrl.text.trim(),
        message: messageCtrl.text.trim(),
        categoryId: selectedCategoryId.value ?? 0,
        tags: tagsCtrl.text.trim(),
      );
      Get.back(result: true);
    } on BlogException catch (e) {
      Get.snackbar('Errore', e.message);
    } catch (_) {
      Get.snackbar('Errore', 'Pubblicazione non riuscita.');
    } finally {
      isSending.value = false;
    }
  }
}

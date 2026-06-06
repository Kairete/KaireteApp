import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/features/blog/models/blog_entry.dart';
import 'package:kairete/features/blog/pages/blog_detail_page.dart';
import 'package:kairete/features/blog/pages/blog_list_page.dart';
import 'package:kairete/features/blog/services/blog_service.dart';

class BlogListController extends GetxController {
  BlogListController({
    this.filterBlogId,
    this.filterCategoryId,
  });

  final int? filterBlogId;
  final int? filterCategoryId;
  final BlogService _service = BlogService();

  final items = <BlogEntry>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadEntries();
  }

  Future<void> loadEntries() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final list = await _service
          .fetchEntries(
            blogId: filterBlogId,
            categoryId: filterCategoryId,
          )
          .timeout(const Duration(seconds: 25));
      items.value = list;
    } on TimeoutException {
      errorMessage.value =
          'Il blog impiega troppo tempo. Controlla la rete e riprova.';
    } on BlogException catch (e) {
      errorMessage.value = e.message;
    } on DioException catch (e) {
      errorMessage.value = XenforoApi.connectionMessage(e);
    } catch (_) {
      errorMessage.value = 'Impossibile caricare i blog.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> react(BlogEntry entry) async {
    try {
      await _service.react(blogEntryId: entry.blogEntryId);
      await loadEntries();
    } on BlogException catch (e) {
      Get.snackbar('Errore', e.message);
    }
  }

  void openDetail(BlogEntry entry) {
    Get.to(() => BlogDetailPage(entryId: entry.blogEntryId));
  }

  void openBlogFilter(BlogEntry entry) {
    final blogId = entry.blog?.blogId;
    if (blogId == null || blogId <= 0) return;
    Get.to(
      () => BlogListPage(
        filterBlogId: blogId,
        pageTitle: entry.blog?.title ?? 'Blog',
      ),
    );
  }

  void openCategoryFilter(BlogEntry entry) {
    final categoryId = entry.category?.categoryId;
    if (categoryId == null || categoryId <= 0) return;
    Get.to(
      () => BlogListPage(
        filterCategoryId: categoryId,
        pageTitle: entry.category?.title ?? 'Categoria',
      ),
    );
  }
}

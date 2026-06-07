import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/utils/app_toast.dart';
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
  final isWatched = false.obs;
  final canWatch = true.obs;
  final watchLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadEntries();
    if (filterBlogId != null) {
      loadWatchState();
    }
  }

  Future<void> loadWatchState() async {
    final blogId = filterBlogId;
    if (blogId == null) return;
    try {
      final state = await _service
          .fetchBlogWatchState(blogId)
          .timeout(const Duration(seconds: 15));
      isWatched.value = state.isWatched;
      canWatch.value = state.canWatch;
    } catch (_) {
      canWatch.value = false;
    }
  }

  Future<void> toggleWatch() async {
    final blogId = filterBlogId;
    if (blogId == null || !canWatch.value || watchLoading.value) return;
    watchLoading.value = true;
    final stop = isWatched.value;
    try {
      final watched = await _service.watchBlog(blogId, stop: stop);
      isWatched.value = watched;
      AppToast.success(watched ? 'Blog seguito.' : 'Watch rimosso.');
    } on BlogException catch (e) {
      AppToast.error(AppToast.mapApiError(e.message));
    } on DioException catch (e) {
      AppToast.error(XenforoApi.connectionMessage(e));
    } catch (_) {
      AppToast.error('Impossibile aggiornare il watch.');
    } finally {
      watchLoading.value = false;
    }
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

  Future<void> react(BlogEntry entry, {int reactionId = 1}) async {
    try {
      final action = await _service.react(
        blogEntryId: entry.blogEntryId,
        authorUserId: entry.author?.userId,
        reactionId: reactionId,
      );
      _bumpScore(entry.blogEntryId, action);
      AppToast.success(
        action == 'delete' ? 'Reazione rimossa.' : 'Reazione inviata.',
      );
      await loadEntries();
    } on BlogException catch (e) {
      AppToast.error(AppToast.mapApiError(e.message));
    }
  }

  void _bumpScore(int entryId, String action) {
    final index = items.indexWhere((entry) => entry.blogEntryId == entryId);
    if (index < 0) return;
    final delta = action == 'delete' ? -1 : 1;
    final current = items[index];
    final next = current.reactionScore + delta;
    items[index] = current.copyWith(reactionScore: next < 0 ? 0 : next);
    items.refresh();
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

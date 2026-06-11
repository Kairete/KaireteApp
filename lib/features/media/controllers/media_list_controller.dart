import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/utils/app_toast.dart';
import 'package:kairete/features/media/models/media_item.dart';
import 'package:kairete/features/media/pages/media_detail_page.dart';
import 'package:kairete/features/media/pages/media_list_page.dart';
import 'package:kairete/features/media/services/media_service.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_navigation.dart';

class MediaListController extends GetxController {
  MediaListController({this.filterAlbumId, this.filterCategoryId});

  final int? filterAlbumId;
  final int? filterCategoryId;
  final MediaService _service = MediaService();

  final items = <MediaItem>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadMedia();
  }

  Future<void> loadMedia() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final list = await _service
          .fetchMedia(
            albumId: filterAlbumId,
            categoryId: filterCategoryId,
          )
          .timeout(const Duration(seconds: 25));
      items.value = list;
    } on TimeoutException {
      errorMessage.value =
          'Il caricamento impiega troppo tempo. Controlla la rete e riprova.';
    } on MediaException catch (e) {
      errorMessage.value = e.message;
    } on DioException catch (e) {
      errorMessage.value = XenforoApi.connectionMessage(e);
    } catch (_) {
      errorMessage.value = 'Impossibile caricare i media.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshAll() => loadMedia();

  void openDetail(MediaItem item) {
    Get.to(() => MediaDetailPage(mediaId: item.mediaId));
  }

  Future<void> react(MediaItem item, {int reactionId = 1}) async {
    try {
      await _service.react(
        mediaId: item.mediaId,
        authorUserId: item.author?.userId,
        reactionId: reactionId,
      );
      await loadMedia();
    } on MediaException catch (e) {
      AppToast.error(AppToast.mapApiError(e.message));
    } on DioException catch (e) {
      AppToast.error(XenforoApi.connectionMessage(e));
    }
  }

  void openAlbumFilter(MediaItem item) {
    final albumId = item.album?.albumId;
    if (albumId == null || albumId <= 0) return;
    Get.to(
      () => MediaListPage(
        filterAlbumId: albumId,
        pageTitle: item.album?.title ?? 'Album',
      ),
    );
  }

  void openCategoryFilter(MediaItem item) {
    final categoryId = item.category?.categoryId;
    if (categoryId == null || categoryId <= 0) return;
    Get.to(
      () => MediaListPage(
        filterCategoryId: categoryId,
        pageTitle: item.category?.title ?? 'Categoria',
      ),
    );
  }

  void openAuthorProfile(MediaItem item) =>
      OmnifeedNavigation.openUserProfile(item.author?.userId);
}

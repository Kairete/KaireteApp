import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/utils/app_toast.dart';
import 'package:kairete/features/app_widgets/utils/app_widget_placements.dart';
import 'package:kairete/features/app_widgets/utils/app_widgets_list_mixin.dart';
import 'package:kairete/features/media/models/media_album_profile.dart';
import 'package:kairete/features/media/models/media_item.dart';
import 'package:kairete/features/media/pages/media_detail_page.dart';
import 'package:kairete/features/media/pages/media_list_page.dart';
import 'package:kairete/features/media/services/media_service.dart';
import 'package:kairete/features/media/utils/media_navigation.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_navigation.dart';

class MediaListController extends GetxController with AppWidgetsListMixin {
  MediaListController({
    this.filterAlbumId,
    this.filterCategoryId,
    this.tenantMapped = false,
  });

  final int? filterAlbumId;
  final int? filterCategoryId;
  final bool tenantMapped;
  final MediaService _service = MediaService();

  final items = <MediaItem>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final albumProfile = Rxn<MediaAlbumProfile>();
  final isWatched = false.obs;
  final canWatch = true.obs;
  final watchLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMedia();
    if (filterAlbumId != null) {
      loadAlbumProfile();
    }
  }

  Future<void> loadAlbumProfile() async {
    final albumId = filterAlbumId;
    if (albumId == null) return;
    try {
      final profile = await _service
          .fetchAlbumProfile(albumId)
          .timeout(const Duration(seconds: 15));
      albumProfile.value = profile;
      isWatched.value = profile.isWatched;
      canWatch.value = true;
    } catch (_) {
      canWatch.value = true;
    }
  }

  Future<void> toggleWatch() async {
    final albumId = filterAlbumId;
    if (albumId == null || watchLoading.value) return;
    watchLoading.value = true;
    final stop = isWatched.value;
    try {
      final watched = await _service.watchAlbum(albumId, stop: stop);
      isWatched.value = watched;
      AppToast.success(watched ? 'Ti sei unito all\'album.' : 'Hai lasciato l\'album.');
    } on MediaException catch (e) {
      AppToast.error(AppToast.mapApiError(e.message));
    } on DioException catch (e) {
      AppToast.error(XenforoApi.connectionMessage(e));
    } catch (_) {
      AppToast.error('Impossibile aggiornare lo stato join.');
    } finally {
      watchLoading.value = false;
    }
  }

  Future<void> loadMedia() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final list = tenantMapped
          ? await _service
              .fetchTenantMappedMedia()
              .timeout(const Duration(seconds: 25))
          : await _service
              .fetchMedia(
                albumId: filterAlbumId,
                categoryId: filterCategoryId,
              )
              .timeout(const Duration(seconds: 25));
      items.value = list;
      await loadAppWidgets(
        AppWidgetPlacements.mediaList,
        contextId: filterAlbumId ?? filterCategoryId,
        forceRefresh: true,
      );
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

  Future<void> refreshAll() async {
    await Future.wait([
      loadMedia(),
      if (filterAlbumId != null) loadAlbumProfile(),
    ]);
  }

  void openDetail(MediaItem item) {
    Get.to(() => MediaDetailPage(mediaId: item.mediaId));
  }

  void openViewer(MediaItem item) => MediaNavigation.openViewer(item);

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
        pageTitle: item.albumHeaderLabel ?? item.album?.title ?? 'Album',
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
      OmnifeedNavigation.openUserProfile(
        item.author?.userId,
        username: item.author?.username,
      );
}

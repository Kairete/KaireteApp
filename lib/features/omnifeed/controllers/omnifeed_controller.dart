import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/services/content_owner_service.dart';
import 'package:kairete/core/utils/app_toast.dart';
import 'package:kairete/core/utils/content_edit_helper.dart';
import 'package:kairete/features/auth/controllers/auth_flow_controller.dart';
import 'package:kairete/features/blog/pages/blog_compose_page.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/features/omnifeed/pages/omnifeed_compose_page.dart';
import 'package:kairete/features/omnifeed/services/omnifeed_service.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_navigation.dart';
import 'package:kairete/features/omnifeed/widgets/omnifeed_content_filters.dart';

class OmnifeedController extends GetxController {
  final OmnifeedService _service = OmnifeedService();
  final ContentOwnerService _ownerService = ContentOwnerService();

  /// Garantisce che il controller esista (GetX a volte lo rimuove navigando).
  static OmnifeedController ensure() {
    if (!Get.isRegistered<OmnifeedController>()) {
      Get.put(OmnifeedController(), permanent: true);
    }
    return Get.find<OmnifeedController>();
  }

  final items = <OmnifeedItem>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final feedModeIndex = 0.obs;
  final sortByLastComment = false.obs;

  String get _feedMode =>
      OmnifeedContentFilters.modes[feedModeIndex.value.clamp(0, 3)];

  String get _feedSort => sortByLastComment.value ? 'last_activity' : 'post_date';

  @override
  void onInit() {
    super.onInit();
    loadFeed();
  }

  void setFeedModeIndex(int index) {
    if (feedModeIndex.value == index) return;
    feedModeIndex.value = index;
    loadFeed();
  }

  void setSortByLastComment(bool value) {
    if (sortByLastComment.value == value) return;
    sortByLastComment.value = value;
    loadFeed();
  }

  Future<void> loadFeed() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final feed = await _service
          .fetchFeed(mode: _feedMode, sort: _feedSort)
          .timeout(
        const Duration(seconds: 25),
        onTimeout: () => throw TimeoutException('feed'),
      );
      items.value = feed.items;
    } on TimeoutException {
      errorMessage.value =
          'Il feed impiega troppo tempo. Controlla la rete e riprova.';
    } on OmnifeedException catch (e) {
      errorMessage.value = e.message;
    } on DioException catch (e) {
      errorMessage.value = XenforoApi.connectionMessage(e);
    } catch (_) {
      errorMessage.value = 'Impossibile caricare il feed.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> react(OmnifeedItem item, {int reactionId = 1}) async {
    try {
      final action = await _service.reactToItem(item: item, reactionId: reactionId);
      _bumpScore(item.itemId, action);
      AppToast.success(
        action == 'delete' ? 'Reazione rimossa.' : 'Reazione inviata.',
      );
      await loadFeed();
    } on OmnifeedException catch (e) {
      AppToast.error(AppToast.mapApiError(e.message));
    } on DioException catch (e) {
      AppToast.error(XenforoApi.connectionMessage(e));
    }
  }

  void _bumpScore(int itemId, String action) {
    final index = items.indexWhere((entry) => entry.itemId == itemId);
    if (index < 0) return;
    final delta = action == 'delete' ? -1 : 1;
    final current = items[index];
    final next = current.reactionScore + delta;
    items[index] = current.copyWith(reactionScore: next < 0 ? 0 : next);
    items.refresh();
  }

  void openDetail(OmnifeedItem item) => OmnifeedNavigation.openDetail(item);

  void openAuthor(OmnifeedItem item) => OmnifeedNavigation.openAuthor(item);

  void openBlog(OmnifeedItem item) => OmnifeedNavigation.openBlog(item);

  void openForum(OmnifeedItem item) => OmnifeedNavigation.openForum(item);

  Future<void> openCompose() async {
    final created = await Get.to<bool>(() => const OmnifeedComposePage());
    if (created == true) await loadFeed();
  }

  Future<bool> openBlogCompose() async {
    final created = await Get.to<bool>(() => const BlogComposePage());
    if (created == true) {
      await loadFeed();
      return true;
    }
    return false;
  }

  bool isOwnedByCurrentUser(OmnifeedItem item) {
    if (!Get.isRegistered<AuthFlowController>()) return false;
    final userId = Get.find<AuthFlowController>().currentUser.value?.userId;
    if (userId == null || userId <= 0) return false;
    return item.author?.userId == userId;
  }

  Future<void> editItem(OmnifeedItem item) async {
    final context = Get.context;
    if (context == null) return;
    final result = await showContentEditDialog(context, item: item);
    if (result == null) return;
    try {
      await _ownerService.updateItem(
        item: item,
        title: result.title,
        message: result.message,
      );
      AppToast.success('Contenuto aggiornato.');
      await loadFeed();
    } on ContentOwnerException catch (e) {
      AppToast.error(AppToast.mapApiError(e.message));
    } on DioException catch (e) {
      AppToast.error(XenforoApi.connectionMessage(e));
    }
  }

  Future<void> deleteItem(OmnifeedItem item) async {
    final context = Get.context;
    if (context == null) return;
    final confirmed = await confirmDeleteContent(context);
    if (!confirmed) return;
    try {
      await _ownerService.deleteItem(item);
      AppToast.success('Contenuto eliminato.');
      await loadFeed();
    } on ContentOwnerException catch (e) {
      AppToast.error(AppToast.mapApiError(e.message));
    } on DioException catch (e) {
      AppToast.error(XenforoApi.connectionMessage(e));
    }
  }
}

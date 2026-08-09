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
import 'package:kairete/features/omnifeed/services/omnifeed_service.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_navigation.dart';
import 'package:kairete/features/tagfeed/services/tagfeed_service.dart';

class TagFeedController extends GetxController {
  TagFeedController({required this.tag});

  final String tag;
  final TagFeedService _service = TagFeedService();
  final ContentOwnerService _ownerService = ContentOwnerService();

  final items = <OmnifeedItem>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final errorMessage = ''.obs;
  final tagLabel = ''.obs;
  final totalCount = 0.obs;

  int _currentPage = 1;
  int _lastPage = 1;

  @override
  void onInit() {
    super.onInit();
    loadFeed();
  }

  Future<void> loadFeed() async {
    _currentPage = 1;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final page = await _service.fetchByTag(tag: tag).timeout(
        const Duration(seconds: 25),
        onTimeout: () => throw TimeoutException('tag-feed'),
      );
      items.value = page.items;
      tagLabel.value = page.tagLabel.isNotEmpty ? page.tagLabel : tag;
      totalCount.value = page.total;
      _lastPage = page.lastPage;
    } on TimeoutException {
      errorMessage.value =
          'Il caricamento impiega troppo tempo. Controlla la rete e riprova.';
    } on OmnifeedException catch (e) {
      errorMessage.value = e.message;
    } on DioException catch (e) {
      errorMessage.value = XenforoApi.connectionMessage(e);
    } catch (_) {
      errorMessage.value = 'Impossibile caricare i contenuti per questo tag.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || _currentPage >= _lastPage) return;
    isLoadingMore.value = true;
    try {
      final nextPage = _currentPage + 1;
      final page = await _service.fetchByTag(tag: tag, page: nextPage);
      items.addAll(page.items);
      _currentPage = nextPage;
      _lastPage = page.lastPage;
    } catch (_) {
      AppToast.error('Impossibile caricare altri contenuti.');
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> react(OmnifeedItem item, {int reactionId = 1}) async {
    try {
      final action =
          await _service.reactToItem(item: item, reactionId: reactionId);
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

  Future<void> toggleBookmark(OmnifeedItem item) async {
    try {
      final bookmarked = await _service.toggleBookmark(item);
      _setBookmarked(item.itemId, bookmarked);
      AppToast.success(bookmarked ? 'Salvato.' : 'Rimosso dai salvati.');
    } on OmnifeedException catch (e) {
      AppToast.error(AppToast.mapApiError(e.message));
    } on DioException catch (e) {
      AppToast.error(XenforoApi.connectionMessage(e));
    }
  }

  void _setBookmarked(int itemId, bool bookmarked) {
    final index = items.indexWhere((entry) => entry.itemId == itemId);
    if (index < 0) return;
    items[index] = items[index].copyWith(isBookmarked: bookmarked);
    items.refresh();
  }

  /// Aggiorna [shareCount] e, se presente, inserisce il post creato in cima.
  void applyShareResult(int itemId, FeedShareApiResult result) {
    final index = items.indexWhere((entry) => entry.itemId == itemId);
    if (index >= 0) {
      items[index] = items[index].copyWith(shareCount: result.shareCount);
    }
    final created = result.createdItem;
    if (created != null) {
      prependItem(created);
    } else {
      items.refresh();
    }
  }

  void prependItem(OmnifeedItem item) {
    if (item.itemId <= 0) return;
    final index = items.indexWhere((entry) => entry.itemId == item.itemId);
    if (index >= 0) {
      items[index] = item;
    } else {
      items.insert(0, item);
    }
    items.refresh();
  }

  void openDetail(OmnifeedItem item) => OmnifeedNavigation.openDetail(item);
  void openAuthor(OmnifeedItem item) => OmnifeedNavigation.openAuthor(item);
  void openBlog(OmnifeedItem item) => OmnifeedNavigation.openBlog(item);
  void openForum(OmnifeedItem item) => OmnifeedNavigation.openForum(item);

  bool isOwnedByCurrentUser(OmnifeedItem item) {
    if (!Get.isRegistered<AuthFlowController>()) return false;
    final userId = Get.find<AuthFlowController>().currentUser.value?.userId;
    if (userId == null || userId <= 0) return false;
    return item.author?.userId == userId;
  }

  Future<void> editItem(OmnifeedItem item) async {
    if (item.contentType == 'ubs_blog_entry') {
      final updated = await Get.to<bool>(
        () => BlogComposePage(editEntryId: item.contentId),
      );
      if (updated == true) await loadFeed();
      return;
    }
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

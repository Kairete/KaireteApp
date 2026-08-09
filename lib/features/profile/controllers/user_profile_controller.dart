import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/utils/app_toast.dart';
import 'package:kairete/core/utils/attachment_picker.dart';
import 'package:kairete/features/app_widgets/utils/app_widget_placements.dart';
import 'package:kairete/features/app_widgets/utils/app_widgets_list_mixin.dart';
import 'package:kairete/features/auth/controllers/auth_flow_controller.dart';
import 'package:kairete/features/blog/pages/blog_compose_page.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/core/services/content_owner_service.dart';
import 'package:kairete/core/utils/content_edit_helper.dart';
import 'package:kairete/features/media/models/media_item.dart';
import 'package:kairete/features/media/pages/media_detail_page.dart';
import 'package:kairete/features/media/services/media_service.dart';
import 'package:kairete/features/omnifeed/pages/omnifeed_compose_page.dart';
import 'package:kairete/features/omnifeed/services/omnifeed_service.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_navigation.dart';
import 'package:kairete/features/profile/models/user_profile.dart';
import 'package:kairete/features/profile/pages/user_follow_list_page.dart';
import 'package:kairete/features/profile/services/profile_service.dart';

enum ProfileTab { feed, media, about }

class UserProfileController extends GetxController with AppWidgetsListMixin {
  UserProfileController({required this.userId});

  final int userId;
  final ProfileService _profileService = ProfileService();
  final OmnifeedService _omnifeedService = OmnifeedService();
  final MediaService _mediaService = MediaService();
  final ContentOwnerService _ownerService = ContentOwnerService();

  final profile = Rxn<UserProfile>();
  final items = <OmnifeedItem>[].obs;
  final mediaItems = <MediaItem>[].obs;
  final selectedTab = ProfileTab.feed.obs;
  final isLoading = true.obs;
  final isFeedLoading = false.obs;
  final isMediaLoading = false.obs;
  final errorMessage = ''.obs;
  final followLoading = false.obs;
  final coverLoading = false.obs;
  final reportLoading = false.obs;

  bool _mediaLoaded = false;

  bool get isCurrentUser {
    if (!Get.isRegistered<AuthFlowController>()) return false;
    final sessionId = Get.find<AuthFlowController>().currentUser.value?.userId;
    return sessionId != null && sessionId == userId;
  }

  bool get showCompose =>
      isCurrentUser && selectedTab.value == ProfileTab.feed;

  bool isOwnedByCurrentUser(OmnifeedItem item) {
    if (!Get.isRegistered<AuthFlowController>()) return false;
    final sessionId = Get.find<AuthFlowController>().currentUser.value?.userId;
    if (sessionId == null || sessionId <= 0) return false;
    return item.author?.userId == sessionId;
  }

  bool canEditItem(OmnifeedItem item) => isOwnedByCurrentUser(item);

  /// Autore oppure titolare del profilo (solo profile post sulla propria bacheca).
  bool canDeleteItem(OmnifeedItem item) {
    if (isOwnedByCurrentUser(item)) return true;
    return isCurrentUser && item.resolvedContentType == 'profile_post';
  }

  bool canShowOwnerActions(OmnifeedItem item) =>
      canEditItem(item) || canDeleteItem(item);

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  void selectTab(ProfileTab tab) {
    if (selectedTab.value == tab) return;
    selectedTab.value = tab;
    if (tab == ProfileTab.media && !_mediaLoaded) {
      loadMedia();
    }
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final user = await _profileService
          .fetchUser(userId)
          .timeout(const Duration(seconds: 25));
      profile.value = user;
      _mediaLoaded = false;
      mediaItems.clear();
      await loadFeed();
      if (selectedTab.value == ProfileTab.media) {
        await loadMedia();
      }
    } on TimeoutException {
      errorMessage.value = 'Il profilo impiega troppo tempo. Riprova.';
    } on ProfileException catch (e) {
      errorMessage.value = e.message;
    } on DioException catch (e) {
      errorMessage.value = XenforoApi.connectionMessage(e);
    } catch (_) {
      errorMessage.value = 'Impossibile caricare il profilo.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadFeed() async {
    isFeedLoading.value = true;
    try {
      final feed = await _profileService
          .fetchUserFeed(userId: userId)
          .timeout(const Duration(seconds: 25));
      items.value = feed.items;
      await _applyProfileHighlightFlags();
      await loadAppWidgets(
        AppWidgetPlacements.userProfileFeed,
        contextId: userId,
        forceRefresh: true,
      );
    } on ProfileException catch (e) {
      AppToast.error(AppToast.mapApiError(e.message));
    } on DioException catch (e) {
      AppToast.error(XenforoApi.connectionMessage(e));
    } catch (_) {
      AppToast.error('Impossibile caricare il feed del profilo.');
    } finally {
      isFeedLoading.value = false;
    }
  }

  Future<void> loadMedia() async {
    isMediaLoading.value = true;
    try {
      final list = await _mediaService
          .fetchMedia(userId: userId, limit: 50)
          .timeout(const Duration(seconds: 25));
      mediaItems.assignAll(list);
      _mediaLoaded = true;
    } on MediaException catch (e) {
      AppToast.error(AppToast.mapApiError(e.message));
    } on DioException catch (e) {
      AppToast.error(XenforoApi.connectionMessage(e));
    } catch (_) {
      AppToast.error('Impossibile caricare i media.');
    } finally {
      isMediaLoading.value = false;
    }
  }

  void openFollowing() {
    final p = profile.value;
    Get.to(
      () => UserFollowListPage(
        userId: userId,
        username: p?.username ?? '',
        mode: UserFollowListMode.following,
      ),
    );
  }

  void openFollowers() {
    final p = profile.value;
    Get.to(
      () => UserFollowListPage(
        userId: userId,
        username: p?.username ?? '',
        mode: UserFollowListMode.followers,
      ),
    );
  }

  void openMediaDetail(MediaItem item) {
    Get.to(() => MediaDetailPage(mediaId: item.mediaId));
  }

  Future<void> toggleFollow() async {
    final current = profile.value;
    if (current == null || followLoading.value) return;
    if (isCurrentUser) return;
    // Mostra/azioni: puoi unfollow se già segui, o follow se permesso.
    if (!current.isFollowed && !current.canFollow) return;
    followLoading.value = true;
    final stop = current.isFollowed;
    try {
      final result = await _profileService.followUser(userId, stop: stop);
      var followers = current.followersCount;
      if (result.followersCount != null) {
        followers = result.followersCount!;
      } else if (result.followed && !current.isFollowed) {
        followers += 1;
      } else if (!result.followed && current.isFollowed) {
        followers = followers > 0 ? followers - 1 : 0;
      }
      profile.value = current.copyWith(
        isFollowed: result.followed,
        followersCount: followers,
      );
      AppToast.success(
        result.followed ? 'Utente seguito.' : 'Follow rimosso.',
      );
    } on ProfileException catch (e) {
      AppToast.error(AppToast.mapApiError(e.message));
    } on DioException catch (e) {
      AppToast.error(XenforoApi.connectionMessage(e));
    } catch (_) {
      AppToast.error('Impossibile aggiornare il follow.');
    } finally {
      followLoading.value = false;
    }
  }

  Future<void> editCover() async {
    final current = profile.value;
    if (current == null || !current.canEditBanner || !isCurrentUser) return;
    final context = Get.context;
    if (context == null) return;

    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_outlined),
                title: const Text('Cambia cover'),
                onTap: () => Navigator.pop(ctx, 'upload'),
              ),
              if (current.bannerUrl != null && current.bannerUrl!.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Rimuovi cover'),
                  onTap: () => Navigator.pop(ctx, 'delete'),
                ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Annulla'),
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
    if (action == 'upload') {
      await _uploadCover();
    } else if (action == 'delete') {
      await _deleteCover();
    }
  }

  Future<void> _uploadCover() async {
    if (coverLoading.value) return;
    final picked = await pickAttachments(allowMultiple: false);
    if (picked.isEmpty) return;
    final oldBanner = profile.value?.bannerUrl;
    coverLoading.value = true;
    try {
      final file = picked.first;
      final updated = await _profileService.uploadBanner(
        filePath: file.path,
        filename: file.displayName,
      );
      if (oldBanner != null && oldBanner.isNotEmpty) {
        await CachedNetworkImage.evictFromCache(oldBanner);
      }
      profile.value = updated;
      AppToast.success('Cover aggiornata.');
    } on ProfileException catch (e) {
      // Alcune risposte non includono user: ricarica.
      if (e.message.contains('ricarica')) {
        await loadAll();
        AppToast.success('Cover aggiornata.');
      } else {
        AppToast.error(AppToast.mapApiError(e.message));
      }
    } on DioException catch (e) {
      AppToast.error(XenforoApi.connectionMessage(e));
    } catch (_) {
      AppToast.error('Impossibile aggiornare la cover.');
    } finally {
      coverLoading.value = false;
    }
  }

  Future<void> _deleteCover() async {
    if (coverLoading.value) return;
    final oldBanner = profile.value?.bannerUrl;
    coverLoading.value = true;
    try {
      final updated = await _profileService.deleteBanner();
      if (oldBanner != null && oldBanner.isNotEmpty) {
        await CachedNetworkImage.evictFromCache(oldBanner);
      }
      if (updated != null) {
        profile.value = updated;
      } else {
        profile.value = profile.value?.copyWith(clearBanner: true);
      }
      AppToast.success('Cover rimossa.');
    } on ProfileException catch (e) {
      AppToast.error(AppToast.mapApiError(e.message));
    } on DioException catch (e) {
      AppToast.error(XenforoApi.connectionMessage(e));
    } catch (_) {
      AppToast.error('Impossibile rimuovere la cover.');
    } finally {
      coverLoading.value = false;
    }
  }

  Future<void> reportUser() async {
    final current = profile.value;
    if (current == null || !current.canReport || isCurrentUser) return;
    final context = Get.context;
    if (context == null) return;

    final messageCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Segnala ${current.username}'),
          content: TextField(
            controller: messageCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Motivo della segnalazione…',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annulla'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Invia'),
            ),
          ],
        );
      },
    );
    final message = messageCtrl.text.trim();
    messageCtrl.dispose();
    if (ok != true) return;
    if (message.isEmpty) {
      AppToast.error('Inserisci un motivo.');
      return;
    }

    reportLoading.value = true;
    try {
      await _profileService.reportUser(userId, message: message);
      AppToast.success('Segnalazione inviata. Grazie.');
    } on ProfileException catch (e) {
      AppToast.error(AppToast.mapApiError(e.message));
    } on DioException catch (e) {
      AppToast.error(XenforoApi.connectionMessage(e));
    } catch (_) {
      AppToast.error('Impossibile inviare la segnalazione.');
    } finally {
      reportLoading.value = false;
    }
  }

  Future<void> react(OmnifeedItem item, {int reactionId = 1}) async {
    try {
      final action =
          await _omnifeedService.reactToItem(item: item, reactionId: reactionId);
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
      final bookmarked = await _omnifeedService.toggleBookmark(item);
      _setBookmarked(item.itemId, bookmarked);
      AppToast.success(bookmarked ? 'Salvato.' : 'Rimosso dai salvati.');
    } on OmnifeedException catch (e) {
      AppToast.error(AppToast.mapApiError(e.message));
    } on DioException catch (e) {
      AppToast.error(XenforoApi.connectionMessage(e));
    }
  }

  Future<void> toggleHighlight(OmnifeedItem item) async {
    try {
      final scope = (item.highlightScope ?? '').trim().isNotEmpty
          ? item.highlightScope!.trim()
          : 'owner:profile:$userId';
      final highlighted = await _omnifeedService.toggleHighlight(
        item.copyWith(
          highlightScope: scope,
          canHighlight: true,
        ),
      );
      _setHighlighted(item.itemId, highlighted);
      AppToast.success(
        highlighted ? 'Fissato in alto sul profilo.' : 'Tolto dall\'alto.',
      );
    } on OmnifeedException catch (e) {
      AppToast.error(AppToast.mapApiError(e.message));
    } on DioException catch (e) {
      AppToast.error(XenforoApi.connectionMessage(e));
    }
  }

  Future<void> _applyProfileHighlightFlags() async {
    final scope = 'owner:profile:$userId';
    try {
      final page = await _omnifeedService.fetchHighlights(scope);
      final pinnedIds = page.itemIds;
      final pinned = pinnedIds.toSet();
      var next = items.map((item) {
        final isProfilePost = item.resolvedContentType == 'profile_post';
        if (!isProfilePost) {
          return item.copyWith(isHighlighted: false);
        }
        final isPinned = pinned.contains(item.itemId) || item.isHighlighted;
        return item.copyWith(
          canHighlight: page.canManage || item.canHighlight || isPinned,
          highlightScope: item.highlightScope ?? scope,
          isHighlighted: isPinned,
        );
      }).toList();
      if (pinnedIds.isNotEmpty) {
        next = OmnifeedService.pinByItemIds(next, pinnedIds);
      } else {
        next = OmnifeedService.sortHubItems(next, 'post_date');
      }
      items.assignAll(next);
    } catch (_) {
      items.assignAll(
        OmnifeedService.sortHubItems(items.toList(), 'post_date'),
      );
    }
  }

  void _setBookmarked(int itemId, bool bookmarked) {
    final index = items.indexWhere((entry) => entry.itemId == itemId);
    if (index < 0) return;
    items[index] = items[index].copyWith(isBookmarked: bookmarked);
    items.refresh();
  }

  void _setHighlighted(int itemId, bool highlighted) {
    final index = items.indexWhere((entry) => entry.itemId == itemId);
    if (index < 0) return;
    items[index] = items[index].copyWith(
      isHighlighted: highlighted,
      highlightScope: items[index].highlightScope ?? 'owner:profile:$userId',
    );
    items.assignAll(
      OmnifeedService.sortHubItems(items.toList(), 'post_date'),
    );
  }

  /// Aggiorna [shareCount] e, se presente, inserisce il post creato in cima.
  void applyShareResult(int itemId, FeedShareApiResult result) {
    final index = items.indexWhere((entry) => entry.itemId == itemId);
    if (index >= 0) {
      items[index] = items[index].copyWith(shareCount: result.shareCount);
    }
    final created = result.createdItem;
    if (created != null) {
      _prependItem(created);
    } else {
      items.refresh();
    }
  }

  Future<void> openCompose() async {
    if (!isCurrentUser) return;
    final created = await Get.to<OmnifeedItem?>(() => const OmnifeedComposePage());
    if (created != null) {
      _prependItem(created);
    }
    await loadFeed();
  }

  void _prependItem(OmnifeedItem item) {
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

  Future<void> editItem(OmnifeedItem item) async {
    if (!canEditItem(item)) return;
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
    if (!canDeleteItem(item)) return;
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

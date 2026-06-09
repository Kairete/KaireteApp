import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/utils/app_toast.dart';
import 'package:kairete/features/auth/controllers/auth_flow_controller.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/core/services/content_owner_service.dart';
import 'package:kairete/core/utils/content_edit_helper.dart';
import 'package:kairete/features/omnifeed/pages/omnifeed_compose_page.dart';
import 'package:kairete/features/omnifeed/services/omnifeed_service.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_navigation.dart';
import 'package:kairete/features/profile/models/user_profile.dart';
import 'package:kairete/features/profile/services/profile_service.dart';

class UserProfileController extends GetxController {
  UserProfileController({required this.userId});

  final int userId;
  final ProfileService _profileService = ProfileService();
  final OmnifeedService _omnifeedService = OmnifeedService();
  final ContentOwnerService _ownerService = ContentOwnerService();

  final profile = Rxn<UserProfile>();
  final items = <OmnifeedItem>[].obs;
  final isLoading = true.obs;
  final isFeedLoading = false.obs;
  final errorMessage = ''.obs;
  final followLoading = false.obs;

  bool get isCurrentUser {
    if (!Get.isRegistered<AuthFlowController>()) return false;
    final sessionId = Get.find<AuthFlowController>().currentUser.value?.userId;
    return sessionId != null && sessionId == userId;
  }

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final user = await _profileService
          .fetchUser(userId)
          .timeout(const Duration(seconds: 25));
      profile.value = user;
      await loadFeed();
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

  Future<void> toggleFollow() async {
    final current = profile.value;
    if (current == null || !current.canFollow || followLoading.value) return;
    followLoading.value = true;
    final stop = current.isFollowed;
    try {
      final followed = await _profileService.followUser(userId, stop: stop);
      profile.value = current.copyWith(isFollowed: followed);
      AppToast.success(followed ? 'Utente seguito.' : 'Follow rimosso.');
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

  Future<void> openCompose() async {
    if (!isCurrentUser) return;
    final created = await Get.to<bool>(() => const OmnifeedComposePage());
    if (created == true) await loadFeed();
  }

  void openDetail(OmnifeedItem item) => OmnifeedNavigation.openDetail(item);

  void openAuthor(OmnifeedItem item) => OmnifeedNavigation.openAuthor(item);

  void openBlog(OmnifeedItem item) => OmnifeedNavigation.openBlog(item);

  void openForum(OmnifeedItem item) => OmnifeedNavigation.openForum(item);

  Future<void> editItem(OmnifeedItem item) async {
    if (!isCurrentUser) return;
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
    if (!isCurrentUser) return;
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

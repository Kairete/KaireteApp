import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/utils/app_toast.dart';
import 'package:kairete/features/forum/models/forum_thread.dart';
import 'package:kairete/features/forum/pages/thread_create_page.dart';
import 'package:kairete/features/forum/pages/thread_detail_page.dart';
import 'package:kairete/features/forum/services/forum_service.dart';
import 'package:kairete/features/forum/utils/forum_react_guard.dart';

class ForumThreadListController extends GetxController {
  ForumThreadListController({
    required this.forumId,
    required this.forumTitle,
  });

  final int forumId;
  final String forumTitle;
  final ForumService _service = ForumService();

  final items = <ForumThread>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final reactingThreadId = Rxn<int>();
  final isWatched = false.obs;
  final watchLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadThreads();
    loadWatchState();
  }

  Future<void> loadWatchState() async {
    try {
      final state = await _service
          .fetchForumWatchState(forumId)
          .timeout(const Duration(seconds: 15));
      isWatched.value = state.isWatched;
    } catch (_) {
      // Watch is optional; list still works without it.
    }
  }

  Future<void> toggleWatch() async {
    if (watchLoading.value) return;
    watchLoading.value = true;
    final stop = isWatched.value;
    try {
      final watched = await _service.watchForum(forumId, stop: stop);
      isWatched.value = watched;
      AppToast.success(watched ? 'Forum seguito.' : 'Watch rimosso.');
    } on ForumException catch (e) {
      AppToast.error(AppToast.mapApiError(e.message));
    } on DioException catch (e) {
      AppToast.error(XenforoApi.connectionMessage(e));
    } catch (_) {
      AppToast.error('Impossibile aggiornare il watch.');
    } finally {
      watchLoading.value = false;
    }
  }

  Future<void> loadThreads() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      items.value = await _service
          .fetchThreads(forumId)
          .timeout(const Duration(seconds: 25));
    } on TimeoutException {
      errorMessage.value =
          'Il caricamento impiega troppo tempo. Controlla la rete e riprova.';
    } on ForumException catch (e) {
      errorMessage.value = e.message;
    } on DioException catch (e) {
      errorMessage.value = XenforoApi.connectionMessage(e);
    } catch (_) {
      errorMessage.value = 'Impossibile caricare le discussioni.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> react(ForumThread thread, {int reactionId = 1}) async {
    final postId = thread.firstPostId;
    if (postId == null || postId <= 0) {
      ForumReactGuard.notifyBlocked('Post non disponibile.');
      return;
    }

    final userId = await ForumReactGuard.currentUserId();
    final blocked = ForumReactGuard.blockMessage(
      userId: userId,
      contentAuthorId: thread.author?.userId,
    );
    if (blocked != null) {
      ForumReactGuard.notifyBlocked(blocked);
      return;
    }

    if (reactingThreadId.value == thread.threadId) return;
    reactingThreadId.value = thread.threadId;
    try {
      final action = await _service.reactToPost(
        postId: postId,
        reactionId: reactionId,
      );
      await loadThreads();
      ForumReactGuard.notifySuccess(
        action == 'delete' ? 'Reazione rimossa.' : 'Reazione inviata.',
      );
    } on ForumException catch (e) {
      ForumReactGuard.notifyError(e.message);
    } on DioException catch (e) {
      ForumReactGuard.notifyError(XenforoApi.connectionMessage(e));
    } finally {
      reactingThreadId.value = null;
    }
  }

  void openDetail(ForumThread thread) {
    Get.to(
      () => ThreadDetailPage(
        threadId: thread.threadId,
        forumTitle: forumTitle,
      ),
    );
  }

  Future<void> openCreate() async {
    final created = await Get.to<bool>(
      () => ThreadCreatePage(
        forumId: forumId,
        forumTitle: forumTitle,
      ),
    );
    if (created == true) {
      await loadThreads();
    }
  }
}

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/utils/app_toast.dart';
import 'package:kairete/features/alerts/controllers/alerts_badge_controller.dart';
import 'package:kairete/features/alerts/models/user_alert.dart';
import 'package:kairete/features/alerts/services/alerts_service.dart';
import 'package:kairete/features/blog/pages/blog_detail_page.dart';
import 'package:kairete/features/forum/pages/thread_detail_page.dart';
import 'package:kairete/features/groups/pages/group_detail_page.dart';

class AlertsController extends GetxController {
  final AlertsService _service = AlertsService();

  final alerts = <UserAlert>[].obs;
  final isLoading = false.obs;
  final isMarkingAll = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAlerts();
  }

  Future<void> loadAlerts() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final page = await _service.fetchAlerts();
      alerts.value = page.alerts;
    } on AlertsException catch (e) {
      errorMessage.value = e.message;
    } on DioException catch (e) {
      errorMessage.value = XenforoApi.connectionMessage(e);
    } catch (_) {
      errorMessage.value = 'Impossibile caricare le notifiche.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAllRead() async {
    if (isMarkingAll.value || alerts.isEmpty) return;
    isMarkingAll.value = true;
    try {
      await _service.markAllRead();
      await loadAlerts();
      _refreshBadge();
      AppToast.success('Notifiche segnate come lette.');
    } on AlertsException catch (e) {
      AppToast.error(e.message);
    } on DioException catch (e) {
      AppToast.error(XenforoApi.connectionMessage(e));
    } finally {
      isMarkingAll.value = false;
    }
  }

  Future<void> openAlert(UserAlert alert) async {
    if (alert.alertId > 0) {
      try {
        await _service.markRead(alert.alertId);
        final index = alerts.indexWhere((a) => a.alertId == alert.alertId);
        if (index >= 0) {
          final current = alerts[index];
          final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          alerts[index] = UserAlert(
            alertId: current.alertId,
            action: current.action,
            alertText: current.alertText,
            alertUrl: current.alertUrl,
            contentType: current.contentType,
            contentId: current.contentId,
            eventDate: current.eventDate,
            readDate: now,
            viewDate: now,
            userId: current.userId,
            username: current.username,
            avatarUrl: current.avatarUrl,
          );
          alerts.refresh();
        }
        _refreshBadge();
      } catch (_) {
        // Navigazione comunque se il mark fallisce.
      }
    }

    final opened = await _navigateToContent(alert);
    if (!opened) {
      AppToast.error('Contenuto non disponibile nell\'app.');
    }
  }

  Future<bool> _navigateToContent(UserAlert alert) async {
    final contentId = alert.contentId;
    if (contentId == null || contentId <= 0) {
      return _navigateFromUrl(alert.alertUrl);
    }

    switch (alert.contentType) {
      case 'thread':
        Get.to(() => ThreadDetailPage(threadId: contentId));
        return true;
      case 'post':
        final threadId = await _service.resolveThreadIdForPost(contentId);
        if (threadId != null && threadId > 0) {
          Get.to(() => ThreadDetailPage(threadId: threadId));
          return true;
        }
        return _navigateFromUrl(alert.alertUrl);
      case 'ubs_blog_entry':
        Get.to(() => BlogDetailPage(entryId: contentId));
        return true;
      case 'tl_group_post':
      case 'social_group':
        Get.to(() => GroupDetailPage(groupId: contentId));
        return true;
      default:
        return _navigateFromUrl(alert.alertUrl);
    }
  }

  bool _navigateFromUrl(String? url) {
    if (url == null || url.trim().isEmpty) return false;

    final threadMatch = RegExp(r'/threads/[^/]+\.(\d+)').firstMatch(url);
    if (threadMatch != null) {
      final threadId = int.tryParse(threadMatch.group(1)!);
      if (threadId != null && threadId > 0) {
        Get.to(() => ThreadDetailPage(threadId: threadId));
        return true;
      }
    }

    final blogMatch = RegExp(r'/blog-entries/[^/]+\.(\d+)').firstMatch(url);
    if (blogMatch != null) {
      final entryId = int.tryParse(blogMatch.group(1)!);
      if (entryId != null && entryId > 0) {
        Get.to(() => BlogDetailPage(entryId: entryId));
        return true;
      }
    }

    final groupMatch = RegExp(r'/social-groups/[^/]+\.(\d+)').firstMatch(url);
    if (groupMatch != null) {
      final groupId = int.tryParse(groupMatch.group(1)!);
      if (groupId != null && groupId > 0) {
        Get.to(() => GroupDetailPage(groupId: groupId));
        return true;
      }
    }

    return false;
  }

  void _refreshBadge() {
    if (Get.isRegistered<AlertsBadgeController>()) {
      Get.find<AlertsBadgeController>().refresh();
    }
  }
}

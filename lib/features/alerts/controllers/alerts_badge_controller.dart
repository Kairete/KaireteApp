import 'package:get/get.dart';
import 'package:kairete/features/alerts/services/alerts_service.dart';

/// Contatore notifiche non lette (badge campanella).
class AlertsBadgeController extends GetxController {
  final AlertsService _service = AlertsService();

  final unreadCount = 0.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    refresh();
  }

  Future<void> refresh() async {
    isLoading.value = true;
    try {
      unreadCount.value = await _service.fetchUnviewedCount();
    } catch (_) {
      // Silenzioso: la campanella resta senza badge se l'API non risponde.
    } finally {
      isLoading.value = false;
    }
  }
}

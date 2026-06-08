import 'package:get/get.dart';
import 'package:kairete/features/alerts/controllers/alerts_badge_controller.dart';
import 'package:kairete/features/auth/bindings/auth_binding.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    AuthBinding().dependencies();
    if (!Get.isRegistered<AlertsBadgeController>()) {
      Get.put(AlertsBadgeController());
    }
  }
}

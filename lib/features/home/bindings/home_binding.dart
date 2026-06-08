import 'package:get/get.dart';
import 'package:kairete/features/alerts/controllers/alerts_badge_controller.dart';
import 'package:kairete/features/auth/bindings/auth_binding.dart';
import 'package:kairete/features/omnifeed/controllers/omnifeed_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    AuthBinding().dependencies();
    if (!Get.isRegistered<OmnifeedController>()) {
      Get.put(OmnifeedController(), permanent: true);
    }
    if (!Get.isRegistered<AlertsBadgeController>()) {
      Get.put(AlertsBadgeController(), permanent: true);
    }
  }
}

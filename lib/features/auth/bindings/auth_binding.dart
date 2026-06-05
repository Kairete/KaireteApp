import 'package:get/get.dart';
import 'package:kairete/features/auth/controllers/auth_flow_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthFlowController>()) {
      Get.put(AuthFlowController(), permanent: true);
    }
  }
}

import 'package:get/get.dart';
import 'package:kairete/constants/app_routes.dart';

abstract class LoginNavigator {
  void nextStep();
  void toRegister();
}

class ILoginNavigator implements LoginNavigator {
  @override
  void nextStep() {}

  @override
  void toRegister() {
    Get.offAllNamed(Routes.register);
  }
}

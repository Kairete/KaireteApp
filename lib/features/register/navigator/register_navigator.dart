import 'package:get/get.dart';
import 'package:kairete/constants/app_routes.dart';

abstract class RegisterNavigator {
  void toLogin({dynamic data});
  void nextStep();
}

class IRegisterNavigator implements RegisterNavigator {
  @override
  void nextStep() {}

  @override
  void toLogin({data}) {
    Get.offAllNamed(Routes.login, arguments: data);
  }
}

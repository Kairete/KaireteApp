import 'package:flutter/material.dart';
import 'package:kairete/constants/app_routes.dart';
import 'package:kairete/constants/key_constant.dart';
import 'package:kairete/features/login/models/user_model.dart';
import 'package:kairete/features/login/navigator/login_navigator.dart';
import 'package:kairete/features/login/usecase/login_usecase.dart';
import 'package:get/get.dart';
import 'package:kairete/helper/user.dart';
import 'package:kairete/local/data_local.dart';

class LoginController extends GetxController {
  LoginUsecase usecase = ILoginUsecase();
  LoginNavigator navigator = ILoginNavigator();

  TextEditingController nameController = TextEditingController();
  TextEditingController passController = TextEditingController();

  var errorName = ''.obs;
  var errorPass = ''.obs;

  @override
  void onInit() {
    if (Get.arguments != null) {
      nameController.text = Get.arguments['email'];
    }
    test();
    super.onInit();
  }

  void test() {
    nameController.text = 'demo1';
    passController.text = 'abc123123@';
  }

  void onLogin() async {
    if (validateData()) {
      final body = {
        'login': nameController.text,
        'password': passController.text,
      };
      final json = await usecase.login(body: body);
      if (json != null) {
        final user = UserModel.fromJson(json);
        await LocalManager.instance
            .save(key: PreferencesKey.token, value: user.user?.userId);
        UserManager.instance.userId = user.user?.userId.toString();
        Get.offAllNamed(Routes.home);
      }
    }
  }

  bool validateData() {
    if (nameController.text.isEmpty) {
      errorName.value = 'required';
      return false;
    } else if (passController.text.isEmpty) {
      errorPass.value = 'required';
      return false;
    }
    return true;
  }

  void toRegister() {
    navigator.toRegister();
  }
}

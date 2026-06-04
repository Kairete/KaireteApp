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
  var loginError = ''.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    if (Get.arguments != null && Get.arguments['email'] != null) {
      nameController.text = Get.arguments['email'];
    }
    super.onInit();
  }

  void onLogin() async {
    loginError.value = '';
    if (!validateData()) return;

    isLoading.value = true;
    try {
      final body = {
        'login': nameController.text.trim(),
        'password': passController.text,
      };
      final json = await usecase.login(body: body);

      if (json == null) {
        loginError.value = 'Errore di connessione. Riprova.';
        return;
      }

      if (json['errors'] != null && json['errors'] is List) {
        final errors = json['errors'] as List;
        if (errors.isNotEmpty) {
          loginError.value =
              errors.first['message']?.toString() ?? 'Accesso non riuscito';
          return;
        }
      }

      final user = UserModel.fromJson(json);
      if (user.user?.userId == null) {
        loginError.value = 'Credenziali non valide';
        return;
      }

      await LocalManager.instance.save(
        key: PreferencesKey.token,
        value: user.user!.userId,
      );
      UserManager.instance.userId = user.user!.userId;
      Get.offAllNamed(Routes.home);
    } finally {
      isLoading.value = false;
    }
  }

  bool validateData() {
    errorName.value = '';
    errorPass.value = '';
    if (nameController.text.trim().isEmpty) {
      errorName.value = 'Obbligatorio';
      return false;
    }
    if (passController.text.isEmpty) {
      errorPass.value = 'Obbligatorio';
      return false;
    }
    return true;
  }

  void toRegister() {
    navigator.toRegister();
  }
}

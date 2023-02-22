import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/features/dashboard/screens/dashboard_screen.dart';
import 'package:kairete/features/login/screens/login_screen.dart';
import 'package:kairete/features/register/screens/register_screen.dart';
import 'package:kairete/helper/user.dart';

import '../constants/app_routes.dart';
import '../constants/key_constant.dart';
import '../local/data_local.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.login,
      page: () => LoginScreen(),
      // middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.register,
      page: () => RegisterScreen(),
    ),
    GetPage(
      name: Routes.home,
      page: () => DashboardScreen(),
    ),
  ];
}

class AuthMiddleware {
  static AuthMiddleware? _instance;

  AuthMiddleware._();

  static AuthMiddleware get instance => _instance ??= AuthMiddleware._();

  var currentState = '';

  Future getCurrenState() async {
    final token = await LocalManager.instance.read(key: PreferencesKey.token);
    UserManager.instance.userId = token;
    var state = (token == null ? Routes.login : Routes.home);
    currentState = state;
  }
}

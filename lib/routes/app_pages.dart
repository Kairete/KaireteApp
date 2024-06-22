import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/features/articles/screens/articles_detail_screen.dart';
import 'package:kairete/features/dashboard/screens/dashboard_screen.dart';
import 'package:kairete/features/login/screens/login_screen.dart';
import 'package:kairete/features/register/screens/register_screen.dart';
import 'package:kairete/features/tags/screens/tags_screen.dart';
import 'package:kairete/helper/user.dart';

import '../constants/app_routes.dart';
import '../constants/key_constant.dart';
import '../features/dashboard/controllers/dashboard_controller.dart';
import '../features/dashboard/models/style_model/css.dart';
import '../features/dashboard/usecase/master_data_usecase.dart';
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
    GetPage(
      name: Routes.tagsDetail,
      page: () => TagsScreen(),
    ),
    GetPage(
      name: Routes.articlesCate,
      page: () => ArticlesDetailScreen(),
    )
  ];
}

class AuthMiddleware {
  static AuthMiddleware? _instance;

  AuthMiddleware._();

  static AuthMiddleware get instance => _instance ??= AuthMiddleware._();

  var currentState = '';
  MasterDataUsecase masterDataUsecase = IMasterDataUsecase();

  Future getCurrenState() async {
    final token = await LocalManager.instance.read(key: PreferencesKey.token);
    UserManager.instance.userId = token;
    var state = (token == null ? Routes.login : Routes.home);
    currentState = state;
  }

  Future fetchStyle() async {
    final json = await masterDataUsecase.fetchStyle();
    Get.find<DashboardController>().style = Css.fromJson(json['css']);
    return true;
  }
}

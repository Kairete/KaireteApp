import 'package:get/get.dart';
import 'package:kairete/features/dashboard/screens/dashboard_screen.dart';
import 'package:kairete/features/login/screens/login_screen.dart';
import 'package:kairete/features/register/screens/register_screen.dart';

import '../constants/app_routes.dart';
import '../constants/key_constant.dart';
import '../local/data_local.dart';

class AppPages {
  static String getCurrenState() {
    final token = LocalManager.instance.read(key: PreferencesKey.token);
    var state = (token == null ? Routes.login : Routes.home);
    return state;
  }

  static final routes = [
    GetPage(name: Routes.login, page: () => LoginScreen()),
    GetPage(name: Routes.register, page: () => RegisterScreen()),
    GetPage(name: Routes.home, page: () => DashboardScreen()),
  ];
}

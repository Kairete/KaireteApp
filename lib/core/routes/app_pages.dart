import 'package:get/get.dart';
import 'package:kairete/core/routes/app_routes.dart';
import 'package:kairete/features/auth/pages/login_page.dart';
import 'package:kairete/features/auth/pages/register_page.dart';
import 'package:kairete/features/auth/pages/splash_page.dart';
import 'package:kairete/features/home/pages/home_shell_page.dart';
import 'package:kairete/features/profile/pages/profile_fields_page.dart';

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => const SplashPage()),
    GetPage(name: AppRoutes.login, page: () => LoginPage()),
    GetPage(name: AppRoutes.register, page: () => const RegisterPage()),
    GetPage(
      name: AppRoutes.profileFields,
      page: () => const ProfileFieldsPage(),
    ),
    GetPage(name: AppRoutes.home, page: () => HomeShellPage()),
  ];
}

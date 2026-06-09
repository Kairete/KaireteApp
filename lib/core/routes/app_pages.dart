import 'package:get/get.dart';
import 'package:kairete/core/routes/app_routes.dart';
import 'package:kairete/features/auth/bindings/auth_binding.dart';
import 'package:kairete/features/auth/pages/login_page.dart';
import 'package:kairete/features/auth/pages/register_page.dart';
import 'package:kairete/features/auth/pages/splash_page.dart';
import 'package:kairete/features/home/bindings/home_binding.dart';
import 'package:kairete/features/home/pages/home_shell_page.dart';
import 'package:kairete/features/profile/pages/profile_fields_page.dart';
import 'package:kairete/features/profile/pages/user_profile_page.dart';

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.profileFields,
      page: () => const ProfileFieldsPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeShellPage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => UserProfilePage(
        userId: int.parse(Get.parameters['userId'] ?? '0'),
      ),
    ),
  ];
}

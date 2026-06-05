import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/routes/app_pages.dart';
import 'package:kairete/core/routes/app_routes.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/auth/bindings/auth_binding.dart';

class KaireteApp extends StatelessWidget {
  const KaireteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Kairete',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialBinding: AuthBinding(),
      initialRoute: AppRoutes.login,
      getPages: AppPages.routes,
    );
  }
}

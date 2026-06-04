import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/routes/app_pages.dart';
import 'package:kairete/core/routes/app_routes.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/auth/controllers/auth_flow_controller.dart';

class KaireteApp extends StatelessWidget {
  const KaireteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Kairete',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialBinding: BindingsBuilder(
        () => Get.put(AuthFlowController(), permanent: true),
      ),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
    );
  }
}

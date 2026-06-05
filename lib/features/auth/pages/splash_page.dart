import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/config/app_config.dart';
import 'package:kairete/core/routes/app_routes.dart';
import 'package:kairete/features/auth/controllers/auth_flow_controller.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _forceLoginTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<AuthFlowController>().bootstrap();
    });
    _forceLoginTimer = Timer(const Duration(seconds: 12), () {
      if (!mounted) return;
      if (Get.currentRoute == AppRoutes.splash) {
        Get.find<AuthFlowController>().skipToLogin();
      }
    });
  }

  @override
  void dispose() {
    _forceLoginTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthFlowController>();
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              const Text(
                'Connessione a Kairete…',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                AppConfig.apiBaseUrl,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () => auth.skipToLogin(),
                child: const Text('Vai al login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

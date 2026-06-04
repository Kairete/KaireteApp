import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/config/app_config.dart';
import 'package:kairete/core/routes/app_routes.dart';
import 'package:kairete/features/auth/controllers/auth_flow_controller.dart';

class LoginPage extends GetView<AuthFlowController> {
  LoginPage({super.key});

  final _loginCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppConfig.appName)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Accedi',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                if (kDebugMode) ...[
                  const SizedBox(height: 8),
                  Text(
                    AppConfig.apiBaseUrl,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
                const SizedBox(height: 24),
                TextField(
                  controller: _loginCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nome utente o email',
                  ),
                  onChanged: (_) => controller.errorMessage.value = '',
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  onChanged: (_) => controller.errorMessage.value = '',
                ),
                if (controller.errorMessage.value.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    controller.errorMessage.value,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.login(_loginCtrl.text, _passCtrl.text),
                  child: Text(
                    controller.isLoading.value ? 'Accesso...' : 'Accedi',
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.register),
                  child: const Text('Crea un account'),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

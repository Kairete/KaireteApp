import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/config/app_config.dart';
import 'package:kairete/core/routes/app_routes.dart';
import 'package:kairete/features/auth/controllers/auth_flow_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _loginCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  AuthFlowController get _auth => Get.find<AuthFlowController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _auth.tryRestoreSession();
    });
  }

  @override
  void dispose() {
    _loginCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

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
                if (_auth.isRestoringSession.value) ...[
                  const SizedBox(height: 16),
                  const LinearProgressIndicator(),
                  const SizedBox(height: 8),
                  const Text(
                    'Ripristino sessione…',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
                const SizedBox(height: 24),
                TextField(
                  controller: _loginCtrl,
                  enabled: !_auth.isRestoringSession.value,
                  decoration: const InputDecoration(
                    labelText: 'Nome utente o email',
                  ),
                  onChanged: (_) => _auth.errorMessage.value = '',
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passCtrl,
                  enabled: !_auth.isRestoringSession.value,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  onChanged: (_) => _auth.errorMessage.value = '',
                ),
                if (_auth.errorMessage.value.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    _auth.errorMessage.value,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _auth.isLoading.value || _auth.isRestoringSession.value
                      ? null
                      : () => _auth.login(_loginCtrl.text, _passCtrl.text),
                  child: Text(
                    _auth.isLoading.value ? 'Accesso...' : 'Accedi',
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _auth.isRestoringSession.value
                      ? null
                      : () => Get.toNamed(AppRoutes.register),
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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/config/app_config.dart';
import 'package:kairete/features/auth/controllers/auth_flow_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  AuthFlowController get _auth => Get.find<AuthFlowController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _auth.tryRestoreSession());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppConfig.appName)),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Accedi a Kairete',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text(
                  'Accedi con il tuo account XenForo nel browser sicuro. '
                  'La password non viene salvata nell’app.',
                ),
                if (kDebugMode) ...[
                  const SizedBox(height: 8),
                  Text(AppConfig.apiBaseUrl, style: const TextStyle(color: Colors.grey)),
                ],
                if (_auth.isRestoringSession.value) ...[
                  const SizedBox(height: 20),
                  const LinearProgressIndicator(),
                ],
                if (_auth.errorMessage.value.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(_auth.errorMessage.value,
                      style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: (_auth.isLoading.value || _auth.isRestoringSession.value)
                      ? null
                      : _auth.loginWithOAuth,
                  child: Text(_auth.isLoading.value ? 'Accesso in corso…' : 'Accedi con Kairete'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _auth.isLoading.value ? null : _auth.enterAsGuest,
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Esplora Kairete come ospite'),
                ),
                const SizedBox(height: 8),
                const Text('Versione di prova: le funzioni personali richiedono un login non ancora disponibile.',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => launchUrl(
                    Uri.parse('${AppConfig.apiBaseUrl}register/'),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: const Text('Crea un account'),
                ),
              ],
            )),
          ),
        ),
      ),
    );
  }
}

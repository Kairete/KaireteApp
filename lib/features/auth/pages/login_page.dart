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
  final _loginCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  AuthFlowController get _auth => Get.find<AuthFlowController>();

  @override
  void dispose() {
    _loginCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppConfig.appName)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Accedi a Kairete',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text('L’accesso avverrà direttamente nell’app, senza aprire il browser.'),
                if (kDebugMode) ...[
                  const SizedBox(height: 8),
                  Text(AppConfig.apiBaseUrl,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
                const SizedBox(height: 24),
                TextField(
                  controller: _loginCtrl,
                  enabled: false,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Nome utente o email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordCtrl,
                  enabled: false,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Accesso con account in preparazione: prima dobbiamo collegare l’autenticazione sicura al server. Non inserire ancora le credenziali.',
                  style: TextStyle(color: Colors.orange),
                ),
                const SizedBox(height: 24),
                const FilledButton(
                  onPressed: null,
                  child: Text('Accedi'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _auth.isLoading.value ? null : _auth.enterAsGuest,
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Esplora Kairete come ospite'),
                ),
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

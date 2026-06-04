import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kairete/core/routes/app_routes.dart';
import 'package:kairete/features/auth/controllers/auth_flow_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  DateTime? _dob;

  AuthFlowController get _auth => Get.find<AuthFlowController>();

  Future<void> _pickDob() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _dob = date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrati')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Obx(() {
            final dobLabel =
                _dob == null ? null : DateFormat('dd/MM/yyyy').format(_dob!);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _usernameCtrl,
                  decoration: const InputDecoration(labelText: 'Nome utente'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickDob,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data di nascita',
                    ),
                    child: Text(dobLabel ?? 'Seleziona data'),
                  ),
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
                  onPressed: _auth.isLoading.value || _dob == null
                      ? null
                      : () => _auth.register(
                            username: _usernameCtrl.text,
                            email: _emailCtrl.text,
                            password: _passCtrl.text,
                            dob: _dob!,
                          ),
                  child: Text(
                    _auth.isLoading.value
                        ? 'Registrazione...'
                        : 'Registrati',
                  ),
                ),
                TextButton(
                  onPressed: () => Get.offNamed(AppRoutes.login),
                  child: const Text('Hai già un account? Accedi'),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

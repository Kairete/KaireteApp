import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/routes/app_routes.dart';
import 'package:kairete/features/auth/controllers/auth_flow_controller.dart';

/// Nome e cognome (custom_fields XenForo). Altri campi profilo verranno aggiunti dopo.
class ProfileFieldsPage extends StatefulWidget {
  const ProfileFieldsPage({super.key});

  @override
  State<ProfileFieldsPage> createState() => _ProfileFieldsPageState();
}

class _ProfileFieldsPageState extends State<ProfileFieldsPage> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();

  AuthFlowController get _auth => Get.find<AuthFlowController>();

  @override
  void initState() {
    super.initState();
    final fields = _auth.currentUser.value?.customFields ?? {};
    _firstName.text = fields['firstName'] ?? '';
    _lastName.text = fields['lastName'] ?? '';
  }

  void _save() {
    _auth.saveProfileFields({
      'firstName': _firstName.text.trim(),
      'lastName': _lastName.text.trim(),
    });
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Completa il profilo')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Inserisci nome e cognome.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _firstName,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Nome'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _lastName,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Cognome'),
                ),
                if (_auth.errorMessage.value.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    _auth.errorMessage.value,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                const Spacer(),
                TextButton(
                  onPressed: _auth.isLoading.value
                      ? null
                      : () {
                          final user = _auth.currentUser.value;
                          if (user != null) {
                            AppApi.instance.bindSession(user.userId);
                          }
                          Future.microtask(
                            () => Get.offAllNamed(AppRoutes.home),
                          );
                        },
                  child: const Text('Salta per ora'),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _auth.isLoading.value ? null : _save,
                  child: Text(
                    _auth.isLoading.value ? 'Salvataggio...' : 'Continua',
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

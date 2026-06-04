import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/features/auth/controllers/auth_flow_controller.dart';

/// Campi profilo XenForo (allineati ai custom_fields del web).
class ProfileFieldsPage extends StatefulWidget {
  const ProfileFieldsPage({super.key});

  @override
  State<ProfileFieldsPage> createState() => _ProfileFieldsPageState();
}

class _ProfileFieldsPageState extends State<ProfileFieldsPage> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _residence = TextEditingController();
  final _hometown = TextEditingController();

  AuthFlowController get _auth => Get.find<AuthFlowController>();

  @override
  void initState() {
    super.initState();
    final fields = _auth.currentUser.value?.customFields ?? {};
    _firstName.text = fields['firstName'] ?? '';
    _lastName.text = fields['lastName'] ?? '';
    _residence.text = fields['residence'] ?? '';
    _hometown.text = fields['hometown'] ?? '';
  }

  void _save() {
    _auth.saveProfileFields({
      'firstName': _firstName.text.trim(),
      'lastName': _lastName.text.trim(),
      'residence': _residence.text.trim(),
      'hometown': _hometown.text.trim(),
    });
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
                  'Inserisci i dati come sul sito web.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _firstName,
                  decoration: const InputDecoration(labelText: 'Nome'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _lastName,
                  decoration: const InputDecoration(labelText: 'Cognome'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _residence,
                  decoration: const InputDecoration(labelText: 'Residenza'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _hometown,
                  decoration: const InputDecoration(labelText: 'Città'),
                ),
                if (_auth.errorMessage.value.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    _auth.errorMessage.value,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                const Spacer(),
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

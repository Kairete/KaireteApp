import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/features/omnifeed/controllers/omnifeed_compose_controller.dart';

class OmnifeedComposePage extends StatefulWidget {
  const OmnifeedComposePage({super.key});

  @override
  State<OmnifeedComposePage> createState() => _OmnifeedComposePageState();
}

class _OmnifeedComposePageState extends State<OmnifeedComposePage> {
  @override
  void initState() {
    super.initState();
    Get.put(OmnifeedComposeController());
  }

  @override
  void dispose() {
    if (Get.isRegistered<OmnifeedComposeController>()) {
      Get.delete<OmnifeedComposeController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<OmnifeedComposeController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuovo post'),
        actions: [
          Obx(() {
            return TextButton(
              onPressed: c.canSend.value && !c.isSending.value
                  ? c.publish
                  : null,
              child: Text(c.isSending.value ? '...' : 'Pubblica'),
            );
          }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: TextField(
                controller: c.messageCtrl,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Scrivi qualcosa…',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (c.pendingAttachments.isEmpty) {
                return OutlinedButton.icon(
                  onPressed: c.isSending.value ? null : () => _pickFiles(c),
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Inserisci allegati'),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: c.pendingAttachments
                        .map(
                          (name) => Chip(
                            label: Text(
                              name,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onDeleted: c.isSending.value
                                ? null
                                : () => c.removeAttachment(name),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: c.isSending.value ? null : () => _pickFiles(c),
                    icon: const Icon(Icons.add),
                    label: const Text('Aggiungi allegato'),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFiles(OmnifeedComposeController c) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return;
    for (final file in result.files) {
      final path = file.path;
      if (path != null && path.isNotEmpty) {
        c.addAttachment(path, file.name);
      }
    }
  }
}

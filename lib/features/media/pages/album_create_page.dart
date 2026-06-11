import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/features/media/controllers/media_compose_controller.dart';

class AlbumCreatePage extends StatefulWidget {
  const AlbumCreatePage({super.key});

  @override
  State<AlbumCreatePage> createState() => _AlbumCreatePageState();
}

class _AlbumCreatePageState extends State<AlbumCreatePage> {
  @override
  void initState() {
    super.initState();
    Get.put(AlbumCreateController());
  }

  @override
  void dispose() {
    if (Get.isRegistered<AlbumCreateController>()) {
      Get.delete<AlbumCreateController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AlbumCreateController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crea album'),
        actions: [
          Obx(
            () => TextButton(
              onPressed: c.canSend.value && !c.isSending.value ? c.publish : null,
              child: Text(c.isSending.value ? '...' : 'Crea'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: c.titleCtrl,
            decoration: const InputDecoration(labelText: 'Titolo album'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: c.descriptionCtrl,
            decoration: const InputDecoration(labelText: 'Descrizione'),
            minLines: 3,
            maxLines: 6,
          ),
          const SizedBox(height: 12),
          const Text(
            'Chi può vederlo',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Column(
              children: albumPrivacyOptions
                  .map(
                    (opt) => RadioListTile<String>(
                      title: Text(opt.label),
                      value: opt.value,
                      groupValue: c.selectedPrivacy.value,
                      onChanged: (v) {
                        if (v != null) c.setPrivacy(v);
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: c.pickCover,
            icon: const Icon(Icons.image_outlined),
            label: Obx(
              () => Text(
                c.pendingFilename.value ?? 'Primo media / cover album',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

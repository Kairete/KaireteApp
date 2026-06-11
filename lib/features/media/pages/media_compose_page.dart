import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/features/media/controllers/media_compose_controller.dart';

class MediaComposePage extends StatefulWidget {
  const MediaComposePage({super.key});

  @override
  State<MediaComposePage> createState() => _MediaComposePageState();
}

class _MediaComposePageState extends State<MediaComposePage> {
  @override
  void initState() {
    super.initState();
    Get.put(MediaComposeController());
  }

  @override
  void dispose() {
    if (Get.isRegistered<MediaComposeController>()) {
      Get.delete<MediaComposeController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MediaComposeController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aggiungi media'),
        actions: [
          Obx(
            () => TextButton(
              onPressed: c.canSend.value && !c.isSending.value ? c.publish : null,
              child: Text(c.isSending.value ? '...' : 'Pubblica'),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (c.loadError.value.isNotEmpty) {
          return Center(child: Text(c.loadError.value));
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: c.titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Titolo del media',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: c.descriptionCtrl,
              decoration: const InputDecoration(
                labelText: 'Descrizione',
              ),
              minLines: 3,
              maxLines: 6,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: c.tagsCtrl,
              decoration: const InputDecoration(
                labelText: 'Tag',
                hintText: 'tag1, tag2, tag3',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: c.selectedAlbumId.value,
              decoration: const InputDecoration(labelText: 'Album'),
              items: c.albums
                  .map(
                    (a) => DropdownMenuItem(
                      value: a.albumId,
                      child: Text(a.title),
                    ),
                  )
                  .toList(),
              onChanged: c.setAlbumId,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: c.pickAttachment,
              icon: const Icon(Icons.attach_file),
              label: Obx(
                () => Text(
                  c.pendingFilename.value ?? 'Allegato (foto, video o audio)',
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

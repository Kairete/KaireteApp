import 'dart:io';

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
          const SizedBox(height: 16),
          _PrivacySection(
            title: 'Chi può vederlo',
            selected: c.selectedViewPrivacy,
            membersCtrl: c.viewMembersCtrl,
            onChanged: c.setViewPrivacy,
          ),
          const SizedBox(height: 16),
          _PrivacySection(
            title: 'Chi può caricare media',
            selected: c.selectedAddPrivacy,
            membersCtrl: c.addMembersCtrl,
            onChanged: c.setAddPrivacy,
          ),
          const SizedBox(height: 16),
          const Text(
            'Cover dell\'album',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Obx(() {
            final path = c.coverPath.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (path != null && path.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.file(
                        File(path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  Container(
                    height: 120,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: const Text(
                      'Nessuna cover selezionata',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: c.isSending.value ? null : c.pickCover,
                      icon: const Icon(Icons.image_outlined),
                      label: const Text('Scegli immagine'),
                    ),
                    if (path != null && path.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: c.isSending.value ? null : c.clearCover,
                        child: const Text('Rimuovi'),
                      ),
                    ],
                  ],
                ),
                const Text(
                  'Immagine orizzontale consigliata. Comparirà in cima alla pagina album.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _PrivacySection extends StatelessWidget {
  const _PrivacySection({
    required this.title,
    required this.selected,
    required this.membersCtrl,
    required this.onChanged,
  });

  final String title;
  final RxString selected;
  final TextEditingController membersCtrl;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Column(
            children: albumPrivacyOptions
                .map(
                  (opt) => RadioListTile<String>(
                    title: Text(opt.label),
                    value: opt.value,
                    groupValue: selected.value,
                    onChanged: (v) {
                      if (v != null) onChanged(v);
                    },
                  ),
                )
                .toList(),
          ),
        ),
        Obx(() {
          if (selected.value != 'shared') return const SizedBox.shrink();
          return TextField(
            controller: membersCtrl,
            decoration: const InputDecoration(
              labelText: 'Membri specifici',
              hintText: 'Nomi utente XenForo separati da virgola',
              helperText:
                  'Visibile solo se hai scelto «Membri specifici» per questa voce.',
            ),
          );
        }),
      ],
    );
  }
}

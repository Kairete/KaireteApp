import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/features/blog/controllers/blog_create_controller.dart';

class BlogCreatePage extends StatefulWidget {
  const BlogCreatePage({super.key});

  @override
  State<BlogCreatePage> createState() => _BlogCreatePageState();
}

class _BlogCreatePageState extends State<BlogCreatePage> {
  @override
  void initState() {
    super.initState();
    Get.put(BlogCreateController());
  }

  @override
  void dispose() {
    if (Get.isRegistered<BlogCreateController>()) {
      Get.delete<BlogCreateController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<BlogCreateController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crea blog'),
        actions: [
          Obx(() {
            return TextButton(
              onPressed: c.canSave.value && !c.isSaving.value ? c.save : null,
              child: Text(c.isSaving.value ? '...' : 'Salva'),
            );
          }),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: c.titleCtrl,
            decoration: const InputDecoration(
              labelText: 'Nome del blog',
              hintText: 'Visibile nel sito e nell\'URL',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: c.slugCtrl,
            decoration: const InputDecoration(
              labelText: 'URL (slug, opzionale)',
              hintText: 'Solo lettere, numeri e trattini',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: c.descriptionCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Descrizione breve',
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => DropdownButtonFormField<int>(
              value: c.isCommunity.value ? 1 : 0,
              decoration: const InputDecoration(labelText: 'Tipo blog'),
              items: const [
                DropdownMenuItem(value: 0, child: Text('Solo il titolare pubblica')),
                DropdownMenuItem(
                  value: 1,
                  child: Text('Community (anche i co-autori)'),
                ),
              ],
              onChanged: (v) => c.setCommunity(v == 1),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: c.membersCtrl,
            decoration: const InputDecoration(
              labelText: 'Co-autori (opzionale)',
              hintText: 'Nomi utente XenForo separati da virgola',
              helperText:
                  'Se inserisci co-autori, il blog viene creato come Community.',
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Cover del blog',
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
                      aspectRatio: 16 / 6,
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
                      onPressed: c.isSaving.value ? null : c.pickCover,
                      icon: const Icon(Icons.image_outlined),
                      label: const Text('Scegli immagine'),
                    ),
                    if (path != null && path.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: c.isSaving.value ? null : c.clearCover,
                        child: const Text('Rimuovi'),
                      ),
                    ],
                  ],
                ),
                const Text(
                  'Immagine orizzontale consigliata. Comparirà sopra la lista degli articoli.',
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

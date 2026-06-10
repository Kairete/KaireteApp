import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/features/blog/controllers/blog_compose_controller.dart';

class BlogComposePage extends StatefulWidget {
  const BlogComposePage({super.key, this.editEntryId});

  final int? editEntryId;

  @override
  State<BlogComposePage> createState() => _BlogComposePageState();
}

class _BlogComposePageState extends State<BlogComposePage> {
  @override
  void initState() {
    super.initState();
    Get.put(BlogComposeController(editEntryId: widget.editEntryId));
  }

  @override
  void dispose() {
    if (Get.isRegistered<BlogComposeController>()) {
      Get.delete<BlogComposeController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<BlogComposeController>();
    return Scaffold(
      appBar: AppBar(
        title: Text(c.isEditing ? 'Modifica articolo' : 'Nuovo articolo blog'),
        actions: [
          Obx(() {
            return TextButton(
              onPressed: c.canSend.value && !c.isSending.value ? c.publish : null,
              child: Text(c.isSending.value ? '...' : (c.isEditing ? 'Salva' : 'Pubblica')),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (c.loadError.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(c.loadError.value, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: c.reload,
                    child: const Text('Riprova'),
                  ),
                ],
              ),
            ),
          );
        }
        if (!c.isEditing && c.blogs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Non hai blog in cui pubblicare.'),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!c.isEditing)
              DropdownButtonFormField<int>(
                value: c.selectedBlogId.value,
                decoration: const InputDecoration(labelText: 'Blog'),
                items: c.blogs
                    .map(
                      (blog) => DropdownMenuItem(
                        value: blog.blogId,
                        child: Text(blog.title),
                      ),
                    )
                    .toList(),
                onChanged: c.setBlogId,
              )
            else
              InputDecorator(
                decoration: const InputDecoration(labelText: 'Blog'),
                child: Text(
                  () {
                    final matches = c.blogs
                        .where((b) => b.blogId == c.selectedBlogId.value)
                        .toList();
                    return matches.isNotEmpty ? matches.first.title : 'Blog';
                  }(),
                ),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: c.titleCtrl,
              decoration: const InputDecoration(labelText: 'Titolo'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: c.messageCtrl,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: 'Testo',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: c.tagsCtrl,
              decoration: const InputDecoration(
                labelText: 'Tag',
                hintText: 'Separati da virgola',
              ),
            ),
            if (c.categories.isNotEmpty) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                value: c.selectedCategoryId.value,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('— Nessuna —'),
                  ),
                  ...c.categories.map(
                    (cat) => DropdownMenuItem<int?>(
                      value: cat.categoryId,
                      child: Text(cat.title),
                    ),
                  ),
                ],
                onChanged: c.setCategoryId,
              ),
            ],
            const SizedBox(height: 12),
            Obx(() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton.icon(
                    onPressed: c.isSending.value ? null : c.pickAttachments,
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Inserisci allegati'),
                  ),
                  if (c.existingAttachments.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: c.existingAttachments
                          .map(
                            (name) => Chip(
                              avatar: const Icon(Icons.image_outlined, size: 18),
                              label: Text(
                                name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const Text(
                      'Allegati già presenti. Puoi aggiungerne di nuovi.',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                  if (c.pendingAttachments.isNotEmpty) ...[
                    const SizedBox(height: 8),
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
                  ],
                ],
              );
            }),
          ],
        );
      }),
    );
  }
}

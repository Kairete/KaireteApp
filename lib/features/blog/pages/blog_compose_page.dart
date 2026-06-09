import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/features/blog/controllers/blog_compose_controller.dart';

class BlogComposePage extends StatefulWidget {
  const BlogComposePage({super.key});

  @override
  State<BlogComposePage> createState() => _BlogComposePageState();
}

class _BlogComposePageState extends State<BlogComposePage> {
  @override
  void initState() {
    super.initState();
    Get.put(BlogComposeController());
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
        title: const Text('Nuovo articolo blog'),
        actions: [
          Obx(() {
            return TextButton(
              onPressed: c.canSend.value && !c.isSending.value ? c.publish : null,
              child: Text(c.isSending.value ? '...' : 'Pubblica'),
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
        if (c.blogs.isEmpty) {
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

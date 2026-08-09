import 'package:flutter/material.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';

Future<bool> confirmDeleteContent(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Elimina contenuto'),
      content: const Text('Sei sicuro di voler eliminare questo contenuto?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annulla')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Elimina')),
      ],
    ),
  );
  return result == true;
}

class ContentEditResult {
  const ContentEditResult({this.title, required this.message});
  final String? title;
  final String message;
}

Future<ContentEditResult?> showContentEditDialog(
  BuildContext context, {
  required OmnifeedItem item,
}) async {
  final titleCtrl = TextEditingController(text: item.contentTitle ?? '');
  final messageCtrl = TextEditingController(text: item.displayBody);
  final needsTitle = item.contentType != 'profile_post' &&
      item.contentType != 'tl_group_post';

  final result = await showDialog<ContentEditResult>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Modifica contenuto'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (needsTitle) ...[
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Titolo'),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: messageCtrl,
              maxLines: 6,
              decoration: const InputDecoration(labelText: 'Testo'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
        FilledButton(
          onPressed: () {
            final message = messageCtrl.text.trim();
            final title = needsTitle ? titleCtrl.text.trim() : null;
            final hasTitle = title != null && title.isNotEmpty;
            if (message.isEmpty && !hasTitle) return;
            Navigator.pop(
              ctx,
              ContentEditResult(title: title, message: message),
            );
          },
          child: const Text('Salva'),
        ),
      ],
    ),
  );

  titleCtrl.dispose();
  messageCtrl.dispose();
  return result;
}

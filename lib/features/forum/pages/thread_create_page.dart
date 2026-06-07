import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/forum/controllers/thread_create_controller.dart';

class ThreadCreatePage extends StatefulWidget {
  const ThreadCreatePage({
    super.key,
    required this.forumId,
    required this.forumTitle,
  });

  final int forumId;
  final String forumTitle;

  @override
  State<ThreadCreatePage> createState() => _ThreadCreatePageState();
}

class _ThreadCreatePageState extends State<ThreadCreatePage> {
  @override
  void initState() {
    super.initState();
    Get.put(
      ThreadCreateController(
        forumId: widget.forumId,
        forumTitle: widget.forumTitle,
      ),
    );
  }

  @override
  void dispose() {
    if (Get.isRegistered<ThreadCreateController>()) {
      Get.delete<ThreadCreateController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ThreadCreateController>();
    return Scaffold(
      backgroundColor: AppTheme.feedFooterBg,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text('Nuova discussione · ${widget.forumTitle}'),
        actions: [
          Obx(() {
            return TextButton(
              onPressed: c.canSend.value && !c.isSending.value ? c.publish : null,
              child: Text(
                c.isSending.value ? '...' : 'Pubblica',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: c.titleCtrl,
              onChanged: (_) => c.validate(),
              decoration: const InputDecoration(
                hintText: 'Titolo della discussione',
                filled: true,
                fillColor: Colors.white,
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: c.messageCtrl,
                onChanged: (_) => c.validate(),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Scrivi il messaggio…',
                  filled: true,
                  fillColor: Colors.white,
                  alignLabelWithHint: true,
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

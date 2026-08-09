import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/omnifeed/services/omnifeed_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Condivisione interna: dialog «Sulla mia bacheca».
Future<FeedShareApiResult?> showFeedShareInternal({
  required BuildContext context,
  required int itemId,
  String? previewText,
}) async {
  final comment = await showDialog<String>(
    context: context,
    builder: (ctx) {
      final controller = TextEditingController();
      return AlertDialog(
        title: const Text('Sulla mia bacheca'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Scrivi un commento (opzionale)…',
              ),
            ),
            if ((previewText ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.cardBorder),
                  color: const Color(0xFFFAFAFA),
                ),
                child: Text(
                  previewText!.trim(),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Pubblica'),
          ),
        ],
      );
    },
  );
  if (comment == null || !context.mounted) return null;

  try {
    final result = await OmnifeedService().shareInternal(
      itemId,
      message: comment,
    );
    Get.snackbar('Condivisione', 'Pubblicato sulla tua bacheca');
    return result;
  } catch (e) {
    Get.snackbar('Condivisione', e.toString());
    return null;
  }
}

/// Condivisione esterna: sheet Copia / WhatsApp / Telegram / Altro.
Future<FeedShareApiResult?> showFeedShareExternal({
  required BuildContext context,
  required int itemId,
  required String? viewUrl,
}) {
  return showModalBottomSheet<FeedShareApiResult>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
    ),
    builder: (ctx) => _FeedShareExternalSheet(
      itemId: itemId,
      viewUrl: viewUrl,
    ),
  );
}

class _FeedShareExternalSheet extends StatefulWidget {
  const _FeedShareExternalSheet({
    required this.itemId,
    required this.viewUrl,
  });

  final int itemId;
  final String? viewUrl;

  @override
  State<_FeedShareExternalSheet> createState() =>
      _FeedShareExternalSheetState();
}

class _FeedShareExternalSheetState extends State<_FeedShareExternalSheet> {
  bool _busy = false;

  String get _link {
    final u = widget.viewUrl?.trim() ?? '';
    return u.isNotEmpty ? u : 'https://www.kairete.it/';
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      final count = await OmnifeedService().shareExternal(widget.itemId);
      if (!mounted) return;
      Navigator.pop(context, FeedShareApiResult(shareCount: count));
    } catch (e) {
      if (!mounted) return;
      Get.snackbar('Condivisione', e.toString());
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Condividi all\'esterno',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            if (_busy)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else ...[
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Copia link'),
                onTap: () => _run(() async {
                  await Clipboard.setData(ClipboardData(text: _link));
                  Get.snackbar('Condivisione', 'Link copiato');
                }),
              ),
              ListTile(
                leading: const Icon(Icons.chat),
                title: const Text('WhatsApp'),
                onTap: () => _run(() async {
                  final uri = Uri.parse(
                    'https://wa.me/?text=${Uri.encodeComponent(_link)}',
                  );
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }),
              ),
              ListTile(
                leading: const Icon(Icons.send_outlined),
                title: const Text('Telegram'),
                onTap: () => _run(() async {
                  final uri = Uri.parse(
                    'https://t.me/share/url?url=${Uri.encodeComponent(_link)}',
                  );
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }),
              ),
              ListTile(
                leading: const Icon(Icons.ios_share),
                title: const Text('Altro'),
                onTap: () => _run(() async {
                  await SharePlus.instance.share(
                    ShareParams(uri: Uri.parse(_link)),
                  );
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

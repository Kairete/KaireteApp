import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Mostra un errore in dialogo scrollabile con pulsante Copia (non scompare da solo).
Future<void> showCopyableErrorDialog({
  String title = 'Errore',
  required String message,
}) async {
  final ctx = Get.context;
  if (ctx == null) {
    Get.snackbar(
      title,
      message,
      duration: const Duration(seconds: 60),
      maxWidth: 600,
    );
    return;
  }

  await showDialog<void>(
    context: ctx,
    barrierDismissible: false,
    builder: (dialogCtx) => AlertDialog(
      title: Text(title),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(dialogCtx).height * 0.55,
          maxWidth: 480,
        ),
        child: SingleChildScrollView(
          child: SelectableText(message),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: message));
            if (dialogCtx.mounted) {
              ScaffoldMessenger.of(dialogCtx).showSnackBar(
                const SnackBar(content: Text('Errore copiato negli appunti')),
              );
            }
          },
          child: const Text('Copia'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogCtx),
          child: const Text('Chiudi'),
        ),
      ],
    ),
  );
}

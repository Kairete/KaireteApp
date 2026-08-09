import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';

/// Campo commento con riga opzionale "Risposta a @nickname".
class FeedCommentComposer extends StatelessWidget {
  const FeedCommentComposer({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isSending,
    required this.onSend,
    this.hintText = 'Scrivi un commento…',
    this.replyLabel,
    this.onCancelReply,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSending;
  final VoidCallback onSend;
  final String hintText;
  final String? replyLabel;
  final VoidCallback? onCancelReply;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (replyLabel != null)
          Row(
            children: [
              Expanded(child: _ReplyLabel(text: replyLabel!)),
              if (onCancelReply != null)
                TextButton(
                  onPressed: onCancelReply,
                  child: const Text('Annulla'),
                ),
            ],
          ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: hintText,
                  isDense: true,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: isSending ? null : onSend,
              icon: isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReplyLabel extends StatelessWidget {
  const _ReplyLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    const prefix = 'Risposta a ';
    if (!text.startsWith(prefix)) {
      return Text(
        text,
        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
      );
    }
    final mention = text.substring(prefix.length);
    return Text.rich(
      TextSpan(
        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        children: [
          const TextSpan(text: prefix),
          TextSpan(
            text: mention,
            style: TextStyle(
              color: AppTheme.brandPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Barra commenti/risposta in fondo alle schermate feed (stile OmniFeed detail).
class FeedCommentBar extends StatelessWidget {
  const FeedCommentBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isSending,
    required this.onSend,
    this.hintText = 'Scrivi un commento…',
    this.replyLabel,
    this.onCancelReply,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSending;
  final VoidCallback onSend;
  final String hintText;
  final String? replyLabel;
  final VoidCallback? onCancelReply;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: Colors.white,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: FeedCommentComposer(
            controller: controller,
            focusNode: focusNode,
            isSending: isSending,
            onSend: onSend,
            hintText: hintText,
            replyLabel: replyLabel,
            onCancelReply: onCancelReply,
          ),
        ),
      ),
    );
  }
}

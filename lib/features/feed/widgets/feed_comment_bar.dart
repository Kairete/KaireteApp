import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (replyLabel != null)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        replyLabel!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
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
          ),
        ),
      ),
    );
  }
}

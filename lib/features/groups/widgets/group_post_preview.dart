import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Group-post preview with an inline link after the final visible word.
/// TextSpan keeps the link in the same text flow rather than a new row.
class GroupPostPreview extends StatefulWidget {
  const GroupPostPreview({
    super.key,
    required this.text,
    this.expanded = false,
    required this.onContinue,
    this.threshold = 280,
  });

  final String text;
  final bool expanded;
  final VoidCallback onContinue;
  final int threshold;

  @override
  State<GroupPostPreview> createState() => _GroupPostPreviewState();
}

class _GroupPostPreviewState extends State<GroupPostPreview> {
  late final TapGestureRecognizer _recognizer =
      TapGestureRecognizer()..onTap = _handleTap;

  void _handleTap() => widget.onContinue();

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final full = widget.text.trim();
    final truncated = !widget.expanded && full.length > widget.threshold;
    final clipped = truncated
        ? full.substring(0, widget.threshold).trimRight()
        : full;

    return Text.rich(
      TextSpan(
        style: const TextStyle(fontSize: 15, height: 1.35, color: Colors.black),
        children: [
          TextSpan(text: truncated ? '$clipped… ' : clipped),
          if (truncated)
            TextSpan(
              text: 'Leggi tutto',
              recognizer: _recognizer,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1769AA),
                decoration: TextDecoration.none,
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';

/// Pulsante refresh feed: solo icona freccia (senza testo).
class FeedRefreshButton extends StatelessWidget {
  const FeedRefreshButton({
    super.key,
    this.onTap,
    this.isLoading = false,
    this.compact = false,
  });

  final VoidCallback? onTap;
  final bool isLoading;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final padding = compact
        ? const EdgeInsets.all(10)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 10);

    return Material(
      color: AppTheme.primary,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF0F4A35)),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.refresh, size: 20, color: Colors.white),
        ),
      ),
    );
  }
}

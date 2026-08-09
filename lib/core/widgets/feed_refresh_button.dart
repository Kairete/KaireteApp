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
        ? const EdgeInsets.all(8)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 10);

    return Material(
      color: AppTheme.brandPrimary,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppTheme.brandAppBarBorder),
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
              : Icon(Icons.refresh, size: compact ? 18 : 20, color: Colors.white),
        ),
      ),
    );
  }
}

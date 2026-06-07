import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';

class OmnifeedComposeBar extends StatelessWidget {
  const OmnifeedComposeBar({super.key, this.onTapCompose});

  final VoidCallback? onTapCompose;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppTheme.composeBg,
        border: Border(
          bottom: BorderSide(color: AppTheme.cardBorder, width: 1),
        ),
      ),
      child: InkWell(
        onTap: onTapCompose,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppTheme.cardBorder),
          ),
          alignment: Alignment.centerLeft,
          child: const Text(
            'Scrivi qualcosa…',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

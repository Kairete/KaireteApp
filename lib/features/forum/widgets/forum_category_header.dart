import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';

/// Intestazione sezione categoria (layout stile XenForo forum index).
class ForumCategoryHeader extends StatelessWidget {
  const ForumCategoryHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.feedItemChromeBg,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppTheme.cardBorder, width: 1),
            bottom: BorderSide(color: AppTheme.cardBorder, width: 1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

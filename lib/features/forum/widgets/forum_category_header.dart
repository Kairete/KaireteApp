import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';

/// Intestazione sezione categoria (stile indice forum XenForo, ben visibile).
class ForumCategoryHeader extends StatelessWidget {
  const ForumCategoryHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final bg = AppTheme.brandHeader;
    final fg = Colors.white;
    return ColoredBox(
      color: bg,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: fg,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

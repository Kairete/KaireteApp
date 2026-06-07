import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';

/// Barra composizione stile OmniFeed (tap → apre schermata di scrittura).
class FeedComposeBar extends StatelessWidget {
  const FeedComposeBar({
    super.key,
    this.hintText = 'Scrivi qualcosa…',
    this.onTapCompose,
    this.showFilterRow = false,
  });

  final String hintText;
  final VoidCallback? onTapCompose;
  final bool showFilterRow;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppTheme.composeBg,
        border: Border(
          bottom: BorderSide(color: AppTheme.cardBorder, width: 1),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTapCompose,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                hintText,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (showFilterRow)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  _FilterIcon(Icons.person_outline),
                  const SizedBox(width: 8),
                  _FilterIcon(Icons.article_outlined),
                  const SizedBox(width: 8),
                  _FilterIcon(Icons.groups_outlined),
                  const SizedBox(width: 8),
                  _FilterIcon(Icons.home_outlined),
                  const Spacer(),
                  Icon(Icons.sort, color: AppTheme.primary, size: 26),
                  const SizedBox(width: 8),
                  Icon(Icons.filter_list, color: AppTheme.primary, size: 26),
                ],
              ),
            )
          else
            const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _FilterIcon extends StatelessWidget {
  const _FilterIcon(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.primary, width: 1.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, color: AppTheme.primary, size: 20),
    );
  }
}

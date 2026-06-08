import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';

/// Barra compatta in home: apre le pagine di composizione (niente TextField qui).
class OmnifeedComposeBar extends StatelessWidget {
  const OmnifeedComposeBar({
    super.key,
    this.onTapCompose,
    this.onTapBlog,
  });

  final VoidCallback? onTapCompose;
  final VoidCallback? onTapBlog;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppTheme.composeBg,
        border: Border(
          bottom: BorderSide(color: AppTheme.cardBorder, width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          children: [
            Expanded(
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                child: InkWell(
                  onTap: onTapCompose,
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
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
              ),
            ),
            if (onTapBlog != null) ...[
              const SizedBox(width: 8),
              Material(
                color: const Color(0xFFFFF6DF),
                borderRadius: BorderRadius.circular(6),
                child: InkWell(
                  onTap: onTapBlog,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFE6A800)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.rss_feed,
                          size: 18,
                          color: Color(0xFF7A4E00),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Blog',
                          style: TextStyle(
                            color: Color(0xFF7A4E00),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

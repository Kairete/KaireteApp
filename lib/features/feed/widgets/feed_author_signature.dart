import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:kairete/core/theme/app_theme.dart';

/// Firma autore sotto il body della card feed (stile XF).
class FeedAuthorSignature extends StatelessWidget {
  const FeedAuthorSignature({
    super.key,
    this.html,
    this.plain,
  });

  final String? html;
  final String? plain;

  /// Restituisce il widget solo se c'è contenuto da mostrare.
  static Widget? maybe({
    String? html,
    String? plain,
    bool show = true,
  }) {
    if (!show) return null;
    final h = html?.trim() ?? '';
    final p = plain?.trim() ?? '';
    if (h.isEmpty && p.isEmpty) return null;
    return FeedAuthorSignature(
      html: h.isEmpty ? null : h,
      plain: p.isEmpty ? null : p,
    );
  }

  @override
  Widget build(BuildContext context) {
    final useHtml = html != null && html!.trim().isNotEmpty;
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
        child: useHtml
            ? Html(
                data: html!,
                style: {
                  'body': Style(
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    fontSize: FontSize(12.5),
                    lineHeight: const LineHeight(1.35),
                    color: AppTheme.textSecondary,
                  ),
                  'p': Style(
                    margin: Margins.only(bottom: 4),
                    padding: HtmlPaddings.zero,
                  ),
                  'img': Style(
                    width: Width(120),
                    height: Height.auto(),
                  ),
                  'a': Style(color: AppTheme.linkBlue),
                },
              )
            : Text(
                plain ?? '',
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.35,
                  color: AppTheme.textSecondary,
                ),
              ),
      ),
    );
  }
}

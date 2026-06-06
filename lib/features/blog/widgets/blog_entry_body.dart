import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/blog/models/blog_entry.dart';

/// Corpo articolo con HTML web e thumbnail tra titolo e testo.
class BlogEntryBody extends StatelessWidget {
  const BlogEntryBody({super.key, required this.entry});

  final BlogEntry entry;

  @override
  Widget build(BuildContext context) {
    final thumbnail = entry.thumbnailUrl;
    final html = entry.messageParsed?.trim().isNotEmpty == true
        ? entry.messageParsed!
        : '<p>${entry.messagePlainText ?? ''}</p>';

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (entry.title?.trim().isNotEmpty == true) ...[
            Text(
              entry.title!,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppTheme.accent,
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (thumbnail != null && thumbnail.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: CachedNetworkImage(
                imageUrl: thumbnail,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Html(
            data: html,
            style: {
              'body': Style(
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
                fontSize: FontSize(15),
                lineHeight: LineHeight(1.35),
                color: Colors.black,
              ),
              'p': Style(margin: Margins.only(bottom: 12)),
            },
          ),
        ],
      ),
    );
  }
}

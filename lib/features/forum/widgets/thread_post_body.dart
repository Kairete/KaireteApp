import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/feed/widgets/feed_link_preview.dart';
import 'package:kairete/features/forum/models/forum_thread.dart';

class ThreadPostBody extends StatelessWidget {
  const ThreadPostBody({
    super.key,
    required this.thread,
    this.post,
  });

  final ForumThread thread;
  final ForumPost? post;

  @override
  Widget build(BuildContext context) {
    final htmlSource = post?.messageParsed?.trim().isNotEmpty == true
        ? post!.messageParsed!
        : thread.messageParsed?.trim().isNotEmpty == true
            ? thread.messageParsed!
            : null;
    final plain = post?.messagePlainText?.trim().isNotEmpty == true
        ? post!.messagePlainText!
        : thread.messagePlainText?.trim().isNotEmpty == true
            ? thread.messagePlainText!
            : '';
    final html = htmlSource ?? '<p>$plain</p>';
    final previews = (post?.linkPreviews.isNotEmpty == true)
        ? post!.linkPreviews
        : thread.linkPreviews;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (thread.title?.trim().isNotEmpty == true) ...[
            Text(
              thread.title!,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppTheme.accent,
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
          if (previews.isNotEmpty) ...[
            const SizedBox(height: 10),
            FeedLinkPreview(previews: previews),
          ],
        ],
      ),
    );
  }
}

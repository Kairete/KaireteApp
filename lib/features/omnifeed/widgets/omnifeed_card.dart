import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/feed/widgets/feed_card_widgets.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_time.dart';

/// Card feed in stile app legacy (screenshot Kairete).
class OmnifeedCard extends StatelessWidget {
  const OmnifeedCard({
    super.key,
    required this.item,
    this.onOpen,
    this.onComment,
    this.onReact,
  });

  final OmnifeedItem item;
  final VoidCallback? onOpen;
  final VoidCallback? onComment;
  final VoidCallback? onReact;

  @override
  Widget build(BuildContext context) {
    final author = item.author;
    final nickname = author?.username ?? author?.label ?? '';

    return FeedCardShell(
      header: FeedCardHeaderBar(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FeedCardAvatar(url: author?.avatarUrl, name: author?.label),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AuthorLine(
                    nickname: nickname,
                    moduleLabel: item.headerModuleLabel,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    formatOmnifeedCardDate(item.itemDate),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            const FeedCardMenuButton(),
          ],
        ),
      ),
      body: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.showsModuleTitle) ...[
                Text(
                  item.moduleTitle,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accent,
                  ),
                ),
                const SizedBox(height: 6),
              ],
              Text(
                item.displayBody,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  height: 1.3,
                ),
              ),
              FeedCardDetailLink(onTap: onOpen),
            ],
          ),
        ),
      ),
      footer: FeedCardActionBar(
        commentCount: item.commentCount,
        onComment: onComment ?? onOpen,
        onReact: onReact,
      ),
    );
  }
}

class _AuthorLine extends StatelessWidget {
  const _AuthorLine({required this.nickname, this.moduleLabel});

  final String nickname;
  final String? moduleLabel;

  @override
  Widget build(BuildContext context) {
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: const TextStyle(fontSize: 14, height: 1.15),
        children: [
          TextSpan(
            text: nickname,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.authorName,
            ),
          ),
          if (moduleLabel != null && moduleLabel!.isNotEmpty) ...[
            const WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 1),
                child: Icon(
                  Icons.play_arrow,
                  size: 15,
                  color: AppTheme.primary,
                ),
              ),
            ),
            TextSpan(
              text: moduleLabel,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/feed/widgets/feed_card_widgets.dart';
import 'package:kairete/features/media/models/media_item.dart';
import 'package:kairete/features/media/widgets/media_thumbnail.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_time.dart';

class MediaFeedCard extends StatelessWidget {
  const MediaFeedCard({
    super.key,
    required this.item,
    this.onOpen,
    this.onComment,
    this.onReact,
    this.onAuthorTap,
    this.onAlbumTap,
    this.onCategoryTap,
    this.onThumbnailTap,
    this.onTagTap,
  });

  final MediaItem item;
  final VoidCallback? onOpen;
  final VoidCallback? onComment;
  final Future<void> Function(int reactionId)? onReact;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onAlbumTap;
  final VoidCallback? onCategoryTap;
  final VoidCallback? onThumbnailTap;
  final void Function(String tag)? onTagTap;

  @override
  Widget build(BuildContext context) {
    final author = item.author;
    final categoryTitle = item.category?.title.trim();

    return FeedCardShell(
      header: FeedCardAuthorHeader(
        avatarUrl: author?.avatarUrl,
        authorName: author?.label ?? author?.username,
        moduleLabel: item.albumHeaderLabel,
        dateLabel: formatOmnifeedCardDate(item.mediaDate),
        categoryLabel: categoryTitle,
        onAuthorTap: onAuthorTap,
        onModuleTap: onAlbumTap,
        onCategoryTap: onCategoryTap,
      ),
      body: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.displayTitle,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accent,
                ),
              ),
              if (item.heroImageUrl != null || item.isPlayable) ...[
                const SizedBox(height: 8),
                MediaThumbnail(
                  item: item,
                  onTap: onThumbnailTap ?? onOpen,
                ),
              ],
              if (item.listPreviewBody.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  item.listPreviewBody,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    height: 1.3,
                  ),
                ),
              ],
              FeedCardDetailLink(
                onTap: onOpen,
                visible: item.previewHasMore,
              ),
            ],
          ),
        ),
      ),
      beforeFooter: item.tags.isNotEmpty
          ? FeedCardTagsRow(tags: item.tags, onTagTap: onTagTap)
          : null,
      footer: FeedCardActionBar(
        commentCount: item.commentCount,
        likeCount: item.reactionScore,
        visitorReactionId: item.visitorReactionId,
        onComment: onComment ?? onOpen,
        onReact: item.canReact ? onReact : null,
      ),
    );
  }
}

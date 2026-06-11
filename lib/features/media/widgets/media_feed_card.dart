import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/feed/widgets/feed_card_widgets.dart';
import 'package:kairete/features/media/models/media_item.dart';
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
    final albumTitle = item.album?.title?.trim();
    final categoryTitle = item.category?.title?.trim();
    final date = formatOmnifeedCardDate(item.mediaDate);
    final hero = item.heroImageUrl;

    return FeedCardShell(
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FeedCardAuthorHeader(
            avatarUrl: author?.avatarUrl,
            authorName: author?.username ?? author?.label,
            moduleLabel: albumTitle?.isNotEmpty == true ? albumTitle : null,
            dateLabel: null,
            onAuthorTap: onAuthorTap,
            onModuleTap: onAlbumTap,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                if (categoryTitle != null && categoryTitle.isNotEmpty) ...[
                  const Text(
                    ' - ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  InkWell(
                    onTap: onCategoryTap,
                    child: Text(
                      categoryTitle,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accent,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      body: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
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
              if (hero != null) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onThumbnailTap ?? onOpen,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: CachedNetworkImage(
                          imageUrl: hero,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                      if (item.isVideo)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: const Icon(
                            Icons.play_circle_fill,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                    ],
                  ),
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

import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/feed/widgets/feed_author_signature.dart';
import 'package:kairete/features/feed/widgets/feed_card_widgets.dart';
import 'package:kairete/features/media/models/media_item.dart';
import 'package:kairete/features/media/widgets/media_thumbnail.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_time.dart';

class MediaFeedCard extends StatelessWidget {
  const MediaFeedCard({
    super.key,
    required this.item,
    this.showAlbumInHeader = true,
    this.onOpen,
    this.onComment,
    this.onReact,
    this.onShareInternal,
    this.onShareExternal,
    this.shareCount = 0,
    this.onAuthorTap,
    this.onAlbumTap,
    this.onCategoryTap,
    this.onThumbnailTap,
    this.onTagTap,
  });

  final MediaItem item;
  final bool showAlbumInHeader;
  final VoidCallback? onOpen;
  final VoidCallback? onComment;
  final Future<void> Function(int reactionId)? onReact;
  final VoidCallback? onShareInternal;
  final VoidCallback? onShareExternal;
  final int shareCount;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onAlbumTap;
  final VoidCallback? onCategoryTap;
  final VoidCallback? onThumbnailTap;
  final void Function(String tag)? onTagTap;

  @override
  Widget build(BuildContext context) {
    final author = item.author;
    final nickname = author?.username.trim().isNotEmpty == true
        ? author!.username
        : (author?.label ?? '');

    return FeedCardShell(
      header: FeedCardAuthorHeader(
        avatarUrl: author?.avatarUrl,
        authorName: nickname,
        moduleLabel: showAlbumInHeader ? item.albumHeaderLabel : null,
        dateLabel: formatOmnifeedCardDate(item.mediaDate),
        onAuthorTap: onAuthorTap,
        onModuleTap: showAlbumInHeader ? onAlbumTap : null,
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
              FeedCardTagsContinueRow(
                tags: item.tags,
                onTagTap: onTagTap,
                onContinue: onOpen,
                showContinue: item.previewHasMore,
                embeddedInBody: true,
              ),
            ],
          ),
        ),
      ),
      beforeFooter: FeedAuthorSignature.maybe(
        html: author?.signatureHtml,
        plain: author?.signaturePlain,
        show: author?.contentShowSignature ?? true,
      ),
      footer: FeedCardActionBar(
        commentCount: item.commentCount,
        likeCount: item.reactionScore,
        visitorReactionId: item.visitorReactionId,
        onComment: onComment ?? onOpen,
        onReact: item.canReact ? onReact : null,
        shareCount: shareCount,
        onShareInternal: onShareInternal,
        onShareExternal: onShareExternal,
      ),
    );
  }
}

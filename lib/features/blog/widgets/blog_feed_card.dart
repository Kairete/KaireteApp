import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/blog/models/blog_entry.dart';
import 'package:kairete/features/feed/widgets/feed_card_widgets.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_time.dart';

class BlogFeedCard extends StatelessWidget {
  const BlogFeedCard({
    super.key,
    required this.entry,
    this.onOpen,
    this.onComment,
    this.onReact,
    this.onAuthorTap,
    this.onBlogTap,
    this.onTagTap,
  });

  final BlogEntry entry;
  final VoidCallback? onOpen;
  final VoidCallback? onComment;
  final Future<void> Function(int reactionId)? onReact;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onBlogTap;
  final void Function(String tag)? onTagTap;

  @override
  Widget build(BuildContext context) {
    final thumbnail = entry.thumbnailUrl;
    final author = entry.author;

    return FeedCardShell(
      header: FeedCardAuthorHeader(
        avatarUrl: author?.avatarUrl,
        authorName: author?.username ?? author?.label,
        moduleLabel: entry.blog?.title,
        dateLabel: _metaDateLine(entry),
        onAuthorTap: onAuthorTap,
        onModuleTap: onBlogTap,
      ),
      body: InkWell(
        onTap: onOpen,
        child: Padding(
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
                    errorWidget: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                entry.listPreviewBody,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  height: 1.3,
                ),
              ),
              FeedCardDetailLink(
                onTap: onOpen,
                visible: entry.previewHasMoreVisible,
              ),
            ],
          ),
        ),
      ),
      beforeFooter: entry.tags.isNotEmpty
          ? FeedCardTagsRow(tags: entry.tags, onTagTap: onTagTap)
          : null,
      footer: FeedCardActionBar(
        commentCount: entry.commentCount,
        likeCount: entry.reactionScore,
        visitorReactionId: entry.visitorReactionId,
        onComment: onComment ?? onOpen,
        onReact: onReact,
      ),
    );
  }

  String _metaDateLine(BlogEntry entry) {
    final date = formatOmnifeedCardDate(entry.postDate);
    final category = entry.category?.title ?? '';
    if (category.isEmpty) return date;
    return '$date - $category';
  }
}

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
    this.onBlogTap,
    this.onCategoryTap,
  });

  final BlogEntry entry;
  final VoidCallback? onOpen;
  final VoidCallback? onComment;
  final Future<void> Function(int reactionId)? onReact;
  final VoidCallback? onBlogTap;
  final VoidCallback? onCategoryTap;

  @override
  Widget build(BuildContext context) {
    final thumbnail = entry.thumbnailUrl;

    return FeedCardShell(
      header: BlogFeedHeader(
        entry: entry,
        onBlogTap: onBlogTap,
        onCategoryTap: onCategoryTap,
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
                visible: entry.previewHasMore,
              ),
            ],
          ),
        ),
      ),
      footer: FeedCardActionBar(
        commentCount: entry.commentCount,
        likeCount: entry.reactionScore,
        visitorReactionId: entry.visitorReactionId,
        onComment: onComment ?? onOpen,
        onReact: onReact,
      ),
    );
  }
}

class BlogFeedHeader extends StatelessWidget {
  const BlogFeedHeader({
    super.key,
    required this.entry,
    this.onBlogTap,
    this.onCategoryTap,
  });

  final BlogEntry entry;
  final VoidCallback? onBlogTap;
  final VoidCallback? onCategoryTap;

  @override
  Widget build(BuildContext context) {
    final author = entry.author;
    final nickname = author?.username ?? author?.label ?? '';
    final blogTitle = entry.blog?.title ?? '';
    final categoryTitle = entry.category?.title ?? '';

    return FeedCardHeaderBar(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FeedCardAvatar(url: author?.avatarUrl, name: author?.label),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BlogAuthorLine(
                  nickname: nickname,
                  blogTitle: blogTitle,
                  onBlogTap: onBlogTap,
                ),
                const SizedBox(height: 3),
                _BlogMetaLine(
                  dateLabel: formatOmnifeedCardDate(entry.postDate),
                  categoryTitle: categoryTitle,
                  onCategoryTap: onCategoryTap,
                ),
              ],
            ),
          ),
          const FeedCardMenuButton(),
        ],
      ),
    );
  }
}

class _BlogAuthorLine extends StatelessWidget {
  const _BlogAuthorLine({
    required this.nickname,
    required this.blogTitle,
    this.onBlogTap,
  });

  final String nickname;
  final String blogTitle;
  final VoidCallback? onBlogTap;

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
          if (blogTitle.isNotEmpty) ...[
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
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: GestureDetector(
                onTap: onBlogTap,
                child: Text(
                  blogTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BlogMetaLine extends StatelessWidget {
  const _BlogMetaLine({
    required this.dateLabel,
    required this.categoryTitle,
    this.onCategoryTap,
  });

  final String dateLabel;
  final String categoryTitle;
  final VoidCallback? onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
          height: 1.1,
        ),
        children: [
          TextSpan(text: dateLabel),
          if (categoryTitle.isNotEmpty) ...[
            const TextSpan(text: ' - '),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: GestureDetector(
                onTap: onCategoryTap,
                child: Text(
                  categoryTitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

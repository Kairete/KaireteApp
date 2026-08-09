import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kairete/features/blog/models/blog_entry.dart';
import 'package:kairete/features/feed/widgets/feed_author_signature.dart';
import 'package:kairete/features/feed/widgets/feed_card_widgets.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_time.dart';

class BlogFeedCard extends StatelessWidget {
  const BlogFeedCard({
    super.key,
    required this.entry,
    this.onOpen,
    this.onComment,
    this.onReact,
    this.onShareInternal,
    this.onShareExternal,
    this.shareCount = 0,
    this.onAuthorTap,
    this.onBlogTap,
    this.onTagTap,
    this.onEdit,
    this.onDelete,
    this.onHighlight,
    this.showOwnerActions = false,
  });

  final BlogEntry entry;
  final VoidCallback? onOpen;
  final VoidCallback? onComment;
  final Future<void> Function(int reactionId)? onReact;
  final VoidCallback? onShareInternal;
  final VoidCallback? onShareExternal;
  final int shareCount;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onBlogTap;
  final void Function(String tag)? onTagTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onHighlight;
  final bool showOwnerActions;

  @override
  Widget build(BuildContext context) {
    final thumbnail = entry.thumbnailUrl;
    final author = entry.author;
    final showMenu = showOwnerActions &&
        (onEdit != null || onDelete != null || onHighlight != null);

    return FeedCardShell(
      header: FeedCardAuthorHeader(
        avatarUrl: author?.avatarUrl,
        authorName: author?.username ?? author?.label,
        moduleLabel: entry.blog?.title,
        dateLabel: _metaDateLine(entry),
        onAuthorTap: onAuthorTap,
        onModuleTap: onBlogTap,
        trailing: showMenu
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (entry.isHighlighted)
                    const Padding(
                      padding: EdgeInsets.only(right: 2),
                      child: Icon(
                        Icons.push_pin,
                        size: 16,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  FeedCardOwnerMenu(
                    onEdit: onEdit,
                    onDelete: onDelete,
                    onHighlight: onHighlight,
                    isHighlighted: entry.isHighlighted,
                  ),
                ],
              )
            : (entry.isHighlighted
                ? const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Icon(
                      Icons.push_pin,
                      size: 16,
                      color: Color(0xFFB45309),
                    ),
                  )
                : const FeedCardMenuButton()),
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
                    color: Colors.black,
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
              FeedCardTagsContinueRow(
                tags: entry.tags,
                onTagTap: onTagTap,
                onContinue: onOpen,
                showContinue: entry.previewHasMoreVisible,
                continueLabel: entry.continueLabel ?? 'Continua',
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
        commentCount: entry.commentCount,
        likeCount: entry.reactionScore,
        visitorReactionId: entry.visitorReactionId,
        onComment: onComment ?? onOpen,
        onReact: onReact,
        shareCount: shareCount,
        onShareInternal: onShareInternal,
        onShareExternal: onShareExternal,
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

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
    this.onAuthorTap,
    this.onBlogTap,
    this.onForumTap,
    this.onEdit,
    this.onDelete,
    this.showOwnerActions = false,
    this.comments = const [],
  });

  final OmnifeedItem item;
  final VoidCallback? onOpen;
  final VoidCallback? onComment;
  final Future<void> Function(int reactionId)? onReact;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onBlogTap;
  final VoidCallback? onForumTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showOwnerActions;
  final List<Widget> comments;

  @override
  Widget build(BuildContext context) {
    final author = item.author;

    return FeedCardShell(
      header: FeedCardAuthorHeader(
        avatarUrl: author?.avatarUrl,
        authorName: author?.username ?? author?.label,
        moduleLabel: item.headerModuleLabel,
        dateLabel: formatOmnifeedCardDate(item.itemDate),
        onAuthorTap: onAuthorTap,
        onModuleTap: _moduleTap(),
        trailing: showOwnerActions && (onEdit != null || onDelete != null)
            ? FeedCardOwnerMenu(onEdit: onEdit, onDelete: onDelete)
            : const FeedCardMenuButton(),
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
                if (item.listPreviewBody.isNotEmpty) const SizedBox(height: 6),
              ],
              if (item.listPreviewBody.isNotEmpty)
                Text(
                  item.listPreviewBody,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    height: 1.3,
                  ),
                ),
              FeedCardDetailLink(
                onTap: onOpen,
                visible: item.listPreviewNeedsDetailLink,
              ),
            ],
          ),
        ),
      ),
      beforeFooter: item.tags.isNotEmpty
          ? FeedCardTagsRow(tags: item.tags)
          : null,
      footer: FeedCardActionBar(
        commentCount: item.commentCount,
        likeCount: item.reactionScore,
        visitorReactionId: item.visitorReactionId,
        onComment: onComment ?? onOpen,
        onReact: onReact,
      ),
      comments: comments,
    );
  }

  VoidCallback? _moduleTap() {
    if (item.contentType == 'ubs_blog_entry') return onBlogTap;
    if (item.contentType == 'thread') return onForumTap;
    return null;
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/feed/widgets/feed_card_widgets.dart';
import 'package:kairete/features/forum/models/forum_thread.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_time.dart';

class ThreadFeedCard extends StatelessWidget {
  const ThreadFeedCard({
    super.key,
    required this.thread,
    required this.forumTitle,
    this.onOpen,
    this.onComment,
    this.onReact,
    this.onAuthorTap,
    this.onForumTap,
    this.onEdit,
    this.onDelete,
    this.showOwnerActions = false,
  });

  final ForumThread thread;
  final String forumTitle;
  final VoidCallback? onOpen;
  final VoidCallback? onComment;
  final Future<void> Function(int reactionId)? onReact;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onForumTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showOwnerActions;

  @override
  Widget build(BuildContext context) {
    final author = thread.author;
    final imageAttachments = thread.attachments
        .where((a) => a.displayImageUrl != null)
        .toList();

    return FeedCardShell(
      header: FeedCardAuthorHeader(
        avatarUrl: author?.avatarUrl,
        authorName: author?.username ?? author?.label,
        moduleLabel: forumTitle,
        dateLabel: formatOmnifeedCardDate(thread.postDate),
        onAuthorTap: onAuthorTap,
        onModuleTap: onForumTap,
        trailing: showOwnerActions && (onEdit != null || onDelete != null)
            ? FeedCardOwnerMenu(onEdit: onEdit, onDelete: onDelete)
            : const FeedCardMenuButton(),
      ),
      body: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (thread.title?.trim().isNotEmpty == true)
                  Text(
                    thread.title!,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accent,
                    ),
                  ),
                if (thread.listPreviewBody.isNotEmpty) ...[
                  if (thread.title?.trim().isNotEmpty == true)
                    const SizedBox(height: 8),
                  Text(
                    thread.listPreviewBody,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      height: 1.3,
                    ),
                  ),
                ],
                if (thread.listPreviewNeedsDetailLink)
                  FeedCardDetailLink(
                    onTap: onOpen,
                    visible: true,
                  ),
                if (imageAttachments.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  FeedCardFullWidthImages(
                    imageUrls: imageAttachments
                        .map((a) => a.displayImageUrl!)
                        .toList(),
                    onTap: onOpen,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      beforeFooter: thread.tags.isNotEmpty
          ? FeedCardTagsRow(tags: thread.tags)
          : null,
      footer: FeedCardActionBar(
        commentCount: thread.commentCount,
        likeCount: thread.firstPostReactionScore,
        onComment: onComment ?? onOpen,
        onReact: onReact,
      ),
    );
  }
}

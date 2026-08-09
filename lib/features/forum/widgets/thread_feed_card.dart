import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/feed/widgets/feed_author_signature.dart';
import 'package:kairete/features/feed/widgets/feed_card_widgets.dart';
import 'package:kairete/features/feed/widgets/feed_link_preview.dart';
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
    this.onShareInternal,
    this.onShareExternal,
    this.shareCount = 0,
    this.onAuthorTap,
    this.onForumTap,
    this.onEdit,
    this.onDelete,
    this.onTagTap,
    this.showOwnerActions = false,
  });

  final ForumThread thread;
  final String forumTitle;
  final VoidCallback? onOpen;
  final VoidCallback? onComment;
  final Future<void> Function(int reactionId)? onReact;
  final VoidCallback? onShareInternal;
  final VoidCallback? onShareExternal;
  final int shareCount;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onForumTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final void Function(String tag)? onTagTap;
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
                if (imageAttachments.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  FeedCardFullWidthImages(
                    imageUrls: imageAttachments
                        .map((a) => a.displayImageUrl!)
                        .toList(),
                    onTap: onOpen,
                  ),
                ],
                if (thread.linkPreviews.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  FeedLinkPreview(previews: thread.linkPreviews),
                ],
                FeedCardTagsContinueRow(
                  tags: thread.tags,
                  onTagTap: onTagTap,
                  onContinue: onOpen,
                  showContinue: thread.listPreviewNeedsDetailLink,
                  embeddedInBody: true,
                ),
              ],
            ),
          ),
        ),
      ),
      beforeFooter: FeedAuthorSignature.maybe(
        html: author?.signatureHtml,
        plain: author?.signaturePlain,
        show: author?.contentShowSignature ?? true,
      ),
      footer: FeedCardActionBar(
        commentCount: thread.commentCount,
        likeCount: thread.firstPostReactionScore,
        onComment: onComment ?? onOpen,
        onReact: onReact,
        shareCount: shareCount,
        onShareInternal: onShareInternal,
        onShareExternal: onShareExternal,
      ),
    );
  }
}

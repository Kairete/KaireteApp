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
  });

  final ForumThread thread;
  final String forumTitle;
  final VoidCallback? onOpen;
  final VoidCallback? onComment;
  final Future<void> Function(int reactionId)? onReact;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onForumTap;

  @override
  Widget build(BuildContext context) {
    return FeedCardShell(
      header: ThreadFeedHeader(
        thread: thread,
        forumTitle: forumTitle,
        onAuthorTap: onAuthorTap,
        onForumTap: onForumTap,
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
              ],
            ),
          ),
        ),
      ),
      footer: FeedCardActionBar(
        commentCount: thread.commentCount,
        likeCount: thread.firstPostReactionScore,
        onComment: onComment ?? onOpen,
        onReact: onReact,
      ),
    );
  }
}

class ThreadFeedHeader extends StatelessWidget {
  const ThreadFeedHeader({
    super.key,
    required this.thread,
    required this.forumTitle,
    this.onAuthorTap,
    this.onForumTap,
  });

  final ForumThread thread;
  final String forumTitle;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onForumTap;

  @override
  Widget build(BuildContext context) {
    final author = thread.author;
    final nickname = author?.username ?? author?.label ?? '';

    return FeedCardHeaderBar(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onAuthorTap,
            child: FeedCardAvatar(url: author?.avatarUrl, name: author?.label),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, height: 1.15),
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: GestureDetector(
                          onTap: onAuthorTap,
                          child: Text(
                            nickname,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.authorName,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      if (forumTitle.isNotEmpty) ...[
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
                            onTap: onForumTap,
                            child: Text(
                              forumTitle,
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
                ),
                const SizedBox(height: 3),
                Text(
                  formatOmnifeedCardDate(thread.postDate),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
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

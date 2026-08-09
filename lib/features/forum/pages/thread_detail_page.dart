import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/feed/widgets/feed_author_signature.dart';
import 'package:kairete/features/feed/widgets/feed_comment_bar.dart';
import 'package:kairete/features/feed/widgets/feed_card_widgets.dart';
import 'package:kairete/features/feed/widgets/feed_nested_comment_thread.dart';
import 'package:kairete/features/feed/widgets/feed_share_sheet.dart';
import 'package:kairete/features/forum/controllers/thread_detail_controller.dart';
import 'package:kairete/features/forum/widgets/thread_post_body.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_time.dart';
import 'package:kairete/features/tagfeed/utils/tagfeed_navigation.dart';

class ThreadDetailPage extends StatefulWidget {
  const ThreadDetailPage({
    super.key,
    required this.threadId,
    this.forumTitle,
  });

  final int threadId;
  final String? forumTitle;

  @override
  State<ThreadDetailPage> createState() => _ThreadDetailPageState();
}

class _ThreadDetailPageState extends State<ThreadDetailPage> {
  late final String _tag;
  int _shareCount = 0;

  @override
  void initState() {
    super.initState();
    _tag = 'thread_${widget.threadId}';
    if (!Get.isRegistered<ThreadDetailController>(tag: _tag)) {
      Get.put(
        ThreadDetailController(
          threadId: widget.threadId,
          forumTitle: widget.forumTitle,
        ),
        tag: _tag,
      );
    }
  }

  @override
  void dispose() {
    if (Get.isRegistered<ThreadDetailController>(tag: _tag)) {
      Get.delete<ThreadDetailController>(tag: _tag);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ThreadDetailController>(tag: _tag);
    final title = widget.forumTitle ?? '';

    return Scaffold(
      backgroundColor: AppTheme.feedFooterBg,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Obx(() {
          final forum = c.thread.value?.forumTitle ?? title;
          return Text(forum.isNotEmpty ? forum : 'Discussione');
        }),
      ),
      body: Obx(() {
        if (c.isLoading.value && c.thread.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (c.errorMessage.value.isNotEmpty && c.thread.value == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(c.errorMessage.value, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: c.load,
                    child: const Text('Riprova'),
                  ),
                ],
              ),
            ),
          );
        }

        final thread = c.thread.value;
        if (thread == null) return const SizedBox.shrink();
        final forumLabel = thread.forumTitle ?? title;

        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: c.load,
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 8),
                  children: [
                    FeedCardShell(
                      header: FeedCardAuthorHeader(
                        avatarUrl: thread.author?.avatarUrl,
                        authorName:
                            thread.author?.username ?? thread.author?.label,
                        moduleLabel:
                            forumLabel.isNotEmpty ? forumLabel : null,
                        dateLabel: formatOmnifeedCardDate(thread.postDate),
                      ),
                      body: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ThreadPostBody(thread: thread),
                          if (thread.attachments
                              .any((a) => a.displayImageUrl != null)) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                              child: FeedCardFullWidthImages(
                                imageUrls: thread.attachments
                                    .map((a) => a.displayImageUrl)
                                    .whereType<String>()
                                    .toList(),
                              ),
                            ),
                          ],
                          if (thread.tags.isNotEmpty)
                            FeedCardTagsRow(
                              tags: thread.tags,
                              onTagTap: TagFeedNavigation.openTag,
                              embeddedInBody: true,
                            ),
                        ],
                      ),
                      beforeFooter: FeedAuthorSignature.maybe(
                        html: thread.author?.signatureHtml,
                        plain: thread.author?.signaturePlain,
                        show: thread.author?.contentShowSignature ?? true,
                      ),
                      footer: FeedCardActionBar(
                        commentCount: thread.commentCount,
                        likeCount: thread.firstPostReactionScore,
                        onComment: c.focusReplies,
                        onReact: (reactionId) => c.react(reactionId: reactionId),
                        shareCount: _shareCount,
                        onShareInternal: () async {
                          final result = await showFeedShareInternal(
                            context: context,
                            itemId: OmnifeedItemId.encode(
                              OmnifeedItemId.typeThread,
                              thread.threadId,
                            ),
                            previewText:
                                thread.messagePlainText ?? thread.title,
                          );
                          if (result != null && mounted) {
                            setState(() {
                              _shareCount = result.shareCount;
                            });
                          }
                        },
                        onShareExternal: () async {
                          final result = await showFeedShareExternal(
                            context: context,
                            itemId: OmnifeedItemId.encode(
                              OmnifeedItemId.typeThread,
                              thread.threadId,
                            ),
                            viewUrl: thread.viewUrl,
                          );
                          if (result != null && mounted) {
                            setState(() {
                              _shareCount = result.shareCount;
                            });
                          }
                        },
                      ),
                      comments: [
                        KeyedSubtree(
                          key: c.repliesKey,
                          child: Obx(
                            () => FeedNestedCommentThread(
                              comments: c.nestedReplies(),
                              highlightCommentId: c.highlightReplyId.value,
                              onReplyTap: c.beginReply,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Obx(() {
                      if (!c.hasMoreReplies.value) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                        child: OutlinedButton(
                          onPressed: c.isLoadingMore.value
                              ? null
                              : c.loadMoreReplies,
                          child: c.isLoadingMore.value
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Carica altre risposte'),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            Obx(
              () => FeedCommentBar(
                controller: c.replyCtrl,
                focusNode: c.replyFocus,
                isSending: c.isSending.value,
                onSend: c.sendFromBar,
                hintText: 'Scrivi una risposta…',
                replyLabel: c.replyDraft.replyLabel,
                onCancelReply: c.replyDraft.isActive ? c.cancelReply : null,
              ),
            ),
          ],
        );
      }),
    );
  }
}

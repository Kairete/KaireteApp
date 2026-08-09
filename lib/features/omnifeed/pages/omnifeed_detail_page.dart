import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/features/feed/widgets/feed_comment_bar.dart';
import 'package:kairete/features/feed/widgets/feed_nested_comment_thread.dart';
import 'package:kairete/features/feed/widgets/feed_share_sheet.dart';
import 'package:kairete/features/omnifeed/controllers/omnifeed_controller.dart';
import 'package:kairete/features/omnifeed/controllers/omnifeed_detail_controller.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/features/omnifeed/widgets/omnifeed_card.dart';
import 'package:kairete/features/tagfeed/utils/tagfeed_navigation.dart';

class OmnifeedDetailPage extends StatefulWidget {
  const OmnifeedDetailPage({super.key, required this.item});

  final OmnifeedItem item;

  @override
  State<OmnifeedDetailPage> createState() => _OmnifeedDetailPageState();
}

class _OmnifeedDetailPageState extends State<OmnifeedDetailPage> {
  @override
  void initState() {
    super.initState();
    Get.put(OmnifeedDetailController(initialItem: widget.item));
  }

  @override
  void dispose() {
    if (Get.isRegistered<OmnifeedDetailController>()) {
      Get.delete<OmnifeedDetailController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<OmnifeedDetailController>();
    return Scaffold(
      appBar: AppBar(
        title: Text(_detailTitle(c.item.value ?? widget.item)),
      ),
      body: Obx(() {
        if (c.isLoading.value && c.item.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final item = c.item.value ?? widget.item;
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 8),
                children: [
                  OmnifeedCard(
                    item: item,
                    expandBody: true,
                    onReact: (reactionId) => c.react(reactionId: reactionId),
                    onBookmark: c.toggleBookmark,
                    onShareInternal: () async {
                      final result = await showFeedShareInternal(
                        context: context,
                        itemId: item.itemId,
                        previewText:
                            item.messagePlainText ?? item.contentTitle,
                      );
                      if (result != null) {
                        c.applyShareResult(result);
                        if (Get.isRegistered<OmnifeedController>()) {
                          OmnifeedController.ensure()
                              .applyShareResult(item.itemId, result);
                        }
                      }
                    },
                    onShareExternal: () async {
                      final result = await showFeedShareExternal(
                        context: context,
                        itemId: item.itemId,
                        viewUrl: item.viewUrl,
                      );
                      if (result != null) {
                        c.applyShareResult(result);
                        if (Get.isRegistered<OmnifeedController>()) {
                          OmnifeedController.ensure()
                              .applyShareResult(item.itemId, result);
                        }
                      }
                    },
                    onTagTap: TagFeedNavigation.openTag,
                    comments: [
                      Obx(
                        () => FeedNestedCommentThread(
                          comments: c.nestedComments(),
                          highlightCommentId: c.highlightCommentId.value,
                          onReplyTap: c.beginReply,
                        ),
                      ),
                    ],
                  ),
                  if (c.commentsErrorMessage.value.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Text(
                        c.commentsErrorMessage.value,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  if (c.errorMessage.value.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        c.errorMessage.value,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
            Obx(
              () => FeedCommentBar(
                controller: c.commentCtrl,
                focusNode: c.commentFocus,
                isSending: c.isSending.value,
                onSend: c.sendFromBar,
                replyLabel: c.replyDraft.replyLabel,
                onCancelReply:
                    c.replyDraft.isActive ? c.cancelReply : null,
              ),
            ),
          ],
        );
      }),
    );
  }

  String _detailTitle(OmnifeedItem item) {
    if (item.contentType == 'social_news_article') {
      final category = item.categoryLabel?.trim();
      if (category != null && category.isNotEmpty) return category;
      final title = item.contentTitle?.trim();
      if (title != null && title.isNotEmpty) return title;
      return 'News';
    }
    return 'OmniFeed';
  }
}

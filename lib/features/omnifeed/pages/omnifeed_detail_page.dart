import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/features/feed/widgets/feed_card_widgets.dart';
import 'package:kairete/features/omnifeed/controllers/omnifeed_detail_controller.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_time.dart';
import 'package:kairete/features/omnifeed/widgets/omnifeed_card.dart';

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
      appBar: AppBar(title: const Text('OmniFeed')),
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
                    onReact: (reactionId) => c.react(reactionId: reactionId),
                    comments: c.comments
                        .map(
                          (comment) => FeedCommentTile(
                            authorName: comment.author?.label ??
                                comment.author?.username ??
                                '',
                            avatarUrl: comment.author?.avatarUrl,
                            dateLabel:
                                formatOmnifeedCardDate(comment.commentDate),
                            message: comment.messagePlainText,
                            likeCount: comment.reactionScore,
                            visitorReactionId: comment.visitorReactionId,
                            showCommentButton: false,
                          ),
                        )
                        .toList(),
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
            _CommentBar(controller: c),
          ],
        );
      }),
    );
  }
}

class _CommentBar extends StatelessWidget {
  const _CommentBar({required this.controller});

  final OmnifeedDetailController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.commentCtrl,
                decoration: const InputDecoration(
                  hintText: 'Scrivi un commento…',
                  isDense: true,
                ),
                minLines: 1,
                maxLines: 3,
              ),
            ),
            const SizedBox(width: 8),
            Obx(() {
              return IconButton(
                onPressed: controller.isSending.value
                    ? null
                    : controller.sendComment,
                icon: controller.isSending.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
              );
            }),
          ],
        ),
      ),
    );
  }
}

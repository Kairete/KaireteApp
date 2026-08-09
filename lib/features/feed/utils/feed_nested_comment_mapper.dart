import 'package:flutter/material.dart';
import 'package:kairete/features/feed/widgets/feed_nested_comment_thread.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_time.dart';

/// Converte commenti/risposte moduli diversi in [FeedNestedCommentData].
class FeedNestedCommentMapper {
  FeedNestedCommentMapper._();

  static List<FeedNestedCommentData> map({
    required List<NestedCommentSource> sources,
  }) {
    return sources
        .map(
          (source) => FeedNestedCommentData(
            id: source.id,
            parentId: source.parentId,
            authorName: source.authorName,
            avatarUrl: source.avatarUrl,
            dateLabel: source.dateLabel != null
                ? formatFeedCommentDate(source.dateLabel)
                : null,
            message: source.message,
            messageHtml: source.messageHtml,
            likeCount: source.likeCount,
            visitorReactionId: source.visitorReactionId,
            canReply: source.canReply,
            canLike: source.canLike,
            onAuthorTap: source.onAuthorTap,
            onLike: source.onLike,
          ),
        )
        .toList();
  }
}

class NestedCommentSource {
  const NestedCommentSource({
    required this.id,
    required this.parentId,
    required this.authorName,
    required this.message,
    this.avatarUrl,
    this.dateLabel,
    this.messageHtml,
    this.likeCount = 0,
    this.visitorReactionId,
    this.canReply = true,
    this.canLike = true,
    this.onAuthorTap,
    this.onLike,
  });

  final int id;
  final int parentId;
  final String authorName;
  final String message;
  final String? avatarUrl;
  final int? dateLabel;
  final String? messageHtml;
  final int likeCount;
  final int? visitorReactionId;
  final bool canReply;
  final bool canLike;
  final VoidCallback? onAuthorTap;
  final Future<void> Function(int reactionId)? onLike;
}

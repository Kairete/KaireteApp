import 'package:kairete/core/utils/json_parse.dart';
import 'package:kairete/features/feed/utils/feed_comment_parent.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';

class OmnifeedCommentsPage {
  OmnifeedCommentsPage({required this.comments});

  final List<OmnifeedComment> comments;

  factory OmnifeedCommentsPage.fromJson(Map<String, dynamic> json) {
    final raw = _readCommentsList(json);
    final comments = <OmnifeedComment>[];
    for (final entry in raw) {
      if (entry is! Map) continue;
      try {
        comments.add(
          OmnifeedComment.fromJson(Map<String, dynamic>.from(entry)),
        );
      } catch (_) {}
    }
    return OmnifeedCommentsPage(comments: comments);
  }

  static List<dynamic> _readCommentsList(Map<String, dynamic> json) {
    for (final key in const [
      'comments',
      'profile_post_comments',
      'profile_post_comment',
    ]) {
      final raw = json[key];
      if (raw is List) return raw;
    }
    return const [];
  }
}

class OmnifeedComment {
  OmnifeedComment({
    required this.commentId,
    required this.messagePlainText,
    this.messageRaw,
    this.parentCommentId = 0,
    this.depth = 0,
    this.author,
    this.reactionScore = 0,
    this.commentDate,
    this.visitorReactionId,
  });

  final int commentId;
  final String messagePlainText;
  final String? messageRaw;
  final int parentCommentId;
  final int depth;
  final OmnifeedAuthor? author;
  final int reactionScore;
  final int? commentDate;
  final int? visitorReactionId;

  factory OmnifeedComment.fromJson(Map<String, dynamic> json) {
    final commentId = JsonParse.intValue(json['comment_id']) > 0
        ? JsonParse.intValue(json['comment_id'])
        : JsonParse.intValue(json['profile_post_comment_id']);
    final plain = json['message_plain_text']?.toString().trim();
    final raw = json['message']?.toString().trim();
    final message = plain != null && plain.isNotEmpty
        ? plain
        : raw ??
            json['message_parsed']
                ?.toString()
                .replaceAll(RegExp(r'<[^>]*>'), ' ')
                .trim() ??
            '';
    final parentId = FeedCommentParent.readParentId(json);
    return OmnifeedComment(
      commentId: commentId,
      messagePlainText: message,
      messageRaw: raw,
      parentCommentId: parentId,
      depth: JsonParse.intValue(json['depth']),
      author: json['User'] is Map
          ? OmnifeedAuthor.fromJson(json['User'] as Map<String, dynamic>)
          : null,
      reactionScore: JsonParse.intValue(json['reaction_score']),
      commentDate: JsonParse.intOrNull(json['comment_date']),
      visitorReactionId: JsonParse.intOrNull(json['visitor_reaction_id']),
    );
  }

  OmnifeedComment withParentCommentId(int parentCommentId) {
    return OmnifeedComment(
      commentId: commentId,
      messagePlainText: messagePlainText,
      messageRaw: messageRaw,
      parentCommentId: parentCommentId,
      depth: depth,
      author: author,
      reactionScore: reactionScore,
      commentDate: commentDate,
      visitorReactionId: visitorReactionId,
    );
  }
}

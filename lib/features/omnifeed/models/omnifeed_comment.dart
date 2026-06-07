import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';

class OmnifeedCommentsPage {
  OmnifeedCommentsPage({required this.comments});

  final List<OmnifeedComment> comments;

  factory OmnifeedCommentsPage.fromJson(Map<String, dynamic> json) {
    final raw = json['comments'] as List<dynamic>? ?? [];
    return OmnifeedCommentsPage(
      comments: raw
          .map((e) => OmnifeedComment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class OmnifeedComment {
  OmnifeedComment({
    required this.commentId,
    required this.messagePlainText,
    this.author,
    this.reactionScore = 0,
    this.commentDate,
    this.visitorReactionId,
  });

  final int commentId;
  final String messagePlainText;
  final OmnifeedAuthor? author;
  final int reactionScore;
  final int? commentDate;
  final int? visitorReactionId;

  factory OmnifeedComment.fromJson(Map<String, dynamic> json) {
    return OmnifeedComment(
      commentId: json['comment_id'] as int? ?? 0,
      messagePlainText: json['message_plain_text']?.toString() ??
          json['message_parsed']?.toString().replaceAll(RegExp(r'<[^>]*>'), ' ') ??
          '',
      author: json['User'] is Map
          ? OmnifeedAuthor.fromJson(json['User'] as Map<String, dynamic>)
          : null,
      reactionScore: json['reaction_score'] as int? ?? 0,
      commentDate: json['comment_date'] as int?,
      visitorReactionId: json['visitor_reaction_id'] as int?,
    );
  }
}

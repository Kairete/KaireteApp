import 'package:kairete/features/blog/models/blog_entry.dart';

class BlogComment {
  BlogComment({
    required this.commentId,
    required this.messagePlainText,
    this.messageParsed,
    this.commentDate,
    this.reactionScore = 0,
    this.canReact = true,
    this.visitorReactionId,
    this.author,
  });

  final int commentId;
  final String messagePlainText;
  final String? messageParsed;
  final int? commentDate;
  final int reactionScore;
  final bool canReact;
  final int? visitorReactionId;
  final BlogAuthor? author;

  factory BlogComment.fromJson(Map<String, dynamic> json) {
    return BlogComment(
      commentId: json['comment_id'] as int? ?? 0,
      messagePlainText: json['message_plain_text']?.toString() ?? '',
      messageParsed: json['message_parsed']?.toString(),
      commentDate: json['comment_date'] as int?,
      reactionScore: json['reaction_score'] as int? ?? 0,
      canReact: json['can_react'] as bool? ?? true,
      visitorReactionId: json['visitor_reaction_id'] as int?,
      author: json['User'] is Map<String, dynamic>
          ? BlogAuthor.fromJson(json['User'] as Map<String, dynamic>)
          : null,
    );
  }
}

class BlogCommentsPage {
  BlogCommentsPage({required this.comments});

  final List<BlogComment> comments;

  factory BlogCommentsPage.fromJson(Map<String, dynamic> json) {
    final raw = json['comments'] as List<dynamic>? ?? [];
    return BlogCommentsPage(
      comments: raw
          .whereType<Map<String, dynamic>>()
          .map(BlogComment.fromJson)
          .toList(),
    );
  }
}

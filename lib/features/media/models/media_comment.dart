class MediaCommentAuthor {
  MediaCommentAuthor({
    required this.userId,
    required this.username,
    this.avatarUrl,
    this.displayName,
  });

  final int userId;
  final String username;
  final String? avatarUrl;
  final String? displayName;

  String get label =>
      displayName?.trim().isNotEmpty == true ? displayName! : username;

  factory MediaCommentAuthor.fromJson(Map<String, dynamic> json) {
    String? avatar;
    final urls = json['avatar_urls'];
    if (urls is Map) {
      avatar = urls['m']?.toString() ?? urls['s']?.toString();
    }
    return MediaCommentAuthor(
      userId: json['user_id'] as int? ?? 0,
      username: json['username']?.toString() ?? '',
      avatarUrl: avatar,
      displayName: json['custom_fields'] is Map
          ? null
          : null,
    );
  }
}

class MediaComment {
  MediaComment({
    required this.commentId,
    this.messagePlainText,
    this.commentDate,
    this.reactionScore = 0,
    this.visitorReactionId,
    this.author,
  });

  final int commentId;
  final String? messagePlainText;
  final int? commentDate;
  final int reactionScore;
  final int? visitorReactionId;
  final MediaCommentAuthor? author;

  factory MediaComment.fromJson(Map<String, dynamic> json) {
    MediaCommentAuthor? author;
    if (json['User'] is Map<String, dynamic>) {
      author =
          MediaCommentAuthor.fromJson(json['User'] as Map<String, dynamic>);
    }
    return MediaComment(
      commentId: json['comment_id'] as int? ??
          json['media_comment_id'] as int? ??
          0,
      messagePlainText: json['message_plain_text']?.toString() ??
          json['message']?.toString(),
      commentDate: json['comment_date'] as int?,
      reactionScore: json['reaction_score'] as int? ?? 0,
      visitorReactionId: json['visitor_reaction_id'] as int?,
      author: author,
    );
  }
}

class MediaCommentsPage {
  MediaCommentsPage({required this.comments});

  final List<MediaComment> comments;

  factory MediaCommentsPage.fromJson(Map<String, dynamic> json) {
    final raw = json['comments'];
    if (raw is! List) return MediaCommentsPage(comments: const []);
    return MediaCommentsPage(
      comments: raw
          .whereType<Map>()
          .map((e) => MediaComment.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

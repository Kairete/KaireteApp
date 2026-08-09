import 'package:kairete/core/utils/json_parse.dart';
import 'package:kairete/features/feed/utils/feed_comment_parent.dart';

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
      userId: JsonParse.intValue(json['user_id']),
      username: json['username']?.toString() ?? '',
      avatarUrl: avatar,
    );
  }
}

class MediaComment {
  MediaComment({
    required this.commentId,
    this.messagePlainText,
    this.messageRaw,
    this.messageParsed,
    this.parentCommentId = 0,
    this.depth = 0,
    this.commentDate,
    this.reactionScore = 0,
    this.visitorReactionId,
    this.author,
  });

  final int commentId;
  final String? messagePlainText;
  final String? messageRaw;
  final String? messageParsed;
  final int parentCommentId;
  final int depth;
  final int? commentDate;
  final int reactionScore;
  final int? visitorReactionId;
  final MediaCommentAuthor? author;

  factory MediaComment.fromJson(Map<String, dynamic> json) {
    final author = _authorFromJson(json);
    final raw = json['message']?.toString();
    final parsed = json['message_parsed']?.toString();
    final plain = json['message_plain_text']?.toString() ?? raw;
    return MediaComment(
      commentId: JsonParse.intValue(json['comment_id']) > 0
          ? JsonParse.intValue(json['comment_id'])
          : JsonParse.intValue(json['media_comment_id']),
      messagePlainText: plain,
      messageRaw: raw,
      messageParsed: parsed,
      parentCommentId: FeedCommentParent.readParentId(json),
      depth: FeedCommentParent.readDepth(json),
      commentDate: JsonParse.intOrNull(json['comment_date']),
      reactionScore: JsonParse.intValue(json['reaction_score']),
      visitorReactionId: JsonParse.intOrNull(json['visitor_reaction_id']),
      author: author,
    );
  }

  static MediaCommentAuthor? _authorFromJson(Map<String, dynamic> json) {
    for (final key in ['User', 'user']) {
      final value = json[key];
      if (value is Map) {
        return MediaCommentAuthor.fromJson(Map<String, dynamic>.from(value));
      }
    }
    final userId = JsonParse.intValue(json['user_id']);
    final username = json['username']?.toString() ?? '';
    if (userId > 0 || username.isNotEmpty) {
      return MediaCommentAuthor(userId: userId, username: username);
    }
    return null;
  }

  MediaComment withParentCommentId(int parentCommentId) {
    return MediaComment(
      commentId: commentId,
      messagePlainText: messagePlainText,
      messageRaw: messageRaw,
      messageParsed: messageParsed,
      parentCommentId: parentCommentId,
      depth: depth,
      commentDate: commentDate,
      reactionScore: reactionScore,
      visitorReactionId: visitorReactionId,
      author: author,
    );
  }

  MediaComment withDepth(int depth) {
    return MediaComment(
      commentId: commentId,
      messagePlainText: messagePlainText,
      messageRaw: messageRaw,
      messageParsed: messageParsed,
      parentCommentId: parentCommentId,
      depth: depth,
      commentDate: commentDate,
      reactionScore: reactionScore,
      visitorReactionId: visitorReactionId,
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
    final comments = <MediaComment>[];
    for (final entry in raw) {
      if (entry is! Map) continue;
      try {
        comments.add(
          MediaComment.fromJson(Map<String, dynamic>.from(entry)),
        );
      } catch (_) {}
    }
    return MediaCommentsPage(comments: comments);
  }
}

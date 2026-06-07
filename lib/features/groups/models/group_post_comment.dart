import 'package:kairete/features/groups/models/social_group.dart';

class GroupPostComment {
  GroupPostComment({
    required this.commentId,
    required this.groupPostId,
    required this.messagePlainText,
    this.commentDate,
    this.reactionScore = 0,
    this.canReact = true,
    this.visitorReactionId,
    this.author,
  });

  final int commentId;
  final int groupPostId;
  final String messagePlainText;
  final int? commentDate;
  final int reactionScore;
  final bool canReact;
  final int? visitorReactionId;
  final SocialGroupMember? author;

  factory GroupPostComment.fromJson(Map<String, dynamic> json) {
    return GroupPostComment(
      commentId: json['comment_id'] as int? ?? 0,
      groupPostId: json['group_post_id'] as int? ?? 0,
      messagePlainText: json['message_plain_text']?.toString() ?? '',
      commentDate: json['comment_date'] as int?,
      reactionScore: json['reaction_score'] as int? ?? 0,
      canReact: json['can_react'] as bool? ?? true,
      visitorReactionId: json['visitor_reaction_id'] as int?,
      author: json['User'] is Map<String, dynamic>
          ? SocialGroupMember.fromJson(json['User'] as Map<String, dynamic>)
          : null,
    );
  }
}

class GroupPostCommentsPage {
  GroupPostCommentsPage({required this.comments});

  final List<GroupPostComment> comments;

  factory GroupPostCommentsPage.fromJson(Map<String, dynamic> json) {
    final raw = json['comments'] as List<dynamic>? ?? [];
    return GroupPostCommentsPage(
      comments: raw
          .whereType<Map<String, dynamic>>()
          .map(GroupPostComment.fromJson)
          .toList(),
    );
  }
}

import 'package:kairete/features/groups/models/social_group.dart';

class GroupPost {
  GroupPost({
    required this.groupPostId,
    required this.groupId,
    required this.messagePlainText,
    this.postDate,
    this.commentCount = 0,
    this.reactionScore = 0,
    this.canReact = true,
    this.canComment = false,
    this.visitorReactionId,
    this.author,
  });

  final int groupPostId;
  final int groupId;
  final String messagePlainText;
  final int? postDate;
  final int commentCount;
  final int reactionScore;
  final bool canReact;
  final bool canComment;
  final int? visitorReactionId;
  final SocialGroupMember? author;

  factory GroupPost.fromJson(Map<String, dynamic> json) {
    return GroupPost(
      groupPostId: json['group_post_id'] as int? ?? 0,
      groupId: json['group_id'] as int? ?? 0,
      messagePlainText: json['message_plain_text']?.toString() ?? '',
      postDate: json['post_date'] as int?,
      commentCount: json['comment_count'] as int? ?? 0,
      reactionScore: json['reaction_score'] as int? ?? 0,
      canReact: json['can_react'] as bool? ?? true,
      canComment: json['can_comment'] as bool? ?? false,
      visitorReactionId: json['visitor_reaction_id'] as int?,
      author: json['User'] is Map<String, dynamic>
          ? SocialGroupMember.fromJson(json['User'] as Map<String, dynamic>)
          : null,
    );
  }
}

class GroupPostsPage {
  GroupPostsPage({required this.posts});

  final List<GroupPost> posts;

  factory GroupPostsPage.fromJson(Map<String, dynamic> json) {
    final raw = json['posts'] as List<dynamic>? ?? [];
    return GroupPostsPage(
      posts: raw
          .whereType<Map<String, dynamic>>()
          .map(GroupPost.fromJson)
          .toList(),
    );
  }
}

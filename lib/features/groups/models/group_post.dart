import 'package:kairete/features/groups/models/social_group.dart';
import 'package:kairete/core/models/feed_attachment.dart';

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
    this.attachments = const [],
    this.reactionIds = const [],
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
  final List<FeedAttachment> attachments;
  final List<int> reactionIds;

  static List<int> _parseReactionIds(Map<String, dynamic> json) {
    final ids = <int>{};
    for (final field in ['reaction_summary', 'reaction_counts', 'reactions']) {
      final raw = json[field];
      if (raw is Map) {
        raw.forEach((key, count) {
          final id = int.tryParse(key.toString()) ?? 0;
          final total = count is Map
              ? int.tryParse((count['count'] ?? count['reaction_count'] ?? 0).toString()) ?? 0
              : int.tryParse(count.toString()) ?? 0;
          if (id > 0 && total > 0) ids.add(id);
        });
      } else if (raw is List) {
        for (final item in raw) {
          if (item is Map) {
            final id = int.tryParse((item['reaction_id'] ?? item['id'] ?? '').toString()) ?? 0;
            final count = int.tryParse((item['count'] ?? item['reaction_count'] ?? 1).toString()) ?? 0;
            if (id > 0 && count > 0) ids.add(id);
          }
        }
      }
    }
    return ids.toList();
  }

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
      attachments: [
        ...FeedAttachment.parseList(json['Attachments'] ?? json['attachments']),
        if (json['image_urls'] is List)
          for (final url in json['image_urls'] as List)
            if (url is String && url.trim().isNotEmpty)
              FeedAttachment(directUrl: url.trim()),
      ],
      reactionIds: _parseReactionIds(json),
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

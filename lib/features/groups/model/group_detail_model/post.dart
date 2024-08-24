import 'package:get/get.dart';
import 'package:kairete/features/newsfeed/models/gr_model.dart';

import '../../../../helper/user.dart';
import '../../../../local/master_data.dart';
import '../../../newsfeed/models/newsfeed_model.dart';
import 'user.dart';

class Post {
  bool? canComment;
  bool? canDelete;
  bool? canEdit;
  bool? canReact;
  int? commentCount;
  int? firstCommentId;
  FirstComment? firstComment;
  Group? group;
  int? groupId;
  bool? isIgnored;
  int? lastCommentDate;
  List<dynamic>? latestComments;
  int? postDate;
  int? postId;
  List<Reactions>? reactions;
  bool? sticky;
  List<dynamic>? tags;
  User? user;
  int? userId;
  String? username;
  String? viewUrl;

  Post({
    this.canComment,
    this.canDelete,
    this.canEdit,
    this.canReact,
    this.commentCount,
    this.firstCommentId,
    this.firstComment,
    this.group,
    this.groupId,
    this.isIgnored,
    this.lastCommentDate,
    this.latestComments,
    this.postDate,
    this.postId,
    this.reactions,
    this.sticky,
    this.tags,
    this.user,
    this.userId,
    this.username,
    this.viewUrl,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        canComment: json['can_comment'] as bool?,
        canDelete: json['can_delete'] as bool?,
        canEdit: json['can_edit'] as bool?,
        canReact: json['can_react'] as bool?,
        commentCount: json['comment_count'] as int?,
        firstCommentId: json['first_comment_id'] as int?,
        firstComment: json['FirstComment'] == null
            ? null
            : FirstComment.fromJson(
                json['FirstComment'] as Map<String, dynamic>),
        group: json['Group'] == null
            ? null
            : Group.fromJson(json['Group'] as Map<String, dynamic>),
        groupId: json['group_id'] as int?,
        isIgnored: json['is_ignored'] as bool?,
        lastCommentDate: json['last_comment_date'] as int?,
        latestComments: json['LatestComments'] as List<dynamic>?,
        postDate: json['post_date'] as int?,
        postId: json['post_id'] as int?,
        reactions: (json['reactions'] as List<dynamic>?)
            ?.map((e) => Reactions.fromJson(e as Map<String, dynamic>))
            .toList(),
        sticky: json['sticky'] as bool?,
        tags: json['tags'] as List<dynamic>?,
        user: json['User'] == null
            ? null
            : User.fromJson(json['User'] as Map<String, dynamic>),
        userId: json['user_id'] as int?,
        username: json['username'] as String?,
        viewUrl: json['view_url'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'can_comment': canComment,
        'can_delete': canDelete,
        'can_edit': canEdit,
        'can_react': canReact,
        'comment_count': commentCount,
        'first_comment_id': firstCommentId,
        'FirstComment': firstComment?.toJson(),
        'Group': group?.toJson(),
        'group_id': groupId,
        'is_ignored': isIgnored,
        'last_comment_date': lastCommentDate,
        'LatestComments': latestComments,
        'post_date': postDate,
        'post_id': postId,
        'reactions': reactions,
        'sticky': sticky,
        'tags': tags,
        'User': user?.toJson(),
        'user_id': userId,
        'username': username,
        'view_url': viewUrl,
      };

  String? getReacitonsUrl() {
    if (reactions != null) {
      final userId = UserManager.instance.userId;
      final item =
          reactions!.firstWhereOrNull((element) => element.userId == userId);
      print('111');
      if (item != null) {
        final path = MasterDataManager.instance.reactionIcons
            .firstWhere((element) => element.reactionId == item.reactionId)
            .imageUrl;
        print(path);
        return path;
      }
    }
  }
}

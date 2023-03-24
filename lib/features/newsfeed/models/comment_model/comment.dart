import 'user.dart';

class Comment {
  bool? canEdit;
  bool? canHardDelete;
  bool? canReact;
  bool? canSoftDelete;
  bool? canViewAttachments;
  int? commentDate;
  bool? isReactedTo;
  String? message;
  String? messageParsed;
  String? messageState;
  int? profilePostCommentId;
  int? profilePostId;
  int? reactionScore;
  User? user;
  int? userId;
  String? username;
  String? viewUrl;
  String? warningMessage;

  Comment({
    this.canEdit,
    this.canHardDelete,
    this.canReact,
    this.canSoftDelete,
    this.canViewAttachments,
    this.commentDate,
    this.isReactedTo,
    this.message,
    this.messageParsed,
    this.messageState,
    this.profilePostCommentId,
    this.profilePostId,
    this.reactionScore,
    this.user,
    this.userId,
    this.username,
    this.viewUrl,
    this.warningMessage,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        canEdit: json['can_edit'] as bool?,
        canHardDelete: json['can_hard_delete'] as bool?,
        canReact: json['can_react'] as bool?,
        canSoftDelete: json['can_soft_delete'] as bool?,
        canViewAttachments: json['can_view_attachments'] as bool?,
        commentDate: json['comment_date'] as int?,
        isReactedTo: json['is_reacted_to'] as bool?,
        message: json['message'] as String?,
        messageParsed: json['message_parsed'] as String?,
        messageState: json['message_state'] as String?,
        profilePostCommentId: json['profile_post_comment_id'] as int?,
        profilePostId: json['profile_post_id'] as int?,
        reactionScore: json['reaction_score'] as int?,
        user: json['User'] == null
            ? null
            : User.fromJson(json['User'] as Map<String, dynamic>),
        userId: json['user_id'] as int?,
        username: json['username'] as String?,
        viewUrl: json['view_url'] as String?,
        warningMessage: json['warning_message'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'can_edit': canEdit,
        'can_hard_delete': canHardDelete,
        'can_react': canReact,
        'can_soft_delete': canSoftDelete,
        'can_view_attachments': canViewAttachments,
        'comment_date': commentDate,
        'is_reacted_to': isReactedTo,
        'message': message,
        'message_parsed': messageParsed,
        'message_state': messageState,
        'profile_post_comment_id': profilePostCommentId,
        'profile_post_id': profilePostId,
        'reaction_score': reactionScore,
        'User': user?.toJson(),
        'user_id': userId,
        'username': username,
        'view_url': viewUrl,
        'warning_message': warningMessage,
      };
}

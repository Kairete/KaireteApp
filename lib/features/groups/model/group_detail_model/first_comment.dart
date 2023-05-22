import 'user.dart';

class FirstComment {
  int? attachCount;
  bool? canDelete;
  bool? canEdit;
  bool? canReact;
  bool? canReply;
  bool? canReport;
  int? commentDate;
  int? commentId;
  int? commentLevel;
  int? contentId;
  String? contentType;
  int? editCount;
  List<dynamic>? embedMetadata;
  bool? hasMoreReplies;
  bool? isIgnored;
  bool? isReactedTo;
  int? lastEditDate;
  int? lastEditUserId;
  String? message;
  String? messageParsed;
  String? messagePlainText;
  int? parentId;
  int? reactionScore;
  int? replyCount;
  User? user;
  int? userId;
  String? username;
  String? viewUrl;

  FirstComment({
    this.attachCount,
    this.canDelete,
    this.canEdit,
    this.canReact,
    this.canReply,
    this.canReport,
    this.commentDate,
    this.commentId,
    this.commentLevel,
    this.contentId,
    this.contentType,
    this.editCount,
    this.embedMetadata,
    this.hasMoreReplies,
    this.isIgnored,
    this.isReactedTo,
    this.lastEditDate,
    this.lastEditUserId,
    this.message,
    this.messageParsed,
    this.messagePlainText,
    this.parentId,
    this.reactionScore,
    this.replyCount,
    this.user,
    this.userId,
    this.username,
    this.viewUrl,
  });

  factory FirstComment.fromJson(Map<String, dynamic> json) => FirstComment(
        attachCount: json['attach_count'] as int?,
        canDelete: json['can_delete'] as bool?,
        canEdit: json['can_edit'] as bool?,
        canReact: json['can_react'] as bool?,
        canReply: json['can_reply'] as bool?,
        canReport: json['can_report'] as bool?,
        commentDate: json['comment_date'] as int?,
        commentId: json['comment_id'] as int?,
        commentLevel: json['comment_level'] as int?,
        contentId: json['content_id'] as int?,
        contentType: json['content_type'] as String?,
        editCount: json['edit_count'] as int?,
        embedMetadata: json['embed_metadata'] as List<dynamic>?,
        hasMoreReplies: json['has_more_replies'] as bool?,
        isIgnored: json['is_ignored'] as bool?,
        isReactedTo: json['is_reacted_to'] as bool?,
        lastEditDate: json['last_edit_date'] as int?,
        lastEditUserId: json['last_edit_user_id'] as int?,
        message: json['message'] as String?,
        messageParsed: json['message_parsed'] as String?,
        messagePlainText: json['message_plain_text'] as String?,
        parentId: json['parent_id'] as int?,
        reactionScore: json['reaction_score'] as int?,
        replyCount: json['reply_count'] as int?,
        user: json['User'] == null
            ? null
            : User.fromJson(json['User'] as Map<String, dynamic>),
        userId: json['user_id'] as int?,
        username: json['username'] as String?,
        viewUrl: json['view_url'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'attach_count': attachCount,
        'can_delete': canDelete,
        'can_edit': canEdit,
        'can_react': canReact,
        'can_reply': canReply,
        'can_report': canReport,
        'comment_date': commentDate,
        'comment_id': commentId,
        'comment_level': commentLevel,
        'content_id': contentId,
        'content_type': contentType,
        'edit_count': editCount,
        'embed_metadata': embedMetadata,
        'has_more_replies': hasMoreReplies,
        'is_ignored': isIgnored,
        'is_reacted_to': isReactedTo,
        'last_edit_date': lastEditDate,
        'last_edit_user_id': lastEditUserId,
        'message': message,
        'message_parsed': messageParsed,
        'message_plain_text': messagePlainText,
        'parent_id': parentId,
        'reaction_score': reactionScore,
        'reply_count': replyCount,
        'User': user?.toJson(),
        'user_id': userId,
        'username': username,
        'view_url': viewUrl,
      };
}

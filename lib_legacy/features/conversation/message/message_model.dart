import 'package:kairete/features/login/models/user_model.dart';

class MessageModel {
  int? attachCount;
  bool? canEdit;
  bool? canReact;
  int? conversationId;
  bool? isReactedTo;
  bool? isUnread;
  String? message;
  int? messageDate;
  int? messageId;
  String? messageParsed;
  int? reactionScore;
  int? userId;
  String? username;
  String? viewUrl;
  User? user;

  MessageModel({
    this.attachCount,
    this.canEdit,
    this.canReact,
    this.conversationId,
    this.isReactedTo,
    this.isUnread,
    this.message,
    this.messageDate,
    this.messageId,
    this.messageParsed,
    this.reactionScore,
    this.userId,
    this.username,
    this.viewUrl,
    this.user,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        attachCount: json['attach_count'] as int?,
        canEdit: json['can_edit'] as bool?,
        canReact: json['can_react'] as bool?,
        conversationId: json['conversation_id'] as int?,
        isReactedTo: json['is_reacted_to'] as bool?,
        isUnread: json['is_unread'] as bool?,
        message: json['message'] as String?,
        messageDate: json['message_date'] as int?,
        messageId: json['message_id'] as int?,
        messageParsed: json['message_parsed'] as String?,
        reactionScore: json['reaction_score'] as int?,
        userId: json['user_id'] as int?,
        username: json['username'] as String?,
        viewUrl: json['view_url'] as String?,
        user: json['User'] != null ? User.fromJson(json['User']) : null,
      );

  Map<String, dynamic> toJson() => {
        'attach_count': attachCount,
        'can_edit': canEdit,
        'can_react': canReact,
        'conversation_id': conversationId,
        'is_reacted_to': isReactedTo,
        'is_unread': isUnread,
        'message': message,
        'message_date': messageDate,
        'message_id': messageId,
        'message_parsed': messageParsed,
        'reaction_score': reactionScore,
        'user_id': userId,
        'username': username,
        'view_url': viewUrl,
      };
}

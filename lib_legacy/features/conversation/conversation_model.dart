import 'package:kairete/features/login/models/user_model.dart';

class ConversationModel {
  String? title;
  int? id;
  AvatarUrls? avatarUrls;
  String? message;
  int? firstMessageId;

  ConversationModel({this.title});

  ConversationModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    id = json['conversation_id'];
    message = json['last_conversation_message_parsed'];
    avatarUrls = json['Starter']['avatar_urls'] != null
        ? AvatarUrls.fromJson(json['Starter']['avatar_urls'])
        : null;
    firstMessageId = json['first_message_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    return data;
  }
}

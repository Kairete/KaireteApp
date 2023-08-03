import 'latest_user.dart';

class ForumStaticModel {
  int? threads;
  int? messages;
  int? users;
  LatestUser? latestUser;

  ForumStaticModel({
    this.threads,
    this.messages,
    this.users,
    this.latestUser,
  });

  factory ForumStaticModel.fromJson(Map<String, dynamic> json) {
    return ForumStaticModel(
      threads: json['threads'] as int?,
      messages: json['messages'] as int?,
      users: json['users'] as int?,
      latestUser: json['latestUser'] == null
          ? null
          : LatestUser.fromJson(json['latestUser'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'threads': threads,
        'messages': messages,
        'users': users,
        'latestUser': latestUser?.toJson(),
      };
}

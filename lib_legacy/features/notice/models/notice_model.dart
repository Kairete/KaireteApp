import '../../login/models/user_model.dart';

class NoticeModel {
  String? action;
  int? alertId;
  String? alertText;
  dynamic alertUrl;
  int? alertedUserId;
  bool? autoRead;
  int? contentId;
  String? contentType;
  int? eventDate;
  int? readDate;
  User? user;
  int? userId;
  String? username;
  int? viewDate;

  NoticeModel({
    this.action,
    this.alertId,
    this.alertText,
    this.alertUrl,
    this.alertedUserId,
    this.autoRead,
    this.contentId,
    this.contentType,
    this.eventDate,
    this.readDate,
    this.user,
    this.userId,
    this.username,
    this.viewDate,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) => NoticeModel(
        action: json['action'] as String?,
        alertId: json['alert_id'] as int?,
        alertText: json['alert_text'] as String?,
        alertUrl: json['alert_url'] as dynamic,
        alertedUserId: json['alerted_user_id'] as int?,
        autoRead: json['auto_read'] as bool?,
        contentId: json['content_id'] as int?,
        contentType: json['content_type'] as String?,
        eventDate: json['event_date'] as int?,
        readDate: json['read_date'] as int?,
        user: json['User'] == null
            ? null
            : User.fromJson(json['User'] as Map<String, dynamic>),
        userId: json['user_id'] as int?,
        username: json['username'] as String?,
        viewDate: json['view_date'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'action': action,
        'alert_id': alertId,
        'alert_text': alertText,
        'alert_url': alertUrl,
        'alerted_user_id': alertedUserId,
        'auto_read': autoRead,
        'content_id': contentId,
        'content_type': contentType,
        'event_date': eventDate,
        'read_date': readDate,
        'User': user?.toJson(),
        'user_id': userId,
        'username': username,
        'view_date': viewDate,
      };
}

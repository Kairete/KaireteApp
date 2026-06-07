class UserAlert {
  UserAlert({
    required this.alertId,
    this.action,
    this.alertText,
    this.alertUrl,
    this.contentType,
    this.contentId,
    this.eventDate,
    this.readDate,
    this.viewDate,
    this.userId,
    this.username,
    this.avatarUrl,
  });

  final int alertId;
  final String? action;
  final String? alertText;
  final String? alertUrl;
  final String? contentType;
  final int? contentId;
  final int? eventDate;
  final int? readDate;
  final int? viewDate;
  final int? userId;
  final String? username;
  final String? avatarUrl;

  bool get isUnread => readDate == null || readDate == 0;

  bool get isUnviewed => viewDate == null || viewDate == 0;

  factory UserAlert.fromJson(Map<String, dynamic> json) {
    String? avatar;
    final user = json['User'];
    if (user is Map) {
      final urls = user['avatar_urls'];
      if (urls is Map) {
        avatar = urls['s']?.toString() ?? urls['m']?.toString();
      }
    }

    return UserAlert(
      alertId: json['alert_id'] as int? ?? 0,
      action: json['action']?.toString(),
      alertText: json['alert_text']?.toString(),
      alertUrl: json['alert_url']?.toString(),
      contentType: json['content_type']?.toString(),
      contentId: json['content_id'] as int?,
      eventDate: json['event_date'] as int?,
      readDate: json['read_date'] as int?,
      viewDate: json['view_date'] as int?,
      userId: json['user_id'] as int?,
      username: json['username']?.toString(),
      avatarUrl: avatar,
    );
  }
}

class AlertsPageResult {
  AlertsPageResult({
    required this.alerts,
    this.unviewedCount,
  });

  final List<UserAlert> alerts;
  final int? unviewedCount;
}

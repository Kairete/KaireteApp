class LatestUser {
  int? userId;
  String? username;
  int? usernameDate;
  int? usernameDateVisible;
  String? email;
  int? styleId;
  int? languageId;
  String? timezone;
  bool? visible;
  bool? activityVisible;
  int? userGroupId;

  LatestUser({
    this.userId,
    this.username,
    this.usernameDate,
    this.usernameDateVisible,
    this.email,
    this.styleId,
    this.languageId,
    this.timezone,
    this.visible,
    this.activityVisible,
    this.userGroupId,
  });

  factory LatestUser.fromJson(Map<String, dynamic> json) => LatestUser(
        userId: json['user_id'] as int?,
        username: json['username'] as String?,
        usernameDate: json['username_date'] as int?,
        usernameDateVisible: json['username_date_visible'] as int?,
        email: json['email'] as String?,
        styleId: json['style_id'] as int?,
        languageId: json['language_id'] as int?,
        timezone: json['timezone'] as String?,
        visible: json['visible'] as bool?,
        activityVisible: json['activity_visible'] as bool?,
        userGroupId: json['user_group_id'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'username': username,
        'username_date': usernameDate,
        'username_date_visible': usernameDateVisible,
        'email': email,
        'style_id': styleId,
        'language_id': languageId,
        'timezone': timezone,
        'visible': visible,
        'activity_visible': activityVisible,
        'user_group_id': userGroupId,
      };
}

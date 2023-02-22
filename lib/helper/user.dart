class UserManager {
  static UserManager? _instance;

  UserManager._();

  static UserManager get instance => _instance ??= UserManager._();

  String? userId;
}

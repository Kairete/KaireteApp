import 'package:jiffy/jiffy.dart';
import 'package:kairete/features/login/models/user_model.dart';

class UserManager {
  static UserManager? _instance;

  UserManager._();

  static UserManager get instance => _instance ??= UserManager._();

  UserModel? user;
}

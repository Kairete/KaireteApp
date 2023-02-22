import 'package:get/get.dart';
import 'package:kairete/constants/app_routes.dart';
import 'package:kairete/constants/key_constant.dart';
import 'package:kairete/features/login/models/user_model.dart';
import 'package:kairete/features/profile/usecase/user_profile_usecase.dart';
import 'package:kairete/helper/user.dart';
import 'package:kairete/local/data_local.dart';

import '../../../helper/notification_service.dart';

class UserProfileController extends GetxController {
  var user = User().obs;
  UserProfileUsecase usecase = IUserProfileUsecase();

  @override
  void onInit() {
    fetchItems();
    super.onInit();
  }

  void fetchItems() async {
    final json = await usecase.fetchData();
    user.value = User.fromJson(json['me']);
  }

  void onLogout() async {
    NotificationManager.instance.disableNotice();
    await LocalManager.instance.remove(key: PreferencesKey.token);
    UserManager.instance.userId = null;
    Get.offAllNamed(Routes.login);
  }
}

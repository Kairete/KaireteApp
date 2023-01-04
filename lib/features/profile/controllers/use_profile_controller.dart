import 'package:get/get.dart';
import 'package:kairete/constants/app_routes.dart';
import 'package:kairete/constants/key_constant.dart';
import 'package:kairete/features/login/models/user_model.dart';
import 'package:kairete/features/profile/usecase/user_profile_usecase.dart';
import 'package:kairete/local/data_local.dart';

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

  void onLogout() {
    // NotificationManager.instance.disableNotice();
    LocalManager.instance.remove(key: PreferencesKey.token);
    Get.offAllNamed(Routes.login);
  }
}

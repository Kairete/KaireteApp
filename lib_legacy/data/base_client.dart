import '../helper/user.dart';
import 'app_api_service.dart';

abstract class BaseClient {
  AppApiService appApiService = AppApiService();

  bool isShowPopupError = true;

  BaseClient() {
    onCreate();
  }

  void onCreate({dynamic userId}) {
    appApiService.create(
        isShowErrorPopup: isShowPopupError,
        userId: userId ?? UserManager.instance.userId.toString());
  }
}

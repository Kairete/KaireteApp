import 'app_api_service.dart';

abstract class BaseClient {
  AppApiService appApiService = AppApiService();

  bool isShowPopupError = true;

  BaseClient() {
    onCreate();
  }

  void onCreate() {
    appApiService.create(isShowErrorPopup: isShowPopupError);
  }
}

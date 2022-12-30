abstract class FCMNavigator {
  void nextStep({dynamic data});
}

class IFCMNavigator implements FCMNavigator {
  @override
  void nextStep({dynamic data}) {}
}

enum NoticeType { showcase, stream }

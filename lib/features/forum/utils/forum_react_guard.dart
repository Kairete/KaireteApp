import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/utils/app_toast.dart';

class ForumReactGuard {
  static Future<int?> currentUserId() async {
    await AppApi.instance.applySession();
    return AppApi.instance.sessionUserId;
  }

  static String? blockMessage({
    required int? userId,
    int? contentAuthorId,
  }) {
    if (userId == null || userId <= 0) {
      return 'Accedi per reagire.';
    }
    if (contentAuthorId != null &&
        contentAuthorId > 0 &&
        contentAuthorId == userId) {
      return 'Non puoi reagire ai tuoi contenuti.';
    }
    return null;
  }

  static void notifyBlocked(String message) => AppToast.info('Reazione', message);

  static void notifyError(String message) =>
      AppToast.error(AppToast.mapApiError(message));

  static void notifySuccess(String message) => AppToast.success(message);
}

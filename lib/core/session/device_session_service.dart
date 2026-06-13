import 'package:kairete/config/api_paths.dart';
import 'package:kairete/config/app_config.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/session/device_session_store.dart';
import 'package:kairete/features/auth/models/user_account.dart';

class DeviceSessionService {
  XenforoApi get _api => AppApi.instance.xenforo;

  Future<void> registerAfterAuth(int userId) async {
    if (userId <= 0) return;
    final deviceKey = await DeviceSessionStore.instance.getOrCreateDeviceKey();
    final json = await _api.post(
      ApiPaths.mobileDeviceSessions,
      body: {
        'device_key': deviceKey,
        'app_id': AppConfig.mobileAppId,
      },
    );
    final err = XenforoApi.firstErrorMessage(json);
    if (err != null) return;
    final token = json['session_token']?.toString();
    if (token != null && token.isNotEmpty) {
      await DeviceSessionStore.instance.saveSessionToken(token);
    }
  }

  /// Prova restore silenzioso prima del login manuale (cross-APK stesso device).
  Future<UserAccount?> tryRestoreFromDevice() async {
    final deviceKey = await DeviceSessionStore.instance.getOrCreateDeviceKey();
    final storedToken =
        await DeviceSessionStore.instance.getSessionToken() ?? '';

    final json = await _api.post(
      ApiPaths.mobileDeviceSessionsRestore,
      body: {
        'device_key': deviceKey,
        if (storedToken.isNotEmpty) 'session_token': storedToken,
        'app_id': AppConfig.mobileAppId,
      },
    );
    final err = XenforoApi.firstErrorMessage(json);
    if (err != null) return null;

    final userId = int.tryParse(json['user_id']?.toString() ?? '') ?? 0;
    if (userId <= 0) return null;

    final token = json['session_token']?.toString();
    if (token != null && token.isNotEmpty) {
      await DeviceSessionStore.instance.saveSessionToken(token);
    }

    await AppApi.instance.applySession(userId: userId);
    final me = await _api.get(ApiPaths.me);
    final meErr = XenforoApi.firstErrorMessage(me);
    if (meErr != null) return null;
    return UserAccount.fromApi(me);
  }
}

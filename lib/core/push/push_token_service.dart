import 'package:kairete/config/api_paths.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';

class PushTokenService {
  XenforoApi get _api => AppApi.instance.xenforo;

  Future<bool> registerToken({
    required int userId,
    required String token,
  }) async {
    if (userId <= 0 || token.isEmpty) return false;

    final json = await _api.post(
      '${ApiPaths.users}/$userId/firebase-device-token',
      body: {'token': token},
    );
    return XenforoApi.firstErrorMessage(json) == null;
  }

  Future<bool> unregisterToken({
    required int userId,
    required String token,
  }) async {
    if (userId <= 0 || token.isEmpty) return false;

    final json = await _api.delete(
      '${ApiPaths.users}/$userId/firebase-device-token',
      body: {'token': token},
    );
    return XenforoApi.firstErrorMessage(json) == null;
  }
}

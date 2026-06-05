import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/session/session_store.dart';

/// Client API condiviso (sessione XenForo via XF-Api-User).
class AppApi {
  AppApi._();
  static final AppApi instance = AppApi._();

  final XenforoApi xenforo = XenforoApi();

  Future<void> applySession({int? userId}) async {
    final id = userId ?? await SessionStore.instance.userId;
    xenforo.setUserId(id);
  }
}

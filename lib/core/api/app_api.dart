import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/session/session_store.dart';

/// Client API condiviso (sessione XenForo via XF-Api-User).
class AppApi {
  AppApi._();
  static final AppApi instance = AppApi._();

  final XenforoApi xenforo = XenforoApi();
  int? _activeUserId;

  int? get activeUserId => _activeUserId;

  void bindSession(int? userId) {
    _activeUserId = userId;
    xenforo.setUserId(userId);
  }

  void clearSession() {
    _activeUserId = null;
    xenforo.setUserId(null);
  }

  Future<void> applySession({int? userId}) async {
    final id = userId ?? _activeUserId ?? await SessionStore.instance.userId;
    if (id != null && id > 0) {
      _activeUserId = id;
    }
    xenforo.setUserId(_activeUserId);
  }

  Future<int?> get sessionUserId async {
    if (_activeUserId != null && _activeUserId! > 0) {
      return _activeUserId;
    }
    final stored = await SessionStore.instance.userId;
    if (stored != null && stored > 0) {
      _activeUserId = stored;
    }
    return _activeUserId;
  }
}

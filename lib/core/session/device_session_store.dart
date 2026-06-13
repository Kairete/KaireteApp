import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Chiave device persistente per SSO cross-APK (network Kairete).
class DeviceSessionStore {
  DeviceSessionStore._();

  static final DeviceSessionStore instance = DeviceSessionStore._();

  static const _storage = FlutterSecureStorage();
  static const _deviceKey = 'kairete_device_key';
  static const _sessionToken = 'kairete_device_session_token';

  Future<String> getOrCreateDeviceKey() async {
    final existing = await _storage.read(key: _deviceKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final key = 'kd_${DateTime.now().millisecondsSinceEpoch}_${_randomSuffix()}';
    await _storage.write(key: _deviceKey, value: key);
    return key;
  }

  Future<String?> getSessionToken() => _storage.read(key: _sessionToken);

  Future<void> saveSessionToken(String token) async {
    await _storage.write(key: _sessionToken, value: token);
  }

  Future<void> clearSessionToken() async {
    await _storage.delete(key: _sessionToken);
  }

  String _randomSuffix() {
    final n = DateTime.now().microsecondsSinceEpoch;
    return n.toRadixString(36);
  }
}

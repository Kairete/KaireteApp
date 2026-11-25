import 'dart:math';
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
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    final key = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
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

}

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionStore {
  SessionStore._();
  static final SessionStore instance = SessionStore._();

  static const _keyUserId = 'kairete_user_id';
  static const _keyUsername = 'kairete_username';

  final _storage = const FlutterSecureStorage();

  Future<int?> get userId async {
    final raw = await _storage.read(key: _keyUserId);
    if (raw == null || raw.isEmpty) return null;
    return int.tryParse(raw);
  }

  Future<String?> get username async => _storage.read(key: _keyUsername);

  Future<void> saveSession({required int userId, String? username}) async {
    await _storage.write(key: _keyUserId, value: userId.toString());
    if (username != null) {
      await _storage.write(key: _keyUsername, value: username);
    }
  }

  Future<void> clear() async {
    await _storage.delete(key: _keyUserId);
    await _storage.delete(key: _keyUsername);
  }
}

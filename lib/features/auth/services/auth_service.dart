import 'package:kairete/config/api_paths.dart';
import 'package:kairete/config/app_config.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/presence/app_presence_service.dart';
import 'package:kairete/core/push/push_notification_service.dart';
import 'package:kairete/core/session/device_session_store.dart';
import 'package:kairete/core/session/session_store.dart';
import 'package:kairete/features/auth/models/user_account.dart';

class AuthService {
  XenforoApi get _api => AppApi.instance.xenforo;

  Future<UserAccount> login({
    required String login,
    required String password,
  }) async {
    final deviceKey = await DeviceSessionStore.instance.getOrCreateDeviceKey();
    final json = await _api.postMobileAuth(
      'api/ms-auth-login',
      body: {
        'login': login.trim(),
        'password': password,
        'device_key': deviceKey,
        'app_id': AppConfig.mobileAppId,
      },
    );
    final err = XenforoApi.firstErrorMessage(json);
    if (err != null) throw AuthException(err);

    final token = json['session_token']?.toString() ?? '';
    if (token.isEmpty) {
      throw AuthException('Il server non ha restituito una sessione valida.');
    }
    final account = UserAccount.fromApi(json);
    if (account.userId <= 0) throw AuthException('Utente non valido.');
    await DeviceSessionStore.instance.saveSessionToken(token);
    await _persist(account);
    // Mobile login is authenticated by the server-issued token.
    // Do not call the legacy device-sessions endpoint with an untrusted user ID.
    return account;
  }

  Future<UserAccount> register({
    required String username,
    required String email,
    required String password,
    required DateTime dateOfBirth,
    Map<String, String>? customFields,
  }) async {
    final body = _registrationBody(
      username: username,
      email: email,
      password: password,
      dateOfBirth: dateOfBirth,
      customFields: customFields,
    );

    final json = await _api.post(ApiPaths.users, body: body);
    final err = XenforoApi.firstErrorMessage(json);
    if (err != null) throw AuthException(err);

    final user = json['user'];
    if (user is! Map<String, dynamic>) {
      throw AuthException('Registrazione non completata. Riprova.');
    }

    final account = UserAccount.fromApi(json);
    await _persist(account);
    await _afterAuth(account);
    return account;
  }

  Future<UserAccount?> restoreSession() async {
    final token = await DeviceSessionStore.instance.getSessionToken();
    if (token == null || token.isEmpty) return null;
    try {
      final json = await _api.postMobileAuth('api/ms-auth-verify', body: {
        'session_token': token,
        'device_key': await DeviceSessionStore.instance.getOrCreateDeviceKey(),
        'app_id': AppConfig.mobileAppId,
      });
      if (XenforoApi.firstErrorMessage(json) != null) {
        await DeviceSessionStore.instance.clearSessionToken();
        await SessionStore.instance.clear();
        return null;
      }
      final id = int.tryParse(json['user_id']?.toString() ?? '') ?? 0;
      if (id <= 0) throw AuthException('Sessione non valida.');
      final account = UserAccount(
        userId: id,
        username: json['username']?.toString() ?? '',
      );
      await _persist(account);
      return account;
    } catch (_) {
      await DeviceSessionStore.instance.clearSessionToken();
      await SessionStore.instance.clear();
      return null;
    }
  }

  Future<UserAccount> fetchMe() async {
    final json = await _api.get(ApiPaths.me);
    final err = XenforoApi.firstErrorMessage(json);
    if (err != null) throw AuthException(err);
    final account = UserAccount.fromApi(json);
    await _persist(account);
    return account;
  }

  Future<UserAccount> updateProfile({
    required int userId,
    required Map<String, String> customFields,
  }) async {
    await AppApi.instance.applySession(userId: userId);
    final body = <String, dynamic>{};
    customFields.forEach((key, value) {
      body['custom_fields[$key]'] = value;
    });

    var json = await _api.post(ApiPaths.me, body: body);
    var err = XenforoApi.firstErrorMessage(json);
    if (err == null) {
      return fetchMe();
    }

    json = await _api.post('${ApiPaths.users}/$userId/', body: body);
    err = XenforoApi.firstErrorMessage(json);
    if (err != null) throw AuthException(err);

    final account = UserAccount.fromApi(json);
    await _persist(account);
    return account;
  }

  Future<void> logout() async {
    final token = await DeviceSessionStore.instance.getSessionToken();
    if (token != null && token.isNotEmpty) {
      try {
        await _api.postMobileAuth('api/ms-auth-logout', body: {
          'session_token': token,
          'device_key': await DeviceSessionStore.instance.getOrCreateDeviceKey(),
          'app_id': AppConfig.mobileAppId,
        });
      } catch (_) {
        // Revoke best-effort if offline. Always clear local credentials.
      }
    }
    await DeviceSessionStore.instance.clearSessionToken();
    try { await AppPresenceService.instance.onUserLoggedOut(); } catch (_) {}
    try { await PushNotificationService.instance.unregister(); } catch (_) {}
    await SessionStore.instance.clear();
    AppApi.instance.clearSession();
  }

  Future<void> _afterAuth(UserAccount account) async {
    AppPresenceService.instance.onUserAuthenticated();

    try {
      await PushNotificationService.instance.register(userId: account.userId);
    } catch (_) {}
  }

  Future<void> _persist(UserAccount account) async {
    await SessionStore.instance.saveSession(
      userId: account.userId,
      username: account.username,
    );
    AppApi.instance.bindSession(account.userId);
  }

  Map<String, dynamic> _registrationBody({
    required String username,
    required String email,
    required String password,
    required DateTime dateOfBirth,
    Map<String, String>? customFields,
  }) {
    final body = <String, dynamic>{
      'username': username.trim(),
      'email': email.trim(),
      'password': password,
      'dob[day]': dateOfBirth.day,
      'dob[month]': dateOfBirth.month,
      'dob[year]': dateOfBirth.year,
      'timezone': 'Europe/Rome',
    };
    if (AppConfig.isTenantApp && AppConfig.tenantId > 0) {
      body['tenant_id'] = AppConfig.tenantId;
    }
    if (customFields != null) {
      customFields.forEach((key, value) {
        body['custom_fields[$key]'] = value;
      });
    }
    return body;
  }
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

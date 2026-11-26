import 'package:kairete/config/api_paths.dart';
import 'package:kairete/config/app_config.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/presence/app_presence_service.dart';
import 'package:kairete/core/push/push_notification_service.dart';
import 'package:kairete/core/session/session_store.dart';
import 'package:kairete/core/session/oauth_session.dart';
import 'package:kairete/features/auth/models/user_account.dart';

class AuthService {
  XenforoApi get _api => AppApi.instance.xenforo;

  /// Opens XenForo in the system browser and exchanges an OAuth2 PKCE code.
  Future<UserAccount> loginWithOAuth() async {
    await OAuthSession.instance.authorize();
    final account = await fetchMe();
    await _afterAuth(account);
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
    final token = await OAuthSession.instance.validToken();
    if (token == null || token.isEmpty) return null;
    final account = await fetchMe();
    await _afterAuth(account);
    return account;
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
    await AppPresenceService.instance.onUserLoggedOut();
    await PushNotificationService.instance.unregister();
    await OAuthSession.instance.clear();
    await SessionStore.instance.clear();
    AppApi.instance.clearSession();
  }

  Future<void> _afterAuth(UserAccount account) async {
    // Legacy device-session issuance is disabled until its backend is hardened.
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

import 'package:kairete/config/api_paths.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/session/session_store.dart';
import 'package:kairete/features/auth/models/user_account.dart';

class AuthService {
  XenforoApi get _api => AppApi.instance.xenforo;

  Future<UserAccount> login({
    required String login,
    required String password,
  }) async {
    final json = await _api.post(
      ApiPaths.auth,
      body: {'login': login.trim(), 'password': password},
    );
    final err = XenforoApi.firstErrorMessage(json);
    if (err != null) throw AuthException(err);

    final account = UserAccount.fromApi(json);
    await _persist(account);
    return account;
  }

  Future<UserAccount> register({
    required String username,
    required String email,
    required String password,
    required DateTime dateOfBirth,
    Map<String, String>? customFields,
  }) async {
    final body = <String, dynamic>{
      'username': username.trim(),
      'email': email.trim(),
      'password': password,
      'dob[day]': dateOfBirth.day,
      'dob[month]': dateOfBirth.month,
      'dob[year]': dateOfBirth.year,
      'timezone': 'Europe/Rome',
    };
    if (customFields != null) {
      customFields.forEach((key, value) {
        body['custom_fields[$key]'] = value;
      });
    }

    final json = await _api.post(ApiPaths.users, body: body);
    final err = XenforoApi.firstErrorMessage(json);
    if (err != null) throw AuthException(err);

    final user = json['user'];
    if (user is! Map<String, dynamic>) {
      throw AuthException('Registrazione non completata. Riprova.');
    }

    final account = UserAccount.fromApi(json);
    await _persist(account);
    return account;
  }

  Future<UserAccount?> restoreSession() async {
    final userId = await SessionStore.instance.userId;
    if (userId == null) return null;
    await AppApi.instance.applySession(userId: userId);
    return fetchMe();
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
    // XenForo richiede XF-Api-User = utente loggato (non 0/guest).
    await AppApi.instance.applySession(userId: userId);
    final body = <String, dynamic>{};
    customFields.forEach((key, value) {
      body['custom_fields[$key]'] = value;
    });

    final json = await _api.post('${ApiPaths.users}/$userId/', body: body);
    final err = XenforoApi.firstErrorMessage(json);
    if (err != null) throw AuthException(err);

    final account = UserAccount.fromApi(json);
    await _persist(account);
    return account;
  }

  Future<void> logout() async {
    await SessionStore.instance.clear();
    await AppApi.instance.applySession();
  }

  Future<void> _persist(UserAccount account) async {
    await SessionStore.instance.saveSession(
      userId: account.userId,
      username: account.username,
    );
    await AppApi.instance.applySession(userId: account.userId);
  }
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

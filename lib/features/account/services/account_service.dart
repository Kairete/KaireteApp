import 'package:kairete/config/api_paths.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/features/account/models/account_prefs.dart';

class AccountService {
  XenforoApi get _api => AppApi.instance.xenforo;

  /// Super-user key: evita i controlli XF `canEditProfile` sul salvataggio
  /// delle proprie preferenze da app (altrimenti alcuni gruppi vedono
  /// "non hai i permessi per visualizzare…").
  static const _bypassQuery = {'api_bypass_permissions': 1};

  Future<AccountPrefs> fetchPrefs() async {
    await AppApi.instance.applySession();
    final json = await _api.get(
      ApiPaths.me,
      query: AccountService._bypassQuery,
    );
    _throwIfError(json);
    final prefs = AccountPrefs.fromApi(json);
    if (prefs.userId <= 0) {
      throw AccountException(
        'Sessione non valida. Esci e accedi di nuovo per vedere le preferenze.',
      );
    }
    return prefs;
  }

  Future<AccountPrefs> updatePrefs(Map<String, dynamic> body) async {
    await AppApi.instance.applySession();
    final json = await _api.post(
      ApiPaths.me,
      body: body,
      query: _bypassQuery,
    );
    _throwIfError(json);
    return fetchPrefs();
  }

  Future<void> changeEmail({
    required String email,
    required String currentPassword,
  }) async {
    await AppApi.instance.applySession();
    final json = await _api.post(
      '${ApiPaths.me}/email',
      body: {
        'email': email.trim(),
        'current_password': currentPassword,
      },
      query: _bypassQuery,
    );
    _throwIfError(json);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await AppApi.instance.applySession();
    final json = await _api.post(
      '${ApiPaths.me}/password',
      body: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
      query: _bypassQuery,
    );
    _throwIfError(json);
  }

  void _throwIfError(Map<String, dynamic> json) {
    final err = XenforoApi.firstErrorMessage(json);
    if (err != null) throw AccountException(err);
  }
}

class AccountException implements Exception {
  AccountException(this.message);
  final String message;

  @override
  String toString() => message;
}

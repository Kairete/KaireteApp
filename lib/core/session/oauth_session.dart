import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kairete/config/app_config.dart';

/// Public OAuth2 client using PKCE. No API secrets or passwords are stored in the APK.
class OAuthSession {
  OAuthSession._();
  static final OAuthSession instance = OAuthSession._();

  static const _auth = FlutterAppAuth();
  static const _storage = FlutterSecureStorage();
  static const _accessKey = 'oauth_access_token';
  static const _refreshKey = 'oauth_refresh_token';
  static const _expiresKey = 'oauth_expires_at';

  static const redirectUrl = 'https://kairete.net/mobile/oauth/callback';
  static const scopes = <String>['user:read'];

  static const configuration = AuthorizationServiceConfiguration(
    authorizationEndpoint: 'https://kairete.net/oauth2/authorize',
    tokenEndpoint: 'https://kairete.net/api/oauth2/token',
  );

  bool get isConfigured => AppConfig.oauthClientId.isNotEmpty;

  Future<String> authorize() async {
    if (!isConfigured) {
      throw StateError(
        'Login OAuth non configurato: creare un client OAuth pubblico in XenForo e impostare KAIRETE_OAUTH_CLIENT_ID.',
      );
    }
    final result = await _auth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        AppConfig.oauthClientId,
        redirectUrl,
        serviceConfiguration: configuration,
        scopes: scopes,
      ),
    );
    final access = result.accessToken;
    if (access == null || access.isEmpty) {
      throw StateError('XenForo non ha restituito un token di accesso.');
    }
    await _save(access, result.refreshToken, result.accessTokenExpirationDateTime);
    return access;
  }

  Future<String?> validToken() async {
    final access = await _storage.read(key: _accessKey);
    if (access == null || access.isEmpty) return null;
    final expiresRaw = await _storage.read(key: _expiresKey);
    final expires = DateTime.tryParse(expiresRaw ?? '');
    if (expires == null || DateTime.now().isBefore(expires.subtract(const Duration(minutes: 2)))) {
      return access;
    }
    final refresh = await _storage.read(key: _refreshKey);
    if (!isConfigured || refresh == null || refresh.isEmpty) return null;
    try {
      final result = await _auth.token(
        TokenRequest(
          AppConfig.oauthClientId,
          redirectUrl,
          serviceConfiguration: configuration,
          refreshToken: refresh,
          scopes: scopes,
        ),
      );
      final updated = result.accessToken;
      if (updated == null || updated.isEmpty) return null;
      await _save(updated, result.refreshToken ?? refresh, result.accessTokenExpirationDateTime);
      return updated;
    } catch (_) {
      // An offline device must not be logged out or have its refresh token removed.
      rethrow;
    }
  }

  Future<void> _save(String access, String? refresh, DateTime? expires) async {
    await _storage.write(key: _accessKey, value: access);
    if (refresh != null && refresh.isNotEmpty) {
      await _storage.write(key: _refreshKey, value: refresh);
    }
    if (expires != null) {
      await _storage.write(key: _expiresKey, value: expires.toUtc().toIso8601String());
    } else {
      await _storage.delete(key: _expiresKey);
    }
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _expiresKey);
  }
}

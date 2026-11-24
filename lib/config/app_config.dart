import 'package:kairete/config/app_branding.dart';

/// Ambiente API Kairete.
class AppConfig {
  AppConfig._();

  static const AppEnvironment environment = AppEnvironment.production;

  static String get apiBaseUrl {
    switch (environment) {
      case AppEnvironment.stagingIt:
        return 'https://www.kairete.it/';
      case AppEnvironment.production:
        return 'https://www.kairete.net/';
    }
  }

  static String get appName => AppBranding.current.appName;
  static String get mobileAppId => AppBranding.current.mobileAppId;
  static int get tenantId => AppBranding.current.tenantId;
  static bool get isTenantApp => AppBranding.current.isTenantApp;
  static bool get isHubApp => AppBranding.current.isHubApp;

  static const String tenantHeader = 'X-Ms-Tenant-Id';

  /// Authentication credentials are provided by a future server-side auth flow.
  /// Never embed an administrative XenForo API key in a mobile app.
  static String get xenforoApiKey => '';

}

enum AppEnvironment { stagingIt, production }

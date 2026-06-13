import 'package:kairete/config/app_branding.dart';

/// Ambiente API Kairete.
class AppConfig {
  AppConfig._();

  static const AppEnvironment environment = AppEnvironment.stagingIt;

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

  /// Chiave XenForo REST API (ACP → API keys).
  /// Override build: --dart-define=KAIRETE_API_KEY=...
  static String get xenforoApiKey {
    const override = String.fromEnvironment('KAIRETE_API_KEY');
    if (override.isNotEmpty) return override;
    switch (environment) {
      case AppEnvironment.stagingIt:
        return 'Plv1OkxfSNp5IWpCfevYxG5loF9lJptQ';
      case AppEnvironment.production:
        return 'Bj-iF2DqxqJcBEolg9H6Qjp94ekWVM1Y';
    }
  }
}

enum AppEnvironment { stagingIt, production }

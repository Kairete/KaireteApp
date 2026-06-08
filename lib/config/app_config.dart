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

  static const String appName = 'Kairete';
  static const String mobileAppId = 'com.kairete.app';

  /// Chiave XenForo REST API (ACP → API keys).
  /// Override build: --dart-define=KAIRETE_API_KEY=...
  static String get xenforoApiKey {
    const override = String.fromEnvironment('KAIRETE_API_KEY');
    if (override.isNotEmpty) return override;
    switch (environment) {
      case AppEnvironment.stagingIt:
        // Kairete App Mobile Alpha @ kairete.it
        return 'Plv1OkxfSNp5IWpCfevYxG5loF9lJptQ';
      case AppEnvironment.production:
        return 'Bj-iF2DqxqJcBEolg9H6Qjp94ekWVM1Y';
    }
  }
}

enum AppEnvironment { stagingIt, production }

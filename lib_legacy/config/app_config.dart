/// Configurazione ambiente API.
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
  static const String tenantHeader = 'X-Ms-Tenant-Id';
  static const String appIdHeader = 'X-Kairete-App-Id';
  static const String mobileAppId = 'com.kairete.app';
  static const String xenforoApiKey = 'Bj-iF2DqxqJcBEolg9H6Qjp94ekWVM1Y';
}

enum AppEnvironment { stagingIt, production }

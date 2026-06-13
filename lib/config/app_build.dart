import 'package:kairete/config/app_branding.dart';
import 'package:kairete/config/app_config.dart';

/// Identificativo build visibile in app (aggiornare ad ogni release).
class AppBuild {
  AppBuild._();

  static const label = 'ms11';
  static const stamp = '20250613k';

  static String get appBarTitle {
    final name = AppBranding.current.appName;
    final tenant =
        AppConfig.isTenantApp ? ' · t${AppConfig.tenantId}' : '';
    return '$name · $label · $stamp$tenant';
  }
}

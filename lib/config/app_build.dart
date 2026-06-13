import 'package:kairete/config/app_branding.dart';

/// Identificativo build visibile in app (aggiornare ad ogni release).
class AppBuild {
  AppBuild._();

  static const label = 'ms1';
  static const stamp = '20250613a';

  static String get appBarTitle {
    final name = AppBranding.current.appName;
    return '$name · $label · $stamp';
  }
}

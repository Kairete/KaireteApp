import 'package:kairete/config/app_config.dart';

class ApiUrl {
  ApiUrl._();

  static String resolve(String? raw) {
    if (raw == null) return '';
    final value = raw.trim();
    if (value.isEmpty) return '';
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    if (value.startsWith('//')) {
      return 'https:$value';
    }
    var base = AppConfig.apiBaseUrl;
    if (!base.endsWith('/')) base = '$base/';
    if (value.startsWith('/')) {
      return '$base${value.substring(1)}';
    }
    return '$base$value';
  }
}

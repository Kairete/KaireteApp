import 'package:kairete/config/app_config.dart';
import 'package:kairete/core/api/app_api.dart';

class MediaPlayback {
  MediaPlayback._();

  static Map<String, String> apiHeaders() {
    final userId = AppApi.instance.activeUserId ?? 0;
    return {
      'XF-Api-Key': AppConfig.xenforoApiKey,
      'XF-Api-User': userId.toString(),
      'Accept': 'application/json',
    };
  }

  static String resolveAbsoluteUrl(String? raw) {
    final url = raw?.trim() ?? '';
    if (url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('//')) return 'https:$url';
    final base = AppConfig.apiBaseUrl;
    if (url.startsWith('/')) {
      return '${base.endsWith('/') ? base.substring(0, base.length - 1) : base}$url';
    }
    return base.endsWith('/') ? '$base$url' : '$base/$url';
  }

  static String dataEndpointUrl(int mediaId) {
    return resolveAbsoluteUrl('api/media/$mediaId/data');
  }

  static bool needsApiAuth(String url) {
    final lower = url.toLowerCase();
    return lower.contains('/api/media/') && lower.contains('/data');
  }
}

import 'package:flutter/foundation.dart';
import 'package:kairete/config/api_paths.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/features/app_widgets/models/app_widget_models.dart';

class AppWidgetsService {
  AppWidgetsService();

  static final AppWidgetsService instance = AppWidgetsService();

  final Map<String, _CacheEntry> _cache = {};
  static const _ttl = Duration(seconds: 60);

  XenforoApi get _api => AppApi.instance.xenforo;

  Future<AppWidgetPayload> fetch(
    String placement, {
    int? contextId,
    bool forceRefresh = false,
  }) async {
    final key = '$placement:${contextId ?? 0}';
    final cached = _cache[key];
    if (!forceRefresh &&
        cached != null &&
        DateTime.now().difference(cached.at) < _ttl) {
      return cached.payload;
    }

    try {
      await AppApi.instance.applySession();
      final query = <String, dynamic>{'placement': placement};
      if (contextId != null && contextId > 0) {
        query['context_id'] = contextId;
      }
      final data = await _api.get(ApiPaths.appWidgets, query: query);
      if (data['errors'] != null) {
        debugPrint('AppWidgets API errors ($placement): ${data['errors']}');
        return cached?.payload ?? AppWidgetPayload.empty();
      }
      final payload = AppWidgetPayload.fromJson(data);
      debugPrint(
        'AppWidgets ($placement): ${payload.widgets.length} widget(s), '
        'every=${payload.rules.insertEvery}',
      );
      _cache[key] = _CacheEntry(payload, DateTime.now());
      return payload;
    } catch (e, st) {
      debugPrint('AppWidgets fetch failed ($placement): $e\n$st');
      return cached?.payload ?? AppWidgetPayload.empty();
    }
  }

  void invalidate([String? placement]) {
    if (placement == null) {
      _cache.clear();
      return;
    }
    _cache.removeWhere((key, _) => key.startsWith('$placement:'));
  }
}

class _CacheEntry {
  _CacheEntry(this.payload, this.at);
  final AppWidgetPayload payload;
  final DateTime at;
}

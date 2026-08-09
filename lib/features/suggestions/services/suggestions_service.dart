import 'package:flutter/foundation.dart';
import 'package:kairete/config/api_paths.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/features/suggestions/models/suggestion_models.dart';

class SuggestionsService {
  SuggestionsService();

  static final SuggestionsService instance = SuggestionsService();

  XenforoApi get _api => AppApi.instance.xenforo;

  Future<SuggestionsPayload> fetch({
    String context = 'app',
    String? contentType,
    String? method,
    int page = 1,
    int? limit,
  }) async {
    await AppApi.instance.applySession();
    final query = <String, dynamic>{
      'context': context,
      'page': page,
      if (contentType != null && contentType.isNotEmpty)
        'content_type': contentType,
      if (method != null && method.isNotEmpty) 'method': method,
      if (limit != null && limit > 0) 'limit': limit,
    };

    // Prima la route OmniFeed (affidabile), poi fallback diretto sull'add-on.
    for (final path in [ApiPaths.suggestions, 'api/suggestions']) {
      try {
        final json = await _api.get(path, query: query);
        final err = XenforoApi.firstErrorMessage(json);
        if (err != null) {
          debugPrint('Suggestions API error ($path): $err');
          continue;
        }
        final payload = SuggestionsPayload.fromJson(json);
        debugPrint(
          'Suggestions ($path): ${payload.suggestions.length} item(s), '
          'enabled=${payload.enabled}, method=${payload.method}',
        );
        if (payload.suggestions.isNotEmpty || payload.enabled) {
          return payload;
        }
      } catch (e, st) {
        debugPrint('Suggestions fetch failed ($path): $e\n$st');
      }
    }
    return SuggestionsPayload.empty();
  }

  Future<void> dismiss({
    required String contentType,
    required int contentId,
  }) async {
    await AppApi.instance.applySession();
    try {
      await _api.post(
        ApiPaths.suggestionsDismiss,
        body: {
          'content_type': contentType,
          'content_id': contentId,
        },
      );
    } catch (_) {
      await _api.post(
        'api/suggestions/dismiss',
        body: {
          'content_type': contentType,
          'content_id': contentId,
        },
      );
    }
  }

  Future<int> restore({String? contentType, int? contentId}) async {
    await AppApi.instance.applySession();
    Map<String, dynamic> json;
    try {
      json = await _api.post(
        ApiPaths.suggestionsRestore,
        body: {
          if (contentType != null && contentType.isNotEmpty)
            'content_type': contentType,
          if (contentId != null && contentId > 0) 'content_id': contentId,
        },
      );
    } catch (_) {
      json = await _api.post(
        'api/suggestions/restore',
        body: {
          if (contentType != null && contentType.isNotEmpty)
            'content_type': contentType,
          if (contentId != null && contentId > 0) 'content_id': contentId,
        },
      );
    }
    if (json['restored'] is num) {
      return (json['restored'] as num).toInt();
    }
    return 0;
  }
}

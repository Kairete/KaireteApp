import 'package:kairete/config/api_paths.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/features/alerts/models/user_alert.dart';

class AlertsService {
  XenforoApi get _api => AppApi.instance.xenforo;

  Future<AlertsPageResult> fetchAlerts({int page = 1, int limit = 30}) async {
    await AppApi.instance.applySession();
    final json = await _api.get(
      ApiPaths.alerts,
      query: {'page': page, 'limit': limit},
    );
    _throwIfError(json);

    final raw = json['alerts'] as List<dynamic>? ?? [];
    final alerts = raw
        .whereType<Map<String, dynamic>>()
        .map(UserAlert.fromJson)
        .where((a) => a.alertId > 0)
        .toList();

    int? unviewed;
    final pagination = json['pagination'];
    if (pagination is Map && pagination['unviewed'] != null) {
      unviewed = pagination['unviewed'] as int?;
    }

    return AlertsPageResult(alerts: alerts, unviewedCount: unviewed);
  }

  Future<int> fetchUnviewedCount() async {
    await AppApi.instance.applySession();

    final meJson = await _api.get(ApiPaths.me);
    _throwIfError(meJson);
    final user = meJson['me'] as Map<String, dynamic>? ??
        meJson['user'] as Map<String, dynamic>? ??
        meJson;
    final counters = user['navigationCounters'] as Map<String, dynamic>?;
    final fromMe = counters?['alerts'];
    if (fromMe is int && fromMe >= 0) return fromMe;

    final page = await fetchAlerts(limit: 50);
    if (page.unviewedCount != null) return page.unviewedCount!;
    return page.alerts.where((a) => a.isUnviewed).length;
  }

  Future<void> markRead(int alertId) async {
    await AppApi.instance.applySession();
    final json = await _api.post(
      '${ApiPaths.alerts}$alertId/mark',
      body: {'read': 1, 'viewed': 1},
    );
    _throwIfError(json);
  }

  Future<void> markAllRead() async {
    await AppApi.instance.applySession();
    var json = await _api.post('${ApiPaths.alerts}mark-all', body: {'viewed': 1});
    _throwIfError(json);
    json = await _api.post('${ApiPaths.alerts}mark-all', body: {'read': 1});
    _throwIfError(json);
  }

  Future<int?> resolveThreadIdForPost(int postId) async {
    await AppApi.instance.applySession();
    final json = await _api.get('${ApiPaths.posts}$postId');
    _throwIfError(json);
    final post = json['post'] as Map<String, dynamic>? ?? json;
    return post['thread_id'] as int?;
  }

  void _throwIfError(Map<String, dynamic> json) {
    final err = XenforoApi.firstErrorMessage(json);
    if (err != null) throw AlertsException(err);
  }
}

class AlertsException implements Exception {
  AlertsException(this.message);
  final String message;

  @override
  String toString() => message;
}

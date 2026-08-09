import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kairete/core/tenant/tenant_bootstrap.dart';

/// Ultimo scope tenant valido dal server (sopravvive a restart se sync fallisce).
class TenantScopeCache {
  TenantScopeCache._();

  static const _storage = FlutterSecureStorage();
  static const _scopePrefix = 'tenant_scope_v1_';

  static String _key(int tenantId) => '$_scopePrefix$tenantId';

  static Future<void> save(TenantBootstrap bootstrap) async {
    if (bootstrap.tenantId <= 0) return;
    if (!_scopePayloadPresent(bootstrap.scope)) return;

    final payload = jsonEncode({
      'tenant_id': bootstrap.tenantId,
      'newsfeed_group_id': bootstrap.newsfeedGroupId,
      'scope': bootstrap.scope,
      'tabs': bootstrap.tabs,
      'saved_at': DateTime.now().toIso8601String(),
    });
    await _storage.write(key: _key(bootstrap.tenantId), value: payload);
  }

  static Future<TenantBootstrap?> load(int tenantId) async {
    if (tenantId <= 0) return null;
    final raw = await _storage.read(key: _key(tenantId));
    if (raw == null || raw.isEmpty) return null;

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final scopeRaw = json['scope'];
      if (scopeRaw is! Map || !_scopePayloadPresent(Map<String, dynamic>.from(scopeRaw))) {
        return null;
      }
      return TenantBootstrap.fromJson({
        'tenant_id': json['tenant_id'] ?? tenantId,
        'title': '',
        'slug': '',
        'newsfeed_group_id': json['newsfeed_group_id'] ?? 0,
        'scope': Map<String, dynamic>.from(scopeRaw),
        'tabs': json['tabs'] ?? const ['feed', 'blog', 'forum'],
      });
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear(int tenantId) async {
    if (tenantId <= 0) return;
    await _storage.delete(key: _key(tenantId));
  }

  static bool _scopePayloadPresent(Map<String, dynamic> scope) {
    for (final key in [
      'forumNodeIds',
      'blogIds',
      'blogCategoryIds',
      'mediaCategoryIds',
      'mediaAlbumIds',
      'groupId',
    ]) {
      if (scope.containsKey(key)) return true;
    }
    return false;
  }
}

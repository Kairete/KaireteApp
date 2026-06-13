import 'package:dio/dio.dart';
import 'package:kairete/config/api_paths.dart';
import 'package:kairete/config/app_config.dart';
import 'package:kairete/config/tenant_apps.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/tenant/tenant_api_helpers.dart';
import 'package:kairete/core/tenant/tenant_bootstrap.dart';

class TenantService {
  XenforoApi get _api => AppApi.instance.xenforo;

  Future<TenantBootstrap> loadBootstrap({int? tenantId}) async {
    final id = tenantId ?? AppConfig.tenantId;
    if (id <= 0) {
      throw TenantException('Tenant non configurato per questa APK.');
    }
    await AppApi.instance.applySession();

    Object? lastError;

    for (final loader in [
      () => _loadScopeFromOmniFeedTenantScope(id),
      () => _loadBootstrapFromMsTenantsQuery(id),
      () => _loadBootstrapFromDedicatedRoute(id),
      () => _loadBootstrapFromTenantsList(id),
    ]) {
      try {
        final bootstrap = await loader();
        if (bootstrap != null) return bootstrap;
      } on TenantException catch (e) {
        lastError = e;
      } on DioException catch (e) {
        lastError = e;
      } catch (e) {
        lastError = e;
      }
    }

    final fallback = _embeddedFallbackBootstrap(id);
    if (fallback != null) {
      return fallback;
    }

    if (lastError is TenantException) throw lastError;
    if (lastError is DioException) {
      throw TenantException(XenforoApi.connectionMessage(lastError));
    }
    throw TenantException('Bootstrap tenant non disponibile.');
  }

  /// Aggiorna scope/tabs dal server (mapping ACP live, senza nuova APK).
  Future<bool> syncScopeFromServer({int? tenantId}) async {
    if (!AppConfig.isTenantApp) return false;
    final id = tenantId ?? AppConfig.tenantId;
    if (id <= 0) return false;

    try {
      await AppApi.instance.applySession();
    } catch (_) {
      return false;
    }

    for (final loader in [
      () => _loadScopeFromOmniFeedTenantScope(id),
      () => _loadBootstrapFromMsTenantsQuery(id),
      () => _loadBootstrapFromDedicatedRoute(id),
      () => _loadBootstrapFromTenantsList(id),
    ]) {
      try {
        final incoming = await loader();
        if (incoming != null && _applyIncomingBootstrap(incoming)) {
          return true;
        }
      } catch (_) {}
    }

    return false;
  }

  bool _applyIncomingBootstrap(TenantBootstrap incoming) {
    if (!_scopePayloadPresent(incoming.scope) && incoming.newsfeedGroupId <= 0) {
      return false;
    }

    final current = TenantRuntime.bootstrap;
    if (current == null) {
      TenantRuntime.bootstrap = incoming;
    } else {
      TenantRuntime.bootstrap = current.mergeFrom(incoming);
    }
    return true;
  }

  bool _scopePayloadPresent(Map<String, dynamic> scope) {
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

  Future<TenantBootstrap?> _loadScopeFromOmniFeedTenantScope(int id) async {
    final json = await _api.get(
      ApiPaths.newsfeedTenantScope,
      query: {'tenant_id': id},
    );
    final err = XenforoApi.firstErrorMessage(json);
    if (err != null) {
      if (TenantApiHelpers.isMissingEndpoint(err)) return null;
      throw TenantException(err);
    }
    return _bootstrapFromScopePayload(json, id);
  }

  Future<TenantBootstrap?> _loadBootstrapFromMsTenantsQuery(int id) async {
    try {
      final json = await _api.get(
        ApiPaths.msTenants,
        query: {'tenant_id': id, 'bootstrap': 1},
      );
      return _parseBootstrapResponseOrNull(json, id);
    } on TenantException catch (e) {
      if (TenantApiHelpers.isMissingEndpoint(e.message)) return null;
      rethrow;
    }
  }

  Future<TenantBootstrap?> _loadBootstrapFromDedicatedRoute(int id) async {
    try {
      final json = await _api.get(ApiPaths.msTenantBootstrap(id));
      return _parseBootstrapResponseOrNull(json, id);
    } on TenantException catch (e) {
      if (TenantApiHelpers.isMissingEndpoint(e.message)) return null;
      rethrow;
    }
  }

  Future<TenantBootstrap?> _loadBootstrapFromTenantsList(int id) async {
    final json = await _api.get(ApiPaths.msTenants);
    final err = XenforoApi.firstErrorMessage(json);
    if (err != null) {
      if (TenantApiHelpers.isMissingEndpoint(err)) return null;
      throw TenantException(err);
    }

    final tenants = json['tenants'] as List<dynamic>? ?? [];
    for (final raw in tenants) {
      if (raw is! Map<String, dynamic>) continue;
      final tid = int.tryParse(raw['tenant_id']?.toString() ?? '') ?? 0;
      if (tid != id) continue;

      final scopeRaw = raw['scope'];
      if (scopeRaw is! Map) continue;

      return TenantBootstrap.fromJson({
        'tenant_id': tid,
        'title': raw['title']?.toString() ?? '',
        'slug': raw['slug']?.toString() ?? '',
        'newsfeed_group_id': raw['newsfeed_group_id'] ?? scopeRaw['groupId'] ?? 0,
        'scope': Map<String, dynamic>.from(scopeRaw),
        'tabs': raw['tabs'] ?? const ['feed', 'blog', 'forum'],
      });
    }

    return null;
  }

  TenantBootstrap? _parseBootstrapResponseOrNull(
    Map<String, dynamic> json,
    int id,
  ) {
    final err = XenforoApi.firstErrorMessage(json);
    if (err != null) {
      if (TenantApiHelpers.isMissingEndpoint(err)) return null;
      throw TenantException(err);
    }

    final bootstrapRaw = json['bootstrap'];
    if (bootstrapRaw is! Map<String, dynamic>) return null;

    final bootstrap = TenantBootstrap.fromJson(bootstrapRaw);
    if (bootstrap.tenantId <= 0) {
      return TenantBootstrap(
        tenantId: id,
        title: bootstrap.title,
        slug: bootstrap.slug,
        newsfeedGroupId: bootstrap.newsfeedGroupId,
        tabs: bootstrap.tabs,
        scope: bootstrap.scope,
      );
    }
    return bootstrap;
  }

  TenantBootstrap? _bootstrapFromScopePayload(
    Map<String, dynamic> json,
    int id,
  ) {
    final scopeRaw = json['scope'];
    final scope = scopeRaw is Map
        ? Map<String, dynamic>.from(scopeRaw)
        : const <String, dynamic>{};

    return TenantBootstrap.fromJson({
      'tenant_id': json['tenant_id'] ?? id,
      'title': json['title']?.toString() ?? '',
      'slug': json['slug']?.toString() ?? '',
      'newsfeed_group_id': json['newsfeed_group_id'] ?? scope['groupId'] ?? 0,
      'scope': scope,
      'tabs': json['tabs'] ?? const ['feed', 'blog', 'forum'],
    });
  }

  TenantBootstrap? _embeddedFallbackBootstrap(int id) {
    final def = TenantApps.byTenantId(id);
    if (def == null) return null;
    if (def.fallbackNewsfeedGroupId <= 0) return null;

    return TenantBootstrap(
      tenantId: id,
      title: def.appName,
      slug: def.slug,
      newsfeedGroupId: def.fallbackNewsfeedGroupId,
      tabs: const ['feed', 'blog', 'forum'],
      scope: {
        'groupId': def.fallbackNewsfeedGroupId,
      },
    );
  }

  Future<void> ensureTenantReady({bool forceReload = false}) async {
    if (!AppConfig.isTenantApp) return;
    if (forceReload) {
      TenantRuntime.bootstrap = await loadBootstrap();
      return;
    }
    if (TenantRuntime.bootstrap == null) {
      TenantRuntime.bootstrap = await loadBootstrap();
      return;
    }
    await syncScopeFromServer();
  }

  Future<void> refreshBootstrap() async {
    TenantRuntime.clear();
    await ensureTenantReady(forceReload: true);
  }
}

class TenantException implements Exception {
  TenantException(this.message);
  final String message;

  @override
  String toString() => message;
}

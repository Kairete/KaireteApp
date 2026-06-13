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

  static const _moduleScopeKeys = [
    'forumNodeIds',
    'blogIds',
    'blogCategoryIds',
    'mediaCategoryIds',
    'mediaAlbumIds',
  ];

  Future<TenantBootstrap> loadBootstrap({int? tenantId}) async {
    final id = tenantId ?? AppConfig.tenantId;
    if (id <= 0) {
      throw TenantException('Tenant non configurato per questa APK.');
    }
    await AppApi.instance.applySession();

    Object? lastError;
    TenantBootstrap? loaded;

    for (final loader in [
      () => _loadScopeFromOmniFeedTenantScope(id),
      () => _loadBootstrapFromMsTenantsQuery(id),
      () => _loadBootstrapFromDedicatedRoute(id),
      () => _loadBootstrapFromTenantsList(id),
    ]) {
      try {
        final bootstrap = await loader();
        if (bootstrap != null) {
          loaded = bootstrap;
          break;
        }
      } on TenantException catch (e) {
        lastError = e;
      } on DioException catch (e) {
        lastError = e;
      } catch (e) {
        lastError = e;
      }
    }

    loaded ??= _embeddedFallbackBootstrap(id);
    if (loaded == null) {
      if (lastError is TenantException) throw lastError;
      if (lastError is DioException) {
        throw TenantException(XenforoApi.connectionMessage(lastError));
      }
      throw TenantException('Bootstrap tenant non disponibile.');
    }

    return _finalizeBootstrap(loaded, id);
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

    var synced = false;
    for (final loader in [
      () => _loadScopeFromOmniFeedTenantScope(id),
      () => _loadBootstrapFromMsTenantsQuery(id),
      () => _loadBootstrapFromDedicatedRoute(id),
      () => _loadBootstrapFromTenantsList(id),
    ]) {
      try {
        final incoming = await loader();
        if (incoming != null && _applyIncomingBootstrap(incoming)) {
          synced = true;
        }
      } catch (_) {}
    }

    _applyEmbeddedModuleFallbackIfNeeded(id);
    return synced;
  }

  TenantBootstrap _finalizeBootstrap(TenantBootstrap bootstrap, int id) {
    var result = bootstrap;
    final current = TenantRuntime.bootstrap;
    if (current != null) {
      result = current.mergeFrom(bootstrap);
    }
    result = _withEmbeddedModuleFallback(result, id);
    TenantRuntime.bootstrap = result;
    return result;
  }

  void _applyEmbeddedModuleFallbackIfNeeded(int id) {
    final current = TenantRuntime.bootstrap;
    if (current == null) return;
    TenantRuntime.bootstrap = _withEmbeddedModuleFallback(current, id);
  }

  TenantBootstrap _withEmbeddedModuleFallback(TenantBootstrap bootstrap, int id) {
    final embedded = _embeddedModuleScope(id);
    if (embedded == null) return bootstrap;

    final scope = Map<String, dynamic>.from(bootstrap.scope);
    for (final key in _moduleScopeKeys) {
      if (_scopeIntList(scope, key).isNotEmpty) continue;
      if (embedded.scope.containsKey(key)) {
        scope[key] = embedded.scope[key];
      }
    }
    if (_scopeInt(scope, 'groupId') <= 0 && embedded.newsfeedGroupId > 0) {
      scope['groupId'] = embedded.newsfeedGroupId;
    }

    return TenantBootstrap(
      tenantId: bootstrap.tenantId,
      title: bootstrap.title,
      slug: bootstrap.slug,
      newsfeedGroupId: bootstrap.newsfeedGroupId > 0
          ? bootstrap.newsfeedGroupId
          : embedded.newsfeedGroupId,
      tabs: bootstrap.tabs.isNotEmpty ? bootstrap.tabs : embedded.tabs,
      scope: scope,
    );
  }

  int _scopeInt(Map<String, dynamic> scope, String key) {
    final raw = scope[key];
    if (raw is int && raw > 0) return raw;
    return int.tryParse(raw?.toString() ?? '') ?? 0;
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
    for (final key in [..._moduleScopeKeys, 'groupId']) {
      if (scope.containsKey(key)) return true;
    }
    return false;
  }

  List<int> _scopeIntList(Map<String, dynamic> scope, String key) {
    final raw = scope[key];
    if (raw is! List) return const [];
    return raw
        .map((v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0)
        .where((id) => id > 0)
        .toList();
  }

  Future<TenantBootstrap?> _loadScopeFromOmniFeedTenantScope(int id) async {
    try {
      final json = await _api.get(
        ApiPaths.newsfeedTenantScope,
        query: {'tenant_id': id},
      );
      final err = XenforoApi.firstErrorMessage(json);
      if (err != null) {
        if (_isScopeLoaderSoftError(err)) return null;
        throw TenantException(err);
      }
      return _bootstrapFromScopePayload(json, id);
    } on DioException catch (e) {
      if (_isScopeLoaderSoftStatus(e.response?.statusCode)) return null;
      rethrow;
    }
  }

  bool _isScopeLoaderSoftError(String? message) {
    if (message == null || message.isEmpty) return false;
    if (TenantApiHelpers.isMissingEndpoint(message)) return true;
    final lower = message.toLowerCase();
    return lower.contains('server error') ||
        lower.contains('unexpected error') ||
        lower.contains('try again');
  }

  bool _isScopeLoaderSoftStatus(int? statusCode) {
    if (statusCode == null) return false;
    return statusCode == 404 || statusCode >= 500;
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
    } on DioException catch (e) {
      if (_isScopeLoaderSoftStatus(e.response?.statusCode)) return null;
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
    } on DioException catch (e) {
      if (_isScopeLoaderSoftStatus(e.response?.statusCode)) return null;
      rethrow;
    }
  }

  Future<TenantBootstrap?> _loadBootstrapFromTenantsList(int id) async {
    try {
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
          'newsfeed_group_id':
              raw['newsfeed_group_id'] ?? scopeRaw['groupId'] ?? 0,
          'scope': Map<String, dynamic>.from(scopeRaw),
          'tabs': raw['tabs'] ?? const ['feed', 'blog', 'forum'],
        });
      }
    } on DioException catch (e) {
      if (_isScopeLoaderSoftStatus(e.response?.statusCode)) return null;
      rethrow;
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
    if (def.fallbackNewsfeedGroupId <= 0 && !_hasEmbeddedModules(def)) {
      return null;
    }

    return TenantBootstrap(
      tenantId: id,
      title: def.appName,
      slug: def.slug,
      newsfeedGroupId: def.fallbackNewsfeedGroupId,
      tabs: const ['feed', 'blog', 'forum'],
      scope: _embeddedScopeMap(def),
    );
  }

  TenantBootstrap? _embeddedModuleScope(int id) {
    final def = TenantApps.byTenantId(id);
    if (def == null || !_hasEmbeddedModules(def)) return null;

    return TenantBootstrap(
      tenantId: id,
      title: def.appName,
      slug: def.slug,
      newsfeedGroupId: def.fallbackNewsfeedGroupId,
      tabs: const ['feed', 'blog', 'forum'],
      scope: _embeddedScopeMap(def),
    );
  }

  bool _hasEmbeddedModules(TenantAppDefinition def) {
    return def.fallbackForumNodeIds.isNotEmpty ||
        def.fallbackBlogIds.isNotEmpty ||
        def.fallbackBlogCategoryIds.isNotEmpty ||
        def.fallbackNewsfeedGroupId > 0;
  }

  Map<String, dynamic> _embeddedScopeMap(TenantAppDefinition def) {
    return {
      if (def.fallbackForumNodeIds.isNotEmpty)
        'forumNodeIds': def.fallbackForumNodeIds,
      if (def.fallbackBlogIds.isNotEmpty) 'blogIds': def.fallbackBlogIds,
      if (def.fallbackBlogCategoryIds.isNotEmpty)
        'blogCategoryIds': def.fallbackBlogCategoryIds,
      if (def.fallbackNewsfeedGroupId > 0)
        'groupId': def.fallbackNewsfeedGroupId,
    };
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
    _applyEmbeddedModuleFallbackIfNeeded(AppConfig.tenantId);
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

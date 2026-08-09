import 'package:dio/dio.dart';
import 'package:kairete/config/api_paths.dart';
import 'package:kairete/config/app_branding.dart';
import 'package:kairete/config/app_config.dart';
import 'package:kairete/config/tenant_apps.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/tenant/tenant_api_helpers.dart';
import 'package:kairete/core/tenant/tenant_bootstrap.dart';
import 'package:kairete/core/tenant/tenant_scope.dart';
import 'package:kairete/core/tenant/tenant_scope_cache.dart';
import 'package:kairete/core/theme/app_theme.dart';

class TenantService {
  XenforoApi get _api => AppApi.instance.xenforo;

  static const tenantMapBlog = 'kairete_blog';
  static const tenantMapAlbum = 'mg_album';

  static const _moduleScopeKeys = [
    'forumNodeIds',
    'blogIds',
    'blogCategoryIds',
    'mediaCategoryIds',
    'mediaAlbumIds',
    'groupId',
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
          TenantRuntime.lastScopeSyncOk = true;
          TenantRuntime.scopeFromCache = false;
          _clearScopeSyncFailure();
          await _persistScopeIfServerPayload(bootstrap);
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

    if (loaded == null) {
      _finalizeScopeSyncFailure(lastError);
    }

    loaded ??= await _loadCachedBootstrap(id);
    loaded ??= _embeddedGroupOnlyBootstrap(id);
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

    for (final loader in [
      () => _loadScopeFromOmniFeedTenantScope(id),
      () => _loadBootstrapFromMsTenantsQuery(id),
      () => _loadBootstrapFromDedicatedRoute(id),
      () => _loadBootstrapFromTenantsList(id),
    ]) {
      try {
        final incoming = await loader();
        if (incoming != null && _applyIncomingBootstrap(incoming)) {
          await _persistScopeIfServerPayload(incoming);
          TenantRuntime.lastScopeSyncOk = true;
          TenantRuntime.scopeFromCache = false;
          _clearScopeSyncFailure();
          return true;
        }
      } catch (e) {
        _recordScopeSyncFailureFromError(
          TenantRuntime.lastScopeSyncEndpoint ?? ApiPaths.newsfeedTenantScope,
          e,
        );
      }
    }

    TenantRuntime.lastScopeSyncOk = false;
    return false;
  }

  void _clearScopeSyncFailure() {
    TenantRuntime.lastScopeSyncEndpoint = null;
    TenantRuntime.lastScopeSyncHttpStatus = null;
    TenantRuntime.lastScopeSyncErrorMessage = null;
  }

  void _recordScopeSyncFailure({
    required String endpoint,
    int? httpStatus,
    String? message,
  }) {
    TenantRuntime.lastScopeSyncEndpoint = endpoint;
    TenantRuntime.lastScopeSyncHttpStatus = httpStatus;
    TenantRuntime.lastScopeSyncErrorMessage = message;
  }

  void _recordScopeSyncFailureFromError(String endpoint, Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      final data = error.response?.data;
      var message = error.message ?? 'Errore di rete';
      if (data is Map) {
        final apiErr = XenforoApi.firstErrorMessage(
          Map<String, dynamic>.from(data),
        );
        if (apiErr != null && apiErr.isNotEmpty) {
          message = apiErr;
        }
      }
      _recordScopeSyncFailure(
        endpoint: endpoint,
        httpStatus: status,
        message: message,
      );
      return;
    }
    if (error is TenantException) {
      _recordScopeSyncFailure(
        endpoint: endpoint,
        message: error.message,
      );
      return;
    }
    _recordScopeSyncFailure(
      endpoint: endpoint,
      message: error.toString(),
    );
  }

  void _finalizeScopeSyncFailure(Object? lastError) {
    if (lastError != null) {
      _recordScopeSyncFailureFromError(
        TenantRuntime.lastScopeSyncEndpoint ?? ApiPaths.newsfeedTenantScope,
        lastError,
      );
    }
  }

  /// Dettaglio debug per banner sync fallita (ms14+).
  static String scopeSyncDebugSummary() {
    if (TenantRuntime.lastScopeSyncOk) return '';
    final endpoint =
        TenantRuntime.lastScopeSyncEndpoint ?? ApiPaths.newsfeedTenantScope;
    final status = TenantRuntime.lastScopeSyncHttpStatus;
    final err = TenantRuntime.lastScopeSyncErrorMessage;
    final buf = StringBuffer('Endpoint: $endpoint');
    if (status != null) {
      buf.write('\nHTTP: $status');
    }
    if (err != null && err.isNotEmpty) {
      buf.write('\nErrore: $err');
    }
    buf.write(
      '\nInstalla OmniFeed 1.7.84+ (e Multisite 1.9.103+) da ACP su kairete.it, poi pull-to-refresh.',
    );
    return buf.toString();
  }

  Future<void> _persistScopeIfServerPayload(TenantBootstrap bootstrap) async {
    if (!_scopePayloadPresent(bootstrap.scope)) return;
    await TenantScopeCache.save(bootstrap);
  }

  TenantBootstrap _finalizeBootstrap(TenantBootstrap bootstrap, int id) {
    var result = bootstrap;
    final current = TenantRuntime.bootstrap;
    if (current != null && _isServerScopePayload(bootstrap)) {
      result = current.applyServerScope(bootstrap);
    } else if (current != null) {
      result = current.mergeFrom(bootstrap);
    }
    result = _withEmbeddedGroupOnly(result, id);
    TenantRuntime.bootstrap = result;
    if (result.branding.isNotEmpty) {
      final profile = AppBranding.applyRuntimeBranding(result.branding);
      if (profile != null) AppTheme.applyBranding(profile);
    }
    return result;
  }

  /// Solo groupId offline: mai forum/blog hardcoded.
  TenantBootstrap _withEmbeddedGroupOnly(TenantBootstrap bootstrap, int id) {
    final def = TenantApps.byTenantId(id);
    if (def == null || def.fallbackNewsfeedGroupId <= 0) return bootstrap;

    final scope = Map<String, dynamic>.from(bootstrap.scope);
    if (_scopeInt(scope, 'groupId') <= 0 && bootstrap.newsfeedGroupId <= 0) {
      scope['groupId'] = def.fallbackNewsfeedGroupId;
    }

    return TenantBootstrap(
      tenantId: bootstrap.tenantId,
      title: bootstrap.title.isNotEmpty ? bootstrap.title : def.appName,
      slug: bootstrap.slug.isNotEmpty ? bootstrap.slug : def.slug,
      newsfeedGroupId: bootstrap.newsfeedGroupId > 0
          ? bootstrap.newsfeedGroupId
          : def.fallbackNewsfeedGroupId,
      tabs: bootstrap.tabs.isNotEmpty ? bootstrap.tabs : const ['feed'],
      scope: scope,
      homepageLayout: bootstrap.homepageLayout,
      branding: bootstrap.branding,
    );
  }

  bool _isServerScopePayload(TenantBootstrap bootstrap) {
    for (final key in _moduleScopeKeys) {
      if (bootstrap.scope.containsKey(key)) return true;
    }
    return bootstrap.newsfeedGroupId > 0;
  }

  bool _applyIncomingBootstrap(TenantBootstrap incoming) {
    if (!_scopePayloadPresent(incoming.scope) && incoming.newsfeedGroupId <= 0) {
      return false;
    }

    final current = TenantRuntime.bootstrap;
    if (current == null) {
      TenantRuntime.bootstrap = incoming;
    } else {
      TenantRuntime.bootstrap = current.applyServerScope(incoming);
    }
    final branding = TenantRuntime.bootstrap?.branding;
    if (branding != null && branding.isNotEmpty) {
      final profile = AppBranding.applyRuntimeBranding(branding);
      if (profile != null) AppTheme.applyBranding(profile);
    }
    return true;
  }

  Future<TenantBootstrap?> _loadCachedBootstrap(int id) async {
    final cached = await TenantScopeCache.load(id);
    if (cached == null) return null;
    TenantRuntime.scopeFromCache = true;
    return cached;
  }

  /// Messaggio utente quando blog/forum risultano vuoti.
  static String mappingUnavailableMessage() {
    if (TenantRuntime.lastScopeSyncOk && !TenantScope.hasMappedModules) {
      return 'Nessun forum/blog mappato per questo tenant in ACP.';
    }
    if (TenantRuntime.scopeFromCache) {
      return 'Mapping offline (ultima sync salvata). Pull-to-refresh per aggiornare dal server.';
    }
    return 'Mapping non caricato dal server. Verifica login e aggiorna OmniFeed/Multisite su kairete.it, poi pull-to-refresh.';
  }

  bool _scopePayloadPresent(Map<String, dynamic> scope) {
    for (final key in _moduleScopeKeys) {
      if (scope.containsKey(key)) return true;
    }
    return false;
  }

  int _scopeInt(Map<String, dynamic> scope, String key) {
    final raw = scope[key];
    if (raw is int && raw > 0) return raw;
    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  Future<TenantBootstrap?> _loadScopeFromOmniFeedTenantScope(int id) async {
    const endpoint = ApiPaths.newsfeedTenantScope;
    TenantRuntime.lastScopeSyncEndpoint = endpoint;
    try {
      final json = await _api.get(
        endpoint,
        query: {'tenant_id': id},
      );
      final err = XenforoApi.firstErrorMessage(json);
      if (err != null) {
        if (_isScopeLoaderSoftError(err)) {
          _recordScopeSyncFailure(endpoint: endpoint, message: err);
          return null;
        }
        throw TenantException(err);
      }
      return _bootstrapFromScopePayload(json, id);
    } on DioException catch (e) {
      if (_isScopeLoaderSoftStatus(e.response?.statusCode)) {
        _recordScopeSyncFailureFromError(endpoint, e);
        return null;
      }
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
    const endpoint = ApiPaths.msTenants;
    TenantRuntime.lastScopeSyncEndpoint = '$endpoint?bootstrap=1';
    try {
      final json = await _api.get(
        endpoint,
        query: {'tenant_id': id, 'bootstrap': 1},
      );
      return _parseBootstrapResponseOrNull(json, id);
    } on TenantException catch (e) {
      if (TenantApiHelpers.isMissingEndpoint(e.message)) {
        _recordScopeSyncFailure(endpoint: endpoint, message: e.message);
        return null;
      }
      rethrow;
    } on DioException catch (e) {
      if (_isScopeLoaderSoftStatus(e.response?.statusCode)) {
        _recordScopeSyncFailureFromError(endpoint, e);
        return null;
      }
      rethrow;
    }
  }

  Future<TenantBootstrap?> _loadBootstrapFromDedicatedRoute(int id) async {
    final endpoint = ApiPaths.msTenantBootstrap(id);
    TenantRuntime.lastScopeSyncEndpoint = endpoint;
    try {
      final json = await _api.get(endpoint);
      return _parseBootstrapResponseOrNull(json, id);
    } on TenantException catch (e) {
      if (TenantApiHelpers.isMissingEndpoint(e.message)) {
        _recordScopeSyncFailure(endpoint: endpoint, message: e.message);
        return null;
      }
      rethrow;
    } on DioException catch (e) {
      if (_isScopeLoaderSoftStatus(e.response?.statusCode)) {
        _recordScopeSyncFailureFromError(endpoint, e);
        return null;
      }
      rethrow;
    }
  }

  Future<TenantBootstrap?> _loadBootstrapFromTenantsList(int id) async {
    const endpoint = ApiPaths.msTenants;
    TenantRuntime.lastScopeSyncEndpoint = endpoint;
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
      if (_isScopeLoaderSoftStatus(e.response?.statusCode)) {
        _recordScopeSyncFailureFromError(endpoint, e);
        return null;
      }
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
        homepageLayout: bootstrap.homepageLayout,
        branding: bootstrap.branding,
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

  TenantBootstrap? _embeddedGroupOnlyBootstrap(int id) {
    final def = TenantApps.byTenantId(id);
    if (def == null || def.fallbackNewsfeedGroupId <= 0) return null;

    return TenantBootstrap(
      tenantId: id,
      title: def.appName,
      slug: def.slug,
      newsfeedGroupId: def.fallbackNewsfeedGroupId,
      tabs: const ['feed'],
      scope: {'groupId': def.fallbackNewsfeedGroupId},
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
    }
  }

  Future<void> refreshBootstrap() async {
    TenantRuntime.clear();
    final bootstrap = await loadBootstrap();
    TenantRuntime.bootstrap = bootstrap;
    if (!TenantRuntime.lastScopeSyncOk && TenantScope.hasMappedModules) {
      TenantRuntime.scopeFromCache = true;
    }
  }

  /// Twin app: registra blog/album appena creati in xf_ms_tenant_mapping (ACP).
  /// Aggiorna lo scope solo dal server — nessuna patch locale.
  Future<void> registerContentMapping({
    required int contentId,
    required String serverContentType,
  }) async {
    if (!AppConfig.isTenantApp || AppConfig.tenantId <= 0 || contentId <= 0) {
      return;
    }

    await ensureTenantReady();
    try {
      await AppApi.instance.applySession();
      final json = await _api.post(
        ApiPaths.newsfeedTenantScope,
        body: {
          'tenant_id': AppConfig.tenantId,
          'content_type': serverContentType,
          'content_id': contentId,
        },
      );
      if (XenforoApi.firstErrorMessage(json) != null) return;

      await TenantScopeCache.clear(AppConfig.tenantId);
      await syncScopeFromServer();
    } catch (_) {
      // Se POST non disponibile, mappa manualmente in ACP Multisite.
    }
  }
}

class TenantException implements Exception {
  TenantException(this.message);
  final String message;

  @override
  String toString() => message;
}

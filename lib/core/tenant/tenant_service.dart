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
      () => _loadBootstrapFromMsTenantsQuery(id),
      () => _loadBootstrapFromDedicatedRoute(id),
      () => _loadBootstrapFromTenantsList(id),
    ]) {
      try {
        return await loader();
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

  /// Aggiorna scope/tabs dal server senza resettare la sessione (mapping ACP live).
  Future<bool> syncScopeFromServer({int? tenantId}) async {
    if (!AppConfig.isTenantApp) return false;
    final id = tenantId ?? AppConfig.tenantId;
    if (id <= 0) return false;

    try {
      await AppApi.instance.applySession();
      final json = await _api.get(ApiPaths.msTenants);
      final err = XenforoApi.firstErrorMessage(json);
      if (err != null) return false;

      final tenants = json['tenants'] as List<dynamic>? ?? [];
      for (final raw in tenants) {
        if (raw is! Map<String, dynamic>) continue;
        final tid = int.tryParse(raw['tenant_id']?.toString() ?? '') ?? 0;
        if (tid != id) continue;

        final scopeRaw = raw['scope'];
        final scope = scopeRaw is Map
            ? Map<String, dynamic>.from(scopeRaw)
            : const <String, dynamic>{};

        final incoming = TenantBootstrap.fromJson({
          'tenant_id': tid,
          'title': raw['title']?.toString() ?? '',
          'slug': raw['slug']?.toString() ?? '',
          'newsfeed_group_id': raw['newsfeed_group_id'] ?? scope['groupId'] ?? 0,
          'scope': scope,
          'tabs': raw['tabs'] ?? const ['feed', 'blog', 'forum'],
        });

        final current = TenantRuntime.bootstrap;
        if (current == null) {
          TenantRuntime.bootstrap = incoming;
        } else {
          TenantRuntime.bootstrap = current.mergeFrom(incoming);
        }
        return true;
      }
    } catch (_) {}

    return false;
  }

  Future<TenantBootstrap> _loadBootstrapFromMsTenantsQuery(int id) async {
    final json = await _api.get(
      ApiPaths.msTenants,
      query: {'tenant_id': id, 'bootstrap': 1},
    );
    return _parseBootstrapResponse(json, id);
  }

  Future<TenantBootstrap> _loadBootstrapFromDedicatedRoute(int id) async {
    final json = await _api.get(ApiPaths.msTenantBootstrap(id));
    return _parseBootstrapResponse(json, id);
  }

  /// Usa api/ms-tenants (già attivo su kairete.it) con scope incluso nel server 1.9.101+.
  Future<TenantBootstrap> _loadBootstrapFromTenantsList(int id) async {
    final json = await _api.get(ApiPaths.msTenants);
    final err = XenforoApi.firstErrorMessage(json);
    if (err != null) throw TenantException(err);

    final tenants = json['tenants'] as List<dynamic>? ?? [];
    for (final raw in tenants) {
      if (raw is! Map<String, dynamic>) continue;
      final tid = int.tryParse(raw['tenant_id']?.toString() ?? '') ?? 0;
      if (tid != id) continue;

      final scopeRaw = raw['scope'];
      final scope = scopeRaw is Map
          ? Map<String, dynamic>.from(scopeRaw)
          : const <String, dynamic>{};

      if (_scopeHasAnyMapping(scope) ||
          (int.tryParse(raw['newsfeed_group_id']?.toString() ?? '') ?? 0) > 0) {
        return TenantBootstrap.fromJson({
          'tenant_id': tid,
          'title': raw['title']?.toString() ?? '',
          'slug': raw['slug']?.toString() ?? '',
          'newsfeed_group_id': raw['newsfeed_group_id'] ?? scope['groupId'] ?? 0,
          'scope': scope,
          'tabs': raw['tabs'] ?? const ['feed', 'blog', 'forum'],
        });
      }
    }

    throw TenantException('Scope tenant non presente nella lista ms-tenants.');
  }

  bool _scopeHasAnyMapping(Map<String, dynamic> scope) {
    for (final key in [
      'forumNodeIds',
      'blogIds',
      'blogCategoryIds',
      'mediaCategoryIds',
      'mediaAlbumIds',
      'groupId',
    ]) {
      final raw = scope[key];
      if (raw is List && raw.isNotEmpty) return true;
      if (raw is int && raw > 0) return true;
    }
    return false;
  }

  bool _scopeHasModuleMapping(Map<String, dynamic> scope) {
    for (final key in [
      'forumNodeIds',
      'blogIds',
      'blogCategoryIds',
      'mediaCategoryIds',
      'mediaAlbumIds',
    ]) {
      final raw = scope[key];
      if (raw is List && raw.isNotEmpty) return true;
    }
    return false;
  }

  TenantBootstrap _parseBootstrapResponse(
    Map<String, dynamic> json,
    int id,
  ) {
    final err = XenforoApi.firstErrorMessage(json);
    if (err != null) {
      if (TenantApiHelpers.isMissingEndpoint(err)) {
        throw TenantException(err);
      }
      throw TenantException(err);
    }

    final bootstrapRaw = json['bootstrap'];
    if (bootstrapRaw is! Map<String, dynamic>) {
      throw TenantException('Bootstrap tenant non disponibile.');
    }

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

  TenantBootstrap? _embeddedFallbackBootstrap(int id) {
    final def = TenantApps.byTenantId(id);
    if (def == null) return null;

    return TenantBootstrap(
      tenantId: id,
      title: def.appName,
      slug: def.slug,
      newsfeedGroupId: def.fallbackNewsfeedGroupId,
      tabs: const ['feed', 'blog', 'forum'],
      scope: {
        if (def.fallbackForumNodeIds.isNotEmpty)
          'forumNodeIds': def.fallbackForumNodeIds,
        if (def.fallbackBlogIds.isNotEmpty) 'blogIds': def.fallbackBlogIds,
        if (def.fallbackBlogCategoryIds.isNotEmpty)
          'blogCategoryIds': def.fallbackBlogCategoryIds,
        if (def.fallbackNewsfeedGroupId > 0)
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
    _maybeUpgradeEmbeddedBootstrap();
    await syncScopeFromServer();
  }

  void _maybeUpgradeEmbeddedBootstrap() {
    final current = TenantRuntime.bootstrap;
    if (current == null) return;
    if (_scopeHasModuleMapping(current.scope)) return;

    final embedded = _embeddedFallbackBootstrap(current.tenantId);
    if (embedded != null && _scopeHasModuleMapping(embedded.scope)) {
      TenantRuntime.bootstrap = current.mergeFrom(embedded);
    }
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

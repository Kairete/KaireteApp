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
      return bootstrap.copyWith(tenantId: id);
    }
    return bootstrap;
  }

  /// Fallback offline quando le route bootstrap non sono ancora su kairete.it.
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

  Future<void> ensureTenantReady() async {
    if (!AppConfig.isTenantApp) return;
    if (TenantRuntime.bootstrap != null) return;
    TenantRuntime.bootstrap = await loadBootstrap();
  }
}

class TenantException implements Exception {
  TenantException(this.message);
  final String message;

  @override
  String toString() => message;
}

extension on TenantBootstrap {
  TenantBootstrap copyWith({int? tenantId}) {
    return TenantBootstrap(
      tenantId: tenantId ?? this.tenantId,
      title: title,
      slug: slug,
      newsfeedGroupId: newsfeedGroupId,
      tabs: tabs,
      scope: scope,
    );
  }
}

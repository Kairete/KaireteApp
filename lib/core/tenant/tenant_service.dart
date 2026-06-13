import 'package:kairete/config/api_paths.dart';
import 'package:kairete/config/app_config.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/tenant/tenant_bootstrap.dart';

class TenantService {
  XenforoApi get _api => AppApi.instance.xenforo;

  Future<TenantBootstrap> loadBootstrap({int? tenantId}) async {
    final id = tenantId ?? AppConfig.tenantId;
    if (id <= 0) {
      throw TenantException('Tenant non configurato per questa APK.');
    }
    await AppApi.instance.applySession();
    final json = await _api.get(ApiPaths.msTenantBootstrap(id));
    final err = XenforoApi.firstErrorMessage(json);
    if (err != null) throw TenantException(err);

    final bootstrapRaw = json['bootstrap'];
    if (bootstrapRaw is! Map<String, dynamic>) {
      throw TenantException('Bootstrap tenant non disponibile.');
    }
    return TenantBootstrap.fromJson(bootstrapRaw);
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

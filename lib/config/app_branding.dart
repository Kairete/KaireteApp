import 'package:flutter/material.dart';
import 'package:kairete/config/tenant_apps.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Profilo visivo hub o community (stesso layout, colori e nome app diversi).
class AppBrandingProfile {
  const AppBrandingProfile({
    required this.variantId,
    required this.appName,
    required this.mobileAppId,
    required this.primary,
    required this.accent,
    required this.appBarBorderBottom,
    this.logoAssetPath,
    this.tenantId = 0,
  });

  factory AppBrandingProfile.hub() => const AppBrandingProfile(
        variantId: 'hub',
        appName: 'Kairete',
        mobileAppId: 'com.kairete.app',
        primary: Color(0xFF176249),
        accent: Color(0xFFC45C3E),
        appBarBorderBottom: Color(0xFF0F4A35),
      );

  factory AppBrandingProfile.fromTenant(TenantAppDefinition tenant) {
    const tenantIdOverride = int.fromEnvironment('TENANT_ID', defaultValue: 0);
    return AppBrandingProfile(
      variantId: tenant.slug,
      appName: tenant.appName,
      mobileAppId: tenant.mobileAppId,
      tenantId: tenantIdOverride > 0 ? tenantIdOverride : tenant.defaultTenantId,
      primary: tenant.primary,
      accent: tenant.accent,
      appBarBorderBottom: tenant.appBarBorderBottom,
      logoAssetPath: tenant.logoAssetPath,
    );
  }

  final String variantId;
  final String appName;
  final String mobileAppId;
  final int tenantId;
  final Color primary;
  final Color accent;
  final Color appBarBorderBottom;
  final String? logoAssetPath;

  bool get isTenantApp => tenantId > 0;
  bool get isHubApp => tenantId <= 0;
}

class AppBranding {
  AppBranding._();

  static AppBrandingProfile _current = AppBrandingProfile.hub();

  static AppBrandingProfile get current => _current;

  static void initFromEnvironment() {
    const variant = String.fromEnvironment('APP_VARIANT', defaultValue: 'hub');
    if (variant == 'hub') {
      _current = AppBrandingProfile.hub();
      return;
    }
    final tenant = TenantApps.bySlug(variant);
    if (tenant != null) {
      _current = AppBrandingProfile.fromTenant(tenant);
      return;
    }
    _current = AppBrandingProfile.hub();
  }

  /// Flavor Android juveSocial ha package dedicato anche senza dart-define.
  static Future<void> ensureFromPackage() async {
    if (_current.isTenantApp) return;
    try {
      final info = await PackageInfo.fromPlatform();
      for (final tenant in TenantApps.registry) {
        if (info.packageName == tenant.mobileAppId) {
          _current = AppBrandingProfile.fromTenant(tenant);
          return;
        }
      }
    } catch (_) {}
  }
}

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
    this.header,
    this.navbar,
    this.logoAssetPath,
    this.tenantId = 0,
  });

  factory AppBrandingProfile.hub() {
    final base = const AppBrandingProfile(
      variantId: 'hub',
      appName: 'Kairete',
      mobileAppId: 'com.kairete.app',
      primary: Color(0xFF176249),
      accent: Color(0xFFC45C3E),
      appBarBorderBottom: Color(0xFF0F4A35),
      header: Color(0xFF176249),
      navbar: Color(0xFF176249),
    );
    return base.applyDartDefines();
  }

  factory AppBrandingProfile.fromTenant(TenantAppDefinition tenant) {
    const tenantIdOverride = int.fromEnvironment('TENANT_ID', defaultValue: 0);
    final base = AppBrandingProfile(
      variantId: tenant.slug,
      appName: tenant.appName,
      mobileAppId: tenant.mobileAppId,
      tenantId: tenantIdOverride > 0 ? tenantIdOverride : tenant.defaultTenantId,
      primary: tenant.primary,
      accent: tenant.accent,
      appBarBorderBottom: tenant.appBarBorderBottom,
      header: tenant.primary,
      navbar: tenant.primary,
      logoAssetPath: tenant.logoAssetPath,
    );
    return base.applyDartDefines();
  }

  final String variantId;
  final String appName;
  final String mobileAppId;
  final int tenantId;
  final Color primary;
  final Color accent;
  final Color appBarBorderBottom;
  final Color? header;
  final Color? navbar;
  final String? logoAssetPath;

  bool get isTenantApp => tenantId > 0;
  bool get isHubApp => tenantId <= 0;

  Color get headerColor => header ?? primary;
  Color get navbarColor => navbar ?? primary;

  AppBrandingProfile copyWith({
    String? appName,
    Color? primary,
    Color? accent,
    Color? appBarBorderBottom,
    Color? header,
    Color? navbar,
  }) {
    return AppBrandingProfile(
      variantId: variantId,
      appName: appName ?? this.appName,
      mobileAppId: mobileAppId,
      tenantId: tenantId,
      primary: primary ?? this.primary,
      accent: accent ?? this.accent,
      appBarBorderBottom: appBarBorderBottom ?? this.appBarBorderBottom,
      header: header ?? this.header,
      navbar: navbar ?? this.navbar,
      logoAssetPath: logoAssetPath,
    );
  }

  AppBrandingProfile applyDartDefines() {
    const nameOverride = String.fromEnvironment('APP_DISPLAY_NAME');
    return copyWith(
      appName: nameOverride.isNotEmpty ? nameOverride : null,
      primary: _colorFromEnv('COLOR_PRIMARY') ?? primary,
      accent: _colorFromEnv('COLOR_ACCENT') ?? accent,
      appBarBorderBottom:
          _colorFromEnv('COLOR_APPBAR_BORDER') ?? appBarBorderBottom,
      header: _colorFromEnv('COLOR_HEADER') ?? header ?? primary,
      navbar: _colorFromEnv('COLOR_NAVBAR') ?? navbar ?? primary,
    );
  }

  static Color? _colorFromEnv(String key) {
    // fromEnvironment richiede costante letterale per chiave → switch esplicito
    final hex = switch (key) {
      'COLOR_PRIMARY' => const String.fromEnvironment('COLOR_PRIMARY'),
      'COLOR_ACCENT' => const String.fromEnvironment('COLOR_ACCENT'),
      'COLOR_HEADER' => const String.fromEnvironment('COLOR_HEADER'),
      'COLOR_NAVBAR' => const String.fromEnvironment('COLOR_NAVBAR'),
      'COLOR_APPBAR_BORDER' =>
        const String.fromEnvironment('COLOR_APPBAR_BORDER'),
      _ => '',
    };
    return parseHexColor(hex);
  }

  static Color? parseHexColor(String? hex) {
    if (hex == null) return null;
    var h = hex.trim();
    if (h.isEmpty) return null;
    if (h.startsWith('#')) h = h.substring(1);
    if (h.length == 3) {
      h = '${h[0]}${h[0]}${h[1]}${h[1]}${h[2]}${h[2]}';
    }
    if (h.length != 6) return null;
    final value = int.tryParse(h, radix: 16);
    if (value == null) return null;
    return Color(0xFF000000 | value);
  }
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

  /// Applica colori/nome dal bootstrap Multisite (runtime).
  /// Chiama poi [AppTheme.applyBranding] dal caller.
  static AppBrandingProfile? applyRuntimeBranding(
    Map<String, dynamic>? branding,
  ) {
    if (branding == null || branding.isEmpty) return null;

    final primary = AppBrandingProfile.parseHexColor(
      branding['primary']?.toString() ?? branding['color_primary']?.toString(),
    );
    final accent = AppBrandingProfile.parseHexColor(
      branding['accent']?.toString() ?? branding['color_accent']?.toString(),
    );
    final header = AppBrandingProfile.parseHexColor(
      branding['header']?.toString() ?? branding['color_header']?.toString(),
    );
    final navbar = AppBrandingProfile.parseHexColor(
      branding['navbar']?.toString() ?? branding['color_navbar']?.toString(),
    );
    final border = AppBrandingProfile.parseHexColor(
      branding['appbar_border']?.toString() ??
          branding['color_appbar_border']?.toString(),
    );
    final name = branding['app_name']?.toString().trim() ?? '';

    _current = _current.copyWith(
      appName: name.isNotEmpty ? name : null,
      primary: primary,
      accent: accent,
      header: header,
      navbar: navbar,
      appBarBorderBottom: border,
    );
    return _current;
  }
}

import 'package:flutter/material.dart';

/// Definizione di una sotto-app community (modello per nuove APK).
///
/// Per aggiungere una community:
/// 1. Aggiungi una voce in [TenantApps.registry]
/// 2. Duplica flavor Android in `android/app/build.gradle` (vedi TENANT_APK.md)
/// 3. Aggiungi logo in `assets/branding/<slug>/logo.png`
/// 4. Build con `--dart-define=APP_VARIANT=<slug>`
class TenantAppDefinition {
  const TenantAppDefinition({
    required this.slug,
    required this.appName,
    required this.mobileAppId,
    required this.defaultTenantId,
    required this.primary,
    required this.accent,
    required this.appBarBorderBottom,
    required this.logoAssetPath,
    this.gradleFlavorName,
  });

  final String slug;
  final String appName;
  final String mobileAppId;
  final int defaultTenantId;
  final Color primary;
  final Color accent;
  final Color appBarBorderBottom;
  final String logoAssetPath;
  final String? gradleFlavorName;

  String get variantId => slug;
}

/// Registry centralizzato delle sotto-app community.
class TenantApps {
  TenantApps._();

  static const juveSocial = TenantAppDefinition(
    slug: 'juve_social',
    appName: 'Juve Social',
    mobileAppId: 'com.kairete.tenant.juve_social',
    defaultTenantId: 3,
    primary: Color(0xFF000000),
    accent: Color(0xFFC9A227),
    appBarBorderBottom: Color(0xFF1A1A1A),
    logoAssetPath: 'assets/branding/juve_social/logo.png',
    gradleFlavorName: 'juveSocial',
  );

  static const List<TenantAppDefinition> registry = [juveSocial];

  static TenantAppDefinition? bySlug(String slug) {
    for (final def in registry) {
      if (def.slug == slug) return def;
    }
    return null;
  }
}

import 'package:flutter/material.dart';

/// Definizione di una sotto-app community (modello per nuove APK).
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
    this.fallbackNewsfeedGroupId = 0,
    this.fallbackForumNodeIds = const [],
    this.fallbackBlogIds = const [],
    this.fallbackBlogCategoryIds = const [],
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
  final int fallbackNewsfeedGroupId;
  final List<int> fallbackForumNodeIds;
  final List<int> fallbackBlogIds;
  final List<int> fallbackBlogCategoryIds;

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
    fallbackNewsfeedGroupId: 4,
  );

  static const List<TenantAppDefinition> registry = [juveSocial];

  static TenantAppDefinition? bySlug(String slug) {
    for (final def in registry) {
      if (def.slug == slug) return def;
    }
    return null;
  }

  static TenantAppDefinition? byTenantId(int tenantId) {
    for (final def in registry) {
      if (def.defaultTenantId == tenantId) return def;
    }
    return null;
  }
}

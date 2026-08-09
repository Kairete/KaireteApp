import 'package:kairete/config/app_config.dart';

class TenantBootstrap {
  TenantBootstrap({
    required this.tenantId,
    required this.title,
    required this.slug,
    required this.newsfeedGroupId,
    required this.tabs,
    this.scope = const {},
    this.homepageLayout = '',
    this.branding = const {},
  });

  factory TenantBootstrap.fromJson(Map<String, dynamic> json) {
    final tabsRaw = json['tabs'];
    final tabs = <String>[];
    if (tabsRaw is List) {
      for (final t in tabsRaw) {
        if (t is String && t.isNotEmpty) tabs.add(t);
      }
    }
    final scopeRaw = json['scope'];
    final scope = scopeRaw is Map
        ? Map<String, dynamic>.from(scopeRaw)
        : const <String, dynamic>{};
    final brandingRaw = json['branding'];
    final branding = brandingRaw is Map
        ? Map<String, dynamic>.from(brandingRaw)
        : const <String, dynamic>{};

    return TenantBootstrap(
      tenantId: _int(json['tenant_id']),
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      newsfeedGroupId: _int(json['newsfeed_group_id']),
      tabs: tabs,
      scope: scope,
      homepageLayout: json['homepage_layout']?.toString() ?? '',
      branding: branding,
    );
  }

  final int tenantId;
  final String title;
  final String slug;
  final int newsfeedGroupId;
  final List<String> tabs;
  final Map<String, dynamic> scope;
  final String homepageLayout;
  final Map<String, dynamic> branding;

  bool tabEnabled(String tab) => tabs.contains(tab);

  TenantBootstrap mergeFrom(TenantBootstrap other) {
    final mergedScope = Map<String, dynamic>.from(scope);
    for (final key in [
      'forumNodeIds',
      'blogIds',
      'blogCategoryIds',
      'mediaCategoryIds',
      'mediaAlbumIds',
      'groupId',
    ]) {
      if (other.scope.containsKey(key)) {
        mergedScope[key] = other.scope[key];
      }
    }

    return TenantBootstrap(
      tenantId: tenantId > 0 ? tenantId : other.tenantId,
      title: other.title.isNotEmpty ? other.title : title,
      slug: other.slug.isNotEmpty ? other.slug : slug,
      newsfeedGroupId: other.newsfeedGroupId > 0
          ? other.newsfeedGroupId
          : newsfeedGroupId,
      tabs: other.tabs.isNotEmpty ? other.tabs : tabs,
      scope: mergedScope,
      homepageLayout:
          other.homepageLayout.isNotEmpty ? other.homepageLayout : homepageLayout,
      branding: other.branding.isNotEmpty ? other.branding : branding,
    );
  }

  /// Sostituisce scope/tabs dal server (demap incluso: liste vuote).
  TenantBootstrap applyServerScope(TenantBootstrap server) {
    final mergedScope = Map<String, dynamic>.from(scope);
    for (final key in [
      'forumNodeIds',
      'blogIds',
      'blogCategoryIds',
      'mediaCategoryIds',
      'mediaAlbumIds',
      'groupId',
    ]) {
      if (server.scope.containsKey(key)) {
        mergedScope[key] = server.scope[key];
      }
    }

    return TenantBootstrap(
      tenantId: server.tenantId > 0 ? server.tenantId : tenantId,
      title: server.title.isNotEmpty ? server.title : title,
      slug: server.slug.isNotEmpty ? server.slug : slug,
      newsfeedGroupId: server.newsfeedGroupId > 0
          ? server.newsfeedGroupId
          : newsfeedGroupId,
      tabs: server.tabs.isNotEmpty ? server.tabs : tabs,
      scope: mergedScope,
      homepageLayout: server.homepageLayout.isNotEmpty
          ? server.homepageLayout
          : homepageLayout,
      branding: server.branding.isNotEmpty ? server.branding : branding,
    );
  }

  static int _int(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}

/// Stato bootstrap tenant per sotto-app community.
class TenantRuntime {
  TenantRuntime._();

  static TenantBootstrap? bootstrap;

  static bool get isReady =>
      !AppConfig.isTenantApp || bootstrap != null;

  static void clear() {
    bootstrap = null;
    lastScopeSyncOk = false;
    scopeFromCache = false;
    lastScopeSyncHttpStatus = null;
    lastScopeSyncErrorMessage = null;
    lastScopeSyncEndpoint = null;
  }

  static bool lastScopeSyncOk = false;
  static bool scopeFromCache = false;

  /// Ultimo endpoint tentato per sync scope (es. api/newsfeed/tenant-scope).
  static String? lastScopeSyncEndpoint;

  /// HTTP status dell'ultimo tentativo fallito (null se non raggiunto il server).
  static int? lastScopeSyncHttpStatus;

  /// Messaggio errore dell'ultimo tentativo fallito.
  static String? lastScopeSyncErrorMessage;
}

import 'package:kairete/config/app_config.dart';

class TenantBootstrap {
  TenantBootstrap({
    required this.tenantId,
    required this.title,
    required this.slug,
    required this.newsfeedGroupId,
    required this.tabs,
    this.scope = const {},
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

    return TenantBootstrap(
      tenantId: _int(json['tenant_id']),
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      newsfeedGroupId: _int(json['newsfeed_group_id']),
      tabs: tabs,
      scope: scope,
    );
  }

  final int tenantId;
  final String title;
  final String slug;
  final int newsfeedGroupId;
  final List<String> tabs;
  final Map<String, dynamic> scope;

  bool tabEnabled(String tab) => tabs.contains(tab);

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
  }
}

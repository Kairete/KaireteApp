import 'package:kairete/config/app_config.dart';
import 'package:kairete/core/tenant/tenant_bootstrap.dart';

/// Scope tenant da bootstrap (forum/blog/media mappati).
class TenantScope {
  TenantScope._();

  static TenantBootstrap? get _bootstrap => TenantRuntime.bootstrap;

  static List<int> _intList(String key) {
    final raw = _bootstrap?.scope[key];
    if (raw is! List) return const [];
    return raw
        .map((v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0)
        .where((id) => id > 0)
        .toList();
  }

  static int _scopeInt(String key) {
    final raw = _bootstrap?.scope[key];
    if (raw is int && raw > 0) return raw;
    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  static List<int> get forumNodeIds => _intList('forumNodeIds');
  static List<int> get blogIds => _intList('blogIds');
  static List<int> get blogCategoryIds => _intList('blogCategoryIds');
  static List<int> get mediaCategoryIds => _intList('mediaCategoryIds');
  static List<int> get mediaAlbumIds => _intList('mediaAlbumIds');

  /// Gruppo newsfeed: campo bootstrap o scope.groupId dal mapping.
  static int get groupId {
    final fromBootstrap = _bootstrap?.newsfeedGroupId ?? 0;
    if (fromBootstrap > 0) return fromBootstrap;
    return _scopeInt('groupId');
  }

  static bool get isActive => AppConfig.isTenantApp && _bootstrap != null;

  static bool tabEnabled(String tab) =>
      !AppConfig.isTenantApp || (_bootstrap?.tabEnabled(tab) ?? false);
}

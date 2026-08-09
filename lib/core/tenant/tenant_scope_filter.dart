import 'package:kairete/config/app_config.dart';
import 'package:kairete/core/tenant/tenant_scope.dart';
import 'package:kairete/features/media/models/media_item.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';

/// Filtra voci feed tenant: solo contenuti effettivamente mappati in ACP.
class TenantScopeFilter {
  TenantScopeFilter._();

  static List<OmnifeedItem> filterFeedItems(List<OmnifeedItem> items) {
    if (!AppConfig.isTenantApp || !TenantScope.isActive) return items;
    return items.where(isAllowed).toList();
  }

  static bool isAllowed(OmnifeedItem item) {
    if (!AppConfig.isTenantApp || !TenantScope.isActive) return true;

    final type = item.contentType ?? '';
    final mappedGroup = TenantScope.groupId;

    switch (type) {
      case 'tl_group_post':
        return mappedGroup > 0 && (item.groupId ?? 0) == mappedGroup;
      case 'profile_post':
        if (mappedGroup > 0 && (item.groupId ?? 0) == mappedGroup) return true;
        return false;
      case 'thread':
        final forums = TenantScope.forumNodeIds;
        if (forums.isEmpty) return false;
        return forums.contains(item.forumId ?? 0);
      case 'ubs_blog_entry':
        return _blogAllowed(item);
      case 'xfmg_media':
        return _mediaAllowed(item);
      default:
        return false;
    }
  }

  static bool _blogAllowed(OmnifeedItem item) {
    final blogIds = TenantScope.blogIds;
    final categoryIds = TenantScope.blogCategoryIds;
    // Nessun mapping blog esplicito: se ci sono forum mappati, accetta (il
    // community-feed può includere blog collegati via kb_forum_blog_id).
    if (blogIds.isEmpty && categoryIds.isEmpty) {
      return TenantScope.forumNodeIds.isNotEmpty;
    }

    final blogId = item.blogId ?? 0;
    if (blogIds.isNotEmpty && blogIds.contains(blogId)) return true;

    final categoryId = item.blogCategoryId ?? 0;
    if (categoryIds.isNotEmpty && categoryIds.contains(categoryId)) return true;

    return false;
  }

  static bool _mediaAllowed(OmnifeedItem item) {
    return isMediaAllowed(
      albumId: item.albumId,
      categoryId: item.mediaCategoryId,
    );
  }

  static bool isMediaAllowed({int? albumId, int? categoryId}) {
    if (!AppConfig.isTenantApp || !TenantScope.isActive) return true;

    final albums = TenantScope.mediaAlbumIds;
    final categories = TenantScope.mediaCategoryIds;
    if (albums.isEmpty && categories.isEmpty) return false;

    final aid = albumId ?? 0;
    if (albums.isNotEmpty) {
      return aid > 0 && albums.contains(aid);
    }

    final cid = categoryId ?? 0;
    return cid > 0 && categories.contains(cid);
  }

  static List<MediaItem> filterMediaItems(List<MediaItem> items) {
    if (!AppConfig.isTenantApp || !TenantScope.isActive) return items;
    return items.where((item) {
      return isMediaAllowed(
        albumId: item.album?.albumId,
        categoryId: item.category?.categoryId,
      );
    }).toList();
  }
}

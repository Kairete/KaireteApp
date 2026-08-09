import 'package:kairete/features/blog/models/blog_entry.dart';
import 'package:kairete/features/blog/services/blog_service.dart';
import 'package:kairete/features/forum/models/forum_thread.dart';
import 'package:kairete/features/forum/services/forum_service.dart';
import 'package:kairete/features/groups/services/groups_service.dart';
import 'package:kairete/features/media/services/media_service.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_media_enrichment.dart';
import 'package:kairete/core/tenant/tenant_scope.dart';
import 'package:kairete/core/tenant/tenant_scope_filter.dart';
import 'package:kairete/core/tenant/tenant_service.dart';

/// Merge client-side dei contenuti mappati tenant (fallback se API community-feed assente).
class TenantFeedMergeService {
  final BlogService _blog = BlogService();
  final ForumService _forum = ForumService();
  final GroupsService _groups = GroupsService();
  final MediaService _media = MediaService();

  Future<List<OmnifeedItem>> buildCommunityItems({
    int page = 1,
    int limit = 20,
    String feedFilter = 'all',
  }) async {
    if (feedFilter == 'following') {
      return [];
    }
    await TenantService().ensureTenantReady();
    final sources = await Future.wait([
      _groupPostItems(),
      _blogItems(),
      _forumThreadItems(),
      _mediaItems(),
    ]);
    final merged = mergeOmnifeedItemLists(sources);
    return _slicePage(
      TenantScopeFilter.filterFeedItems(merged),
      page: page,
      limit: limit,
    );
  }

  Future<List<OmnifeedItem>> buildUserItems({
    required int userId,
    int page = 1,
    int limit = 20,
  }) async {
    await TenantService().ensureTenantReady();
    if (userId <= 0) return [];

    final allowedForums = TenantScope.forumNodeIds.toSet();
    final allowedBlogIds = TenantScope.blogIds.toSet();
    final allowedBlogCats = TenantScope.blogCategoryIds.toSet();
    final allowedAlbums = TenantScope.mediaAlbumIds.toSet();
    final allowedMediaCats = TenantScope.mediaCategoryIds.toSet();
    final groupId = TenantScope.groupId;

    final sources = await Future.wait([
      _blogItemsForUser(
        userId,
        allowedBlogIds: allowedBlogIds,
        allowedBlogCats: allowedBlogCats,
      ),
      _forumThreadsForUser(userId, allowedForums: allowedForums),
      _mediaForUser(
        userId,
        allowedAlbums: allowedAlbums,
        allowedMediaCats: allowedMediaCats,
      ),
      _groupPostsForUser(userId, groupId: groupId),
    ]);

    final merged = mergeOmnifeedItemLists(sources)
        .where((item) => item.author?.userId == userId)
        .toList();
    return _slicePage(merged, page: page, limit: limit);
  }

  Future<List<OmnifeedItem>> _groupPostItems() async {
    final groupId = TenantScope.groupId;
    if (groupId <= 0) return [];
    try {
      final page = await _groups.fetchPosts(groupId, page: 1);
      return page.posts
          .map(
            (post) => OmnifeedItem.fromGroupPostApi({
              'group_post_id': post.groupPostId,
              'group_id': post.groupId,
              'message_plain_text': post.messagePlainText,
              'post_date': post.postDate,
              'comment_count': post.commentCount,
              'reaction_score': post.reactionScore,
              if (post.author != null)
                'User': {
                  'user_id': post.author!.userId,
                  'username': post.author!.username,
                },
            }),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Solo articoli blog per integrazione nel newsfeed tenant.
  Future<List<OmnifeedItem>> buildBlogFeedItems() => _blogItems();

  Future<List<OmnifeedItem>> _blogItems() async {
    final allowedBlogIds = await _resolvedBlogIds();
    final allowedCats = TenantScope.blogCategoryIds.toSet();
    if (allowedBlogIds.isEmpty && allowedCats.isEmpty) {
      return [];
    }

    final byId = <int, OmnifeedItem>{};

    // Per-blog: evita l’API mapped-entries che fallisce se lo scope ACP è vuoto.
    if (allowedBlogIds.isNotEmpty) {
      final lists = await Future.wait(
        allowedBlogIds.map((blogId) async {
          try {
            return await _blog.fetchEntries(blogId: blogId);
          } catch (_) {
            return <BlogEntry>[];
          }
        }),
      );
      for (final entries in lists) {
        for (final entry in entries) {
          final item = OmnifeedItem.fromBlogEntry(entry);
          byId[item.contentId ?? item.itemId] = item;
        }
      }
    }

    if (allowedCats.isNotEmpty) {
      try {
        final entries = await _blog.fetchEntries();
        for (final entry in entries) {
          final catId = entry.category?.categoryId ?? 0;
          if (!allowedCats.contains(catId)) continue;
          final item = OmnifeedItem.fromBlogEntry(entry);
          byId[item.contentId ?? item.itemId] = item;
        }
      } catch (_) {}
    }

    return byId.values.toList();
  }

  /// Blog mappati in ACP + blog collegati ai forum mappati (forum-link).
  Future<Set<int>> _resolvedBlogIds() async {
    final ids = TenantScope.blogIds.toSet();
    final forums = TenantScope.forumNodeIds;
    if (forums.isEmpty) return ids;
    final linked = await Future.wait(
      forums.map((nodeId) async {
        try {
          final link = await _forum.fetchLinkedBlog(nodeId);
          return link?.blogId ?? 0;
        } catch (_) {
          return 0;
        }
      }),
    );
    for (final id in linked) {
      if (id > 0) ids.add(id);
    }
    return ids;
  }

  Future<List<OmnifeedItem>> _forumThreadItems() async {
    final nodeIds = TenantScope.forumNodeIds;
    if (nodeIds.isEmpty) return [];

    final nodeTitles = <int, String>{};
    try {
      final groups = await _forum.fetchForumGroups();
      for (final group in groups) {
        for (final forum in group.forums) {
          nodeTitles[forum.nodeId] = forum.title;
        }
      }
    } catch (_) {}

    final lists = await Future.wait(
      nodeIds.map((nodeId) async {
        try {
          final threads = await _forum.fetchThreads(nodeId);
          final forumTitle = nodeTitles[nodeId];
          if (forumTitle == null || forumTitle.isEmpty) return threads;
          return threads
              .map(
                (thread) => thread.forumTitle?.trim().isNotEmpty == true
                    ? thread
                    : thread.copyWith(forumTitle: forumTitle),
              )
              .toList();
        } catch (_) {
          return <ForumThread>[];
        }
      }),
    );

    return lists
        .expand((threads) => threads)
        .map(OmnifeedItem.fromForumThread)
        .toList();
  }

  Future<List<OmnifeedItem>> _mediaItems() async {
    final albumIds = TenantScope.mediaAlbumIds;
    final categoryIds = TenantScope.mediaCategoryIds;
    if (albumIds.isEmpty && categoryIds.isEmpty) return [];

    final futures = <Future<List<OmnifeedItem>>>[];
    for (final albumId in albumIds) {
      futures.add(_mediaItemsForAlbum(albumId));
    }
    for (final categoryId in categoryIds) {
      futures.add(_mediaItemsForCategory(categoryId));
    }
    final lists = await Future.wait(futures);
    return lists.expand((list) => list).toList();
  }

  Future<List<OmnifeedItem>> _mediaItemsForAlbum(int albumId) async {
    try {
      final items = await _media.fetchMedia(albumId: albumId, limit: 25);
      return items.map(OmnifeedItem.fromMediaItem).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<OmnifeedItem>> _mediaItemsForCategory(int categoryId) async {
    try {
      final items = await _media.fetchMedia(categoryId: categoryId, limit: 25);
      return items.map(OmnifeedItem.fromMediaItem).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<OmnifeedItem>> _blogItemsForUser(
    int userId, {
    required Set<int> allowedBlogIds,
    required Set<int> allowedBlogCats,
  }) async {
    if (allowedBlogIds.isEmpty && allowedBlogCats.isEmpty) return [];
    try {
      final entries = await _blog.fetchEntries();
      return entries
          .where((entry) {
            if (entry.author?.userId != userId) return false;
            final blogId = entry.blog?.blogId ?? 0;
            final catId = entry.category?.categoryId ?? 0;
            if (allowedBlogIds.isNotEmpty && allowedBlogIds.contains(blogId)) {
              return true;
            }
            if (allowedBlogCats.isNotEmpty && allowedBlogCats.contains(catId)) {
              return true;
            }
            return false;
          })
          .map(OmnifeedItem.fromBlogEntry)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<OmnifeedItem>> _forumThreadsForUser(
    int userId, {
    required Set<int> allowedForums,
  }) async {
    if (allowedForums.isEmpty) return [];
    final lists = await Future.wait(
      allowedForums.map((nodeId) async {
        try {
          return await _forum.fetchThreads(nodeId);
        } catch (_) {
          return <ForumThread>[];
        }
      }),
    );
    return lists
        .expand((threads) => threads)
        .where((thread) => thread.author?.userId == userId)
        .map(OmnifeedItem.fromForumThread)
        .toList();
  }

  Future<List<OmnifeedItem>> _mediaForUser(
    int userId, {
    required Set<int> allowedAlbums,
    required Set<int> allowedMediaCats,
  }) async {
    if (allowedAlbums.isEmpty && allowedMediaCats.isEmpty) return [];
    try {
      final items = await _media.fetchMedia(userId: userId, limit: 40);
      return items
          .where((item) {
            final albumId = item.album?.albumId ?? 0;
            final catId = item.category?.categoryId ?? 0;
            if (allowedAlbums.isNotEmpty && allowedAlbums.contains(albumId)) {
              return true;
            }
            if (allowedMediaCats.isNotEmpty &&
                allowedMediaCats.contains(catId)) {
              return true;
            }
            return false;
          })
          .map(OmnifeedItem.fromMediaItem)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<OmnifeedItem>> _groupPostsForUser(
    int userId, {
    required int groupId,
  }) async {
    if (groupId <= 0) return [];
    try {
      final page = await _groups.fetchPosts(groupId, page: 1);
      return page.posts
          .where((post) => post.author?.userId == userId)
          .map(
            (post) => OmnifeedItem.fromGroupPostApi({
              'group_post_id': post.groupPostId,
              'group_id': post.groupId,
              'message_plain_text': post.messagePlainText,
              'post_date': post.postDate,
              'comment_count': post.commentCount,
              'reaction_score': post.reactionScore,
              if (post.author != null)
                'User': {
                  'user_id': post.author!.userId,
                  'username': post.author!.username,
                },
            }),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<OmnifeedItem> _slicePage(
    List<OmnifeedItem> items, {
    required int page,
    required int limit,
  }) {
    if (items.isEmpty) return items;
    final sorted = List<OmnifeedItem>.from(items)
      ..sort((a, b) => (b.itemDate ?? 0).compareTo(a.itemDate ?? 0));
    final offset = (page - 1) * limit;
    if (offset >= sorted.length) return [];
    final end = offset + limit;
    return sorted.sublist(
      offset,
      end > sorted.length ? sorted.length : end,
    );
  }
}

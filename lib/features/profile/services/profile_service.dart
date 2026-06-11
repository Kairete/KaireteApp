import 'package:kairete/config/api_paths.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/features/blog/models/blog_entry.dart';
import 'package:kairete/features/forum/models/forum_thread.dart';
import 'package:kairete/features/media/models/media_item.dart';
import 'package:kairete/features/media/services/media_service.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_media_enrichment.dart';
import 'package:kairete/features/profile/models/user_profile.dart';

class ProfileService {
  XenforoApi get _api => AppApi.instance.xenforo;

  Future<UserProfile> fetchUser(int userId) async {
    await AppApi.instance.applySession();
    final json = await _api.get('${ApiPaths.users}/$userId');
    _throwIfError(json);
    return UserProfile.fromJson(json);
  }

  /// Attività pubblicata da [userId]: post, blog, forum, gruppi (non il muro altrui).
  Future<OmnifeedFeed> fetchUserFeed({
    required int userId,
    int page = 1,
    String sort = 'post_date',
  }) async {
    await AppApi.instance.applySession();

    final sources = await Future.wait([
      _fetchUserFeedFromApi(userId, page: page, sort: sort),
      _fetchAuthoredProfilePosts(userId, page: page),
      _fetchUserBlogItems(userId, page: page),
      _fetchUserThreadItems(userId, page: page),
      _fetchUserGroupPostItems(userId, page: page),
      _fetchUserMediaItems(userId),
    ]);

    return OmnifeedFeed(
      items: await enrichMediaAlbumHeaders(
        _mergeAuthoredItems(sources, userId),
      ),
    );
  }

  Future<List<OmnifeedItem>> _fetchUserFeedFromApi(
    int userId, {
    required int page,
    required String sort,
  }) async {
    try {
      final json = await _api.get(
        ApiPaths.newsfeedUserFeed,
        query: {
          'id': userId,
          'page': page,
          'limit': 20,
          'sort': sort,
        },
      );
      if (XenforoApi.firstErrorMessage(json) == null) {
        return OmnifeedFeed.fromJson(json).items;
      }
    } catch (_) {}
    return [];
  }

  /// Post profilo scritti da [userId] (esclude messaggi lasciati da altri sul suo muro).
  Future<List<OmnifeedItem>> _fetchAuthoredProfilePosts(
    int userId, {
    required int page,
  }) async {
    try {
      final json = await _api.get(
        '${ApiPaths.users}/$userId/profile-posts',
        query: {
          'page': page,
          'limit': 20,
        },
      );
      if (XenforoApi.firstErrorMessage(json) != null) return [];

      final raw = json['profile_posts'] as List<dynamic>? ?? [];
      return raw
          .whereType<Map<String, dynamic>>()
          .where((post) => _profilePostAuthorId(post) == userId)
          .map(OmnifeedItem.fromProfilePostApi)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<OmnifeedItem>> _fetchUserBlogItems(
    int userId, {
    required int page,
  }) async {
    try {
      final json = await _api.get(
        ApiPaths.blogEntries,
        query: {
          'user_id': userId,
          'page': page,
          'limit': 20,
        },
      );
      if (XenforoApi.firstErrorMessage(json) != null) return [];

      final raw = json['blogEntryItems'] as List<dynamic>? ?? [];
      return raw
          .whereType<Map<String, dynamic>>()
          .map((entry) => OmnifeedItem.fromBlogEntry(BlogEntry.fromJson(entry)))
          .where((item) => _isAuthoredBy(item, userId))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<OmnifeedItem>> _fetchUserGroupPostItems(
    int userId, {
    required int page,
  }) async {
    try {
      final json = await _api.get(
        ApiPaths.groupPosts,
        query: {
          'user_id': userId,
          'page': page,
          'limit': 20,
        },
      );
      if (XenforoApi.firstErrorMessage(json) != null) return [];

      final raw = json['posts'] as List<dynamic>? ??
          json['group_posts'] as List<dynamic>? ??
          [];
      return raw
          .whereType<Map<String, dynamic>>()
          .map(OmnifeedItem.fromGroupPostApi)
          .where((item) => _isAuthoredBy(item, userId))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<OmnifeedItem>> _fetchUserMediaItems(int userId) async {
    try {
      final media = await MediaService().fetchMedia(userId: userId, limit: 30);
      return media.map(OmnifeedItem.fromMediaItem).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<OmnifeedItem>> _fetchUserThreadItems(
    int userId, {
    required int page,
  }) async {
    try {
      final json = await _api.get(
        ApiPaths.threads,
        query: {
          'starter_id': userId,
          'page': page,
          'limit': 20,
        },
      );
      if (XenforoApi.firstErrorMessage(json) != null) return [];

      return ForumThreadsPage.fromJson(json)
          .threads
          .map(OmnifeedItem.fromForumThread)
          .where((item) => _isAuthoredBy(item, userId))
          .toList();
    } catch (_) {
      return [];
    }
  }

  int _profilePostAuthorId(Map<String, dynamic> json) {
    final user = json['User'];
    if (user is Map<String, dynamic>) {
      return user['user_id'] as int? ?? 0;
    }
    return json['user_id'] as int? ?? 0;
  }

  bool _isAuthoredBy(OmnifeedItem item, int userId) {
    if (userId <= 0) return false;
    return item.author?.userId == userId;
  }

  List<OmnifeedItem> _mergeAuthoredItems(
    List<List<OmnifeedItem>> sources,
    int userId,
  ) {
    final filtered = sources
        .map(
          (list) => list
              .where(
                (item) => item.itemId > 0 && _isAuthoredBy(item, userId),
              )
              .toList(),
        )
        .toList();
    return mergeOmnifeedItemLists(filtered);
  }

  Future<bool> followUser(int userId, {required bool stop}) async {
    await AppApi.instance.applySession();
    final json = await _api.post(
      '${ApiPaths.users}/$userId/follow',
      body: stop ? {'stop': true} : {},
    );
    _throwIfError(json);
    final action = json['action']?.toString() ?? '';
    if (action == 'follow') return true;
    if (action == 'unfollow') return false;
    return !stop;
  }

  void _throwIfError(Map<String, dynamic> json) {
    final err = XenforoApi.firstErrorMessage(json);
    if (err != null) throw ProfileException(err);
  }
}

class ProfileException implements Exception {
  ProfileException(this.message);
  final String message;

  @override
  String toString() => message;
}

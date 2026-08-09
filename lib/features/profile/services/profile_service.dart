import 'package:kairete/config/app_config.dart';
import 'package:kairete/config/api_paths.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/tenant/tenant_api_helpers.dart';
import 'package:dio/dio.dart';
import 'package:kairete/features/account/services/account_list_service.dart';
import 'package:kairete/features/blog/models/blog_entry.dart';
import 'package:kairete/features/forum/models/forum_thread.dart';
import 'package:kairete/features/groups/services/groups_service.dart';
import 'package:kairete/features/media/services/media_service.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/core/tenant/tenant_feed_merge.dart';
import 'package:kairete/core/tenant/tenant_service.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_media_enrichment.dart';
import 'package:kairete/features/profile/models/user_profile.dart';

class ProfileService {
  XenforoApi get _api => AppApi.instance.xenforo;
  final GroupsService _groups = GroupsService();

  Future<UserProfile> fetchUser(int userId, {String? username}) async {
    await AppApi.instance.applySession();

    final enriched = await _tryFetchEnrichedProfile(userId);
    if (enriched != null) return enriched;

    Map<String, dynamic>? json = await _tryFetchUserDirect(userId);
    if (json == null &&
        username != null &&
        username.trim().isNotEmpty) {
      json = await _tryFetchUserByName(username.trim());
    }
    json ??= await _fetchUserFromList(userId);

    _throwIfError(json);
    return UserProfile.fromJson(json);
  }

  Future<UserProfile?> _tryFetchEnrichedProfile(int userId) async {
    try {
      final json = await _api.get(
        ApiPaths.userProfile,
        query: {'id': userId},
      );
      final err = XenforoApi.firstErrorMessage(json);
      if (err != null) {
        if (TenantApiHelpers.isMissingEndpoint(err)) return null;
        throw ProfileException(err);
      }
      if (_hasUserPayload(json)) return UserProfile.fromJson(json);
    } catch (e) {
      if (e is ProfileException) rethrow;
    }
    return null;
  }

  Future<List<AccountUserRef>> fetchFollowingUsers(
    int userId, {
    int page = 1,
    int limit = 50,
  }) async {
    return _fetchRelationUsers(
      ApiPaths.userFollowing,
      userId,
      page: page,
      limit: limit,
    );
  }

  Future<List<AccountUserRef>> fetchFollowerUsers(
    int userId, {
    int page = 1,
    int limit = 50,
  }) async {
    return _fetchRelationUsers(
      ApiPaths.userFollowers,
      userId,
      page: page,
      limit: limit,
    );
  }

  Future<List<AccountUserRef>> _fetchRelationUsers(
    String path,
    int userId, {
    required int page,
    required int limit,
  }) async {
    await AppApi.instance.applySession();
    final json = await _api.get(
      path,
      query: {'id': userId, 'page': page, 'limit': limit},
    );
    _throwIfError(json);
    final raw = json['users'];
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((e) => AccountUserRef.fromJson(Map<String, dynamic>.from(e)))
        .where((u) => u.userId > 0)
        .toList();
  }

  Future<UserProfile> uploadBanner({
    required String filePath,
    required String filename,
  }) async {
    await AppApi.instance.applySession();
    final json = await _api.postMultipart(
      ApiPaths.userProfileBanner,
      files: {
        'upload': MultipartFile.fromFileSync(filePath, filename: filename),
      },
    );
    _throwIfError(json);
    if (_hasUserPayload(json)) return UserProfile.fromJson(json);
    // Ricarica profilo se la risposta non include user.
    throw ProfileException('Cover aggiornata, ricarica il profilo.');
  }

  Future<UserProfile?> deleteBanner() async {
    await AppApi.instance.applySession();
    final json = await _api.post(
      ApiPaths.userProfileBanner,
      body: {'delete_banner': 1},
    );
    _throwIfError(json);
    if (_hasUserPayload(json)) return UserProfile.fromJson(json);
    return null;
  }

  Future<void> reportUser(int userId, {required String message}) async {
    await AppApi.instance.applySession();
    final json = await _api.post(
      ApiPaths.userReport,
      body: {
        'id': userId,
        'message': message,
      },
    );
    _throwIfError(json);
  }

  Future<Map<String, dynamic>?> _tryFetchUserDirect(int userId) async {
    for (final path in [
      '${ApiPaths.users}/$userId/',
      '${ApiPaths.users}/$userId',
    ]) {
      final json = await _api.get(path);
      final err = XenforoApi.firstErrorMessage(json);
      if (err == null && _hasUserPayload(json)) return json;
      if (err != null && !TenantApiHelpers.isMissingEndpoint(err)) {
        throw ProfileException(err);
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> _tryFetchUserByName(String username) async {
    final json = await _api.get(
      '${ApiPaths.users}/find-name',
      query: {'username': username},
    );
    if (XenforoApi.firstErrorMessage(json) != null) return null;
    final exact = json['exact'];
    if (exact is Map<String, dynamic>) return {'user': exact};
    final user = json['user'];
    if (user is Map<String, dynamic>) return {'user': user};
    return null;
  }

  Future<Map<String, dynamic>> _fetchUserFromList(int userId) async {
    for (var page = 1; page <= 20; page++) {
      final json = await _api.get(
        '${ApiPaths.users}/',
        query: {'page': page, 'limit': 50},
      );
      final err = XenforoApi.firstErrorMessage(json);
      if (err != null) throw ProfileException(err);

      final users = json['users'] as List<dynamic>? ?? [];
      for (final entry in users) {
        if (entry is Map && entry['user_id'] == userId) {
          return {'user': Map<String, dynamic>.from(entry)};
        }
      }

      final pagination = json['pagination'] as Map<String, dynamic>?;
      final lastPage = pagination?['last_page'] as int? ?? page;
      if (page >= lastPage || users.isEmpty) break;
    }
    throw ProfileException('Utente non trovato.');
  }

  bool _hasUserPayload(Map<String, dynamic> json) {
    if (json['user'] is Map) return true;
    return json['user_id'] is int && (json['user_id'] as int) > 0;
  }

  /// Attività pubblicata da [userId]: post, blog, forum, gruppi (non il muro altrui).
  Future<OmnifeedFeed> fetchUserFeed({
    required int userId,
    int page = 1,
    String sort = 'post_date',
  }) async {
    await AppApi.instance.applySession();

    if (AppConfig.isTenantApp && AppConfig.tenantId > 0) {
      return _fetchTenantMappedUserFeed(
        userId,
        page: page,
        sort: sort,
      );
    }

    final sources = await Future.wait([
      _fetchUserFeedFromApi(userId, page: page, sort: sort),
      _fetchProfilePostsForUser(userId),
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

  Future<OmnifeedFeed> _fetchTenantMappedUserFeed(
    int userId, {
    required int page,
    String sort = 'post_date',
  }) async {
    await TenantService().ensureTenantReady();

    final sources = <List<OmnifeedItem>>[];

    try {
      final json = await _api.get(
        ApiPaths.msTenantMappedUserFeed(AppConfig.tenantId, userId),
        query: {
          'page': page,
          'limit': 20,
          'tenant_id': AppConfig.tenantId,
        },
      );
      if (XenforoApi.firstErrorMessage(json) == null) {
        sources.add(_parseFeedItems(json));
      }
    } catch (_) {}

    sources.add(await _fetchUserFeedFromApi(userId, page: page, sort: sort));
    sources.add(await _fetchProfilePostsForUser(userId));

    try {
      sources.add(
        await TenantFeedMergeService().buildUserItems(
          userId: userId,
          page: page,
          limit: 20,
        ),
      );
    } catch (_) {}

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
    int limit = 20,
  }) async {
    try {
      final json = await _api.get(
        ApiPaths.newsfeedUserFeed,
        query: {
          'id': userId,
          'page': page,
          'limit': limit,
          'sort': sort,
        },
      );
      if (XenforoApi.firstErrorMessage(json) == null) {
        return _parseFeedItems(json);
      }
    } catch (_) {}
    return [];
  }

  /// Profile post scritti da [userId].
  Future<List<OmnifeedItem>> _fetchProfilePostsForUser(
    int userId, {
    int maxPages = 5,
  }) async {
    try {
      final json = await _api.get(
        ApiPaths.newsfeedUserProfilePosts,
        query: {
          'id': userId,
          'page': 1,
          'limit': 50,
        },
      );
      if (XenforoApi.firstErrorMessage(json) == null) {
        final items = _parseFeedItems(json);
        if (items.isNotEmpty) {
          return items;
        }
      }
    } catch (_) {}

    final posts = <OmnifeedItem>[];
    final seen = <int>{};

    for (var page = 1; page <= maxPages; page++) {
      try {
        final json = await _api.get(
          ApiPaths.newsfeed,
          query: {
            'mode': 'all',
            'page': page,
            'limit': 50,
            'sort': 'post_date',
          },
        );
        if (XenforoApi.firstErrorMessage(json) != null) break;

        for (final item in _parseFeedItems(json)) {
          if (item.contentType != 'profile_post') continue;
          if (!_isAuthoredBy(item, userId)) continue;
          if (!seen.add(item.itemId)) continue;
          posts.add(item);
        }

        final pagination = json['pagination'] as Map<String, dynamic>?;
        final current = pagination?['current_page'] as int? ?? page;
        final last = pagination?['last_page'] as int? ?? current;
        if (current >= last) break;
      } catch (_) {
        break;
      }
    }

    return posts;
  }

  List<OmnifeedItem> _parseFeedItems(Map<String, dynamic> json) {
    return OmnifeedFeed.fromJson(json)
        .items
        .map((item) => item.withResolvedItemId())
        .where((item) => item.itemId > 0)
        .toList();
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
      return await _groups.fetchAuthoredFeedItems(
        userId,
        maxPagesPerGroup: page <= 1 ? 2 : 1,
      );
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

  List<OmnifeedItem> _mergeAuthoredItems(
    List<List<OmnifeedItem>> sources,
    int userId,
  ) {
    if (sources.isEmpty) return [];

    final repaired = sources
        .map(
          (list) => list
              .map((item) => item.withResolvedItemId())
              .where((item) => item.itemId > 0)
              .toList(),
        )
        .toList();

    // user-feed OmniFeed: già filtrato lato server, non scartare per autore.
    final userFeed = repaired.isNotEmpty ? repaired[0] : <OmnifeedItem>[];

    final profilePosts = repaired.length > 1
        ? repaired[1]
            .where((item) => item.contentType == 'profile_post')
            .toList()
        : <OmnifeedItem>[];

    final supplemental = repaired
        .skip(2)
        .map(
          (list) =>
              list.where((item) => _keepInProfileFeed(item, userId)).toList(),
        )
        .toList();

    return mergeOmnifeedItemLists([
      userFeed,
      profilePosts,
      ...supplemental,
    ]);
  }

  bool _keepInProfileFeed(OmnifeedItem item, int userId) {
    if (item.itemId <= 0) return false;
    if (item.contentType == 'profile_post') return true;
    return _isAuthoredBy(item, userId);
  }

  bool _isAuthoredBy(OmnifeedItem item, int userId) {
    if (userId <= 0) return false;
    final authorId = item.author?.userId ?? 0;
    if (authorId == userId) return true;
    if (item.contentType == 'profile_post' && authorId <= 0) return true;
    return false;
  }

  Future<({bool followed, int? followersCount})> followUser(
    int userId, {
    required bool stop,
  }) async {
    await AppApi.instance.applySession();
    final json = await _api.post(
      ApiPaths.userFollow,
      body: {
        'id': userId,
        'stop': stop ? 1 : 0,
      },
    );
    _throwIfError(json);
    var followed = !stop;
    if (json['is_followed'] is bool) {
      followed = json['is_followed'] as bool;
    } else {
      final action = json['action']?.toString() ?? '';
      if (action == 'follow') followed = true;
      if (action == 'unfollow') followed = false;
    }
    final followers = json['followers_count'];
    return (
      followed: followed,
      followersCount: followers is num ? followers.toInt() : null,
    );
  }

  Future<bool> fanUser(int userId, {required bool stop}) async {
    await AppApi.instance.applySession();
    final json = await _api.post(
      '${ApiPaths.users}/$userId/fan',
      body: stop ? {'stop': true} : {},
    );
    _throwIfError(json);
    if (json['is_fan'] is bool) return json['is_fan'] as bool;
    if (json['is_fanned'] is bool) return json['is_fanned'] as bool;
    final action = json['action']?.toString() ?? '';
    if (action == 'fan') return true;
    if (action == 'unfan') return false;
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

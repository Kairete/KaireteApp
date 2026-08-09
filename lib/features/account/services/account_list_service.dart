import 'package:kairete/config/api_paths.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/utils/api_url.dart';

class AccountUserRef {
  AccountUserRef({
    required this.userId,
    required this.username,
    this.userTitle = '',
    this.avatarUrl,
    this.messageCount = 0,
    this.reactionScore = 0,
    this.trophyPoints = 0,
    this.questionSolutionCount = 0,
    this.registerDate = 0,
    this.lastActivity = 0,
    this.location = '',
    this.website = '',
    this.isStaff = false,
  });

  final int userId;
  final String username;
  final String userTitle;
  final String? avatarUrl;
  final int messageCount;
  final int reactionScore;
  final int trophyPoints;
  final int questionSolutionCount;
  final int registerDate;
  final int lastActivity;
  final String location;
  final String website;
  final bool isStaff;

  factory AccountUserRef.fromJson(Map<String, dynamic> json) {
    String? avatar;
    final urls = json['avatar_urls'];
    if (urls is Map) {
      avatar = urls['m']?.toString() ?? urls['s']?.toString();
    }
    final title = json['user_title']?.toString().trim().isNotEmpty == true
        ? json['user_title'].toString()
        : (json['custom_title']?.toString() ?? '');
    return AccountUserRef(
      userId: json['user_id'] as int? ?? 0,
      username: json['username']?.toString() ?? '',
      userTitle: title,
      avatarUrl: avatar != null ? ApiUrl.resolve(avatar) : null,
      messageCount: json['message_count'] as int? ?? 0,
      reactionScore: json['reaction_score'] as int? ?? 0,
      trophyPoints: json['trophy_points'] as int? ?? 0,
      questionSolutionCount: json['question_solution_count'] as int? ?? 0,
      registerDate: json['register_date'] as int? ?? 0,
      lastActivity: json['last_activity'] as int? ?? 0,
      location: json['location']?.toString() ?? '',
      website: json['website']?.toString() ?? '',
      isStaff: json['is_staff'] == true,
    );
  }
}

class AccountListService {
  XenforoApi get _api => AppApi.instance.xenforo;

  static const _bypass = {'api_bypass_permissions': 1};

  Future<List<AccountUserRef>> fetchFollowing() async {
    await AppApi.instance.applySession();
    final json = await _api.get(
      ApiPaths.mobileAccountFollowing,
      query: {..._bypass, 'limit': 100},
    );
    _throwIfError(json);
    return _users(json['users']);
  }

  Future<List<AccountUserRef>> fetchIgnored() async {
    await AppApi.instance.applySession();
    final json = await _api.get(
      ApiPaths.mobileAccountIgnored,
      query: {..._bypass, 'limit': 100},
    );
    _throwIfError(json);
    return _users(json['users']);
  }

  Future<void> setIgnored(int userId, {required bool stop}) async {
    await AppApi.instance.applySession();
    final json = await _api.post(
      ApiPaths.mobileAccountIgnored,
      body: {
        'user_id': userId,
        if (stop) 'stop': true,
      },
      query: _bypass,
    );
    _throwIfError(json);
  }

  Future<AccountReactionsPageData> fetchReactions({
    int page = 1,
    int reactionId = 0,
  }) async {
    await AppApi.instance.applySession();
    final json = await _api.get(
      ApiPaths.mobileAccountReactions,
      query: {
        ..._bypass,
        'page': page,
        'limit': 30,
        if (reactionId > 0) 'reaction_id': reactionId,
      },
    );
    _throwIfError(json);
    final list = json['reactions'];
    final tabsRaw = json['tabs'];
    final pagination = json['pagination'];
    return AccountReactionsPageData(
      reactions: list is List
          ? list
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : const [],
      tabs: tabsRaw is List
          ? tabsRaw
              .whereType<Map>()
              .map((e) => AccountReactionTab.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      total: pagination is Map ? (pagination['total'] as int? ?? 0) : 0,
      page: pagination is Map ? (pagination['current_page'] as int? ?? page) : page,
    );
  }

  Future<List<Map<String, dynamic>>> fetchBookmarks({int page = 1}) async {
    await AppApi.instance.applySession();
    final json = await _api.get(
      ApiPaths.mobileAccountBookmarks,
      query: {..._bypass, 'page': page, 'limit': 30},
    );
    _throwIfError(json);
    final list = json['bookmarks'];
    if (list is! List) return [];
    return list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, dynamic>> fetchWallet() async {
    await AppApi.instance.applySession();
    final json = await _api.get(
      ApiPaths.mobileAccountWallet,
      query: _bypass,
    );
    _throwIfError(json);
    return json;
  }

  Future<Map<String, dynamic>> fetchUpgrades() async {
    await AppApi.instance.applySession();
    final json = await _api.get(
      ApiPaths.mobileAccountUpgrades,
      query: _bypass,
    );
    _throwIfError(json);
    return json;
  }

  Future<List<Map<String, dynamic>>> fetchConnectedAccounts() async {
    await AppApi.instance.applySession();
    final json = await _api.get(
      ApiPaths.mobileAccountConnected,
      query: _bypass,
    );
    _throwIfError(json);
    final list = json['providers'];
    if (list is! List) return [];
    return list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> fetchApplications() async {
    await AppApi.instance.applySession();
    final json = await _api.get(
      ApiPaths.mobileAccountApplications,
      query: _bypass,
    );
    _throwIfError(json);
    final list = json['applications'];
    if (list is! List) return [];
    return list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> revokeApplication(int tokenId) async {
    await AppApi.instance.applySession();
    final json = await _api.delete(
      ApiPaths.mobileAccountApplications,
      body: {..._bypass, 'token_id': tokenId},
    );
    _throwIfError(json);
  }

  List<AccountUserRef> _users(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((e) => AccountUserRef.fromJson(Map<String, dynamic>.from(e)))
        .where((u) => u.userId > 0)
        .toList();
  }

  void _throwIfError(Map<String, dynamic> json) {
    final err = XenforoApi.firstErrorMessage(json);
    if (err != null) throw AccountListException(err);
  }
}

class AccountReactionTab {
  AccountReactionTab({
    required this.reactionId,
    required this.title,
    required this.total,
    this.imageUrl = '',
  });

  final int reactionId;
  final String title;
  final int total;
  final String imageUrl;

  factory AccountReactionTab.fromJson(Map<String, dynamic> json) {
    final rawUrl = json['image_url']?.toString() ?? '';
    return AccountReactionTab(
      reactionId: json['reaction_id'] as int? ?? 0,
      title: json['title']?.toString() ?? '',
      total: json['total'] as int? ?? 0,
      imageUrl: rawUrl.isEmpty ? '' : ApiUrl.resolve(rawUrl),
    );
  }
}

class AccountReactionsPageData {
  AccountReactionsPageData({
    required this.reactions,
    required this.tabs,
    required this.total,
    required this.page,
  });

  final List<Map<String, dynamic>> reactions;
  final List<AccountReactionTab> tabs;
  final int total;
  final int page;
}

class AccountListException implements Exception {
  AccountListException(this.message);
  final String message;

  @override
  String toString() => message;
}

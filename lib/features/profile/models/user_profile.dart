import 'package:kairete/core/utils/api_url.dart';

class ProfileField {
  ProfileField({
    required this.id,
    required this.title,
    required this.value,
    this.group = '',
  });

  final String id;
  final String title;
  final String value;
  final String group;

  factory ProfileField.fromJson(Map<String, dynamic> json) {
    return ProfileField(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
      group: json['group']?.toString() ?? '',
    );
  }
}

class ProfileUserPreview {
  ProfileUserPreview({
    required this.userId,
    required this.username,
    this.avatarUrl,
  });

  final int userId;
  final String username;
  final String? avatarUrl;

  factory ProfileUserPreview.fromJson(Map<String, dynamic> json) {
    final avatar = ApiUrl.resolve(json['avatar_url']?.toString());
    return ProfileUserPreview(
      userId: json['user_id'] as int? ?? 0,
      username: json['username']?.toString() ?? '',
      avatarUrl: avatar.isEmpty ? null : avatar,
    );
  }
}

class ProfileTrophy {
  ProfileTrophy({
    required this.trophyId,
    required this.title,
    this.description = '',
    this.trophyPoints = 0,
    this.awardDate = 0,
  });

  final int trophyId;
  final String title;
  final String description;
  final int trophyPoints;
  final int awardDate;

  factory ProfileTrophy.fromJson(Map<String, dynamic> json) {
    return ProfileTrophy(
      trophyId: json['trophy_id'] as int? ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      trophyPoints: json['trophy_points'] as int? ?? 0,
      awardDate: json['award_date'] as int? ?? 0,
    );
  }
}

class UserProfile {
  UserProfile({
    required this.userId,
    required this.username,
    this.avatarUrl,
    this.bannerUrl,
    this.about = '',
    this.location = '',
    this.website = '',
    this.userTitle = '',
    this.signature = '',
    this.signaturePlain = '',
    this.messageCount = 0,
    this.mediaCount = 0,
    this.reactionScore = 0,
    this.trophyPoints = 0,
    this.questionSolutionCount = 0,
    this.registerDate = 0,
    this.lastActivity = 0,
    this.followingCount = 0,
    this.followersCount = 0,
    this.age,
    this.dobDay,
    this.dobMonth,
    this.dobYear,
    this.profileFields = const [],
    this.customFields = const {},
    this.followingPreview = const [],
    this.followersPreview = const [],
    this.trophies = const [],
    this.isFollowed = false,
    this.canFollow = false,
    this.canPostProfile = false,
    this.canEditBanner = false,
    this.canReport = false,
    this.canViewIdentities = false,
    this.canStartConversation = false,
    this.isStaff = false,
    this.viewUrl,
  });

  final int userId;
  final String username;
  final String? avatarUrl;
  final String? bannerUrl;
  final String about;
  final String location;
  final String website;
  final String userTitle;
  final String signature;
  final String signaturePlain;
  final int messageCount;
  final int mediaCount;
  final int reactionScore;
  final int trophyPoints;
  final int questionSolutionCount;
  final int registerDate;
  final int lastActivity;
  final int followingCount;
  final int followersCount;
  final int? age;
  final int? dobDay;
  final int? dobMonth;
  final int? dobYear;
  final List<ProfileField> profileFields;
  final Map<String, String> customFields;
  final List<ProfileUserPreview> followingPreview;
  final List<ProfileUserPreview> followersPreview;
  final List<ProfileTrophy> trophies;
  final bool isFollowed;
  final bool canFollow;
  final bool canPostProfile;
  final bool canEditBanner;
  final bool canReport;
  final bool canViewIdentities;
  final bool canStartConversation;
  final bool isStaff;
  final String? viewUrl;

  List<ProfileField> get personalFields =>
      profileFields.where((f) => f.group == 'personal').toList();

  List<ProfileField> get contactFields =>
      profileFields.where((f) => f.group == 'contact').toList();

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? json;
    String? avatar;
    final avatars = user['avatar_urls'];
    if (avatars is Map) {
      avatar = avatars['l']?.toString() ??
          avatars['m']?.toString() ??
          avatars['o']?.toString();
    }
    final avatarResolved = ApiUrl.resolve(avatar);
    if (avatarResolved.isNotEmpty) avatar = avatarResolved;

    String? banner;
    final banners = user['profile_banner_urls'];
    if (banners is Map) {
      banner = banners['l']?.toString() ??
          banners['m']?.toString() ??
          banners['s']?.toString();
      if (banner == 'null' || banner?.isEmpty == true) banner = null;
    }
    if (banner != null) {
      final bannerResolved = ApiUrl.resolve(banner);
      banner = bannerResolved.isEmpty ? null : bannerResolved;
    }

    final fields = <ProfileField>[];
    final rawFields = user['profile_fields'];
    if (rawFields is List) {
      for (final row in rawFields) {
        if (row is Map) {
          fields.add(ProfileField.fromJson(Map<String, dynamic>.from(row)));
        }
      }
    }

    final custom = <String, String>{};
    final rawCustom = user['custom_fields'];
    if (rawCustom is Map) {
      rawCustom.forEach((k, v) {
        if (v == null) return;
        final s = v.toString().trim();
        if (s.isNotEmpty) custom[k.toString()] = s;
      });
    }

    int? age;
    final ageRaw = user['age'];
    if (ageRaw is num) age = ageRaw.toInt();

    int? dobDay;
    int? dobMonth;
    int? dobYear;
    final dob = user['dob'];
    if (dob is Map) {
      dobDay = (dob['day'] as num?)?.toInt();
      dobMonth = (dob['month'] as num?)?.toInt();
      dobYear = (dob['year'] as num?)?.toInt();
    }

    final followingPreview = _parsePreviews(
      json['following_preview'] ?? user['following_preview'],
    );
    final followersPreview = _parsePreviews(
      json['followers_preview'] ?? user['followers_preview'],
    );
    final trophies = _parseTrophies(json['trophies'] ?? user['trophies']);

    return UserProfile(
      userId: user['user_id'] as int? ?? 0,
      username: user['username']?.toString() ?? '',
      avatarUrl: avatar,
      bannerUrl: banner,
      about: user['about']?.toString() ?? '',
      location: user['location']?.toString() ?? '',
      website: user['website']?.toString() ?? '',
      userTitle: user['user_title']?.toString() ?? '',
      signature: user['signature']?.toString() ?? '',
      signaturePlain: user['signature_plain']?.toString() ?? '',
      messageCount: user['message_count'] as int? ?? 0,
      mediaCount: user['media_count'] as int? ?? 0,
      reactionScore: user['reaction_score'] as int? ?? 0,
      trophyPoints: user['trophy_points'] as int? ?? 0,
      questionSolutionCount: user['question_solution_count'] as int? ?? 0,
      registerDate: user['register_date'] as int? ?? 0,
      lastActivity: user['last_activity'] as int? ?? 0,
      followingCount: user['following_count'] as int? ?? 0,
      followersCount: user['followers_count'] as int? ?? 0,
      age: age,
      dobDay: dobDay,
      dobMonth: dobMonth,
      dobYear: dobYear,
      profileFields: fields,
      customFields: custom,
      followingPreview: followingPreview,
      followersPreview: followersPreview,
      trophies: trophies,
      isFollowed: user['is_followed'] == true,
      canFollow: user['can_follow'] == true,
      canPostProfile: user['can_post_profile'] == true,
      canEditBanner: user['can_edit_banner'] == true,
      canReport: user['can_report'] == true,
      canViewIdentities: user['can_view_identities'] == true,
      canStartConversation: user['can_start_conversation'] == true,
      isStaff: user['is_staff'] == true,
      viewUrl: user['view_url']?.toString(),
    );
  }

  static List<ProfileUserPreview> _parsePreviews(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => ProfileUserPreview.fromJson(Map<String, dynamic>.from(e)))
        .where((u) => u.userId > 0)
        .toList();
  }

  static List<ProfileTrophy> _parseTrophies(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => ProfileTrophy.fromJson(Map<String, dynamic>.from(e)))
        .where((t) => t.title.isNotEmpty)
        .toList();
  }

  UserProfile copyWith({
    bool? isFollowed,
    int? followingCount,
    int? followersCount,
    String? bannerUrl,
    bool clearBanner = false,
  }) {
    return UserProfile(
      userId: userId,
      username: username,
      avatarUrl: avatarUrl,
      bannerUrl: clearBanner ? null : (bannerUrl ?? this.bannerUrl),
      about: about,
      location: location,
      website: website,
      userTitle: userTitle,
      signature: signature,
      signaturePlain: signaturePlain,
      messageCount: messageCount,
      mediaCount: mediaCount,
      reactionScore: reactionScore,
      trophyPoints: trophyPoints,
      questionSolutionCount: questionSolutionCount,
      registerDate: registerDate,
      lastActivity: lastActivity,
      followingCount: followingCount ?? this.followingCount,
      followersCount: followersCount ?? this.followersCount,
      age: age,
      dobDay: dobDay,
      dobMonth: dobMonth,
      dobYear: dobYear,
      profileFields: profileFields,
      customFields: customFields,
      followingPreview: followingPreview,
      followersPreview: followersPreview,
      trophies: trophies,
      isFollowed: isFollowed ?? this.isFollowed,
      canFollow: canFollow,
      canPostProfile: canPostProfile,
      canEditBanner: canEditBanner,
      canReport: canReport,
      canViewIdentities: canViewIdentities,
      canStartConversation: canStartConversation,
      isStaff: isStaff,
      viewUrl: viewUrl,
    );
  }
}

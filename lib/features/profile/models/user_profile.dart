class UserProfile {
  UserProfile({
    required this.userId,
    required this.username,
    this.avatarUrl,
    this.bannerUrl,
    this.about = '',
    this.location = '',
    this.userTitle = '',
    this.messageCount = 0,
    this.reactionScore = 0,
    this.trophyPoints = 0,
    this.isFollowed = false,
    this.canFollow = false,
    this.canPostProfile = false,
    this.viewUrl,
  });

  final int userId;
  final String username;
  final String? avatarUrl;
  final String? bannerUrl;
  final String about;
  final String location;
  final String userTitle;
  final int messageCount;
  final int reactionScore;
  final int trophyPoints;
  final bool isFollowed;
  final bool canFollow;
  final bool canPostProfile;
  final String? viewUrl;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? json;
    String? avatar;
    final avatars = user['avatar_urls'];
    if (avatars is Map) {
      avatar = avatars['l']?.toString() ??
          avatars['m']?.toString() ??
          avatars['o']?.toString();
    }
    String? banner;
    final banners = user['profile_banner_urls'];
    if (banners is Map) {
      banner = banners['m']?.toString() ?? banners['l']?.toString();
      if (banner == 'null' || banner?.isEmpty == true) banner = null;
    }

    return UserProfile(
      userId: user['user_id'] as int? ?? 0,
      username: user['username']?.toString() ?? '',
      avatarUrl: avatar,
      bannerUrl: banner,
      about: user['about']?.toString() ?? '',
      location: user['location']?.toString() ?? '',
      userTitle: user['user_title']?.toString() ?? '',
      messageCount: user['message_count'] as int? ?? 0,
      reactionScore: user['reaction_score'] as int? ?? 0,
      trophyPoints: user['trophy_points'] as int? ?? 0,
      isFollowed: user['is_followed'] == true,
      canFollow: user['can_follow'] == true,
      canPostProfile: user['can_post_profile'] == true,
      viewUrl: user['view_url']?.toString(),
    );
  }

  UserProfile copyWith({bool? isFollowed}) {
    return UserProfile(
      userId: userId,
      username: username,
      avatarUrl: avatarUrl,
      bannerUrl: bannerUrl,
      about: about,
      location: location,
      userTitle: userTitle,
      messageCount: messageCount,
      reactionScore: reactionScore,
      trophyPoints: trophyPoints,
      isFollowed: isFollowed ?? this.isFollowed,
      canFollow: canFollow,
      canPostProfile: canPostProfile,
      viewUrl: viewUrl,
    );
  }
}

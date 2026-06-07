class SocialGroupMember {
  SocialGroupMember({
    required this.userId,
    required this.username,
    this.avatarUrl,
  });

  final int userId;
  final String username;
  final String? avatarUrl;

  factory SocialGroupMember.fromJson(Map<String, dynamic> json) {
    String? avatar;
    final urls = json['avatar_urls'];
    if (urls is Map) {
      avatar = urls['m']?.toString() ?? urls['s']?.toString();
    }
    return SocialGroupMember(
      userId: json['user_id'] as int? ?? 0,
      username: json['username']?.toString() ?? '',
      avatarUrl: avatar,
    );
  }
}

class SocialGroup {
  SocialGroup({
    required this.groupId,
    required this.title,
    this.description = '',
    this.privacyState = 'public',
    this.memberCount = 0,
    this.postCount = 0,
    this.createDate,
    this.lastPostDate,
    this.avatarUrl,
    this.coverUrl,
    this.isMember = false,
    this.isOwner = false,
    this.canJoin = false,
    this.canLeave = false,
    this.canPost = false,
    this.categoryTitle,
    this.owner,
  });

  final int groupId;
  final String title;
  final String description;
  final String privacyState;
  final int memberCount;
  final int postCount;
  final int? createDate;
  final int? lastPostDate;
  final String? avatarUrl;
  final String? coverUrl;
  final bool isMember;
  final bool isOwner;
  final bool canJoin;
  final bool canLeave;
  final bool canPost;
  final String? categoryTitle;
  final SocialGroupMember? owner;

  factory SocialGroup.fromJson(Map<String, dynamic> json) {
    String? categoryTitle;
    if (json['Category'] is Map<String, dynamic>) {
      categoryTitle =
          (json['Category'] as Map<String, dynamic>)['title']?.toString();
    }

    return SocialGroup(
      groupId: json['group_id'] as int? ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      privacyState: json['privacy_state']?.toString() ?? 'public',
      memberCount: json['member_count'] as int? ?? 0,
      postCount: json['post_count'] as int? ?? 0,
      createDate: json['create_date'] as int?,
      lastPostDate: json['last_post_date'] as int?,
      avatarUrl: json['avatar_url']?.toString(),
      coverUrl: json['cover_url']?.toString(),
      isMember: json['is_member'] as bool? ?? false,
      isOwner: json['is_owner'] as bool? ?? false,
      canJoin: json['can_join'] as bool? ?? false,
      canLeave: json['can_leave'] as bool? ?? false,
      canPost: json['can_post'] as bool? ?? false,
      categoryTitle: categoryTitle,
      owner: json['Owner'] is Map<String, dynamic>
          ? SocialGroupMember.fromJson(json['Owner'] as Map<String, dynamic>)
          : null,
    );
  }

  SocialGroup copyWith({
    bool? isMember,
    bool? canJoin,
    bool? canLeave,
    bool? canPost,
    int? memberCount,
  }) {
    return SocialGroup(
      groupId: groupId,
      title: title,
      description: description,
      privacyState: privacyState,
      memberCount: memberCount ?? this.memberCount,
      postCount: postCount,
      createDate: createDate,
      lastPostDate: lastPostDate,
      avatarUrl: avatarUrl,
      coverUrl: coverUrl,
      isMember: isMember ?? this.isMember,
      isOwner: isOwner,
      canJoin: canJoin ?? this.canJoin,
      canLeave: canLeave ?? this.canLeave,
      canPost: canPost ?? this.canPost,
      categoryTitle: categoryTitle,
      owner: owner,
    );
  }
}

class SocialGroupsPage {
  SocialGroupsPage({required this.groups});

  final List<SocialGroup> groups;

  factory SocialGroupsPage.fromJson(Map<String, dynamic> json) {
    final raw = json['groups'] as List<dynamic>? ?? [];
    return SocialGroupsPage(
      groups: raw
          .whereType<Map<String, dynamic>>()
          .map(SocialGroup.fromJson)
          .toList(),
    );
  }
}

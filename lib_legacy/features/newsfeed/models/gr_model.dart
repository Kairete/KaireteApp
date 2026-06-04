import 'newsfeed_model.dart';

class Group {
  int? albumCount;
  bool? allowGuestPosting;
  bool? alwaysModerateJoin;
  String? avatarUrl;
  bool? canDelete;
  bool? canEdit;
  bool? canEditTags;
  bool? canHardDelete;
  bool? canJoin;
  bool? canLeave;
  bool? canManageAvatar;
  bool? canManageCover;
  bool? canPost;
  Category? category;
  int? discussionCount;
  int? eventCount;
  int? groupId;
  String? groupState;
  bool? isIgnored;
  bool? isJoined;
  bool? isOwner;
  String? languageCode;
  int? lastActivity;
  int? memberCount;
  int? memberModeratedCount;
  String? name;
  int? ownerUserId;
  String? ownerUsername;
  String? privacy;
  String? shortDescription;
  List<String>? tags;
  int? viewCount;
  String? viewUrl;

  Group(
      {this.albumCount,
      this.allowGuestPosting,
      this.alwaysModerateJoin,
      this.avatarUrl,
      this.canDelete,
      this.canEdit,
      this.canEditTags,
      this.canHardDelete,
      this.canJoin,
      this.canLeave,
      this.canManageAvatar,
      this.canManageCover,
      this.canPost,
      this.category});

  Group.fromJson(Map<String, dynamic> json) {
    albumCount = json['album_count'];
    allowGuestPosting = json['allow_guest_posting'];
    alwaysModerateJoin = json['always_moderate_join'];
    avatarUrl = json['avatar_url'];
    canDelete = json['can_delete'];
    canEdit = json['can_edit'];
    canEditTags = json['can_edit_tags'];
    canHardDelete = json['can_hard_delete'];
    canJoin = json['can_join'];
    canLeave = json['can_leave'];
    canManageAvatar = json['can_manage_avatar'];
    canManageCover = json['can_manage_cover'];
    canPost = json['can_post'];
    category = json['Category'] != null
        ? new Category.fromJson(json['Category'])
        : null;
    discussionCount = json['discussion_count'];
    eventCount = json['event_count'];
    groupId = json['group_id'];
    groupState = json['group_state'];
    isIgnored = json['is_ignored'];
    isJoined = json['is_joined'];
    isOwner = json['is_owner'];
    languageCode = json['language_code'];
    lastActivity = json['last_activity'];
    memberCount = json['member_count'];
    memberModeratedCount = json['member_moderated_count'];
    name = json['name'];
    ownerUserId = json['owner_user_id'];
    ownerUsername = json['owner_username'];
    privacy = json['privacy'];
    shortDescription = json['short_description'];
    tags = json['tags'].cast<String>();
    viewCount = json['view_count'];
    viewUrl = json['view_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['album_count'] = albumCount;
    data['allow_guest_posting'] = allowGuestPosting;
    data['always_moderate_join'] = alwaysModerateJoin;
    data['avatar_url'] = avatarUrl;
    data['can_delete'] = canDelete;
    data['can_edit'] = canEdit;
    data['can_edit_tags'] = canEditTags;
    data['can_hard_delete'] = canHardDelete;
    data['can_join'] = canJoin;
    data['can_leave'] = canLeave;
    data['can_manage_avatar'] = canManageAvatar;
    data['can_manage_cover'] = canManageCover;
    data['can_post'] = canPost;
    if (category != null) {
      data['Category'] = category!.toJson();
    }
    return data;
  }
}

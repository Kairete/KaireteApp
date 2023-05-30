import '../../newsfeed/models/comment_model/custom_fields.dart';
import 'category.dart';
import 'dynamic_color.dart';
import 'latest_member.dart';

class Group {
  int? albumCount;
  bool? allowGuestPosting;
  bool? alwaysModerateJoin;
  dynamic avatarUrl;
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
  int? categoryId;
  dynamic coverUrl;
  int? createdDate;
  CustomFields? customFields;
  String? description;
  int? discussionCount;
  DynamicColor? dynamicColor;
  int? eventCount;
  int? groupId;
  String? groupState;
  bool? isIgnored;
  bool? isJoined;
  bool? isNewsfeedGroup;
  bool? isOwner;
  String? languageCode;
  int? lastActivity;
  List<LatestMember>? latestMembers;
  int? memberCount;
  int? memberModeratedCount;
  String? name;
  int? ownerUserId;
  String? ownerUsername;
  String? privacy;
  String? shortDescription;
  List<dynamic>? tags;
  int? viewCount;
  String? viewUrl;
  int? postId;

  Group({
    this.albumCount,
    this.allowGuestPosting,
    this.alwaysModerateJoin,
    this.postId,
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
    this.category,
    this.categoryId,
    this.coverUrl,
    this.createdDate,
    this.customFields,
    this.description,
    this.discussionCount,
    this.dynamicColor,
    this.eventCount,
    this.groupId,
    this.groupState,
    this.isIgnored,
    this.isJoined,
    this.isNewsfeedGroup,
    this.isOwner,
    this.languageCode,
    this.lastActivity,
    this.latestMembers,
    this.memberCount,
    this.memberModeratedCount,
    this.name,
    this.ownerUserId,
    this.ownerUsername,
    this.privacy,
    this.shortDescription,
    this.tags,
    this.viewCount,
    this.viewUrl,
  });

  factory Group.fromJson(Map<String, dynamic> json) => Group(
        albumCount: json['album_count'] as int?,
        postId: json['post_id'] as int?,
        allowGuestPosting: json['allow_guest_posting'] as bool?,
        alwaysModerateJoin: json['always_moderate_join'] as bool?,
        avatarUrl: json['avatar_url'] as dynamic,
        canDelete: json['can_delete'] as bool?,
        canEdit: json['can_edit'] as bool?,
        canEditTags: json['can_edit_tags'] as bool?,
        canHardDelete: json['can_hard_delete'] as bool?,
        canJoin: json['can_join'] as bool?,
        canLeave: json['can_leave'] as bool?,
        canManageAvatar: json['can_manage_avatar'] as bool?,
        canManageCover: json['can_manage_cover'] as bool?,
        canPost: json['can_post'] as bool?,
        category: json['Category'] == null
            ? null
            : Category.fromJson(json['Category'] as Map<String, dynamic>),
        categoryId: json['category_id'] as int?,
        coverUrl: json['cover_url'] as dynamic,
        createdDate: json['created_date'] as int?,
        customFields: json['custom_fields'] == null
            ? null
            : CustomFields.fromJson(
                json['custom_fields'] as Map<String, dynamic>),
        description: json['description'] as String?,
        discussionCount: json['discussion_count'] as int?,
        dynamicColor: json['dynamic_color'] == null
            ? null
            : DynamicColor.fromJson(
                json['dynamic_color'] as Map<String, dynamic>),
        eventCount: json['event_count'] as int?,
        groupId: json['group_id'] as int?,
        groupState: json['group_state'] as String?,
        isIgnored: json['is_ignored'] as bool?,
        isJoined: json['is_joined'] as bool?,
        isNewsfeedGroup: json['is_newsfeed_group'] as bool?,
        isOwner: json['is_owner'] as bool?,
        languageCode: json['language_code'] as String?,
        lastActivity: json['last_activity'] as int?,
        latestMembers: (json['LatestMembers'] as List<dynamic>?)
            ?.map((e) => LatestMember.fromJson(e as Map<String, dynamic>))
            .toList(),
        memberCount: json['member_count'] as int?,
        memberModeratedCount: json['member_moderated_count'] as int?,
        name: json['name'] as String?,
        ownerUserId: json['owner_user_id'] as int?,
        ownerUsername: json['owner_username'] as String?,
        privacy: json['privacy'] as String?,
        shortDescription: json['short_description'] as String?,
        tags: json['tags'] as List<dynamic>?,
        viewCount: json['view_count'] as int?,
        viewUrl: json['view_url'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'album_count': albumCount,
        'allow_guest_posting': allowGuestPosting,
        'always_moderate_join': alwaysModerateJoin,
        'avatar_url': avatarUrl,
        'can_delete': canDelete,
        'can_edit': canEdit,
        'can_edit_tags': canEditTags,
        'can_hard_delete': canHardDelete,
        'can_join': canJoin,
        'can_leave': canLeave,
        'can_manage_avatar': canManageAvatar,
        'can_manage_cover': canManageCover,
        'can_post': canPost,
        'Category': category?.toJson(),
        'category_id': categoryId,
        'cover_url': coverUrl,
        'created_date': createdDate,
        'custom_fields': customFields?.toJson(),
        'description': description,
        'discussion_count': discussionCount,
        'dynamic_color': dynamicColor?.toJson(),
        'event_count': eventCount,
        'group_id': groupId,
        'group_state': groupState,
        'is_ignored': isIgnored,
        'is_joined': isJoined,
        'is_newsfeed_group': isNewsfeedGroup,
        'is_owner': isOwner,
        'language_code': languageCode,
        'last_activity': lastActivity,
        'LatestMembers': latestMembers?.map((e) => e.toJson()).toList(),
        'member_count': memberCount,
        'member_moderated_count': memberModeratedCount,
        'name': name,
        'owner_user_id': ownerUserId,
        'owner_username': ownerUsername,
        'privacy': privacy,
        'short_description': shortDescription,
        'tags': tags,
        'view_count': viewCount,
        'view_url': viewUrl,
      };
}

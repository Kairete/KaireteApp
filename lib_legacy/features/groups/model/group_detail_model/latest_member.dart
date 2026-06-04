import 'avatar_urls.dart';
import 'custom_fields.dart';
import 'profile_banner_urls.dart';

class LatestMember {
  AvatarUrls? avatarUrls;
  bool? canBan;
  bool? canConverse;
  bool? canEdit;
  bool? canFollow;
  bool? canIgnore;
  bool? canPostProfile;
  bool? canViewProfile;
  bool? canViewProfilePosts;
  bool? canWarn;
  bool? canWatch;
  CustomFields? customFields;
  String? firebaseDeviceToken;
  bool? isFollowed;
  bool? isIgnored;
  bool? isStaff;
  bool? isWatched;
  int? lastActivity;
  String? location;
  int? messageCount;
  ProfileBannerUrls? profileBannerUrls;
  int? questionSolutionCount;
  int? reactionScore;
  int? registerDate;
  bool? sgCanAddGroup;
  String? signature;
  int? trophyPoints;
  int? userId;
  String? userTitle;
  String? username;
  String? viewUrl;
  int? voteScore;
  String? website;

  LatestMember({
    this.avatarUrls,
    this.canBan,
    this.canConverse,
    this.canEdit,
    this.canFollow,
    this.canIgnore,
    this.canPostProfile,
    this.canViewProfile,
    this.canViewProfilePosts,
    this.canWarn,
    this.canWatch,
    this.customFields,
    this.firebaseDeviceToken,
    this.isFollowed,
    this.isIgnored,
    this.isStaff,
    this.isWatched,
    this.lastActivity,
    this.location,
    this.messageCount,
    this.profileBannerUrls,
    this.questionSolutionCount,
    this.reactionScore,
    this.registerDate,
    this.sgCanAddGroup,
    this.signature,
    this.trophyPoints,
    this.userId,
    this.userTitle,
    this.username,
    this.viewUrl,
    this.voteScore,
    this.website,
  });

  factory LatestMember.fromJson(Map<String, dynamic> json) => LatestMember(
        avatarUrls: json['avatar_urls'] == null
            ? null
            : AvatarUrls.fromJson(json['avatar_urls'] as Map<String, dynamic>),
        canBan: json['can_ban'] as bool?,
        canConverse: json['can_converse'] as bool?,
        canEdit: json['can_edit'] as bool?,
        canFollow: json['can_follow'] as bool?,
        canIgnore: json['can_ignore'] as bool?,
        canPostProfile: json['can_post_profile'] as bool?,
        canViewProfile: json['can_view_profile'] as bool?,
        canViewProfilePosts: json['can_view_profile_posts'] as bool?,
        canWarn: json['can_warn'] as bool?,
        canWatch: json['can_watch'] as bool?,
        customFields: json['custom_fields'] == null
            ? null
            : CustomFields.fromJson(
                json['custom_fields'] as Map<String, dynamic>),
        firebaseDeviceToken: json['firebase_device_token'] as String?,
        isFollowed: json['is_followed'] as bool?,
        isIgnored: json['is_ignored'] as bool?,
        isStaff: json['is_staff'] as bool?,
        isWatched: json['is_watched'] as bool?,
        lastActivity: json['last_activity'] as int?,
        location: json['location'] as String?,
        messageCount: json['message_count'] as int?,
        profileBannerUrls: json['profile_banner_urls'] == null
            ? null
            : ProfileBannerUrls.fromJson(
                json['profile_banner_urls'] as Map<String, dynamic>),
        questionSolutionCount: json['question_solution_count'] as int?,
        reactionScore: json['reaction_score'] as int?,
        registerDate: json['register_date'] as int?,
        sgCanAddGroup: json['sg_can_add_group'] as bool?,
        signature: json['signature'] as String?,
        trophyPoints: json['trophy_points'] as int?,
        userId: json['user_id'] as int?,
        userTitle: json['user_title'] as String?,
        username: json['username'] as String?,
        viewUrl: json['view_url'] as String?,
        voteScore: json['vote_score'] as int?,
        website: json['website'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'avatar_urls': avatarUrls?.toJson(),
        'can_ban': canBan,
        'can_converse': canConverse,
        'can_edit': canEdit,
        'can_follow': canFollow,
        'can_ignore': canIgnore,
        'can_post_profile': canPostProfile,
        'can_view_profile': canViewProfile,
        'can_view_profile_posts': canViewProfilePosts,
        'can_warn': canWarn,
        'can_watch': canWatch,
        'custom_fields': customFields?.toJson(),
        'firebase_device_token': firebaseDeviceToken,
        'is_followed': isFollowed,
        'is_ignored': isIgnored,
        'is_staff': isStaff,
        'is_watched': isWatched,
        'last_activity': lastActivity,
        'location': location,
        'message_count': messageCount,
        'profile_banner_urls': profileBannerUrls?.toJson(),
        'question_solution_count': questionSolutionCount,
        'reaction_score': reactionScore,
        'register_date': registerDate,
        'sg_can_add_group': sgCanAddGroup,
        'signature': signature,
        'trophy_points': trophyPoints,
        'user_id': userId,
        'user_title': userTitle,
        'username': username,
        'view_url': viewUrl,
        'vote_score': voteScore,
        'website': website,
      };
}

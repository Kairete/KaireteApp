import 'avatar_urls.dart';
import 'custom_fields.dart';
import 'navigation_counters.dart';
import 'profile_banner_urls.dart';

class ReactionUser {
  bool? activityVisible;
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
  String? contentSubscribeCostAmount;
  String? contentSubscribeCtaMessage;
  String? contentSubscribeCtaTitle;
  String? contentSubscribePeriod;
  CustomFields? customFields;
  String? customTitle;
  String? firebaseDeviceToken;
  bool? isAdmin;
  bool? isBanned;
  bool? isContentSubscribable;
  bool? isDiscouraged;
  bool? isDonationsEnabled;
  bool? isFollowed;
  bool? isIgnored;
  bool? isModerator;
  bool? isStaff;
  bool? isSubscribed;
  bool? isSuperAdmin;
  bool? isWatched;
  int? lastActivity;
  String? location;
  int? messageCount;
  NavigationCounters? navigationCounters;
  ProfileBannerUrls? profileBannerUrls;
  int? questionSolutionCount;
  int? reactionScore;
  int? registerDate;
  List<dynamic>? secondaryGroupIds;
  bool? sgCanAddGroup;
  String? signature;
  List<dynamic>? subscribedUserIds;
  int? trophyPoints;
  int? userGroupId;
  int? userId;
  String? userState;
  String? userTitle;
  String? username;
  String? viewUrl;
  bool? visible;
  int? voteScore;
  int? warningPoints;
  String? website;

  ReactionUser({
    this.activityVisible,
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
    this.contentSubscribeCostAmount,
    this.contentSubscribeCtaMessage,
    this.contentSubscribeCtaTitle,
    this.contentSubscribePeriod,
    this.customFields,
    this.customTitle,
    this.firebaseDeviceToken,
    this.isAdmin,
    this.isBanned,
    this.isContentSubscribable,
    this.isDiscouraged,
    this.isDonationsEnabled,
    this.isFollowed,
    this.isIgnored,
    this.isModerator,
    this.isStaff,
    this.isSubscribed,
    this.isSuperAdmin,
    this.isWatched,
    this.lastActivity,
    this.location,
    this.messageCount,
    this.navigationCounters,
    this.profileBannerUrls,
    this.questionSolutionCount,
    this.reactionScore,
    this.registerDate,
    this.secondaryGroupIds,
    this.sgCanAddGroup,
    this.signature,
    this.subscribedUserIds,
    this.trophyPoints,
    this.userGroupId,
    this.userId,
    this.userState,
    this.userTitle,
    this.username,
    this.viewUrl,
    this.visible,
    this.voteScore,
    this.warningPoints,
    this.website,
  });

  String getSubText() {
    return 'Messages: ${messageCount.toString()} • Reaction score: ${reactionScore.toString()} • Points: ${trophyPoints.toString()} • Referrals: ${questionSolutionCount.toString()}';
  }

  factory ReactionUser.fromJson(Map<String, dynamic> json) => ReactionUser(
        activityVisible: json['activity_visible'] as bool?,
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
        contentSubscribeCostAmount:
            json['content_subscribe_cost_amount'] as String?,
        contentSubscribeCtaMessage:
            json['content_subscribe_cta_message'] as String?,
        contentSubscribeCtaTitle:
            json['content_subscribe_cta_title'] as String?,
        contentSubscribePeriod: json['content_subscribe_period'] as String?,
        customFields: json['custom_fields'] == null
            ? null
            : CustomFields.fromJson(
                json['custom_fields'] as Map<String, dynamic>),
        customTitle: json['custom_title'] as String?,
        firebaseDeviceToken: json['firebase_device_token'] as String?,
        isAdmin: json['is_admin'] as bool?,
        isBanned: json['is_banned'] as bool?,
        isContentSubscribable: json['is_content_subscribable'] as bool?,
        isDiscouraged: json['is_discouraged'] as bool?,
        isDonationsEnabled: json['is_donations_enabled'] as bool?,
        isFollowed: json['is_followed'] as bool?,
        isIgnored: json['is_ignored'] as bool?,
        isModerator: json['is_moderator'] as bool?,
        isStaff: json['is_staff'] as bool?,
        isSubscribed: json['is_subscribed'] as bool?,
        isSuperAdmin: json['is_super_admin'] as bool?,
        isWatched: json['is_watched'] as bool?,
        lastActivity: json['last_activity'] as int?,
        location: json['location'] as String?,
        messageCount: json['message_count'] as int?,
        navigationCounters: json['navigationCounters'] == null
            ? null
            : NavigationCounters.fromJson(
                json['navigationCounters'] as Map<String, dynamic>),
        profileBannerUrls: json['profile_banner_urls'] == null
            ? null
            : ProfileBannerUrls.fromJson(
                json['profile_banner_urls'] as Map<String, dynamic>),
        questionSolutionCount: json['question_solution_count'] as int?,
        reactionScore: json['reaction_score'] as int?,
        registerDate: json['register_date'] as int?,
        secondaryGroupIds: json['secondary_group_ids'] as List<dynamic>?,
        sgCanAddGroup: json['sg_can_add_group'] as bool?,
        signature: json['signature'] as String?,
        subscribedUserIds: json['subscribed_user_ids'] as List<dynamic>?,
        trophyPoints: json['trophy_points'] as int?,
        userGroupId: json['user_group_id'] as int?,
        userId: json['user_id'] as int?,
        userState: json['user_state'] as String?,
        userTitle: json['user_title'] as String?,
        username: json['username'] as String?,
        viewUrl: json['view_url'] as String?,
        visible: json['visible'] as bool?,
        voteScore: json['vote_score'] as int?,
        warningPoints: json['warning_points'] as int?,
        website: json['website'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'activity_visible': activityVisible,
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
        'content_subscribe_cost_amount': contentSubscribeCostAmount,
        'content_subscribe_cta_message': contentSubscribeCtaMessage,
        'content_subscribe_cta_title': contentSubscribeCtaTitle,
        'content_subscribe_period': contentSubscribePeriod,
        'custom_fields': customFields?.toJson(),
        'custom_title': customTitle,
        'firebase_device_token': firebaseDeviceToken,
        'is_admin': isAdmin,
        'is_banned': isBanned,
        'is_content_subscribable': isContentSubscribable,
        'is_discouraged': isDiscouraged,
        'is_donations_enabled': isDonationsEnabled,
        'is_followed': isFollowed,
        'is_ignored': isIgnored,
        'is_moderator': isModerator,
        'is_staff': isStaff,
        'is_subscribed': isSubscribed,
        'is_super_admin': isSuperAdmin,
        'is_watched': isWatched,
        'last_activity': lastActivity,
        'location': location,
        'message_count': messageCount,
        'navigationCounters': navigationCounters?.toJson(),
        'profile_banner_urls': profileBannerUrls?.toJson(),
        'question_solution_count': questionSolutionCount,
        'reaction_score': reactionScore,
        'register_date': registerDate,
        'secondary_group_ids': secondaryGroupIds,
        'sg_can_add_group': sgCanAddGroup,
        'signature': signature,
        'subscribed_user_ids': subscribedUserIds,
        'trophy_points': trophyPoints,
        'user_group_id': userGroupId,
        'user_id': userId,
        'user_state': userState,
        'user_title': userTitle,
        'username': username,
        'view_url': viewUrl,
        'visible': visible,
        'vote_score': voteScore,
        'warning_points': warningPoints,
        'website': website,
      };
}

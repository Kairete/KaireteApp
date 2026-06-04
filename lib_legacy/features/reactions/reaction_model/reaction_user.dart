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

  factory ReactionUser.fromJson(Map<String, dynamic> json) {
    try {
      return ReactionUser(
        activityVisible:
            tryParse<bool>(json['activity_visible'], 'activity_visible'),
        avatarUrls: json['avatar_urls'] == null
            ? null
            : AvatarUrls.fromJson(json['avatar_urls'] as Map<String, dynamic>),
        canBan: tryParse<bool>(json['can_ban'], 'can_ban'),
        canConverse: tryParse<bool>(json['can_converse'], 'can_converse'),
        canEdit: tryParse<bool>(json['can_edit'], 'can_edit'),
        canFollow: tryParse<bool>(json['can_follow'], 'can_follow'),
        canIgnore: tryParse<bool>(json['can_ignore'], 'can_ignore'),
        canPostProfile:
            tryParse<bool>(json['can_post_profile'], 'can_post_profile'),
        canViewProfile:
            tryParse<bool>(json['can_view_profile'], 'can_view_profile'),
        canViewProfilePosts: tryParse<bool>(
            json['can_view_profile_posts'], 'can_view_profile_posts'),
        canWarn: tryParse<bool>(json['can_warn'], 'can_warn'),
        canWatch: tryParse<bool>(json['can_watch'], 'can_watch'),
        contentSubscribeCostAmount: tryParse<String>(
            json['content_subscribe_cost_amount'],
            'content_subscribe_cost_amount'),
        contentSubscribeCtaMessage: tryParse<String>(
            json['content_subscribe_cta_message'],
            'content_subscribe_cta_message'),
        contentSubscribeCtaTitle: tryParse<String>(
            json['content_subscribe_cta_title'], 'content_subscribe_cta_title'),
        contentSubscribePeriod: tryParse<String>(
            json['content_subscribe_period'], 'content_subscribe_period'),
        customFields: json['custom_fields'] == null
            ? null
            : CustomFields.fromJson(
                json['custom_fields'] as Map<String, dynamic>),
        customTitle: tryParse<String>(json['custom_title'], 'custom_title'),
        firebaseDeviceToken: tryParse<String>(
            json['firebase_device_token'], 'firebase_device_token'),
        isAdmin: tryParse<bool>(json['is_admin'], 'is_admin'),
        isBanned: tryParse<bool>(json['is_banned'], 'is_banned'),
        isContentSubscribable: tryParse<bool>(
            json['is_content_subscribable'], 'is_content_subscribable'),
        isDiscouraged: tryParse<bool>(json['is_discouraged'], 'is_discouraged'),
        isDonationsEnabled: tryParse<bool>(
            json['is_donations_enabled'], 'is_donations_enabled'),
        isFollowed: tryParse<bool>(json['is_followed'], 'is_followed'),
        isIgnored: tryParse<bool>(json['is_ignored'], 'is_ignored'),
        isModerator: tryParse<bool>(json['is_moderator'], 'is_moderator'),
        isStaff: tryParse<bool>(json['is_staff'], 'is_staff'),
        isSubscribed: tryParse<bool>(json['is_subscribed'], 'is_subscribed'),
        isSuperAdmin: tryParse<bool>(json['is_super_admin'], 'is_super_admin'),
        isWatched: tryParse<bool>(json['is_watched'], 'is_watched'),
        lastActivity: tryParse<int>(json['last_activity'], 'last_activity'),
        location: tryParse<String>(json['location'], 'location'),
        messageCount: tryParse<int>(json['message_count'], 'message_count'),
        navigationCounters: json['navigationCounters'] == null
            ? null
            : NavigationCounters.fromJson(
                json['navigationCounters'] as Map<String, dynamic>),
        profileBannerUrls: json['profile_banner_urls'] == null
            ? null
            : ProfileBannerUrls.fromJson(
                json['profile_banner_urls'] as Map<String, dynamic>),
        questionSolutionCount: tryParse<int>(
            json['question_solution_count'], 'question_solution_count'),
        reactionScore: tryParse<int>(json['reaction_score'], 'reaction_score'),
        registerDate: tryParse<int>(json['register_date'], 'register_date'),
        secondaryGroupIds: tryParse<List<dynamic>>(
            json['secondary_group_ids'], 'secondary_group_ids'),
        sgCanAddGroup:
            tryParse<bool>(json['sg_can_add_group'], 'sg_can_add_group'),
        signature: tryParse<String>(json['signature'], 'signature'),
        subscribedUserIds: tryParse<List<dynamic>>(
            json['subscribed_user_ids'], 'subscribed_user_ids'),
        trophyPoints: tryParse<int>(json['trophy_points'], 'trophy_points'),
        userGroupId: tryParse<int>(json['user_group_id'], 'user_group_id'),
        userId: tryParse<int>(json['user_id'], 'user_id'),
        userState: tryParse<String>(json['user_state'], 'user_state'),
        userTitle: tryParse<String>(json['user_title'], 'user_title'),
        username: tryParse<String>(json['username'], 'username'),
        viewUrl: tryParse<String>(json['view_url'], 'view_url'),
        visible: tryParse<bool>(json['visible'], 'visible'),
        voteScore: tryParse<int>(json['vote_score'], 'vote_score'),
        warningPoints: tryParse<int>(json['warning_points'], 'warning_points'),
        website: tryParse<String>(json['website'], 'website'),
      );
    } catch (e, stack) {
      print('Error parsing ReactionUser: $e');
      print('Stack trace: $stack');
      return ReactionUser();
    }
  }

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

T? tryParse<T>(dynamic value, String fieldName) {
  try {
    return value as T;
  } catch (e) {
    print('Error parsing field $fieldName: $e');
    return null;
  }
}

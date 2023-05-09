class UserModel {
  bool? success;
  User? user;

  UserModel({this.success, this.user});

  UserModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class User {
  String? about;
  bool? activityVisible;
  String? allowPostProfile;
  String? allowReceiveNewsFeed;
  String? allowSendPersonalConversation;
  String? allowViewIdentities;
  String? allowViewProfile;
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
  bool? contentShowSignature;
  String? creationWatchState;
  String? customTitle;
  Dob? dob;
  String? email;
  bool? emailOnConversation;
  String? gravatar;
  String? interactionWatchState;
  bool? isAdmin;
  bool? isBanned;
  bool? isDiscouraged;
  bool? isFollowed;
  bool? isIgnored;
  bool? isModerator;
  bool? isStaff;
  bool? isSuperAdmin;
  bool? isWatched;
  int? lastActivity;
  String? location;
  int? messageCount;
  bool? pushOnConversation;
  int? questionSolutionCount;
  int? reactionScore;
  bool? receiveAdminEmail;
  int? registerDate;
  bool? sgCanAddGroup;
  bool? showDobDate;
  bool? showDobYear;
  String? signature;
  String? timezone;
  int? trophyPoints;
  bool? usaTfa;
  bool? useTfa;
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
  AvatarUrls? profileBannerUrls;
  CustomFields? customFields;
  List<dynamic>? secondaryGroupIds;

  User(
      {this.about,
      this.activityVisible,
      this.allowPostProfile,
      this.allowReceiveNewsFeed,
      this.allowSendPersonalConversation,
      this.allowViewIdentities,
      this.allowViewProfile,
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
      this.contentShowSignature,
      this.creationWatchState,
      this.customTitle,
      this.dob,
      this.email,
      this.emailOnConversation,
      this.gravatar,
      this.interactionWatchState,
      this.isAdmin,
      this.isBanned,
      this.isDiscouraged,
      this.isFollowed,
      this.isIgnored,
      this.isModerator,
      this.isStaff,
      this.isSuperAdmin,
      this.isWatched,
      this.lastActivity,
      this.location,
      this.messageCount,
      this.pushOnConversation,
      this.questionSolutionCount,
      this.reactionScore,
      this.receiveAdminEmail,
      this.registerDate,
      this.sgCanAddGroup,
      this.showDobDate,
      this.showDobYear,
      this.signature,
      this.timezone,
      this.trophyPoints,
      this.usaTfa,
      this.useTfa,
      this.userGroupId,
      this.userId,
      this.userState,
      this.userTitle,
      this.username,
      this.viewUrl,
      this.visible,
      this.voteScore,
      this.warningPoints,
      this.website});

  User.fromJson(Map<String, dynamic> json) {
    about = json['about'];
    activityVisible = json['activity_visible'];
    allowPostProfile = json['allow_post_profile'];
    allowReceiveNewsFeed = json['allow_receive_news_feed'];
    allowSendPersonalConversation = json['allow_send_personal_conversation'];
    allowViewIdentities = json['allow_view_identities'];
    allowViewProfile = json['allow_view_profile'];
    avatarUrls = json['avatar_urls'] != null
        ? AvatarUrls.fromJson(json['avatar_urls'])
        : null;
    profileBannerUrls = json['profile_banner_urls'] != null
        ? AvatarUrls.fromJson(json['profile_banner_urls'])
        : null;
    canBan = json['can_ban'];
    canConverse = json['can_converse'];
    canEdit = json['can_edit'];
    canFollow = json['can_follow'];
    canIgnore = json['can_ignore'];
    canPostProfile = json['can_post_profile'];
    canViewProfile = json['can_view_profile'];
    canViewProfilePosts = json['can_view_profile_posts'];
    canWarn = json['can_warn'];
    canWatch = json['can_watch'];
    contentShowSignature = json['content_show_signature'];
    creationWatchState = json['creation_watch_state'];
    customTitle = json['custom_title'];
    dob = json['dob'] != null ? Dob.fromJson(json['dob']) : null;
    email = json['email'];
    emailOnConversation = json['email_on_conversation'];
    gravatar = json['gravatar'];
    interactionWatchState = json['interaction_watch_state'];
    isAdmin = json['is_admin'];
    isBanned = json['is_banned'];
    isDiscouraged = json['is_discouraged'];
    isFollowed = json['is_followed'];
    isIgnored = json['is_ignored'];
    isModerator = json['is_moderator'];
    isStaff = json['is_staff'];
    isSuperAdmin = json['is_super_admin'];
    isWatched = json['is_watched'];
    lastActivity = json['last_activity'];
    location = json['location'];
    messageCount = json['message_count'];
    pushOnConversation = json['push_on_conversation'];
    questionSolutionCount = json['question_solution_count'];
    reactionScore = json['reaction_score'];
    receiveAdminEmail = json['receive_admin_email'];
    registerDate = json['register_date'];
    sgCanAddGroup = json['sg_can_add_group'];
    showDobDate = json['show_dob_date'];
    showDobYear = json['show_dob_year'];
    signature = json['signature'];
    timezone = json['timezone'];
    trophyPoints = json['trophy_points'];
    usaTfa = json['usa_tfa'];
    useTfa = json['use_tfa'];
    userGroupId = json['user_group_id'];
    userId = json['user_id'];
    userState = json['user_state'];
    userTitle = json['user_title'];
    username = json['username'];
    viewUrl = json['view_url'];
    visible = json['visible'];
    voteScore = json['vote_score'];
    warningPoints = json['warning_points'];
    website = json['website'];
    customFields = json['custom_fields'] != null
        ? CustomFields.fromJson(json['custom_fields'])
        : null;
    if (json['secondary_group_ids'] != null) {
      secondaryGroupIds = <dynamic>[];
      json['secondary_group_ids'].forEach((v) {
        secondaryGroupIds!.add(v);
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['about'] = about;
    data['activity_visible'] = activityVisible;
    data['allow_post_profile'] = allowPostProfile;
    data['allow_receive_news_feed'] = allowReceiveNewsFeed;
    data['allow_send_personal_conversation'] = allowSendPersonalConversation;
    data['allow_view_identities'] = allowViewIdentities;
    data['allow_view_profile'] = allowViewProfile;
    if (avatarUrls != null) {
      data['avatar_urls'] = avatarUrls!.toJson();
    }
    data['can_ban'] = canBan;
    data['can_converse'] = canConverse;
    data['can_edit'] = canEdit;
    data['can_follow'] = canFollow;
    data['can_ignore'] = canIgnore;
    data['can_post_profile'] = canPostProfile;
    data['can_view_profile'] = canViewProfile;
    data['can_view_profile_posts'] = canViewProfilePosts;
    data['can_warn'] = canWarn;
    data['can_watch'] = canWatch;
    data['content_show_signature'] = contentShowSignature;
    data['creation_watch_state'] = creationWatchState;
    data['custom_title'] = customTitle;
    if (dob != null) {
      data['dob'] = dob!.toJson();
    }
    data['email'] = email;
    data['email_on_conversation'] = emailOnConversation;
    data['gravatar'] = gravatar;
    data['interaction_watch_state'] = interactionWatchState;
    data['is_admin'] = isAdmin;
    data['is_banned'] = isBanned;
    data['is_discouraged'] = isDiscouraged;
    data['is_followed'] = isFollowed;
    data['is_ignored'] = isIgnored;
    data['is_moderator'] = isModerator;
    data['is_staff'] = isStaff;
    data['is_super_admin'] = isSuperAdmin;
    data['is_watched'] = isWatched;
    data['last_activity'] = lastActivity;
    data['location'] = location;
    data['message_count'] = messageCount;
    data['push_on_conversation'] = pushOnConversation;
    data['question_solution_count'] = questionSolutionCount;
    data['reaction_score'] = reactionScore;
    data['receive_admin_email'] = receiveAdminEmail;
    data['register_date'] = registerDate;
    data['sg_can_add_group'] = sgCanAddGroup;
    data['show_dob_date'] = showDobDate;
    data['show_dob_year'] = showDobYear;
    data['signature'] = signature;
    data['timezone'] = timezone;
    data['trophy_points'] = trophyPoints;
    data['usa_tfa'] = usaTfa;
    data['use_tfa'] = useTfa;
    data['user_group_id'] = userGroupId;
    data['user_id'] = userId;
    data['user_state'] = userState;
    data['user_title'] = userTitle;
    data['username'] = username;
    data['view_url'] = viewUrl;
    data['visible'] = visible;
    data['vote_score'] = voteScore;
    data['warning_points'] = warningPoints;
    data['website'] = website;
    return data;
  }
}

class AvatarUrls {
  String? o;
  String? h;
  String? l;
  String? m;
  String? s;

  AvatarUrls({this.o, this.h, this.l, this.m, this.s});

  AvatarUrls.fromJson(Map<String, dynamic> json) {
    o = json['o'];
    h = json['h'];
    l = json['l'];
    m = json['m'];
    s = json['s'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['o'] = o;
    data['h'] = h;
    data['l'] = l;
    data['m'] = m;
    data['s'] = s;
    return data;
  }
}

class Dob {
  int? year;
  int? month;
  int? day;

  Dob({this.year, this.month, this.day});

  Dob.fromJson(Map<String, dynamic> json) {
    year = json['year'];
    month = json['month'];
    day = json['day'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['year'] = year;
    data['month'] = month;
    data['day'] = day;
    return data;
  }
}

class CustomFields {
  String? lastName;
  String? firstName;
  String? skype;
  String? facebook;
  String? twitter;
  String? residence;
  String? hometown;
  String? fullName;

  CustomFields(
      {this.lastName,
      this.firstName,
      this.skype,
      this.facebook,
      this.twitter,
      this.residence,
      this.hometown});

  CustomFields.fromJson(Map<String, dynamic> json) {
    lastName = json['lastName'] ?? '';
    firstName = json['firstName'] ?? '';
    skype = json['skype'];
    facebook = json['facebook'];
    twitter = json['twitter'];
    residence = json['residence'];
    hometown = json['hometown'];
    fullName =
        firstName != '' && lastName != '' ? '$firstName $lastName' : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lastName'] = lastName;
    data['firstName'] = firstName;
    data['skype'] = skype;
    data['facebook'] = facebook;
    data['twitter'] = twitter;
    data['residence'] = residence;
    data['hometown'] = hometown;
    return data;
  }
}

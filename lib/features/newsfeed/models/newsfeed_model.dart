class BaseNewsfeedModel {
  int? newsfeedTabId;
  List<NewsfeedModel>? newsfeedItems;
  Pagination? pagination;

  BaseNewsfeedModel({this.newsfeedTabId, this.newsfeedItems, this.pagination});

  BaseNewsfeedModel.fromJson(Map<String, dynamic> json) {
    newsfeedTabId = json['newsfeed_tab_id'];
    if (json['newsfeedItems'] != null) {
      newsfeedItems = <NewsfeedModel>[];
      json['newsfeedItems'].forEach((v) {
        newsfeedItems!.add(NewsfeedModel.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['newsfeed_tab_id'] = newsfeedTabId;
    if (newsfeedItems != null) {
      data['newsfeedItems'] = newsfeedItems!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}

class Pagination {
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? shown;
  int? total;

  Pagination(
      {this.currentPage, this.lastPage, this.perPage, this.shown, this.total});

  Pagination.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    perPage = json['per_page'];
    shown = json['shown'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    data['last_page'] = lastPage;
    data['per_page'] = perPage;
    data['shown'] = shown;
    data['total'] = total;
    return data;
  }
}

class NewsfeedModel {
  BlogEntryItem? blogEntryItem;
  int? commentCount;
  int? contentId;
  String? contentType;
  String? contentTitle;
  String? contentUrl;
  String? itemCategory;
  int? itemDate;
  int? itemId;
  int? itemLastCommentDate;
  String? messageParsed;
  String? messagePlainText;
  int? reactionScore;
  List<Reactions>? reactions;
  int? shareCount;
  String? title;
  User? user;
  int? userId;
  String? viewUrl;
  GroupItemModel? groupPostItem;

  NewsfeedModel(
      {this.blogEntryItem,
      this.commentCount,
      this.contentId,
      this.contentType,
      this.contentTitle,
      this.contentUrl,
      this.itemCategory,
      this.itemDate,
      this.itemId,
      this.itemLastCommentDate,
      this.messageParsed,
      this.messagePlainText,
      this.reactionScore,
      this.reactions,
      this.shareCount,
      this.title,
      this.user,
      this.userId,
      this.viewUrl});

  NewsfeedModel.fromJson(Map<String, dynamic> json) {
    blogEntryItem = json['BlogEntryItem'] != null
        ? BlogEntryItem.fromJson(json['BlogEntryItem'])
        : null;
    groupPostItem = json['GroupPost'] != null
        ? GroupItemModel.fromJson(json['GroupPost'])
        : null;
    commentCount = json['comment_count'];
    contentId = json['content_id'];
    contentType = json['content_type'];
    contentTitle = json['ContentTitle'];
    contentUrl = json['ContentUrl'];
    itemCategory = json['item_category'];
    itemDate = json['item_date'];
    itemId = json['item_id'];
    itemLastCommentDate = json['item_last_comment_date'];
    messageParsed = json['message_parsed'];
    messagePlainText = json['message_plain_text'];
    reactionScore = json['reaction_score'];
    if (json['reactions'] != null) {
      reactions = <Reactions>[];
      json['reactions'].forEach((v) {
        reactions!.add(Reactions.fromJson(v));
      });
    }
    shareCount = json['share_count'];
    title = json['title'];
    user = json['User'] != null ? User.fromJson(json['User']) : null;
    userId = json['user_id'];
    viewUrl = json['view_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (blogEntryItem != null) {
      data['BlogEntryItem'] = blogEntryItem!.toJson();
    }
    data['comment_count'] = commentCount;
    data['content_id'] = contentId;
    data['content_type'] = contentType;
    data['ContentTitle'] = contentTitle;
    data['ContentUrl'] = contentUrl;
    data['item_category'] = itemCategory;
    data['item_date'] = itemDate;
    data['item_id'] = itemId;
    data['item_last_comment_date'] = itemLastCommentDate;
    data['message_parsed'] = messageParsed;
    data['message_plain_text'] = messagePlainText;
    data['reaction_score'] = reactionScore;
    if (reactions != null) {
      data['reactions'] = reactions!.map((v) => v.toJson()).toList();
    }
    data['share_count'] = shareCount;
    data['title'] = title;
    if (user != null) {
      data['User'] = user!.toJson();
    }
    data['user_id'] = userId;
    data['view_url'] = viewUrl;
    return data;
  }
}

class BlogEntryItem {
  List<Attachments>? attachments;
  Blog? blog;
  int? blogEntryId;
  bool? canComment;
  bool? canDelete;
  bool? canEdit;
  bool? canReact;
  Category? category;
  Attachments? coverImage;
  bool? isIgnored;
  String? messageParsed;
  String? messagePlainText;
  int? reactionScore;
  List<Reactions>? reactions;
  String? title;
  User? user;
  String? viewUrl;

  BlogEntryItem(
      {this.attachments,
      this.blog,
      this.blogEntryId,
      this.canComment,
      this.canDelete,
      this.canEdit,
      this.canReact,
      this.category,
      this.coverImage,
      this.isIgnored,
      this.messageParsed,
      this.messagePlainText,
      this.reactionScore,
      this.reactions,
      this.title,
      this.user,
      this.viewUrl});

  BlogEntryItem.fromJson(Map<String, dynamic> json) {
    if (json['Attachments'] != null) {
      attachments = <Attachments>[];
      json['Attachments'].forEach((v) {
        attachments!.add(Attachments.fromJson(v));
      });
    }
    blog = json['Blog'] != null ? Blog.fromJson(json['Blog']) : null;
    blogEntryId = json['blog_entry_id'];
    canComment = json['can_comment'];
    canDelete = json['can_delete'];
    canEdit = json['can_edit'];
    canReact = json['can_react'];
    category =
        json['Category'] != null ? Category.fromJson(json['Category']) : null;
    coverImage = json['CoverImage'] != null
        ? Attachments.fromJson(json['CoverImage'])
        : null;
    isIgnored = json['is_ignored'];
    messageParsed = json['message_parsed'];
    messagePlainText = json['message_plain_text'];
    reactionScore = json['reaction_score'];
    if (json['reactions'] != null) {
      reactions = <Reactions>[];
      json['reactions'].forEach((v) {
        reactions!.add(Reactions.fromJson(v));
      });
    }
    title = json['title'];
    user = json['User'] != null ? User.fromJson(json['User']) : null;
    viewUrl = json['view_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (attachments != null) {
      data['Attachments'] = attachments!.map((v) => v.toJson()).toList();
    }
    if (blog != null) {
      data['Blog'] = blog!.toJson();
    }
    data['blog_entry_id'] = blogEntryId;
    data['can_comment'] = canComment;
    data['can_delete'] = canDelete;
    data['can_edit'] = canEdit;
    data['can_react'] = canReact;
    if (category != null) {
      data['Category'] = category!.toJson();
    }
    if (coverImage != null) {
      data['CoverImage'] = coverImage!.toJson();
    }
    data['is_ignored'] = isIgnored;
    data['message_parsed'] = messageParsed;
    data['message_plain_text'] = messagePlainText;
    data['reaction_score'] = reactionScore;
    if (reactions != null) {
      data['reactions'] = reactions!.map((v) => v.toJson()).toList();
    }
    data['title'] = title;
    if (user != null) {
      data['User'] = user!.toJson();
    }
    data['view_url'] = viewUrl;
    return data;
  }
}

class Attachments {
  int? attachDate;
  int? attachmentId;
  int? contentId;
  String? contentType;
  String? directUrl;
  int? fileSize;
  String? filename;
  int? height;
  bool? isAudio;
  bool? isVideo;
  String? thumbnailUrl;
  int? viewCount;
  int? width;
  int? i1088;

  Attachments(
      {this.attachDate,
      this.attachmentId,
      this.contentId,
      this.contentType,
      this.directUrl,
      this.fileSize,
      this.filename,
      this.height,
      this.isAudio,
      this.isVideo,
      this.thumbnailUrl,
      this.viewCount,
      this.width});

  Attachments.fromJson(Map<String, dynamic> json) {
    attachDate = json['attach_date'];
    attachmentId = json['attachment_id'];
    contentId = json['content_id'];
    contentType = json['content_type'];
    directUrl = json['direct_url'];
    fileSize = json['file_size'];
    filename = json['filename'];
    height = json['height'];
    isAudio = json['is_audio'];
    isVideo = json['is_video'];
    thumbnailUrl = json['thumbnail_url'];
    viewCount = json['view_count'];
    width = json['width'];
    i1088 = json['1088'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['attach_date'] = attachDate;
    data['attachment_id'] = attachmentId;
    data['content_id'] = contentId;
    data['content_type'] = contentType;
    data['direct_url'] = directUrl;
    data['file_size'] = fileSize;
    data['filename'] = filename;
    data['height'] = height;
    data['is_audio'] = isAudio;
    data['is_video'] = isVideo;
    data['thumbnail_url'] = thumbnailUrl;
    data['view_count'] = viewCount;
    data['width'] = width;
    return data;
  }
}

class Blog {
  int? blogId;
  bool? canAddBlogEntry;
  bool? canDelete;
  bool? canEdit;
  bool? canEditTags;
  bool? canHardDelete;
  String? description;
  bool? isIgnored;
  String? messageParsed;
  String? messagePlainText;
  int? reactionScore;
  List<String>? tags;
  String? title;
  User? user;
  String? viewUrl;

  Blog(
      {this.blogId,
      this.canAddBlogEntry,
      this.canDelete,
      this.canEdit,
      this.canEditTags,
      this.canHardDelete,
      this.description,
      this.isIgnored,
      this.messageParsed,
      this.messagePlainText,
      this.reactionScore,
      this.tags,
      this.title,
      this.user,
      this.viewUrl});

  Blog.fromJson(Map<String, dynamic> json) {
    blogId = json['blog_id'];
    canAddBlogEntry = json['can_add_blog_entry'];
    canDelete = json['can_delete'];
    canEdit = json['can_edit'];
    canEditTags = json['can_edit_tags'];
    canHardDelete = json['can_hard_delete'];
    description = json['description'];
    isIgnored = json['is_ignored'];
    messageParsed = json['message_parsed'];
    messagePlainText = json['message_plain_text'];
    reactionScore = json['reaction_score'];
    // if (json['tags'] != null) {
    //   tags = <String>[];
    //   json['tags'].forEach((v) {
    //     tags!.add(Null.fromJson(v));
    //   });
    // }
    title = json['title'];
    user = json['User'] != null ? User.fromJson(json['User']) : null;
    viewUrl = json['view_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['blog_id'] = blogId;
    data['can_add_blog_entry'] = canAddBlogEntry;
    data['can_delete'] = canDelete;
    data['can_edit'] = canEdit;
    data['can_edit_tags'] = canEditTags;
    data['can_hard_delete'] = canHardDelete;
    data['description'] = description;
    data['is_ignored'] = isIgnored;
    data['message_parsed'] = messageParsed;
    data['message_plain_text'] = messagePlainText;
    data['reaction_score'] = reactionScore;
    // if (tags != null) {
    //   data['tags'] = tags!.map((v) => v.toJson()).toList();
    // }
    data['title'] = title;
    if (user != null) {
      data['User'] = user!.toJson();
    }
    data['view_url'] = viewUrl;
    return data;
  }
}

class User {
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
  CustomFields? customFields;
  String? customTitle;
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
  ProfileBannerUrls? profileBannerUrls;
  int? questionSolutionCount;
  int? reactionScore;
  int? registerDate;
  List<String>? secondaryGroupIds;
  bool? sgCanAddGroup;
  String? signature;
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

  User(
      {this.activityVisible,
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
      this.customTitle,
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
      this.profileBannerUrls,
      this.questionSolutionCount,
      this.reactionScore,
      this.registerDate,
      this.secondaryGroupIds,
      this.sgCanAddGroup,
      this.signature,
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
      this.website});

  User.fromJson(Map<String, dynamic> json) {
    activityVisible = json['activity_visible'];
    avatarUrls = json['avatar_urls'] != null
        ? AvatarUrls.fromJson(json['avatar_urls'])
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
    customFields = json['custom_fields'] != null
        ? CustomFields.fromJson(json['custom_fields'])
        : null;
    customTitle = json['custom_title'];
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
    profileBannerUrls = json['profile_banner_urls'] != null
        ? ProfileBannerUrls.fromJson(json['profile_banner_urls'])
        : null;
    questionSolutionCount = json['question_solution_count'];
    reactionScore = json['reaction_score'];
    registerDate = json['register_date'];
    if (json['secondary_group_ids'] != null) {
      secondaryGroupIds = <String>[];
      json['secondary_group_ids'].forEach((v) {
        secondaryGroupIds!.add(v);
      });
    }
    sgCanAddGroup = json['sg_can_add_group'];
    signature = json['signature'];
    trophyPoints = json['trophy_points'];
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['activity_visible'] = activityVisible;
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
    if (customFields != null) {
      data['custom_fields'] = customFields!.toJson();
    }
    data['custom_title'] = customTitle;
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
    if (profileBannerUrls != null) {
      data['profile_banner_urls'] = profileBannerUrls!.toJson();
    }
    data['question_solution_count'] = questionSolutionCount;
    data['reaction_score'] = reactionScore;
    data['register_date'] = registerDate;
    if (secondaryGroupIds != null) {
      data['secondary_group_ids'] = secondaryGroupIds!.map((v) => v).toList();
    }
    data['sg_can_add_group'] = sgCanAddGroup;
    data['signature'] = signature;
    data['trophy_points'] = trophyPoints;
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

class ProfileBannerUrls {
  String? l;
  String? m;

  ProfileBannerUrls({this.l, this.m});

  ProfileBannerUrls.fromJson(Map<String, dynamic> json) {
    l = json['l'];
    m = json['m'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['l'] = l;
    data['m'] = m;
    return data;
  }
}

class Category {
  bool? canAddBlogEntry;
  bool? canUploadAttachments;
  int? categoryId;
  String? description;
  int? displayOrder;
  int? parentCategoryId;
  String? title;

  Category(
      {this.canAddBlogEntry,
      this.canUploadAttachments,
      this.categoryId,
      this.description,
      this.displayOrder,
      this.parentCategoryId,
      this.title});

  Category.fromJson(Map<String, dynamic> json) {
    canAddBlogEntry = json['can_add_blog_entry'];
    canUploadAttachments = json['can_upload_attachments'];
    categoryId = json['category_id'];
    description = json['description'];
    displayOrder = json['display_order'];
    parentCategoryId = json['parent_category_id'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['can_add_blog_entry'] = canAddBlogEntry;
    data['can_upload_attachments'] = canUploadAttachments;
    data['category_id'] = categoryId;
    data['description'] = description;
    data['display_order'] = displayOrder;
    data['parent_category_id'] = parentCategoryId;
    data['title'] = title;
    return data;
  }
}

class Reactions {
  int? userId;
  String? username;
  int? reactionId;

  Reactions({this.userId, this.username, this.reactionId});

  Reactions.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    username = json['username'];
    reactionId = json['reaction_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['username'] = username;
    data['reaction_id'] = reactionId;
    return data;
  }
}

class GroupItemModel {
  bool? canComment;
  bool? canDelete;
  bool? canEdit;
  bool? canReact;
  int? commentCount;
  int? firstCommentId;
  FirstComment? firstComment;
  Group? group;

  GroupItemModel(
      {this.canComment,
      this.canDelete,
      this.canEdit,
      this.canReact,
      this.commentCount,
      this.firstCommentId,
      this.firstComment});

  GroupItemModel.fromJson(Map<String, dynamic> json) {
    canComment = json['can_comment'];
    canDelete = json['can_delete'];
    canEdit = json['can_edit'];
    canReact = json['can_react'];
    commentCount = json['comment_count'];
    firstCommentId = json['first_comment_id'];
    firstComment = json['FirstComment'] != null
        ? new FirstComment.fromJson(json['FirstComment'])
        : null;
    group = json['Group'] != null ? new Group.fromJson(json['Group']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['can_comment'] = this.canComment;
    data['can_delete'] = this.canDelete;
    data['can_edit'] = this.canEdit;
    data['can_react'] = this.canReact;
    data['comment_count'] = this.commentCount;
    data['first_comment_id'] = this.firstCommentId;
    if (this.firstComment != null) {
      data['FirstComment'] = this.firstComment!.toJson();
    }
    return data;
  }
}

class FirstComment {
  int? attachCount;
  List<Attachments>? attachments;
  bool? canDelete;
  bool? canEdit;
  bool? canReact;
  bool? canReply;
  bool? canReport;
  int? commentDate;
  int? commentId;
  int? commentLevel;
  int? contentId;
  String? contentType;
  int? editCount;
  EmbedMetadata? embedMetadata;
  bool? hasMoreReplies;
  bool? isIgnored;
  bool? isReactedTo;
  int? lastEditDate;
  int? lastEditUserId;
  String? message;
  String? messageParsed;
  String? messagePlainText;
  int? parentId;
  int? reactionScore;
  int? replyCount;
  User? user;
  int? userId;
  String? username;
  String? viewUrl;

  FirstComment(
      {this.attachCount,
      this.attachments,
      this.canDelete,
      this.canEdit,
      this.canReact,
      this.canReply,
      this.canReport,
      this.commentDate,
      this.commentId,
      this.commentLevel,
      this.contentId,
      this.contentType,
      this.editCount,
      this.embedMetadata,
      this.hasMoreReplies,
      this.isIgnored,
      this.isReactedTo,
      this.lastEditDate,
      this.lastEditUserId,
      this.message,
      this.messageParsed,
      this.messagePlainText,
      this.parentId,
      this.reactionScore,
      this.replyCount,
      this.user,
      this.userId,
      this.username,
      this.viewUrl});

  FirstComment.fromJson(Map<String, dynamic> json) {
    attachCount = json['attach_count'];
    if (json['Attachments'] != null) {
      attachments = <Attachments>[];
      json['Attachments'].forEach((v) {
        attachments!.add(new Attachments.fromJson(v));
      });
    }
    canDelete = json['can_delete'];
    canEdit = json['can_edit'];
    canReact = json['can_react'];
    canReply = json['can_reply'];
    canReport = json['can_report'];
    commentDate = json['comment_date'];
    commentId = json['comment_id'];
    commentLevel = json['comment_level'];
    contentId = json['content_id'];
    contentType = json['content_type'];
    editCount = json['edit_count'];
    // embedMetadata = json['embed_metadata'] != null
    //     ? new EmbedMetadata.fromJson(json['embed_metadata'])
    //     : null;
    hasMoreReplies = json['has_more_replies'];
    isIgnored = json['is_ignored'];
    isReactedTo = json['is_reacted_to'];
    lastEditDate = json['last_edit_date'];
    lastEditUserId = json['last_edit_user_id'];
    message = json['message'];
    messageParsed = json['message_parsed'];
    messagePlainText = json['message_plain_text'];
    parentId = json['parent_id'];
    reactionScore = json['reaction_score'];
    replyCount = json['reply_count'];
    user = json['User'] != null ? new User.fromJson(json['User']) : null;
    userId = json['user_id'];
    username = json['username'];
    viewUrl = json['view_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['attach_count'] = this.attachCount;
    if (this.attachments != null) {
      data['Attachments'] = this.attachments!.map((v) => v.toJson()).toList();
    }
    data['can_delete'] = this.canDelete;
    data['can_edit'] = this.canEdit;
    data['can_react'] = this.canReact;
    data['can_reply'] = this.canReply;
    data['can_report'] = this.canReport;
    data['comment_date'] = this.commentDate;
    data['comment_id'] = this.commentId;
    data['comment_level'] = this.commentLevel;
    data['content_id'] = this.contentId;
    data['content_type'] = this.contentType;
    data['edit_count'] = this.editCount;
    if (this.embedMetadata != null) {
      data['embed_metadata'] = this.embedMetadata!.toJson();
    }
    data['has_more_replies'] = this.hasMoreReplies;
    data['is_ignored'] = this.isIgnored;
    data['is_reacted_to'] = this.isReactedTo;
    data['last_edit_date'] = this.lastEditDate;
    data['last_edit_user_id'] = this.lastEditUserId;
    data['message'] = this.message;
    data['message_parsed'] = this.messageParsed;
    data['message_plain_text'] = this.messagePlainText;
    data['parent_id'] = this.parentId;
    data['reaction_score'] = this.reactionScore;
    data['reply_count'] = this.replyCount;
    if (this.user != null) {
      data['User'] = this.user!.toJson();
    }
    data['user_id'] = this.userId;
    data['username'] = this.username;
    data['view_url'] = this.viewUrl;
    return data;
  }
}

class EmbedMetadata {
  Attachments? attachments;

  EmbedMetadata({this.attachments});

  EmbedMetadata.fromJson(Map<String, dynamic> json) {
    // attachments = json['attachments'] != null
    //     ? new Attachments.fromJson(json['attachments'])
    //     : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.attachments != null) {
      data['attachments'] = this.attachments!.toJson();
    }
    return data;
  }
}

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
    data['album_count'] = this.albumCount;
    data['allow_guest_posting'] = this.allowGuestPosting;
    data['always_moderate_join'] = this.alwaysModerateJoin;
    data['avatar_url'] = this.avatarUrl;
    data['can_delete'] = this.canDelete;
    data['can_edit'] = this.canEdit;
    data['can_edit_tags'] = this.canEditTags;
    data['can_hard_delete'] = this.canHardDelete;
    data['can_join'] = this.canJoin;
    data['can_leave'] = this.canLeave;
    data['can_manage_avatar'] = this.canManageAvatar;
    data['can_manage_cover'] = this.canManageCover;
    data['can_post'] = this.canPost;
    if (this.category != null) {
      data['Category'] = this.category!.toJson();
    }
    return data;
  }
}

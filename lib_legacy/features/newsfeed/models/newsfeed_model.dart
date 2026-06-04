import 'package:kairete/features/reactions/reaction_model/reaction_model.dart';
import 'package:kairete/helper/user.dart';
import 'package:get/get.dart';
import 'package:kairete/local/master_data.dart';

import '../../login/models/user_model.dart';
import 'gr_model.dart';

class BaseNewsfeedModel {
  int? newsfeedTabId;
  List<NewsfeedModel>? newsfeedItems;
  Pagination? pagination;
  dynamic filters;

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
    if (json['filters'] != null) {
      filters = <String>[];
      json['filters'].forEach((v) {
        filters!.add(v);
      });
    }
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
  bool isReation = false;
  String? reactionIconUrl;
  ContentTypeNewFeed? type;
  BlogEntryItem? profilePost;
  bool? isWatched;
  List<ReactionModel>? reactionsList;

  NewsfeedModel({
    this.blogEntryItem,
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
    this.viewUrl,
    this.isWatched,
  });

  NewsfeedModel.fromJson(Map<String, dynamic> json) {
    profilePost = json['ProfilePost'] != null
        ? BlogEntryItem.fromJson(json['ProfilePost'])
        : null;

    blogEntryItem = json['Content'] != null
        ? BlogEntryItem.fromJson(json['Content'])
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
    if (reactions != null) {
      final userId = UserManager.instance.userId;
      final item =
          reactions!.firstWhereOrNull((element) => element.userId == userId);
      if (item != null) {
        final path = MasterDataManager.instance.reactionIcons
            .firstWhere((element) => element.reactionId == item.reactionId)
            .imageUrl;
        reactionIconUrl = path;
      }
      isReation = item != null;
    }
    if (contentType != null) {
      switch (contentType) {
        case 'thread':
          type = ContentTypeNewFeed.thread;
          break;
        case 'profile_post':
          type = ContentTypeNewFeed.profilePost;
          break;
        case 'tl_group_post':
          type = ContentTypeNewFeed.tlGroupPost;
          break;
        case 'xfmg_media':
          type = ContentTypeNewFeed.media;
          break;
        case 'xfmg_album':
          type = ContentTypeNewFeed.album;
          break;
        case 'ubs_blog_entry':
          type = ContentTypeNewFeed.blogEntry;
          break;
        case 'ams_article':
          type = ContentTypeNewFeed.article;
          break;
        default:
      }
    }
    isWatched = json['is_watched'];
    if (json['reactions_full_list'] != null) {
      reactionsList = json['reactions_full_list']
          .map<ReactionModel>((e) => ReactionModel.fromJson(e))
          .toList();
    }
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
  bool isReation = false;
  String? reactionIconUrl;
  int? commentCount;
  int? blogId;
  bool? isWatched;
  String tags = '';
  dynamic tagsKey = [];

  Map<String, dynamic>? contenTags;

  BlogEntryItem({
    this.attachments,
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
    this.blogId,
    this.viewUrl,
    this.isWatched,
  });

  BlogEntryItem.fromJson(Map<String, dynamic> json) {
    if (json['Attachments'] != null) {
      attachments = <Attachments>[];
      json['Attachments'].forEach((v) {
        attachments!.add(Attachments.fromJson(v));
      });
    }
    blogId = json['blog_id'];
    commentCount = json['comment_count'];
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
    if (reactions != null) {
      final userId = UserManager.instance.userId;
      final item =
          reactions!.firstWhereOrNull((element) => element.userId == userId);
      if (item != null) {
        final path = MasterDataManager.instance.reactionIcons
            .firstWhere((element) => element.reactionId == item.reactionId)
            .imageUrl;
        reactionIconUrl = path;
      }
      isReation = item != null;
    }
    isWatched = json['is_watched'];
    if (json['tags'] != null) {
      json['tags'].forEach((e) {
        final tag = e['tag'].replaceAll(' ', '');
        // final tagKey = e['tag_url'];
        final string = '#' + tag + ' ';
        tags += string;
        // tagsKey.add(tagKey);
      });
    }
    tagsKey = json['tags'];
    // if (json['ContentTags'] != null) {
    //   final result = json['ContentTags'];
    //   final keys = result.keys;
    //   keys.forEach((element) {
    //     final json = result[element];
    //     if (json != null) {
    //       final tag = json['tag'].replaceAll(' ', '');
    //       final tagKey = json['tag_url'].replaceAll(' ', '');
    //       final string = '#' + tag + ' ';
    //       tags += string;
    //       tagsKey.add(tagKey);
    //       final value = {
    //         'tag': tag,
    //         'tagKey': tagKey,
    //       };
    //       print(value);
    //       tagsKeyDynamic.add(value);
    //     }
    //   });
    // }
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
  int? viewCount;
  int? lastBlogEntryDate;

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
    viewCount = json['view_count'];
    lastBlogEntryDate = json['last_blog_entry_date'];
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
    title = json['title'] ?? json['category_title'];
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
    data['can_comment'] = canComment;
    data['can_delete'] = canDelete;
    data['can_edit'] = canEdit;
    data['can_react'] = canReact;
    data['comment_count'] = commentCount;
    data['first_comment_id'] = firstCommentId;
    if (firstComment != null) {
      data['FirstComment'] = firstComment!.toJson();
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
    data['attach_count'] = attachCount;
    if (attachments != null) {
      data['Attachments'] = attachments!.map((v) => v.toJson()).toList();
    }
    data['can_delete'] = canDelete;
    data['can_edit'] = canEdit;
    data['can_react'] = canReact;
    data['can_reply'] = canReply;
    data['can_report'] = canReport;
    data['comment_date'] = commentDate;
    data['comment_id'] = commentId;
    data['comment_level'] = commentLevel;
    data['content_id'] = contentId;
    data['content_type'] = contentType;
    data['edit_count'] = editCount;
    if (embedMetadata != null) {
      data['embed_metadata'] = embedMetadata!.toJson();
    }
    data['has_more_replies'] = hasMoreReplies;
    data['is_ignored'] = isIgnored;
    data['is_reacted_to'] = isReactedTo;
    data['last_edit_date'] = lastEditDate;
    data['last_edit_user_id'] = lastEditUserId;
    data['message'] = message;
    data['message_parsed'] = messageParsed;
    data['message_plain_text'] = messagePlainText;
    data['parent_id'] = parentId;
    data['reaction_score'] = reactionScore;
    data['reply_count'] = replyCount;
    if (user != null) {
      data['User'] = user!.toJson();
    }
    data['user_id'] = userId;
    data['username'] = username;
    data['view_url'] = viewUrl;
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
    if (attachments != null) {
      data['attachments'] = attachments!.toJson();
    }
    return data;
  }
}

enum ContentTypeNewFeed {
  thread,
  profilePost,
  tlGroupPost,
  media,
  album,
  blogEntry,
  article,
}

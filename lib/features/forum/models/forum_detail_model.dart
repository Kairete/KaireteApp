import '../../newsfeed/models/newsfeed_model.dart';

class ForumDetailModel {
  List<Threads>? threads;
  Pagination? pagination;

  ForumDetailModel({this.threads, this.pagination});

  ForumDetailModel.fromJson(Map<String, dynamic> json) {
    if (json['threads'] != null) {
      threads = <Threads>[];
      json['threads'].forEach((v) {
        threads!.add(Threads.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (threads != null) {
      data['threads'] = threads!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}

class Threads {
  bool? canEdit;
  bool? canEditTags;
  bool? canHardDelete;
  bool? canReply;
  bool? canSoftDelete;
  bool? canViewAttachments;
  CustomFields? customFields;
  bool? discussionOpen;
  String? discussionState;
  String? discussionType;
  int? firstPostId;
  int? firstPostReactionScore;
  List<dynamic>? highlightedPostIds;
  bool? isFirstPostPinned;
  bool? isUnread;
  bool? isWatching;
  int? lastPostDate;
  int? lastPostId;
  int? lastPostUserId;
  String? lastPostUsername;
  int? nodeId;
  int? postDate;
  int? prefixId;
  dynamic reactions;
  int? replyCount;
  bool? sticky;
  List<String>? tags;
  int? threadId;
  String? title;
  User? user;
  int? userId;
  String? username;
  int? viewCount;
  String? viewUrl;
  int? visitorPostCount;

  Threads(
      {this.canEdit,
      this.canEditTags,
      this.canHardDelete,
      this.canReply,
      this.canSoftDelete,
      this.canViewAttachments,
      this.customFields,
      this.discussionOpen,
      this.discussionState,
      this.discussionType,
      this.firstPostId,
      this.firstPostReactionScore,
      this.highlightedPostIds,
      this.isFirstPostPinned,
      this.isUnread,
      this.isWatching,
      this.lastPostDate,
      this.lastPostId,
      this.lastPostUserId,
      this.lastPostUsername,
      this.nodeId,
      this.postDate,
      this.prefixId,
      this.reactions,
      this.replyCount,
      this.sticky,
      this.tags,
      this.threadId,
      this.title,
      this.user,
      this.userId,
      this.username,
      this.viewCount,
      this.viewUrl,
      this.visitorPostCount});

  Threads.fromJson(Map<String, dynamic> json) {
    canEdit = json['can_edit'];
    canEditTags = json['can_edit_tags'];
    canHardDelete = json['can_hard_delete'];
    canReply = json['can_reply'];
    canSoftDelete = json['can_soft_delete'];
    canViewAttachments = json['can_view_attachments'];
    customFields = json['custom_fields'] != null
        ? CustomFields.fromJson(json['custom_fields'])
        : null;
    discussionOpen = json['discussion_open'];
    discussionState = json['discussion_state'];
    discussionType = json['discussion_type'];
    firstPostId = json['first_post_id'];
    firstPostReactionScore = json['first_post_reaction_score'];
    // if (json['highlighted_post_ids'] != null) {
    // 	highlightedPostIds = <Null>[];
    // 	json['highlighted_post_ids'].forEach((v) { highlightedPostIds!.add(Null.fromJson(v)); });
    // }
    isFirstPostPinned = json['is_first_post_pinned'];
    isUnread = json['is_unread'];
    isWatching = json['is_watching'];
    lastPostDate = json['last_post_date'];
    lastPostId = json['last_post_id'];
    lastPostUserId = json['last_post_user_id'];
    lastPostUsername = json['last_post_username'];
    nodeId = json['node_id'];
    postDate = json['post_date'];
    prefixId = json['prefix_id'];
    reactions = json['reactions'];
    replyCount = json['reply_count'];
    sticky = json['sticky'];
    tags = json['tags'].cast<String>();
    threadId = json['thread_id'];
    title = json['title'];
    user = json['User'] != null ? User.fromJson(json['User']) : null;
    userId = json['user_id'];
    username = json['username'];
    viewCount = json['view_count'];
    viewUrl = json['view_url'];
    visitorPostCount = json['visitor_post_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['can_edit'] = canEdit;
    data['can_edit_tags'] = canEditTags;
    data['can_hard_delete'] = canHardDelete;
    data['can_reply'] = canReply;
    data['can_soft_delete'] = canSoftDelete;
    data['can_view_attachments'] = canViewAttachments;
    if (customFields != null) {
      data['custom_fields'] = customFields!.toJson();
    }
    data['discussion_open'] = discussionOpen;
    data['discussion_state'] = discussionState;
    data['discussion_type'] = discussionType;
    data['first_post_id'] = firstPostId;
    data['first_post_reaction_score'] = firstPostReactionScore;
    // if (highlightedPostIds != null) {
    //   data['highlighted_post_ids'] = highlightedPostIds!.map((v) => v.toJson()).toList();
    // }
    data['is_first_post_pinned'] = isFirstPostPinned;
    data['is_unread'] = isUnread;
    data['is_watching'] = isWatching;
    data['last_post_date'] = lastPostDate;
    data['last_post_id'] = lastPostId;
    data['last_post_user_id'] = lastPostUserId;
    data['last_post_username'] = lastPostUsername;
    data['node_id'] = nodeId;
    data['post_date'] = postDate;
    data['prefix_id'] = prefixId;
    data['reactions'] = reactions;
    data['reply_count'] = replyCount;
    data['sticky'] = sticky;
    data['tags'] = tags;
    data['thread_id'] = threadId;
    data['title'] = title;
    if (user != null) {
      data['User'] = user!.toJson();
    }
    data['user_id'] = userId;
    data['username'] = username;
    data['view_count'] = viewCount;
    data['view_url'] = viewUrl;
    data['visitor_post_count'] = visitorPostCount;
    return data;
  }
}

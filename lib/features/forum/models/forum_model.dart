class ForumModel {
  List<Nodes>? nodes;

  ForumModel({this.nodes});

  ForumModel.fromJson(Map<String, dynamic> json) {
    if (json['nodes'] != null) {
      nodes = <Nodes>[];
      json['nodes'].forEach((v) {
        nodes!.add(Nodes.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (nodes != null) {
      data['nodes'] = nodes!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Nodes {
  List<Breadcrumbs>? breadcrumbs;
  String? description;
  bool? displayInList;
  int? displayOrder;
  int? nodeId;
  String? nodeName;
  String? nodeTypeId;
  int? parentNodeId;
  String? title;
  TypeData? typeData;
  String? viewUrl;

  Nodes(
      {this.breadcrumbs,
      this.description,
      this.displayInList,
      this.displayOrder,
      this.nodeId,
      this.nodeName,
      this.nodeTypeId,
      this.parentNodeId,
      this.title,
      this.typeData,
      this.viewUrl});

  Nodes.fromJson(Map<String, dynamic> json) {
    if (json['breadcrumbs'] != null) {
      breadcrumbs = <Breadcrumbs>[];
      json['breadcrumbs'].forEach((v) {
        breadcrumbs!.add(Breadcrumbs.fromJson(v));
      });
    }
    description = json['description'];
    displayInList = json['display_in_list'];
    displayOrder = json['display_order'];
    nodeId = json['node_id'];
    nodeName = json['node_name'];
    nodeTypeId = json['node_type_id'];
    parentNodeId = json['parent_node_id'];
    title = json['title'];
    typeData =
        json['type_data'] != null ? TypeData.fromJson(json['type_data']) : null;
    viewUrl = json['view_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (breadcrumbs != null) {
      data['breadcrumbs'] = breadcrumbs!.map((v) => v.toJson()).toList();
    }
    data['description'] = description;
    data['display_in_list'] = displayInList;
    data['display_order'] = displayOrder;
    data['node_id'] = nodeId;
    data['node_name'] = nodeName;
    data['node_type_id'] = nodeTypeId;
    data['parent_node_id'] = parentNodeId;
    data['title'] = title;
    if (typeData != null) {
      data['type_data'] = typeData!.toJson();
    }
    data['view_url'] = viewUrl;
    return data;
  }
}

class Breadcrumbs {
  int? nodeId;
  String? title;
  String? nodeTypeId;

  Breadcrumbs({this.nodeId, this.title, this.nodeTypeId});

  Breadcrumbs.fromJson(Map<String, dynamic> json) {
    nodeId = json['node_id'];
    title = json['title'];
    nodeTypeId = json['node_type_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['node_id'] = nodeId;
    data['title'] = title;
    data['node_type_id'] = nodeTypeId;
    return data;
  }
}

class TypeData {
  bool? allowPosting;
  bool? canCreateThread;
  bool? canUploadAttachment;
  Discussion? discussion;
  int? discussionCount;
  String? forumTypeId;
  bool? isUnread;
  int? lastPostDate;
  int? lastPostId;
  String? lastPostUsername;
  int? lastThreadId;
  int? lastThreadPrefixId;
  String? lastThreadTitle;
  int? messageCount;
  int? minTags;
  bool? requirePrefix;

  TypeData(
      {this.allowPosting,
      this.canCreateThread,
      this.canUploadAttachment,
      this.discussion,
      this.discussionCount,
      this.forumTypeId,
      this.isUnread,
      this.lastPostDate,
      this.lastPostId,
      this.lastPostUsername,
      this.lastThreadId,
      this.lastThreadPrefixId,
      this.lastThreadTitle,
      this.messageCount,
      this.minTags,
      this.requirePrefix});

  TypeData.fromJson(Map<String, dynamic> json) {
    allowPosting = json['allow_posting'];
    canCreateThread = json['can_create_thread'];
    canUploadAttachment = json['can_upload_attachment'];
    discussion = json['discussion'] != null
        ? Discussion.fromJson(json['discussion'])
        : null;
    discussionCount = json['discussion_count'];
    forumTypeId = json['forum_type_id'];
    isUnread = json['is_unread'];
    lastPostDate = json['last_post_date'];
    lastPostId = json['last_post_id'];
    lastPostUsername = json['last_post_username'];
    lastThreadId = json['last_thread_id'];
    lastThreadPrefixId = json['last_thread_prefix_id'];
    lastThreadTitle = json['last_thread_title'];
    messageCount = json['message_count'];
    minTags = json['min_tags'];
    requirePrefix = json['require_prefix'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['allow_posting'] = allowPosting;
    data['can_create_thread'] = canCreateThread;
    data['can_upload_attachment'] = canUploadAttachment;
    if (discussion != null) {
      data['discussion'] = discussion!.toJson();
    }
    data['discussion_count'] = discussionCount;
    data['forum_type_id'] = forumTypeId;
    data['is_unread'] = isUnread;
    data['last_post_date'] = lastPostDate;
    data['last_post_id'] = lastPostId;
    data['last_post_username'] = lastPostUsername;
    data['last_thread_id'] = lastThreadId;
    data['last_thread_prefix_id'] = lastThreadPrefixId;
    data['last_thread_title'] = lastThreadTitle;
    data['message_count'] = messageCount;
    data['min_tags'] = minTags;
    data['require_prefix'] = requirePrefix;
    return data;
  }
}

class Discussion {
  List<String>? allowedThreadTypes;
  bool? allowAnswerVoting;
  bool? allowAnswerDownvote;

  Discussion(
      {this.allowedThreadTypes,
      this.allowAnswerVoting,
      this.allowAnswerDownvote});

  Discussion.fromJson(Map<String, dynamic> json) {
    allowedThreadTypes = json['allowed_thread_types'].cast<String>();
    allowAnswerVoting = json['allow_answer_voting'];
    allowAnswerDownvote = json['allow_answer_downvote'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['allowed_thread_types'] = allowedThreadTypes;
    data['allow_answer_voting'] = allowAnswerVoting;
    data['allow_answer_downvote'] = allowAnswerDownvote;
    return data;
  }
}

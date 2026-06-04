import 'package:get/get_navigation/src/root/parse_route.dart';
import 'package:kairete/features/login/models/user_model.dart';
import 'package:kairete/features/newsfeed/models/newsfeed_model.dart';
import 'package:kairete/features/reactions/reaction_model/reaction_model.dart';
import 'package:kairete/helper/user.dart';
import 'package:kairete/local/master_data.dart';

class MediaModel {
  int? albumId;
  bool? canEdit;
  bool? canEditTags;
  bool? canHardDelete;
  bool? canReact;
  bool? canSoftDelete;
  int? categoryId;
  int? commentCount;
  int? containerId;
  String? containerName;
  String? containerType;
  CustomFields? customFields;
  String? description;
  int? fileSize;
  int? height;
  bool? isReactedTo;
  bool? isWatching;
  int? lastCommentDate;
  int? lastCommentId;
  int? lastCommentUserId;
  String? lastCommentUsername;
  int? lastEditDate;
  int? mediaDate;
  int? mediaId;
  String? mediaState;
  String? mediaType;
  String? mediaUrl;
  int? pbCweWatcherCount;
  int? ratingAvg;
  int? ratingCount;
  int? ratingWeighted;
  int? reactionScore;
  List<Reactions>? reactions;
  List<ReactionModel>? reactionsFullList;
  String? thumbnailUrl;
  String? title;
  User? user;
  int? userId;
  String? username;
  int? viewCount;
  String? viewUrl;
  String? warningMessage;
  int? width;
  String tags = '';
  dynamic tagsKey = [];
  int? newfeedId;
  String? reactionIconUrl;
  bool isReation = false;
  String? mediaEmbedUrl;

  MediaModel(
      {this.albumId,
      this.canEdit,
      this.canEditTags,
      this.canHardDelete,
      this.canReact,
      this.canSoftDelete,
      this.categoryId,
      this.commentCount,
      this.containerId,
      this.containerName,
      this.containerType,
      this.customFields,
      this.description,
      this.fileSize,
      this.height,
      this.isReactedTo,
      this.isWatching,
      this.lastCommentDate,
      this.lastCommentId,
      this.lastCommentUserId,
      this.lastCommentUsername,
      this.lastEditDate,
      this.mediaDate,
      this.mediaId,
      this.mediaState,
      this.mediaType,
      this.mediaUrl,
      this.pbCweWatcherCount,
      this.ratingAvg,
      this.ratingCount,
      this.ratingWeighted,
      this.reactionScore,
      this.reactions,
      this.reactionsFullList,
      this.thumbnailUrl,
      this.title,
      this.user,
      this.userId,
      this.username,
      this.viewCount,
      this.viewUrl,
      this.warningMessage,
      this.width});

  MediaModel.fromJson(Map<String, dynamic> json) {
    newfeedId = json['newsfeed_item_id'];
    mediaEmbedUrl = json['media_embed_url'];
    albumId = json['album_id'];
    canEdit = json['can_edit'];
    canEditTags = json['can_edit_tags'];
    canHardDelete = json['can_hard_delete'];
    canReact = json['can_react'];
    canSoftDelete = json['can_soft_delete'];
    categoryId = json['category_id'];
    commentCount = json['comment_count'];
    containerId = json['container_id'];
    containerName = json['container_name'];
    containerType = json['container_type'];
    customFields = json['custom_fields'] != null
        ? new CustomFields.fromJson(json['custom_fields'])
        : null;
    description = json['description'];
    fileSize = json['file_size'];
    height = json['height'];
    isReactedTo = json['is_reacted_to'];
    isWatching = json['is_watching'];
    lastCommentDate = json['last_comment_date'];
    lastCommentId = json['last_comment_id'];
    lastCommentUserId = json['last_comment_user_id'];
    lastCommentUsername = json['last_comment_username'];
    lastEditDate = json['last_edit_date'];
    mediaDate = json['media_date'];
    mediaId = json['media_id'];
    mediaState = json['media_state'];
    mediaType = json['media_type'];
    mediaUrl = json['media_url'];
    pbCweWatcherCount = json['pb_cwe_watcher_count'];
    ratingAvg = json['rating_avg'];
    ratingCount = json['rating_count'];
    ratingWeighted = json['rating_weighted'];
    reactionScore = json['reaction_score'];
    if (json['reactions'] != null) {
      reactions = <Reactions>[];
      json['reactions'].forEach((v) {
        reactions!.add(Reactions.fromJson(v));
      });
    }
    if (json['reactions_full_list'] != null) {
      reactionsFullList = <ReactionModel>[];
      json['reactions_full_list'].forEach((v) {
        reactionsFullList!.add(ReactionModel.fromJson(v));
      });
    }
    if (json['tags'] != null) {
      json['tags'].forEach((e) {
        final tag = e['tag'].replaceAll(' ', '');
        final string = '#' + tag + ' ';
        tags += string;
      });
    }
    tagsKey = json['tags'];
    thumbnailUrl = json['thumbnail_url'];
    title = json['title'];
    user = json['User'] != null ? new User.fromJson(json['User']) : null;
    userId = json['user_id'];
    username = json['username'];
    viewCount = json['view_count'];
    viewUrl = json['view_url'];
    warningMessage = json['warning_message'];
    width = json['width'];
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['album_id'] = this.albumId;
    data['can_edit'] = this.canEdit;
    data['can_edit_tags'] = this.canEditTags;
    data['can_hard_delete'] = this.canHardDelete;
    data['can_react'] = this.canReact;
    data['can_soft_delete'] = this.canSoftDelete;
    data['category_id'] = this.categoryId;
    data['comment_count'] = this.commentCount;
    data['container_id'] = this.containerId;
    data['container_name'] = this.containerName;
    data['container_type'] = this.containerType;
    if (this.customFields != null) {
      data['custom_fields'] = this.customFields!.toJson();
    }
    data['description'] = this.description;
    data['file_size'] = this.fileSize;
    data['height'] = this.height;
    data['is_reacted_to'] = this.isReactedTo;
    data['is_watching'] = this.isWatching;
    data['last_comment_date'] = this.lastCommentDate;
    data['last_comment_id'] = this.lastCommentId;
    data['last_comment_user_id'] = this.lastCommentUserId;
    data['last_comment_username'] = this.lastCommentUsername;
    data['last_edit_date'] = this.lastEditDate;
    data['media_date'] = this.mediaDate;
    data['media_id'] = this.mediaId;
    data['media_state'] = this.mediaState;
    data['media_type'] = this.mediaType;
    data['media_url'] = this.mediaUrl;
    data['pb_cwe_watcher_count'] = this.pbCweWatcherCount;
    data['rating_avg'] = this.ratingAvg;
    data['rating_count'] = this.ratingCount;
    data['rating_weighted'] = this.ratingWeighted;
    data['reaction_score'] = this.reactionScore;
    if (this.reactions != null) {
      data['reactions'] = this.reactions!.map((v) => v.toJson()).toList();
    }
    if (this.reactionsFullList != null) {
      data['reactions_full_list'] =
          this.reactionsFullList!.map((v) => v.toJson()).toList();
    }

    data['thumbnail_url'] = this.thumbnailUrl;
    data['title'] = this.title;
    if (this.user != null) {
      data['User'] = this.user!.toJson();
    }
    data['user_id'] = this.userId;
    data['username'] = this.username;
    data['view_count'] = this.viewCount;
    data['view_url'] = this.viewUrl;
    data['warning_message'] = this.warningMessage;
    data['width'] = this.width;
    return data;
  }
}

class MediaCategoryModel {
  int? albumCount;
  List<String>? allowedTypes;
  bool? canAdd;
  int? categoryId;
  String? categoryIndexLimit;
  String? categoryType;
  int? commentCount;
  String? description;
  int? displayOrder;
  int? mediaCount;
  int? minTags;
  int? parentCategoryId;
  int? pbCweWatcherCount;
  String? title;
  String? viewUrl;

  MediaCategoryModel(
      {this.albumCount,
      this.allowedTypes,
      this.canAdd,
      this.categoryId,
      this.categoryIndexLimit,
      this.categoryType,
      this.commentCount,
      this.description,
      this.displayOrder,
      this.mediaCount,
      this.minTags,
      this.parentCategoryId,
      this.pbCweWatcherCount,
      this.title,
      this.viewUrl});

  MediaCategoryModel.fromJson(Map<String, dynamic> json) {
    albumCount = json['album_count'];
    allowedTypes = json['allowed_types'].cast<String>();
    canAdd = json['can_add'];
    categoryId = json['category_id'];
    categoryIndexLimit = json['category_index_limit'];
    categoryType = json['category_type'];
    commentCount = json['comment_count'];
    description = json['description'];
    displayOrder = json['display_order'];
    mediaCount = json['media_count'];
    minTags = json['min_tags'];
    parentCategoryId = json['parent_category_id'];
    pbCweWatcherCount = json['pb_cwe_watcher_count'];
    title = json['title'];
    viewUrl = json['view_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['album_count'] = this.albumCount;
    data['allowed_types'] = this.allowedTypes;
    data['can_add'] = this.canAdd;
    data['category_id'] = this.categoryId;
    data['category_index_limit'] = this.categoryIndexLimit;
    data['category_type'] = this.categoryType;
    data['comment_count'] = this.commentCount;
    data['description'] = this.description;
    data['display_order'] = this.displayOrder;
    data['media_count'] = this.mediaCount;
    data['min_tags'] = this.minTags;
    data['parent_category_id'] = this.parentCategoryId;
    data['pb_cwe_watcher_count'] = this.pbCweWatcherCount;
    data['title'] = this.title;
    data['view_url'] = this.viewUrl;
    return data;
  }
}

class MediaAlbumModel {
  int? albumId;
  String? title;

  MediaAlbumModel({
    this.albumId,
    this.title,
  });

  MediaAlbumModel.fromJson(Map<String, dynamic> json) {
    albumId = json['album_id'];
    title = json['title'];
  }
}

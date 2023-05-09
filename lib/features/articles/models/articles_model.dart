import '../../login/models/user_model.dart';
import '../../newsfeed/models/newsfeed_model.dart';

class ArticlesModel {
  List<ArticleItems>? articleItems;
  Pagination? pagination;

  ArticlesModel({this.articleItems, this.pagination});

  ArticlesModel.fromJson(Map<String, dynamic> json) {
    if (json['articleItems'] != null) {
      articleItems = <ArticleItems>[];
      json['articleItems'].forEach((v) {
        articleItems!.add(new ArticleItems.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? new Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.articleItems != null) {
      data['articleItems'] = this.articleItems!.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    return data;
  }
}

class ArticleItems {
  int? articleId;
  bool? canComment;
  bool? canDelete;
  bool? canEdit;
  bool? canReact;
  Category? category;
  CoverImage? coverImage;
  bool? isIgnored;
  String? messageParsed;
  String? messagePlainText;
  int? reactionScore;
  List<Reactions>? reactions;
  String? title;
  User? user;
  String? viewUrl;
  List<Attachments>? attachments;

  ArticleItems(
      {this.articleId,
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
      this.viewUrl,
      this.attachments});

  ArticleItems.fromJson(Map<String, dynamic> json) {
    articleId = json['article_id'];
    canComment = json['can_comment'];
    canDelete = json['can_delete'];
    canEdit = json['can_edit'];
    canReact = json['can_react'];
    category = json['Category'] != null
        ? new Category.fromJson(json['Category'])
        : null;
    coverImage = json['CoverImage'] != null
        ? new CoverImage.fromJson(json['CoverImage'])
        : null;
    isIgnored = json['is_ignored'];
    messageParsed = json['message_parsed'];
    messagePlainText = json['message_plain_text'];
    reactionScore = json['reaction_score'];
    if (json['reactions'] != null) {
      reactions = <Reactions>[];
      json['reactions'].forEach((v) {
        reactions!.add(new Reactions.fromJson(v));
      });
    }
    title = json['title'];
    user = json['User'] != null ? new User.fromJson(json['User']) : null;
    viewUrl = json['view_url'];
    if (json['Attachments'] != null) {
      attachments = <Attachments>[];
      json['Attachments'].forEach((v) {
        attachments!.add(new Attachments.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['article_id'] = this.articleId;
    data['can_comment'] = this.canComment;
    data['can_delete'] = this.canDelete;
    data['can_edit'] = this.canEdit;
    data['can_react'] = this.canReact;
    if (this.category != null) {
      data['Category'] = this.category!.toJson();
    }
    if (this.coverImage != null) {
      data['CoverImage'] = this.coverImage!.toJson();
    }
    data['is_ignored'] = this.isIgnored;
    data['message_parsed'] = this.messageParsed;
    data['message_plain_text'] = this.messagePlainText;
    data['reaction_score'] = this.reactionScore;
    if (this.reactions != null) {
      data['reactions'] = this.reactions!.map((v) => v.toJson()).toList();
    }
    data['title'] = this.title;
    if (this.user != null) {
      data['User'] = this.user!.toJson();
    }
    data['view_url'] = this.viewUrl;
    if (this.attachments != null) {
      data['Attachments'] = this.attachments!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CoverImage {
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

  CoverImage(
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

  CoverImage.fromJson(Map<String, dynamic> json) {
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['attach_date'] = this.attachDate;
    data['attachment_id'] = this.attachmentId;
    data['content_id'] = this.contentId;
    data['content_type'] = this.contentType;
    data['direct_url'] = this.directUrl;
    data['file_size'] = this.fileSize;
    data['filename'] = this.filename;
    data['height'] = this.height;
    data['is_audio'] = this.isAudio;
    data['is_video'] = this.isVideo;
    data['thumbnail_url'] = this.thumbnailUrl;
    data['view_count'] = this.viewCount;
    data['width'] = this.width;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['l'] = this.l;
    data['m'] = this.m;
    return data;
  }
}

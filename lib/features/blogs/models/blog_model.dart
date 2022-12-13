import '../../newsfeed/models/newsfeed_model.dart';

class BlogModel {
  List<BlogEntryItems>? blogEntryItems;
  Pagination? pagination;

  BlogModel({this.blogEntryItems, this.pagination});

  BlogModel.fromJson(Map<String, dynamic> json) {
    if (json['blogEntryItems'] != null) {
      blogEntryItems = <BlogEntryItems>[];
      json['blogEntryItems'].forEach((v) {
        blogEntryItems!.add(BlogEntryItems.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (blogEntryItems != null) {
      data['blogEntryItems'] = blogEntryItems!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}

class BlogEntryItems {
  List<Attachments>? attachments;
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
  String? title;
  User? user;
  String? viewUrl;

  BlogEntryItems(
      {this.attachments,
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
      this.title,
      this.user,
      this.viewUrl});

  BlogEntryItems.fromJson(Map<String, dynamic> json) {
    if (json['Attachments'] != null) {
      attachments = <Attachments>[];
      json['Attachments'].forEach((v) {
        attachments!.add(Attachments.fromJson(v));
      });
    }
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
    title = json['title'];
    user = json['User'] != null ? User.fromJson(json['User']) : null;
    viewUrl = json['view_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (attachments != null) {
      data['Attachments'] = attachments!.map((v) => v.toJson()).toList();
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
    data['title'] = title;
    if (user != null) {
      data['User'] = user!.toJson();
    }
    data['view_url'] = viewUrl;
    return data;
  }
}

import '../../newsfeed/models/newsfeed_model.dart';

class BlogModel {
  List<BlogEntryItem>? blogEntryItems;
  Pagination? pagination;

  BlogModel({this.blogEntryItems, this.pagination});

  BlogModel.fromJson(Map<String, dynamic> json) {
    if (json['blogEntryItems'] != null) {
      blogEntryItems = <BlogEntryItem>[];
      json['blogEntryItems'].forEach((v) {
        blogEntryItems!.add(BlogEntryItem.fromJson(v));
      });
    }
    if (json['blogEntries'] != null) {
      blogEntryItems = <BlogEntryItem>[];
      json['blogEntries'].forEach((v) {
        blogEntryItems!.add(BlogEntryItem.fromJson(v));
      });
    }
    if (json['blogItems'] != null) {
      blogEntryItems = <BlogEntryItem>[];
      json['blogItems'].forEach((v) {
        blogEntryItems!.add(BlogEntryItem.fromJson(v));
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

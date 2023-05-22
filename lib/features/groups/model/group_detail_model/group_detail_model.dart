import 'pagination.dart';
import 'post.dart';

class GroupDetailModel {
  List<Post>? posts;
  Pagination? pagination;

  GroupDetailModel({this.posts, this.pagination});

  factory GroupDetailModel.fromJson(Map<String, dynamic> json) {
    return GroupDetailModel(
      posts: (json['posts'] as List<dynamic>?)
          ?.map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: json['pagination'] == null
          ? null
          : Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'posts': posts?.map((e) => e.toJson()).toList(),
        'pagination': pagination?.toJson(),
      };
}

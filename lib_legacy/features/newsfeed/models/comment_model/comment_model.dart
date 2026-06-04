import 'comment.dart';
import 'pagination.dart';

class CommentModel {
  List<Comment>? comments;
  Pagination? pagination;

  CommentModel({this.comments, this.pagination});

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
        comments: (json['comments'] as List<dynamic>?)
            ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
            .toList(),
        pagination: json['pagination'] == null
            ? null
            : Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'comments': comments?.map((e) => e.toJson()).toList(),
        'pagination': pagination?.toJson(),
      };
}

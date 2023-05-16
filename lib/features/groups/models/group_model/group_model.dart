import 'group.dart';
import 'pagination.dart';

class GroupModel {
  List<Group>? groups;
  Pagination? pagination;

  GroupModel({this.groups, this.pagination});

  factory GroupModel.fromJson(Map<String, dynamic> json) => GroupModel(
        groups: (json['groups'] as List<dynamic>?)
            ?.map((e) => Group.fromJson(e as Map<String, dynamic>))
            .toList(),
        pagination: json['pagination'] == null
            ? null
            : Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'groups': groups?.map((e) => e.toJson()).toList(),
        'pagination': pagination?.toJson(),
      };
}

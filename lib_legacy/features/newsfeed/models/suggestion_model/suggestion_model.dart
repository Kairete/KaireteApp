import 'package:kairete/features/forum/models/forum_model.dart';
import 'package:kairete/features/groups/model/group.dart';
import 'package:kairete/features/login/models/user_model.dart';
import 'package:kairete/features/newsfeed/models/newsfeed_model.dart';

class SuggestionModel {
  List<Group>? groups;
  List<Nodes>? forums;
  List<Blog>? blogs;
  List<User>? users;

  SuggestionModel({this.groups, this.forums, this.blogs, this.users});

  SuggestionModel.fromJson(Map<String, dynamic> json) {
    if (json['groups'] != null) {
      groups = <Group>[];
      json['groups'].forEach((v) {
        print("====== $v");
        groups!.add(new Group.fromJson(v));
      });
    }
    if (json['forums'] != null) {
      forums = <Nodes>[];
      json['forums'].forEach((v) {
        forums!.add(new Nodes.fromJson(v));
      });
    }
    if (json['blogs'] != null) {
      blogs = <Blog>[];
      json['blogs'].forEach((v) {
        blogs!.add(new Blog.fromJson(v));
      });
    }
    if (json['users'] != null) {
      users = <User>[];
      json['users'].forEach((v) {
        users!.add(new User.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.groups != null) {
      data['groups'] = this.groups!.map((v) => v.toJson()).toList();
    }
    if (this.forums != null) {
      data['forums'] = this.forums!.map((v) => v.toJson()).toList();
    }
    if (this.blogs != null) {
      data['blogs'] = this.blogs!.map((v) => v.toJson()).toList();
    }
    if (this.users != null) {
      data['users'] = this.users!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

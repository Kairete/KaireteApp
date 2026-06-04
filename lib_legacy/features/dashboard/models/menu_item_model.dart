class GroupMenuModel {
  String? name;
  List<MenuItemModel>? items;
  GroupItemType? type;
  GroupMenuModel({
    this.name,
    this.items,
    this.type,
  });
}

class MenuItemModel {
  String? name;

  MenuItemModel({this.name});
}

enum GroupItemType {
  forums,
  newsfeed,
  media,
  members,
  articles,
  blogs,
  login,
  register,
  groups,
  conversation,
}

class ReactionIconModel {
  List<ReactionsIcon>? reactions;

  ReactionIconModel({this.reactions});

  ReactionIconModel.fromJson(Map<String, dynamic> json) {
    if (json['reactions'] != null) {
      reactions = <ReactionsIcon>[];
      json['reactions'].forEach((v) {
        reactions!.add(ReactionsIcon.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (reactions != null) {
      data['reactions'] = reactions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ReactionsIcon {
  bool? active;
  String? imageUrl;
  int? reactionId;
  String? title;

  ReactionsIcon({this.active, this.imageUrl, this.reactionId, this.title});

  ReactionsIcon.fromJson(Map<String, dynamic> json) {
    active = json['active'];
    imageUrl = 'https://www.kairete.net/' + json['image_url'];
    reactionId = json['reaction_id'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['active'] = active;
    data['image_url'] = imageUrl;
    data['reaction_id'] = reactionId;
    data['title'] = title;
    return data;
  }
}

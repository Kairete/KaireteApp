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
  register
}

import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/constants/app_routes.dart';
import 'package:kairete/helper/user.dart';

import '../../../helper/notification_service.dart';
import '../models/menu_item_model.dart';

class DashboardController extends GetxController {
  var items = <GroupMenuModel>[].obs;
  GlobalKey<ContainedTabBarViewState> keyTabbar = GlobalKey();

  @override
  void onInit() {
    fetchFcmToken();
    items.value = addData();
    super.onInit();
  }

  List<GroupMenuModel> addData() {
    final items = [
      GroupMenuModel(
        name: 'Forums',
        type: GroupItemType.forums,
        items: [
          MenuItemModel(name: 'New posts'),
          MenuItemModel(name: 'Search forums'),
        ],
      ),
      GroupMenuModel(
        name: 'Newsfeed',
        type: GroupItemType.newsfeed,
        items: [],
      ),
      GroupMenuModel(
        name: 'Media',
        type: GroupItemType.media,
        items: [
          MenuItemModel(name: 'New Media'),
          MenuItemModel(name: 'New comments'),
          MenuItemModel(name: 'Search Media'),
        ],
      ),
      GroupMenuModel(
        name: 'Members',
        type: GroupItemType.members,
        items: [
          MenuItemModel(name: 'Current visitors'),
          MenuItemModel(name: 'New profile posts'),
          MenuItemModel(name: 'Search profile posts'),
        ],
      ),
      GroupMenuModel(
        name: 'Articles',
        type: GroupItemType.articles,
        items: [
          MenuItemModel(name: 'New articles'),
          MenuItemModel(name: 'New comments'),
          MenuItemModel(name: 'Search articles'),
        ],
      ),
      GroupMenuModel(
        name: 'Blogs',
        type: GroupItemType.blogs,
        items: [
          MenuItemModel(name: 'New entries'),
          MenuItemModel(name: 'New comments'),
          MenuItemModel(name: 'Blog list'),
          MenuItemModel(name: 'Search blogs'),
        ],
      ),
    ];
    if (UserManager.instance.user == null) {
      items.insert(
          0,
          GroupMenuModel(
            name: 'Register',
            type: GroupItemType.register,
            items: [],
          ));
      items.insert(
          0,
          GroupMenuModel(
            name: 'Login',
            type: GroupItemType.login,
            items: [],
          ));
    }
    return items;
  }

  void nextStepSubMenu({required String item}) {
    print(item);
  }

  void nextStepFromMenu({required GroupMenuModel item}) {
    switch (item.type) {
      case GroupItemType.login:
        Get.offAllNamed(Routes.login);
        break;
      case GroupItemType.register:
        Get.offAllNamed(Routes.register);
        break;
      case GroupItemType.newsfeed:
        Navigator.pop(Get.context!);
        keyTabbar.currentState?.animateTo(0);
        break;
      case GroupItemType.blogs:
        Navigator.pop(Get.context!);
        keyTabbar.currentState?.animateTo(1);
        break;
      case GroupItemType.articles:
        Navigator.pop(Get.context!);
        keyTabbar.currentState?.animateTo(2);
        break;
      default:
    }
  }

  fetchFcmToken() async {
    NotificationManager.instance.requestPermission();
    NotificationManager.instance.init();
    NotificationManager.instance.enableNotice();
    NotificationManager.instance.onActionSelected(ActionNoticeType.FCM);
  }
}

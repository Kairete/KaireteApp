import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/constants/app_routes.dart';
import 'package:kairete/features/dashboard/usecase/master_data_usecase.dart';
import 'package:kairete/features/forum/screens/forum_screen.dart';
import 'package:kairete/features/groups/screens/group_screen.dart';
import 'package:kairete/helper/user.dart';
import 'package:kairete/local/master_data.dart';

import '../../../helper/notification_service.dart';
import '../../login/models/user_model.dart';
import '../../profile/usecase/user_profile_usecase.dart';
import '../models/menu_item_model.dart';

class DashboardController extends GetxController {
  var items = <GroupMenuModel>[].obs;
  GlobalKey<ContainedTabBarViewState> keyTabbar = GlobalKey();
  UserProfileUsecase usecase = IUserProfileUsecase();
  var user = User().obs;
  MasterDataUsecase masterDataUsecase = IMasterDataUsecase();

  @override
  void onInit() {
    fetchFcmToken();
    fetchItems();
    fetchIcons();
    items.value = addData();
    super.onInit();
  }

  void fetchItems() async {
    final json = await usecase.fetchData();
    user.value = User.fromJson(json['me']);
  }

  void fetchIcons() async {
    final json = await masterDataUsecase.fetchReactionIcons();
    final item = ReactionIconModel.fromJson(json);
    if (item.reactions != null) {
      MasterDataManager.instance.reactionIcons = item.reactions!;
    }
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
        name: 'Groups',
        type: GroupItemType.groups,
        items: [],
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
    if (UserManager.instance.userId == null) {
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
      case GroupItemType.forums:
        Navigator.pop(Get.context!);
        Get.to(() => ForumScreen());
        break;
      case GroupItemType.groups:
        Navigator.pop(Get.context!);
        Get.to(() => GroupScreen());
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

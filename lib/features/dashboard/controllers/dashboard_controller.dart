import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/admob/admob_manager.dart';
import 'package:kairete/constants/app_routes.dart';
import 'package:kairete/features/conversation/conversation_screen.dart';
import 'package:kairete/features/dashboard/models/style_model/css.dart';
import 'package:kairete/features/dashboard/usecase/master_data_usecase.dart';
import 'package:kairete/features/forum/screens/forum_screen.dart';
import 'package:kairete/features/groups/screens/group_screen.dart';
import 'package:kairete/helper/user.dart';
import 'package:kairete/local/master_data.dart';

import '../../../helper/notification_service.dart';
import '../../blogs/models/blog_model.dart';
import '../../blogs/screens/blog_detail_screen.dart';
import '../../login/models/user_model.dart';
import '../../newsfeed/models/newsfeed_model.dart';
import '../../profile/usecase/user_profile_usecase.dart';
import '../models/menu_item_model.dart';

class DashboardController extends GetxController
    with GetSingleTickerProviderStateMixin {
  var items = <GroupMenuModel>[].obs;
  GlobalKey<ContainedTabBarViewState> keyTabbar = GlobalKey();
  late TabController tabController;

  UserProfileUsecase usecase = IUserProfileUsecase();
  var user = User().obs;
  MasterDataUsecase masterDataUsecase = IMasterDataUsecase();
  Css? style;
  var blogs = <BlogEntryItem>[].obs;
  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void onInit() {
    tabController = TabController(length: 4, vsync: this);
    // AdMobManager().initialize();
    // AdMobManager().loadBannerAd(); // Load banner ad
    // AdMobManager().loadInterstitialAd(); // Load interstitial ad

    fetchFcmToken();
    fetchIcons();
    fetchWidget();
    items.value = addData();
    super.onInit();
  }

  void fetchWidget() async {
    final params = {'widget_key': 'blognewsfeed'};
    final json = await masterDataUsecase.fetchWidget(body: params);
    final data = BlogModel.fromJson(json[0]);
    blogs.value = data.blogEntryItems ?? [];
    print('========= ${blogs.length}');
    fetchItems();
  }

  void toDetail({required BlogEntryItem item}) {
    Navigator.pop(Get.context!);
    Get.to(() => BlogDetailScreen(), arguments: {'item': item});
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
      GroupMenuModel(
        name: 'Conversation',
        type: GroupItemType.conversation,
        items: [],
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
      case GroupItemType.conversation:
        Get.to(() => ConversationScreen());
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

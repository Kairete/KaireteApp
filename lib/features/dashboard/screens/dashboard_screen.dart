import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:kairete/components/kairete_icon.dart';
import 'package:kairete/components/kairete_search_field.dart';
import 'package:kairete/constants/color.dart';
import 'package:kairete/constants/font_constant.dart';
import 'package:kairete/features/blogs/screens/blog_screen.dart';
import 'package:kairete/features/dashboard/controllers/dashboard_controller.dart';
import 'package:get/get.dart';
import 'package:kairete/features/media/screens/media_screen.dart';
import 'package:kairete/features/newsfeed/screens/newsfeed_screen.dart';
import 'package:kairete/features/notice/screens/notice_screen.dart';
import 'package:kairete/features/profile/screens/user_profile_screen.dart';
import 'package:kairete/helper/extenstions.dart';
import '../../../components/cache_image.dart';
import '../../../helper/time.dart';
import '../../articles/screens/articles_screen.dart';
import '../../newsfeed/screens/newsfeed_search_screen.dart';

class DashboardScreen extends GetView<DashboardController> {
  DashboardScreen({Key? key}) : super(key: key);
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  // @override
  // DashboardController controller = Get.put(DashboardController());
  var currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: baseAppBar(
        key: _key,
        contorller: controller,
      ),
      drawer: AppDrawer(
        controller: controller,
      ),
      body: ContainedTabBarView(
        key: controller.keyTabbar,
        tabs: [
          Obx(() => TabbarIcon(
                icon: 'ic_tab_home',
                count: controller.user.value.navigationCounters?.threads,
              )),
          Obx(() => TabbarIcon(
                title: 'Blogs',
                icon: 'ic_tab_blog',
                count: controller.user.value.navigationCounters?.ubsBlogEntries,
              )),
          Obx(
            () => TabbarIcon(
              icon: 'ic_tab_new',
              title: 'Articles',
              count: controller.user.value.navigationCounters?.amsArticles,
            ),
          ),
          TabbarIcon(
            icon: 'ic_tab_new',
            title: 'Media',
          ),
        ],
        views: [
          NewsFeedScreen(),
          BlogScreen(),
          ArticlesScreen(),
          MediaScreen(),
        ],
        onChange: (index) {},
        tabBarProperties: const TabBarProperties(
            indicatorColor: kPrimaryColor, indicatorWeight: 2),
      ),
    );
  }
}

AppBar baseAppBar({
  required GlobalKey<ScaffoldState> key,
  bool isShowBack = false,
  bool isShowSearch = true,
  bool isShowMenu = true,
  bool isShowActions = true,
  String? title,
  DashboardController? contorller,
  Function? onTapBack,
}) {
  return AppBar(
    titleTextStyle: TextStyle(),
    actions: isShowActions
        ? [
            Obx(
              () => Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        InkWell(
                          onTap: () {
                            Get.to(() => NoticeScreen(), arguments: {
                              'count': contorller
                                      ?.user.value.navigationCounters?.alerts ??
                                  0,
                            });
                          },
                          child: Icon(
                            Icons.notifications,
                            size: 30,
                          ),
                        ),
                        if (Get.find<DashboardController>()
                                .user
                                .value
                                .navigationCounters
                                ?.alerts !=
                            null)
                          Positioned(
                            right: 1,
                            top: 2,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    InkWell(
                      onTap: () {
                        Get.to(() => UserProfileScreen());
                      },
                      child: KaireteCacheNetworkImage(
                        url: Get.find<DashboardController>()
                                .user
                                .value
                                .avatarUrls
                                ?.o ??
                            '',
                        nameImage:
                            Get.find<DashboardController>().user.value.username,
                        width: 30,
                        height: 30,
                        isCircle: true,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ]
        : null,
    leading: Row(
      children: [
        SizedBox(
          width: 16,
        ),
        if (isShowBack)
          GestureDetector(
            child: Icon(Icons.arrow_back_ios),
            onTap: () {
              if (onTapBack != null) {
                onTapBack();
              }
              Get.back();
            },
          ),
        if (isShowMenu)
          Expanded(
            child: GestureDetector(
              child: Icon(
                Icons.menu,
              ),
              onTap: () {
                key.currentState!.openDrawer();
              },
            ),
          ),
      ],
    ),
    backgroundColor: kPrimaryColor,
    title: title != null
        ? Text(
            title,
            style: kTextHeadingStyle.copyWith(color: Colors.white),
          )
        : SizedBox(
            child: Row(
              children: [
                if (isShowSearch)
                  Expanded(
                    child: KaireteSearchField(
                      onChanged: (value) {},
                      readOnly: true,
                      onTap: () {
                        Get.to(() => NewsfeedSearchScreen(),
                            fullscreenDialog: true);
                      },
                    ),
                  ),
              ],
            ),
            height: 36,
          ),
  );
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.controller,
  });

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: kPrimaryColor,
      child: SafeArea(
          child: Container(
        color: kPrimaryColor,
        child: Column(
          children: [
            SizedBox(
              height: 16,
            ),
            Text(
              'Menu',
              style:
                  kTextHeadingStyle.copyWith(color: Colors.white, fontSize: 24),
            ),
            Expanded(
              child: Obx(() => ListView.builder(
                    itemCount:
                        controller.items.length + controller.blogs.value.length,
                    itemBuilder: (context, index) {
                      if (index < controller.items.length) {
                        final item = controller.items[index];
                        return ExpansionTile(
                          title: InkWell(
                            onTap: () {
                              controller.nextStepFromMenu(item: item);
                            },
                            child: Text(
                              item.name ?? '',
                              style: kTextHeadingStyle.copyWith(
                                  color: Colors.white, fontSize: 20),
                            ),
                          ),
                          onExpansionChanged: (value) {},
                          childrenPadding: const EdgeInsets.only(left: 16),
                          collapsedIconColor: item.items!.isEmpty
                              ? Colors.transparent
                              : Colors.white,
                          iconColor: item.items!.isEmpty
                              ? Colors.transparent
                              : Colors.white,
                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                          expandedAlignment: Alignment.centerLeft,
                          children: item.items == null
                              ? []
                              : item.items!
                                  .map((e) => InkWell(
                                        onTap: () {
                                          controller.nextStepSubMenu(
                                              item: e.name ?? '');
                                        },
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 16),
                                          child: Text(
                                            e.name ?? '',
                                            style: kTextMediumtStyle.copyWith(
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                        );
                      } else {
                        final item =
                            controller.blogs[index - controller.items.length];

                        return InkWell(
                          onTap: () {
                            controller.toDetail(item: item);
                          },
                          child: Container(
                            color: Colors.white,
                            padding: EdgeInsets.all(8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                KaireteCacheNetworkImage(
                                  url: item.user?.avatarUrls?.l ?? '',
                                  width: 36,
                                  height: 36,
                                  isCircle: true,
                                  nameImage: controller.user.value.username,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title ?? '',
                                        style: kTextRegularStyle.copyWith(
                                          color: kPrimaryColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        item.messagePlainText ?? '',
                                        style: kTextRegularStyle.copyWith(
                                          fontSize: 14,
                                        ),
                                        maxLines: 4,
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                          TimeManager.instance
                                              .convertFromTimeStamp(
                                                  timestamp: item
                                                          .attachments?[0]
                                                          .attachDate ??
                                                      0),
                                          style: kTextMediumtStyle.copyWith(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          )),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  )),
            )
          ],
        ),
      )),
    );
  }
}

class TabbarIcon extends StatelessWidget {
  const TabbarIcon({
    Key? key,
    this.icon,
    this.title,
    this.count,
    this.iconWidget,
  }) : super(key: key);

  final String? icon;
  final String? title;
  final int? count;
  final Widget? iconWidget;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconWidget != null) iconWidget!,
            if (icon != null)
              SvgIcon(
                name: icon!,
                width: 16,
                height: 16,
              ),
            Text(
              title ?? 'Newsfeed',
              style: kTextMediumtStyle.copyWith(
                  color: kPrimaryColor, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        if (count != null)
          Positioned(
            bottom: 20,
            right: 0,
            child: Container(
              width: 23,
              height: 23,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
              child: Center(
                child: Text(
                  count!.formatNumber(),
                  style: kTextRegularStyle.copyWith(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

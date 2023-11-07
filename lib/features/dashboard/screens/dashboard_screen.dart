import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:kairete/components/kairete_search_field.dart';
import 'package:kairete/constants/color.dart';
import 'package:kairete/constants/font_constant.dart';
import 'package:kairete/features/blogs/screens/blog_screen.dart';
import 'package:kairete/features/dashboard/controllers/dashboard_controller.dart';
import 'package:get/get.dart';
import 'package:kairete/features/newsfeed/screens/newsfeed_screen.dart';
import 'package:kairete/features/profile/screens/user_profile_screen.dart';
import '../../../components/cache_image.dart';
import '../../../helper/time.dart';
import '../../articles/screens/articles_screen.dart';
import '../../newsfeed/screens/newsfeed_search_screen.dart';

class DashboardScreen extends GetView<DashboardController> {
  DashboardScreen({Key? key}) : super(key: key);
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  // @override
  // DashboardController controller = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: baseAppBar(key: _key),
      drawer: AppDrawer(
        controller: controller,
      ),
      body: ContainedTabBarView(
        key: controller.keyTabbar,
        tabs: const [
          TabbarIcon(),
          TabbarIcon(
            title: 'Blogs',
          ),
          TabbarIcon(
            title: 'Articles',
          ),
        ],
        views: [
          NewsFeedScreen(),
          BlogScreen(),
          ArticlesScreen(),
        ],
        onChange: (index) {},
        tabBarProperties: const TabBarProperties(
            indicatorColor: kPrimaryColor, indicatorWeight: 2),
      ),
    );
  }
}

AppBar baseAppBar(
    {required GlobalKey<ScaffoldState> key, bool isShowBack = false}) {
  return AppBar(
    actions: [
      Obx(
        () => InkWell(
          onTap: () {
            Get.to(() => UserProfileScreen());
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications,
                  size: 30,
                ),
                const SizedBox(
                  width: 4,
                ),
                KaireteCacheNetworkImage(
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
              ],
            ),
          ),
        ),
      )
    ],
    leading: Row(
      children: [
        SizedBox(
          width: isShowBack ? 8 : 16,
        ),
        if (isShowBack)
          GestureDetector(
            child: Icon(Icons.arrow_back_ios),
            onTap: () {
              Get.back();
            },
          ),
        GestureDetector(
          child: Icon(
            Icons.menu,
          ),
          onTap: () {
            key.currentState!.openDrawer();
          },
        ),
      ],
    ),
    backgroundColor: kPrimaryColor,
    title: SizedBox(
      child: Row(
        children: [
          Expanded(
            child: KaireteSearchField(
              onChanged: (value) {},
              readOnly: true,
              onTap: () {
                Get.to(() => NewsfeedSearchScreen(), fullscreenDialog: true);
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
  }) : super(key: key);

  final Widget? icon;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title ?? 'Newsfeed',
      style: kTextMediumtStyle.copyWith(
          color: kPrimaryColor, fontWeight: FontWeight.w600),
    );
  }
}

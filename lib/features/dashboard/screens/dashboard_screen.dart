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
import '../../../helper/user.dart';
import '../../articles/screens/articles_screen.dart';
import '../../newsfeed/screens/newsfeed_search_screen.dart';

class DashboardScreen extends GetView {
  DashboardScreen({Key? key}) : super(key: key);

  @override
  DashboardController controller = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Obx(() => InkWell(
                onTap: () {
                  Get.to(() => UserProfileScreen());
                },
                child: controller.user.value.avatarUrls != null
                    ? Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: KaireteCacheNetworkImage(
                          url: controller.user.value.avatarUrls?.o ?? '',
                          nameImage: controller.user.value.username,
                          width: 30,
                          height: 30,
                          isCircle: true,
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.account_circle_outlined,
                            ),
                          ],
                        ),
                      ),
              ))
        ],
        backgroundColor: kPrimaryColor,
        title: SizedBox(
          child: KaireteSearchField(
            onChanged: (value) {},
            readOnly: true,
            onTap: () {
              Get.to(() => NewsfeedSearchScreen(), fullscreenDialog: true);
            },
          ),
          height: 36,
        ),
      ),
      drawer: Drawer(
        backgroundColor: kPrimaryColor,
        child: SafeArea(
            child: Container(
          color: kPrimaryColor,
          child: Column(
            children: [
              Text(
                'Menu',
                style: kTextHeadingStyle.copyWith(
                    color: Colors.white, fontSize: 24),
              ),
              Expanded(
                child: Obx(() => ListView.builder(
                      itemCount: controller.items.length,
                      itemBuilder: (context, index) {
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
                      },
                    )),
              )
            ],
          ),
        )),
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

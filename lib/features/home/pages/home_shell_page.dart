import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/config/app_build.dart';
import 'package:kairete/config/app_config.dart';
import 'package:kairete/core/services/reaction_catalog.dart';
import 'package:kairete/core/tenant/tenant_service.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/alerts/controllers/alerts_badge_controller.dart';
import 'package:kairete/features/alerts/pages/alerts_page.dart';
import 'package:kairete/features/auth/controllers/auth_flow_controller.dart';
import 'package:kairete/features/blog/controllers/blog_list_controller.dart';
import 'package:kairete/features/blog/pages/blog_create_page.dart';
import 'package:kairete/features/blog/pages/blog_list_page.dart';
import 'package:kairete/features/forum/controllers/forum_list_controller.dart';
import 'package:kairete/features/forum/pages/forum_list_page.dart';
import 'package:kairete/features/groups/pages/groups_list_page.dart';
import 'package:kairete/features/media/pages/media_list_page.dart';
import 'package:kairete/features/home/bindings/home_binding.dart';
import 'package:kairete/features/home/widgets/home_side_menu.dart';
import 'package:kairete/features/omnifeed/controllers/omnifeed_controller.dart';
import 'package:kairete/features/omnifeed/pages/omnifeed_page.dart';
import 'package:kairete/features/omnifeed/widgets/omnifeed_compose_bar.dart';
import 'package:kairete/features/omnifeed/widgets/omnifeed_feed_tabs.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_navigation.dart';
import 'package:kairete/features/search/pages/search_page.dart';
import 'package:kairete/features/social_news/controllers/social_news_home_controller.dart';
import 'package:kairete/features/social_news/pages/social_news_home_page.dart';

/// Shell principale: tab + menu laterale (hamburger).
class HomeShellPage extends StatefulWidget {
  const HomeShellPage({super.key});

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage> {
  int _tabIndex = 0;
  late final OmnifeedController _feed;

  AuthFlowController get _auth => Get.find<AuthFlowController>();

  @override
  void initState() {
    super.initState();
    ReactionCatalog.instance.ensureLoaded();
    HomeBinding().dependencies();
    _feed = OmnifeedController.ensure();
    if (AppConfig.isTenantApp) {
      TenantService().refreshBootstrap();
    }
    if (Get.isRegistered<AlertsBadgeController>()) {
      Get.find<AlertsBadgeController>().refresh();
    }
  }

  void _openAlerts() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AlertsPage()),
    ).then((_) {
      if (Get.isRegistered<AlertsBadgeController>()) {
        Get.find<AlertsBadgeController>().refresh();
      }
    });
  }

  Future<void> _openCreateBlog() async {
    final created = await Get.to<bool>(() => const BlogCreatePage());
    if (created == true) {
      const tag = 'blog_0_0';
      if (Get.isRegistered<BlogListController>(tag: tag)) {
        await Get.find<BlogListController>(tag: tag).loadEntries();
      }
    }
  }

  Set<int> _hiddenTabIndexes() {
    if (AppConfig.isTenantApp) return const {};
    return const {};
  }

  Future<void> _onTabSelected(int i) async {
    if (i == _tabIndex) return;
    if (AppConfig.isTenantApp) {
      await TenantService().syncScopeFromServer();
    }
    setState(() => _tabIndex = i);
    if (!AppConfig.isTenantApp) return;
    if (i == 0) {
      await _feed.loadFeed();
    } else if (i == 1) {
      if (Get.isRegistered<SocialNewsHomeController>()) {
        await Get.find<SocialNewsHomeController>().loadHomepage();
      }
    } else if (i == 2) {
      const tag = 'blog_0_0';
      if (Get.isRegistered<BlogListController>(tag: tag)) {
        await Get.find<BlogListController>(tag: tag).loadEntries();
      }
    } else if (i == 3 && Get.isRegistered<ForumListController>()) {
      await Get.find<ForumListController>().loadForums();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTenant = AppConfig.isTenantApp;
    final tabLayout =
        isTenant ? OmnifeedTabLayout.tenant : OmnifeedTabLayout.hub;

    return Scaffold(
      backgroundColor: AppTheme.feedFooterBg,
      drawer: const HomeSideMenu(),
      appBar: AppBar(
        backgroundColor: AppTheme.brandHeader,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(AppBuild.appBarTitle),
        shape: Border(
          bottom: BorderSide(color: AppTheme.brandAppBarBorder, width: 1),
        ),
        actions: [
          IconButton(
            tooltip: 'Cerca',
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SearchPage()),
              );
            },
          ),
          Obx(() {
            final badge = Get.isRegistered<AlertsBadgeController>()
                ? Get.find<AlertsBadgeController>().unreadCount.value
                : 0;
            return SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                alignment: Alignment.center,
                children: [
                  IconButton(
                    tooltip: 'Notifiche',
                    icon: const Icon(Icons.notifications_none),
                    onPressed: _openAlerts,
                  ),
                  if (badge > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      constraints: const BoxConstraints(minWidth: 18),
                      decoration: BoxDecoration(
                        color: AppTheme.badgeRed,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        badge > 99 ? '99+' : '$badge',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Obx(() {
              final user = _auth.currentUser.value;
              final name = user?.username ?? '';
              return InkWell(
                onTap: user == null
                    ? null
                    : () => OmnifeedNavigation.openUserProfile(user.userId),
                customBorder: const CircleBorder(),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white24,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              );
            }),
          ),
          IconButton(
            tooltip: 'Esci',
            icon: const Icon(Icons.logout, size: 20),
            onPressed: _auth.logout,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OmnifeedFeedTabs(
            selectedIndex: _tabIndex,
            onSelected: _onTabSelected,
            hiddenTabs: _hiddenTabIndexes(),
            layout: tabLayout,
          ),
          if (_showComposeBar(isTenant))
            Obx(
              () => OmnifeedComposeBar(
                mode: _tabIndex == 0
                    ? OmnifeedComposeBarMode.newsfeed
                    : OmnifeedComposeBarMode.blog,
                onTapCompose: _tabIndex == 0 ? _feed.openCompose : null,
                onTapRefresh: _tabIndex == 0
                    ? _feed.loadFeed
                    : _tabIndex == 2
                        ? () async {
                            const tag = 'blog_0_0';
                            if (Get.isRegistered<BlogListController>(tag: tag)) {
                              await Get.find<BlogListController>(tag: tag)
                                  .loadEntries();
                            }
                          }
                        : null,
                isRefreshing: _tabIndex == 0
                    ? _feed.isLoading.value
                    : _tabIndex == 2 &&
                            Get.isRegistered<BlogListController>(tag: 'blog_0_0')
                        ? Get.find<BlogListController>(tag: 'blog_0_0')
                            .isLoading
                            .value
                        : false,
                onTapBlog: isTenant ? null : _feed.openBlogCompose,
                onTapCreateBlog:
                    !isTenant && _tabIndex == 2 ? _openCreateBlog : null,
              ),
            ),
          Expanded(
            child: ColoredBox(
              color: AppTheme.feedFooterBg,
              child: _tabBody(isTenant),
            ),
          ),
        ],
      ),
    );
  }

  bool _showComposeBar(bool isTenant) {
    return _tabIndex == 0 || _tabIndex == 2;
  }

  Widget _tabBody(bool isTenant) {
    if (isTenant) {
      return switch (_tabIndex) {
        0 => const OmnifeedPage(),
        1 => const SocialNewsHomePage(),
        2 => BlogListPage(),
        3 => ForumListPage(embedded: true),
        _ => MediaListPage(),
      };
    }
    return switch (_tabIndex) {
      0 => const OmnifeedPage(),
      1 => const SocialNewsHomePage(),
      2 => BlogListPage(),
      3 => ForumListPage(embedded: true),
      4 => const GroupsListPage(),
      _ => MediaListPage(),
    };
  }
}

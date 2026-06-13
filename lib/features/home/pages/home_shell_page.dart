import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/config/app_branding.dart';
import 'package:kairete/config/app_config.dart';
import 'package:kairete/core/services/reaction_catalog.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/alerts/controllers/alerts_badge_controller.dart';
import 'package:kairete/features/alerts/pages/alerts_page.dart';
import 'package:kairete/features/auth/controllers/auth_flow_controller.dart';
import 'package:kairete/features/blog/controllers/blog_list_controller.dart';
import 'package:kairete/features/blog/pages/blog_create_page.dart';
import 'package:kairete/features/blog/pages/blog_list_page.dart';
import 'package:kairete/features/forum/pages/forum_list_page.dart';
import 'package:kairete/features/groups/pages/groups_list_page.dart';
import 'package:kairete/features/media/pages/media_list_page.dart';
import 'package:kairete/features/home/bindings/home_binding.dart';
import 'package:kairete/features/omnifeed/controllers/omnifeed_controller.dart';
import 'package:kairete/features/omnifeed/pages/omnifeed_page.dart';
import 'package:kairete/features/omnifeed/widgets/omnifeed_compose_bar.dart';
import 'package:kairete/features/omnifeed/widgets/omnifeed_feed_tabs.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_navigation.dart';

/// Home senza drawer: il drawer GetX lasciava una barriera modale che
/// bloccava tutto il body (schermo bianco / tap morti).
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

  @override
  Widget build(BuildContext context) {
    final isTenant = AppConfig.isTenantApp;
    final tabLayout =
        isTenant ? OmnifeedTabLayout.tenant : OmnifeedTabLayout.hub;

    return Scaffold(
      backgroundColor: AppTheme.feedFooterBg,
      appBar: AppBar(
        backgroundColor: AppTheme.brandPrimary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          isTenant ? AppBranding.current.appName : AppBranding.current.appName,
        ),
        shape: Border(
          bottom: BorderSide(color: AppTheme.brandAppBarBorder, width: 1),
        ),
        actions: [
          if (!isTenant)
            IconButton(
              tooltip: 'Forum',
              icon: const Icon(Icons.forum_outlined),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => ForumListPage()),
                );
              },
            ),
          Obx(() {
            final badge = Get.isRegistered<AlertsBadgeController>()
                ? Get.find<AlertsBadgeController>().unreadCount.value
                : 0;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  tooltip: 'Notifiche',
                  icon: const Icon(Icons.notifications_none),
                  onPressed: _openAlerts,
                ),
                if (badge > 0)
                  Positioned(
                    right: 8,
                    top: 8,
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
            onSelected: (i) => setState(() => _tabIndex = i),
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
                    : _tabIndex == 1
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
                    : _tabIndex == 1 &&
                            Get.isRegistered<BlogListController>(tag: 'blog_0_0')
                        ? Get.find<BlogListController>(tag: 'blog_0_0')
                            .isLoading
                            .value
                        : false,
                onTapBlog: isTenant ? null : _feed.openBlogCompose,
                onTapCreateBlog:
                    !isTenant && _tabIndex == 1 ? _openCreateBlog : null,
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
    if (isTenant) return _tabIndex == 0 || _tabIndex == 1;
    return _tabIndex != 2 && _tabIndex != 3;
  }

  Widget _tabBody(bool isTenant) {
    if (isTenant) {
      return switch (_tabIndex) {
        0 => const OmnifeedPage(),
        1 => BlogListPage(),
        _ => ForumListPage(embedded: true),
      };
    }
    return switch (_tabIndex) {
      0 => const OmnifeedPage(),
      1 => BlogListPage(),
      2 => const GroupsListPage(),
      _ => MediaListPage(),
    };
  }
}

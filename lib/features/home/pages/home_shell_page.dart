import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/config/app_build.dart';
import 'package:kairete/core/services/reaction_catalog.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/alerts/controllers/alerts_badge_controller.dart';
import 'package:kairete/features/alerts/pages/alerts_page.dart';
import 'package:kairete/features/auth/controllers/auth_flow_controller.dart';
import 'package:kairete/features/blog/pages/blog_list_page.dart';
import 'package:kairete/features/forum/pages/forum_list_page.dart';
import 'package:kairete/features/groups/pages/groups_list_page.dart';
import 'package:kairete/features/omnifeed/controllers/omnifeed_controller.dart';
import 'package:kairete/features/omnifeed/pages/omnifeed_page.dart';
import 'package:kairete/features/omnifeed/widgets/omnifeed_compose_bar.dart';
import 'package:kairete/features/omnifeed/widgets/omnifeed_feed_tabs.dart';

class HomeShellPage extends StatefulWidget {
  const HomeShellPage({super.key});

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage> {
  int _tabIndex = 0;

  AuthFlowController get _auth => Get.find<AuthFlowController>();
  OmnifeedController get _feed => Get.find<OmnifeedController>();

  @override
  void initState() {
    super.initState();
    ReactionCatalog.instance.ensureLoaded();
    if (!Get.isRegistered<AlertsBadgeController>()) {
      Get.put(AlertsBadgeController());
    } else {
      Get.find<AlertsBadgeController>().refresh();
    }
  }

  void _openAlerts() {
    Get.to(() => const AlertsPage())?.then((_) {
      if (Get.isRegistered<AlertsBadgeController>()) {
        Get.find<AlertsBadgeController>().refresh();
      }
    });
  }

  void _onMenuSelected(String value) {
    switch (value) {
      case 'feed':
        setState(() => _tabIndex = 0);
        break;
      case 'blog':
        setState(() => _tabIndex = 1);
        break;
      case 'forum':
        Get.to(() => ForumListPage());
        break;
      case 'groups':
        setState(() => _tabIndex = 2);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.feedFooterBg,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Kairete · ${AppBuild.label}'),
        shape: const Border(
          bottom: BorderSide(color: Color(0xFF0F4A35), width: 1),
        ),
        leading: PopupMenuButton<String>(
          icon: const Icon(Icons.menu),
          tooltip: 'Menu',
          onSelected: _onMenuSelected,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'feed',
              child: ListTile(
                leading: Icon(Icons.home_outlined),
                title: Text('News feed'),
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const PopupMenuItem(
              value: 'blog',
              child: ListTile(
                leading: Icon(Icons.menu_book_outlined),
                title: Text('Blog'),
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const PopupMenuItem(
              value: 'forum',
              child: ListTile(
                leading: Icon(Icons.forum_outlined),
                title: Text('Forum'),
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const PopupMenuItem(
              value: 'groups',
              child: ListTile(
                leading: Icon(Icons.groups_outlined),
                title: Text('Gruppi'),
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
            PopupMenuItem(
              enabled: false,
              child: Text(
                'Build ${AppBuild.label}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          Obx(() {
            final badge = Get.isRegistered<AlertsBadgeController>()
                ? Get.find<AlertsBadgeController>().unreadCount.value
                : 0;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
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
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white24,
              child: Obx(() {
                final name = _auth.currentUser.value?.username ?? '';
                return Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                );
              }),
            ),
          ),
          IconButton(
            tooltip: 'Esci',
            icon: const Icon(Icons.logout, size: 20),
            onPressed: _auth.logout,
          ),
        ],
      ),
      body: ColoredBox(
        color: AppTheme.feedFooterBg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OmnifeedFeedTabs(
              selectedIndex: _tabIndex,
              onSelected: (i) => setState(() => _tabIndex = i),
            ),
            OmnifeedComposeBar(onRefresh: _feed.loadFeed),
            Expanded(
              child: _tabIndex == 0
                  ? const OmnifeedPage()
                  : _tabIndex == 1
                      ? BlogListPage()
                      : const GroupsListPage(),
            ),
          ],
        ),
      ),
    );
  }
}

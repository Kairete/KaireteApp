import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/config/app_build.dart';
import 'package:kairete/core/services/reaction_catalog.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/home/bindings/home_binding.dart';
import 'package:kairete/features/alerts/controllers/alerts_badge_controller.dart';
import 'package:kairete/features/alerts/pages/alerts_page.dart';
import 'package:kairete/features/auth/controllers/auth_flow_controller.dart';
import 'package:kairete/features/blog/pages/blog_list_page.dart';
import 'package:kairete/features/forum/pages/forum_list_page.dart';
import 'package:kairete/features/groups/pages/groups_list_page.dart';
import 'package:kairete/features/omnifeed/controllers/omnifeed_controller.dart';
import 'package:kairete/features/omnifeed/pages/omnifeed_page.dart';
import 'package:kairete/features/omnifeed/widgets/omnifeed_compose_bar.dart';

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
    HomeBinding().dependencies();
    ReactionCatalog.instance.ensureLoaded();
    _feed = OmnifeedController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _feed.onInit();
      if (Get.isRegistered<AlertsBadgeController>()) {
        Get.find<AlertsBadgeController>().refresh();
      }
    });
  }

  @override
  void dispose() {
    _feed.onClose();
    super.dispose();
  }

  void _openAlerts() {
    Get.to(() => const AlertsPage())?.then((_) {
      if (Get.isRegistered<AlertsBadgeController>()) {
        Get.find<AlertsBadgeController>().refresh();
      }
    });
  }

  void _openForum() {
    Get.to(() => ForumListPage());
  }

  @override
  Widget build(BuildContext context) {
    final username = _auth.currentUser.value?.username ?? '';
    final badge = Get.isRegistered<AlertsBadgeController>()
        ? Get.find<AlertsBadgeController>().unreadCount.value
        : 0;

    return Scaffold(
      backgroundColor: AppTheme.feedFooterBg,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Kairete · ${AppBuild.label}',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            tooltip: 'Forum',
            icon: const Icon(Icons.forum_outlined),
            onPressed: _openForum,
          ),
          Stack(
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
          ),
          IconButton(
            tooltip: 'Esci',
            icon: const Icon(Icons.logout, size: 22),
            onPressed: _auth.logout,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.primary.withOpacity(0.15),
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Blog',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Gruppi',
          ),
        ],
      ),
      body: IndexedStack(
        index: _tabIndex,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (username.isNotEmpty)
                Material(
                  color: const Color(0xFFE8F5E9),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Text(
                      'Ciao, $username',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ),
              OmnifeedComposeBar(onRefresh: _feed.loadFeed),
              Expanded(child: OmnifeedPage(controller: _feed)),
            ],
          ),
          BlogListPage(),
          const GroupsListPage(),
        ],
      ),
    );
  }
}

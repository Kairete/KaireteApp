import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/services/reaction_catalog.dart';
import 'package:kairete/config/app_build.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/alerts/controllers/alerts_badge_controller.dart';
import 'package:kairete/features/alerts/pages/alerts_page.dart';
import 'package:kairete/features/auth/controllers/auth_flow_controller.dart';
import 'package:kairete/features/blog/pages/blog_list_page.dart';
import 'package:kairete/features/forum/pages/forum_list_page.dart';
import 'package:kairete/features/groups/pages/groups_list_page.dart';
import 'package:kairete/features/home/bindings/home_binding.dart';
import 'package:kairete/features/omnifeed/controllers/omnifeed_controller.dart';
import 'package:kairete/features/omnifeed/pages/omnifeed_page.dart';
import 'package:kairete/features/omnifeed/widgets/omnifeed_compose_bar.dart';
import 'package:kairete/features/omnifeed/widgets/omnifeed_feed_tabs.dart';
import 'package:kairete/features/home/pages/home_shell_page.dart';
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

  void _openForum() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ForumListPage()),
    );
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
        actions: [
          IconButton(
            tooltip: 'Forum',
            icon: const Icon(Icons.forum_outlined),
            onPressed: _openForum,
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
          ),
          OmnifeedComposeBar(
            onTapCompose: _feed.openCompose,
            onTapBlog: _feed.openBlogCompose,
          ),
          Expanded(
            child: ColoredBox(
              color: AppTheme.feedFooterBg,
              child: _tabIndex == 0
                  ? const OmnifeedPage()
                  : _tabIndex == 1
                      ? BlogListPage()
                      : const GroupsListPage(),
            ),
          ),
        ],
      ),
    );
  }
}

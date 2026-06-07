import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/services/reaction_catalog.dart';
import 'package:kairete/core/theme/app_theme.dart';
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
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  AuthFlowController get _auth => Get.find<AuthFlowController>();

  @override
  void initState() {
    super.initState();
    ReactionCatalog.instance.ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<OmnifeedController>()) {
      Get.put(OmnifeedController());
    }
    final feed = Get.find<OmnifeedController>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.feedFooterBg,
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: AppTheme.primary),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Obx(() {
                    final name = _auth.currentUser.value?.username ?? 'Utente';
                    return Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text('News feed'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _tabIndex = 0);
                },
              ),
              ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: const Text('Blog'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _tabIndex = 1);
                },
              ),
              ListTile(
                leading: const Icon(Icons.forum_outlined),
                title: const Text('Forum'),
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => ForumListPage());
                },
              ),
              ListTile(
                leading: const Icon(Icons.groups_outlined),
                title: const Text('Gruppi'),
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => const GroupsListPage());
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: const Border(
          bottom: BorderSide(color: Color(0xFF0F4A35), width: 1),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
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
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () {},
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.badgeRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OmnifeedFeedTabs(
            selectedIndex: _tabIndex,
            onSelected: (i) => setState(() => _tabIndex = i),
          ),
          OmnifeedComposeBar(onTapCompose: feed.openCompose),
          Expanded(
            child: _tabIndex == 0
                ? OmnifeedPage()
                : _tabIndex == 1
                    ? BlogListPage()
                    : Center(
                    child: Text(
                      'Prossimamente',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

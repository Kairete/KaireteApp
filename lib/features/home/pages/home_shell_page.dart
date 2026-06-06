import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/auth/controllers/auth_flow_controller.dart';
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

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<OmnifeedController>()) {
      Get.put(OmnifeedController());
    }
    final feed = Get.find<OmnifeedController>();

    return Scaffold(
      backgroundColor: AppTheme.feedFooterBg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HomeTopBar(auth: _auth),
          OmnifeedFeedTabs(
            selectedIndex: _tabIndex,
            onSelected: (i) => setState(() => _tabIndex = i),
          ),
          OmnifeedComposeBar(onTapCompose: feed.openCompose),
          Expanded(
            child: _tabIndex == 0
                ? OmnifeedPage()
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

class _HomeTopBar extends StatelessWidget {
  const _HomeTopBar({required this.auth});

  final AuthFlowController auth;

  static const _barHeight = 36.0;
  static const _iconSize = 18.0;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.feedFooterBg,
      child: SafeArea(
        bottom: false,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppTheme.cardBorder, width: 1),
            ),
          ),
          child: SizedBox(
            height: _barHeight,
            child: Row(
              children: [
                _HeaderIconButton(
                  icon: Icons.menu,
                  onPressed: () {},
                ),
                const Spacer(),
                _HeaderIconButton(
                  icon: Icons.chat_bubble_outline,
                  onPressed: () {},
                ),
                _HeaderIconButton(
                  icon: Icons.search,
                  onPressed: () {},
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _HeaderIconButton(
                      icon: Icons.notifications_none,
                      onPressed: () {},
                    ),
                    Positioned(
                      right: 7,
                      top: 6,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppTheme.badgeRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: CircleAvatar(
                    radius: 11,
                    backgroundColor: AppTheme.cardBorder,
                    child: Obx(() {
                      final name = auth.currentUser.value?.username ?? '';
                      return Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }),
                  ),
                ),
                _HeaderIconButton(
                  icon: Icons.logout,
                  tooltip: 'Esci',
                  onPressed: auth.logout,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = InkWell(
      onTap: onPressed,
      child: SizedBox(
        width: 34,
        height: _HomeTopBar._barHeight,
        child: Center(
          child: Icon(
            icon,
            size: _HomeTopBar._iconSize,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

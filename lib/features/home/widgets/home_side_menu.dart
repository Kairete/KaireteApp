import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/config/app_branding.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/account/pages/account_details_page.dart';
import 'package:kairete/features/account/pages/account_native_lists_pages.dart';
import 'package:kairete/features/suggestions/pages/suggestions_page.dart';
import 'package:kairete/features/account/pages/account_preferences_page.dart';
import 'package:kairete/features/account/pages/account_privacy_page.dart';
import 'package:kairete/features/account/pages/account_security_page.dart';
import 'package:kairete/features/account/pages/account_signature_page.dart';
import 'package:kairete/features/alerts/pages/alerts_page.dart';
import 'package:kairete/features/auth/controllers/auth_flow_controller.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_navigation.dart';

/// Menu laterale allineato alla sidebar account del web XenForo
/// (`account_wrapper`) + Wallet Kairete. Tutte le voci sono native.
class HomeSideMenu extends StatelessWidget {
  const HomeSideMenu({super.key});

  void _openPage(BuildContext context, Widget page) {
    final nav = Navigator.of(context);
    nav.pop();
    nav.push(MaterialPageRoute<void>(builder: (_) => page));
  }

  void _openProfile(BuildContext context) {
    Navigator.of(context).pop();
    final user = Get.find<AuthFlowController>().currentUser.value;
    OmnifeedNavigation.openUserProfile(
      user?.userId,
      username: user?.username,
    );
  }

  Future<void> _logout(BuildContext context) async {
    Navigator.of(context).pop();
    await Get.find<AuthFlowController>().logout();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              color: AppTheme.brandPrimary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppBranding.current.appName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Obx(() {
                    final user =
                        Get.find<AuthFlowController>().currentUser.value;
                    final name = user?.username ?? '';
                    if (name.isEmpty) return const SizedBox.shrink();
                    return Text(
                      name,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  const _SectionHeader('Il tuo account'),
                  _MenuTile(
                    icon: Icons.person_outline,
                    label: 'Il tuo profilo',
                    onTap: () => _openProfile(context),
                  ),
                  _MenuTile(
                    icon: Icons.notifications_none,
                    label: 'Notifiche',
                    onTap: () => _openPage(context, const AlertsPage()),
                  ),
                  _MenuTile(
                    icon: Icons.favorite_border,
                    label: 'Reazioni ricevute',
                    onTap: () =>
                        _openPage(context, const AccountReactionsPage()),
                  ),
                  _MenuTile(
                    icon: Icons.bookmark_border,
                    label: 'Segnalibri',
                    onTap: () =>
                        _openPage(context, const AccountBookmarksPage()),
                  ),
                  _MenuTile(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Wallet',
                    onTap: () => _openPage(context, const AccountWalletPage()),
                  ),
                  const _SectionHeader('Impostazioni'),
                  _MenuTile(
                    icon: Icons.badge_outlined,
                    label: 'Dettagli account',
                    onTap: () =>
                        _openPage(context, const AccountDetailsPage()),
                  ),
                  _MenuTile(
                    icon: Icons.lock_outline,
                    label: 'Password e sicurezza',
                    onTap: () =>
                        _openPage(context, const AccountSecurityPage()),
                  ),
                  _MenuTile(
                    icon: Icons.privacy_tip_outlined,
                    label: 'Privacy',
                    onTap: () =>
                        _openPage(context, const AccountPrivacyPage()),
                  ),
                  _MenuTile(
                    icon: Icons.tune,
                    label: 'Preferenze',
                    onTap: () =>
                        _openPage(context, const AccountPreferencesPage()),
                  ),
                  _MenuTile(
                    icon: Icons.draw_outlined,
                    label: 'Firma',
                    onTap: () =>
                        _openPage(context, const AccountSignaturePage()),
                  ),
                  _MenuTile(
                    icon: Icons.workspace_premium_outlined,
                    label: 'Upgrade account',
                    onTap: () =>
                        _openPage(context, const AccountUpgradesPage()),
                  ),
                  _MenuTile(
                    icon: Icons.link,
                    label: 'Account connessi',
                    onTap: () =>
                        _openPage(context, const AccountConnectedPage()),
                  ),
                  _MenuTile(
                    icon: Icons.apps_outlined,
                    label: 'Applicazioni',
                    onTap: () =>
                        _openPage(context, const AccountApplicationsPage()),
                  ),
                  _MenuTile(
                    icon: Icons.recommend_outlined,
                    label: 'Suggerimenti',
                    onTap: () =>
                        _openPage(context, const SuggestionsPage()),
                  ),
                  _MenuTile(
                    icon: Icons.person_add_alt_outlined,
                    label: 'Utenti che segui',
                    onTap: () =>
                        _openPage(context, const AccountFollowingPage()),
                  ),
                  _MenuTile(
                    icon: Icons.person_off_outlined,
                    label: 'Utenti che ignori',
                    onTap: () =>
                        _openPage(context, const AccountIgnoredPage()),
                  ),
                  const Divider(height: 24),
                  _MenuTile(
                    icon: Icons.logout,
                    label: 'Esci',
                    danger: true,
                    onTap: () => _logout(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppTheme.badgeRed : AppTheme.textPrimary;
    return ListTile(
      dense: true,
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
      trailing: danger
          ? null
          : const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppTheme.textSecondary,
            ),
      onTap: onTap,
    );
  }
}

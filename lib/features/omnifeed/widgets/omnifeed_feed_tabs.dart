import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kairete/core/icons/fa_icon_map.dart';
import 'package:kairete/core/theme/app_theme.dart';

enum OmnifeedTabLayout { hub, tenant }

class OmnifeedFeedTabs extends StatelessWidget {
  const OmnifeedFeedTabs({
    super.key,
    this.selectedIndex = 0,
    this.onSelected,
    this.hiddenTabs = const {},
    this.layout = OmnifeedTabLayout.hub,
  });

  final int selectedIndex;
  final ValueChanged<int>? onSelected;
  final Set<int> hiddenTabs;
  final OmnifeedTabLayout layout;

  static const _hubTabs = [
    _TabSpec(icon: Icons.home_outlined, label: 'News feed'),
    _TabSpec(faIconKey: 'newspaper', label: 'News'),
    _TabSpec(icon: Icons.menu_book_outlined, label: 'Blogs'),
    _TabSpec(icon: Icons.forum_outlined, label: 'Forum'),
    _TabSpec(icon: Icons.groups_outlined, label: 'Gruppi'),
    _TabSpec(icon: Icons.perm_media_outlined, label: 'Media'),
  ];

  static const _tenantTabs = [
    _TabSpec(icon: Icons.home_outlined, label: 'News feed'),
    _TabSpec(faIconKey: 'newspaper', label: 'News'),
    _TabSpec(icon: Icons.menu_book_outlined, label: 'Blog'),
    _TabSpec(icon: Icons.forum_outlined, label: 'Forum'),
    _TabSpec(icon: Icons.perm_media_outlined, label: 'Media'),
  ];

  List<_TabSpec> get _tabs =>
      layout == OmnifeedTabLayout.tenant ? _tenantTabs : _hubTabs;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppTheme.cardBorder, width: 1),
        ),
      ),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          if (hiddenTabs.contains(i)) {
            return const SizedBox.shrink();
          }
          final tab = _tabs[i];
          final active = i == selectedIndex;
          return Expanded(
            child: InkWell(
              onTap: () => onSelected?.call(i),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 4),
                  if (tab.faIconKey != null)
                    FaIcon(
                      FaIconMap.iconFor(tab.faIconKey!),
                      color: AppTheme.brandNavbar,
                      size: 18,
                    )
                  else
                    Icon(
                      tab.icon,
                      color: AppTheme.brandNavbar,
                      size: 20,
                    ),
                  const SizedBox(height: 2),
                  Text(
                    tab.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                      color: AppTheme.brandNavbar,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 2,
                    color: active ? AppTheme.brandNavbar : Colors.transparent,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _TabSpec {
  const _TabSpec({
    this.icon,
    this.faIconKey,
    required this.label,
  });

  final IconData? icon;
  final String? faIconKey;
  final String label;
}

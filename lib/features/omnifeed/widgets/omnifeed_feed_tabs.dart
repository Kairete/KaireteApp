import 'package:flutter/material.dart';
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
    _TabSpec(Icons.home_outlined, 'News feed', 0),
    _TabSpec(Icons.menu_book_outlined, 'Blogs', 0),
    _TabSpec(Icons.groups_outlined, 'Gruppi', 0),
    _TabSpec(Icons.perm_media_outlined, 'Media', 0),
  ];

  static const _tenantTabs = [
    _TabSpec(Icons.home_outlined, 'News feed', 0),
    _TabSpec(Icons.menu_book_outlined, 'Blog', 0),
    _TabSpec(Icons.forum_outlined, 'Forum', 0),
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
                  const SizedBox(height: 6),
                  Icon(
                    tab.icon,
                    color: AppTheme.brandPrimary,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tab.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                      color: AppTheme.brandPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 3,
                    color: active ? AppTheme.brandPrimary : Colors.transparent,
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
  const _TabSpec(this.icon, this.label, this.badge);
  final IconData icon;
  final String label;
  final int badge;
}

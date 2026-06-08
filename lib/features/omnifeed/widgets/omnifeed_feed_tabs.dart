import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';

class OmnifeedFeedTabs extends StatelessWidget {
  const OmnifeedFeedTabs({
    super.key,
    this.selectedIndex = 0,
    this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int>? onSelected;

  static const _tabs = [
    _TabSpec(Icons.home_outlined, 'News feed', 0),
    _TabSpec(Icons.menu_book_outlined, 'Blogs', 0),
    _TabSpec(Icons.groups_outlined, 'Gruppi', 0),
  ];

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
          final tab = _tabs[i];
          final active = i == selectedIndex;
          return Expanded(
            child: InkWell(
              onTap: () => onSelected?.call(i),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 6),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        tab.icon,
                        color: AppTheme.primary,
                        size: 22,
                      ),
                      if (tab.badge > 0)
                        Positioned(
                          right: -10,
                          top: -6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.badgeRed,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tab.badge > 999
                                  ? '${(tab.badge / 1000).toStringAsFixed(1)}K'
                                  : '${tab.badge}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
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
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 3,
                    color: active ? AppTheme.primary : Colors.transparent,
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

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kairete/core/icons/fa_icon_map.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_tab.dart';

/// Striscia tab newsfeed allineata all'ACP OmniFeed (stesso ordine/icone del web).
///
/// Se [tabs] è vuoto dopo il caricamento server, non mostra nulla (come il web).
/// Il fallback legacy compare solo se [allowLegacyFallback] è true (API tabs assente).
class OmnifeedContentFilters extends StatelessWidget {
  const OmnifeedContentFilters({
    super.key,
    required this.tabs,
    required this.selectedModeIndex,
    required this.onModeSelected,
    this.sortMode = 'post_date',
    this.onSortChanged,
    this.showSortToggle = false,
    this.allowLegacyFallback = false,
    this.tabsReady = true,
  });

  final List<OmnifeedTab> tabs;
  final int selectedModeIndex;
  final ValueChanged<int> onModeSelected;
  final String sortMode;
  final ValueChanged<String>? onSortChanged;
  /// Solo fallback legacy (senza tab ACP): mostra menu sort.
  final bool showSortToggle;
  /// True solo se l'API tabs non è disponibile: mostra i 4 mode storici.
  final bool allowLegacyFallback;
  /// False mentre i tab non sono ancora stati richiesti al server.
  final bool tabsReady;

  /// Fallback se l'API tabs non è ancora disponibile.
  static const legacyModes = ['network', 'interests', 'following', 'all'];

  @override
  Widget build(BuildContext context) {
    if (!tabsReady) {
      return const SizedBox.shrink();
    }

    final useLegacy = tabs.isEmpty && allowLegacyFallback;
    if (tabs.isEmpty && !useLegacy) {
      // ACP senza tab attivi: niente striscia (allineato al web).
      return const SizedBox.shrink();
    }

    final count = useLegacy ? legacyModes.length : tabs.length;
    final activeSortLabel = !useLegacy && tabs.isNotEmpty
        ? tabs[selectedModeIndex.clamp(0, tabs.length - 1)].sortLabel
        : null;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppTheme.cardBorder, width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var i = 0; i < count; i++) ...[
                      if (i > 0) const SizedBox(width: 4),
                      _FilterSquare(
                        faIcon: useLegacy
                            ? null
                            : FaIconMap.iconFor(tabs[i].icon),
                        materialIcon: useLegacy ? _legacyIcon(i) : null,
                        tooltip:
                            useLegacy ? legacyModes[i] : tabs[i].tooltip,
                        isActive: selectedModeIndex == i,
                        onTap: () => onModeSelected(i),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (activeSortLabel != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  activeSortLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            if (showSortToggle && onSortChanged != null)
              _SortToggle(
                sortMode: sortMode,
                onChanged: onSortChanged!,
              ),
          ],
        ),
      ),
    );
  }

  static IconData _legacyIcon(int index) {
    switch (index) {
      case 0:
        return Icons.add;
      case 1:
        return Icons.newspaper_outlined;
      case 2:
        return Icons.people_outline;
      default:
        return Icons.home_outlined;
    }
  }
}

class _FilterSquare extends StatelessWidget {
  const _FilterSquare({
    required this.isActive,
    required this.onTap,
    this.faIcon,
    this.materialIcon,
    this.tooltip,
  });

  final FaIconData? faIcon;
  final IconData? materialIcon;
  final bool isActive;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppTheme.primary : AppTheme.textSecondary;
    final child = Material(
      color: isActive
          ? AppTheme.primary.withValues(alpha: 0.12)
          : Colors.white,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isActive ? AppTheme.primary : AppTheme.cardBorder,
              width: isActive ? 2 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: faIcon != null
              ? FaIcon(faIcon, size: 16, color: color)
              : Icon(materialIcon ?? Icons.circle_outlined, size: 18, color: color),
        ),
      ),
    );
    if (tooltip == null || tooltip!.isEmpty) return child;
    return Tooltip(message: tooltip!, child: child);
  }
}

class _SortToggle extends StatelessWidget {
  const _SortToggle({
    required this.sortMode,
    required this.onChanged,
  });

  final String sortMode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Ordina feed',
      icon: const Icon(Icons.sort, color: AppTheme.primary, size: 22),
      onSelected: onChanged,
      itemBuilder: (context) => [
        CheckedPopupMenuItem<String>(
          value: 'post_date',
          checked: sortMode == 'post_date',
          child: const Text('Recentezza del contenuto'),
        ),
        CheckedPopupMenuItem<String>(
          value: 'last_comment',
          checked: sortMode == 'last_comment' || sortMode == 'last_activity',
          child: const Text('Ultimo commento'),
        ),
        CheckedPopupMenuItem<String>(
          value: 'last_like',
          checked: sortMode == 'last_like',
          child: const Text('Ultimo like'),
        ),
        CheckedPopupMenuItem<String>(
          value: 'author_reaction_score',
          checked: sortMode == 'author_reaction_score',
          child: const Text('Reaction score autore'),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';

/// Filtri contenuto newsfeed (4 quadrati) + ordinamento a destra.
class OmnifeedContentFilters extends StatelessWidget {
  const OmnifeedContentFilters({
    super.key,
    required this.selectedModeIndex,
    required this.sortByLastComment,
    required this.onModeSelected,
    required this.onSortChanged,
  });

  final int selectedModeIndex;
  final bool sortByLastComment;
  final ValueChanged<int> onModeSelected;
  final ValueChanged<bool> onSortChanged;

  static const modes = ['network', 'interests', 'following', 'all'];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppTheme.cardBorder, width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Row(
          children: [
            _FilterSquare(
              icon: Icons.add,
              isActive: selectedModeIndex == 0,
              onTap: () => onModeSelected(0),
            ),
            const SizedBox(width: 8),
            _FilterSquare(
              icon: Icons.newspaper_outlined,
              isActive: selectedModeIndex == 1,
              onTap: () => onModeSelected(1),
            ),
            const SizedBox(width: 8),
            _FilterSquare(
              icon: Icons.people_outline,
              isActive: selectedModeIndex == 2,
              onTap: () => onModeSelected(2),
            ),
            const SizedBox(width: 8),
            _FilterSquare(
              icon: Icons.home_outlined,
              isActive: selectedModeIndex == 3,
              onTap: () => onModeSelected(3),
            ),
            const Spacer(),
            _SortToggle(
              sortByLastComment: sortByLastComment,
              onChanged: onSortChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSquare extends StatelessWidget {
  const _FilterSquare({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? AppTheme.primary.withOpacity(0.12) : Colors.white,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isActive ? AppTheme.primary : AppTheme.cardBorder,
              width: isActive ? 2 : 1,
            ),
          ),
          child: Icon(
            icon,
            size: 22,
            color: isActive ? AppTheme.primary : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _SortToggle extends StatelessWidget {
  const _SortToggle({
    required this.sortByLastComment,
    required this.onChanged,
  });

  final bool sortByLastComment;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<bool>(
      tooltip: 'Ordina feed',
      icon: const Icon(Icons.sort, color: AppTheme.primary, size: 26),
      onSelected: onChanged,
      itemBuilder: (context) => [
        CheckedPopupMenuItem<bool>(
          value: false,
          checked: !sortByLastComment,
          child: const Text('Ultimo inserimento autore'),
        ),
        CheckedPopupMenuItem<bool>(
          value: true,
          checked: sortByLastComment,
          child: const Text('Ultimo commento'),
        ),
      ],
    );
  }
}

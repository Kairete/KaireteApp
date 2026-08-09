import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/suggestions/models/suggestion_models.dart';
import 'package:kairete/features/suggestions/widgets/suggestion_facebook_card.dart';

/// Riga orizzontale di suggerimenti (stile People You May Know).
class SuggestionsHorizontalRail extends StatelessWidget {
  const SuggestionsHorizontalRail({
    super.key,
    required this.items,
    required this.onAction,
    this.onDismiss,
    this.title = 'Suggerimenti',
    this.showTitle = true,
    this.busyIds = const {},
  });

  final List<SuggestionItem> items;
  final Future<void> Function(SuggestionItem item) onAction;
  final Future<void> Function(SuggestionItem item)? onDismiss;
  final String title;
  final bool showTitle;
  final Set<String> busyIds;

  String _key(SuggestionItem item) =>
      '${item.contentType}:${item.contentId}';

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showTitle)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              final key = _key(item);
              return SuggestionFacebookCard(
                item: item,
                busy: busyIds.contains(key),
                onAction: () => onAction(item),
                onDismiss:
                    onDismiss == null ? null : () => onDismiss!(item),
              );
            },
          ),
        ),
      ],
    );
  }
}

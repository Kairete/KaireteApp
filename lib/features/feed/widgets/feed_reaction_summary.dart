import 'package:flutter/material.dart';

/// Estrae solo nomi realmente forniti dall'API. Non inventa utenti.
List<String> parseReactionNames(Map<String, dynamic> json) {
  dynamic raw = json['reaction_users'] ??
      json['reacted_users'] ??
      json['reaction_usernames'] ??
      json['reactionUsers'];
  if (raw is Map) raw = raw.values.toList();
  if (raw is! List) return const [];
  final names = <String>[];
  for (final user in raw) {
    final value = user is Map
        ? (user['username'] ?? user['display_name'] ?? user['name'])
        : user;
    final name = value?.toString().trim() ?? '';
    if (name.isNotEmpty && !names.contains(name)) names.add(name);
    if (names.length == 2) break;
  }
  return names;
}

/// Riepilogo reazioni in stile XenForo, immediatamente sopra il footer.
/// Il numero residuo sottrae i due utenti nominati dal totale.
class FeedReactionSummary extends StatelessWidget {
  const FeedReactionSummary({
    super.key,
    required this.total,
    this.names = const [],
    this.onTap,
  });

  final int total;
  final List<String> names;
  final VoidCallback? onTap;

  void _showKnownReactions(
    BuildContext context,
    List<String> shown,
    int remaining,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reazioni ($total)',
                  style: Theme.of(sheetContext).textTheme.titleMedium),
              const SizedBox(height: 12),
              for (final name in shown)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(children: [
                    const Icon(Icons.person_outline, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text(name)),
                  ]),
                ),
              if (remaining > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    shown.isEmpty
                        ? '$remaining ${remaining == 1 ? 'reazione' : 'reazioni'}'
                        : 'Altre $remaining ${remaining == 1 ? 'reazione' : 'reazioni'}',
                    style: Theme.of(sheetContext).textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (total <= 0) return const SizedBox.shrink();
    final shown = names.where((name) => name.trim().isNotEmpty)
        .take(total < 2 ? total : 2).toList();
    final remaining = total - shown.length;
    final parts = <String>[...shown];
    if (remaining > 0) {
      parts.add(shown.isEmpty
          ? '$remaining ${remaining == 1 ? 'persona ha reagito' : 'persone hanno reagito'}'
          : '${shown.isNotEmpty ? 'altre ' : ''}$remaining ${remaining == 1 ? 'persona' : 'persone'}');
    }
    final label = parts.length <= 1
        ? parts.join()
        : '${parts.take(parts.length - 1).join(', ')} e ${parts.last}';
    return Material(
      color: const Color(0xFFF5F5F5),
      child: InkWell(
        onTap: onTap ?? () => _showKnownReactions(context, shown, remaining),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            children: [
              const Icon(Icons.thumb_up, size: 16, color: Color(0xFF2878C5)),
              const SizedBox(width: 3),
              const Text('😍', style: TextStyle(fontSize: 15)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF2878C5))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

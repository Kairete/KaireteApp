import 'package:flutter/material.dart';
import 'package:kairete/core/services/reaction_catalog.dart';
import 'package:kairete/core/widgets/reaction_face.dart';

/// Small summary above the footer of a social-group post.
/// Uses only reaction IDs actually reported by the API (plus the visitor's
/// confirmed reaction), never invents a breakdown from the aggregate score.
class GroupReactionBar extends StatelessWidget {
  const GroupReactionBar({
    super.key,
    required this.total,
    this.reactionIds = const [],
    this.visitorReactionId,
  });

  final int total;
  final List<int> reactionIds;
  final int? visitorReactionId;

  @override
  Widget build(BuildContext context) {
    if (total <= 0) return const SizedBox.shrink();

    final ids = <int>{...reactionIds};
    if ((visitorReactionId ?? 0) > 0) ids.add(visitorReactionId!);
    final sorted = ids.toList()..sort();
    final shown = sorted.take(5).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 7, 12, 7),
      child: Row(
        children: [
          if (shown.isEmpty)
            const Icon(Icons.emoji_emotions_outlined,
                size: 19, color: Color(0xFF667085))
          else
            for (final id in shown) ...[
              if (id != shown.first) const SizedBox(width: 3),
              Builder(builder: (_) {
                final icon = ReactionCatalog.instance.iconFor(id);
                return icon != null
                    ? ReactionFace(icon: icon, size: 20)
                    : const Icon(Icons.emoji_emotions_outlined, size: 20);
              }),
            ],
          const SizedBox(width: 7),
          Text(
            '$total',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF667085),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

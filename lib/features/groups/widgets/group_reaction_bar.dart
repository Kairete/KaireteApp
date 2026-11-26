import 'package:flutter/material.dart';
import 'package:kairete/core/services/reaction_catalog.dart';
import 'package:kairete/core/widgets/reaction_face.dart';

/// XenForo-style reaction summary: actual reaction faces on the left and
/// overall score alongside, in a compact row immediately above the footer.
/// No invented breakdown when the API only supplies an aggregate score.
class GroupReactionBar extends StatefulWidget {
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
  State<GroupReactionBar> createState() => _GroupReactionBarState();
}

class _GroupReactionBarState extends State<GroupReactionBar> {
  @override
  void initState() {
    super.initState();
    ReactionCatalog.instance.ensureLoaded().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.total <= 0) return const SizedBox.shrink();
    final ids = <int>{...widget.reactionIds};
    if ((widget.visitorReactionId ?? 0) > 0) {
      ids.add(widget.visitorReactionId!);
    }
    final displayed = ids.take(5).toList();
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 7, 12, 7),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          for (final id in displayed) ...[
            if (id != displayed.first) const SizedBox(width: 3),
            Builder(builder: (_) {
              final icon = ReactionCatalog.instance.iconFor(id);
              return icon == null
                  ? const Icon(Icons.emoji_emotions_outlined,
                      size: 19, color: Color(0xFF667085))
                  : ReactionFace(icon: icon, size: 19);
            }),
          ],
          if (displayed.isEmpty)
            const Icon(Icons.thumb_up_alt_outlined,
                size: 17, color: Color(0xFF667085)),
          const SizedBox(width: 6),
          Text(
            '${widget.total}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF667085),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:kairete/core/services/reaction_catalog.dart';
import 'package:kairete/core/widgets/reaction_face.dart';

/// XenForo reaction summary: small faces followed by linked-looking user
/// names and the remaining count. Names are only shown when supplied by API.
class GroupReactionBar extends StatefulWidget {
  const GroupReactionBar({
    super.key,
    required this.total,
    this.reactionIds = const [],
    this.reactionUsernames = const [],
    this.visitorReactionId,
  });
  final int total;
  final List<int> reactionIds;
  final List<String> reactionUsernames;
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
    if (widget.total <= 0 && widget.reactionIds.isEmpty) {
      return const SizedBox.shrink();
    }
    final ids = <int>{
      ...widget.reactionIds.where((id) => id > 0),
      if ((widget.visitorReactionId ?? 0) > 0) widget.visitorReactionId!,
    }.take(4).toList();

    // XenForo-style summary: two real names, then the remaining people.
    final names = widget.reactionUsernames.take(2).toList();
    final remaining = (widget.total - names.length).clamp(0, 1 << 30);
    String label;
    if (names.length == 2) {
      label = remaining > 0
          ? '${names[0]}, ${names[1]} e $remaining ${remaining == 1 ? 'persona' : 'persone'} hanno reagito'
          : '${names[0]} e ${names[1]} hanno reagito';
    } else if (names.length == 1) {
      label = remaining > 0
          ? '${names[0]} e $remaining ${remaining == 1 ? 'persona' : 'persone'} hanno reagito'
          : '${names[0]} ha reagito';
    } else {
      label = '${widget.total} ${widget.total == 1 ? 'persona ha' : 'persone hanno'} reagito';
    }

    return Container(
      width: double.infinity,
      color: const Color(0xFFF5F5F5),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (ids.isEmpty)
            const Icon(Icons.thumb_up, size: 17, color: Color(0xFFBE8F22))
          else
            ...ids.map((id) {
              final reaction = ReactionCatalog.instance.iconFor(id);
              return Padding(
                padding: const EdgeInsets.only(right: 2),
                child: reaction == null
                    ? const Icon(Icons.thumb_up, size: 17,
                        color: Color(0xFFBE8F22))
                    : ReactionFace(icon: reaction, size: 19),
              );
            }),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                height: 1.2,
                color: Color(0xFF176493),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

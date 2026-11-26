import 'package:flutter/material.dart';
import 'package:kairete/core/services/reaction_catalog.dart';
import 'package:kairete/core/widgets/reaction_face.dart';

/// Flutter counterpart of XenForo's reactionsBar / reactionSummary.
/// The actual faces come from XF's installed reaction catalog.
/// Never invent user names or specific counts absent from the API response.
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
    if (widget.total <= 0 && widget.reactionIds.isEmpty) {
      return const SizedBox.shrink();
    }
    final ids = <int>{
      ...widget.reactionIds.where((id) => id > 0),
      if ((widget.visitorReactionId ?? 0) > 0) widget.visitorReactionId!,
    };
    final shown = ids.take(5).toList();
    final catalog = ReactionCatalog.instance;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 7, 12, 7),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        border: Border(
          top: BorderSide(color: Color(0xFFE5E5E5), width: 0.7),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (shown.isNotEmpty)
            SizedBox(
              width: 20.0 + (shown.length - 1) * 15.0,
              height: 22,
              child: Stack(
                children: [
                  for (var i = 0; i < shown.length; i++)
                    Positioned(
                      left: i * 15.0,
                      child: Container(
                        width: 22,
                        height: 22,
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE3E3E3),
                            width: 0.6,
                          ),
                        ),
                        child: catalog.iconFor(shown[i]) case final icon?
                            ? ReactionFace(icon: icon, size: 18)
                            : const Icon(
                                Icons.thumb_up,
                                color: Color(0xFF667085),
                                size: 15,
                              ),
                      ),
                    ),
                ],
              ),
            )
          else
            const Icon(
              Icons.thumb_up,
              color: Color(0xFF667085),
              size: 17,
            ),
          const SizedBox(width: 7),
          Text(
            '${widget.total}',
            style: const TextStyle(
              color: Color(0xFF555555),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

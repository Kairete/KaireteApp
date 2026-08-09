import 'package:flutter/material.dart';
import 'package:kairete/core/services/reaction_catalog.dart';
import 'package:kairete/core/widgets/reaction_face.dart';

/// Icona reazione attiva del visitatore, oppure thumb outline di default.
class FeedReactionIcon extends StatelessWidget {
  const FeedReactionIcon({
    super.key,
    this.visitorReactionId,
    this.size = 16,
    this.fallbackColor = Colors.white,
    this.outlined = false,
  });

  final int? visitorReactionId;
  final double size;
  final Color fallbackColor;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final reactionId = visitorReactionId ?? 0;
    if (reactionId > 0) {
      final icon = ReactionCatalog.instance.iconFor(reactionId);
      if (icon != null) {
        return ReactionFace(
          icon: icon,
          size: size,
          fallback: Icon(
            outlined ? Icons.thumb_up_outlined : Icons.thumb_up,
            size: size,
            color: fallbackColor,
            weight: outlined ? 300 : null,
            opticalSize: outlined ? 20 : null,
          ),
        );
      }
    }
    return Icon(
      Icons.thumb_up_outlined,
      size: size,
      color: fallbackColor,
      weight: outlined ? 300 : null,
      opticalSize: outlined ? 20 : null,
    );
  }
}

/// Calcola la reazione visitatore dopo toggle XenForo.
int applyReactionAction({
  required int? currentReactionId,
  required int pickedReactionId,
  required String action,
}) {
  if (action == 'delete') return 0;
  return pickedReactionId;
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kairete/core/services/reaction_catalog.dart';

/// Icona reazione attiva del visitatore, oppure thumb di default.
class FeedReactionIcon extends StatelessWidget {
  const FeedReactionIcon({
    super.key,
    this.visitorReactionId,
    this.size = 16,
    this.fallbackColor = Colors.white,
  });

  final int? visitorReactionId;
  final double size;
  final Color fallbackColor;

  @override
  Widget build(BuildContext context) {
    final reactionId = visitorReactionId ?? 0;
    if (reactionId > 0) {
      final icon = ReactionCatalog.instance.iconFor(reactionId);
      if (icon != null && icon.imageUrl.isNotEmpty) {
        return CachedNetworkImage(
          imageUrl: icon.imageUrl,
          width: size,
          height: size,
          errorWidget: (_, __, ___) => Icon(
            Icons.thumb_up,
            size: size,
            color: fallbackColor,
          ),
        );
      }
    }
    return Icon(
      reactionId > 0 ? Icons.thumb_up : Icons.thumb_up_outlined,
      size: size,
      color: fallbackColor,
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

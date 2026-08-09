import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kairete/core/models/reaction_icon.dart';

/// Faccia reazione allineata al web (Twemoji / emoji nativa).
class ReactionFace extends StatelessWidget {
  const ReactionFace({
    super.key,
    required this.icon,
    this.size = 32,
    this.fallback,
  });

  final ReactionIcon icon;
  final double size;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    if (icon.hasNetworkImage) {
      return CachedNetworkImage(
        imageUrl: icon.imageUrl,
        width: size,
        height: size,
        fit: BoxFit.contain,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        errorWidget: (_, __, ___) => _emojiOrFallback(),
      );
    }
    return _emojiOrFallback();
  }

  Widget _emojiOrFallback() {
    if (icon.emoji.isNotEmpty) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text(
            icon.emoji,
            style: TextStyle(fontSize: size * 0.85, height: 1),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return fallback ??
        Icon(Icons.emoji_emotions_outlined, size: size);
  }
}

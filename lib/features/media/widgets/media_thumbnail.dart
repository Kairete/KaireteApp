import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kairete/core/utils/media_playback.dart';
import 'package:kairete/features/media/models/media_item.dart';

class MediaThumbnail extends StatelessWidget {
  const MediaThumbnail({
    super.key,
    required this.item,
    this.onTap,
    this.borderRadius = 4,
  });

  final MediaItem item;
  final VoidCallback? onTap;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final hero = item.heroImageUrl;
    if (!item.isPlayable && (hero == null || hero.isEmpty)) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (hero != null && hero.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: CachedNetworkImage(
                imageUrl: hero,
                httpHeaders:
                    MediaPlayback.needsApiAuth(hero) ? MediaPlayback.apiHeaders() : null,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _PlayablePlaceholder(
                  item: item,
                  borderRadius: borderRadius,
                ),
              ),
            )
          else
            _PlayablePlaceholder(item: item, borderRadius: borderRadius),
          if (item.isPlayable) _PlayOverlay(onTap: onTap, borderRadius: borderRadius),
        ],
      ),
    );
  }
}

class _PlayablePlaceholder extends StatelessWidget {
  const _PlayablePlaceholder({
    required this.item,
    required this.borderRadius,
  });

  final MediaItem item;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: double.infinity,
        height: 200,
        color: const Color(0xFF1A1A1A),
        child: Icon(
          item.isAudio ? Icons.audiotrack : Icons.videocam_outlined,
          color: Colors.white54,
          size: 48,
        ),
      ),
    );
  }
}

class _PlayOverlay extends StatelessWidget {
  const _PlayOverlay({this.onTap, required this.borderRadius});

  final VoidCallback? onTap;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.all(12),
          child: const Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: 56,
          ),
        ),
      ),
    );
  }
}

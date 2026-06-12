import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kairete/core/utils/media_duration_format.dart';
import 'package:kairete/core/utils/media_playback.dart';
import 'package:kairete/features/media/models/media_item.dart';
import 'package:kairete/features/media/services/media_duration_cache.dart';

class MediaThumbnail extends StatefulWidget {
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
  State<MediaThumbnail> createState() => _MediaThumbnailState();
}

class _MediaThumbnailState extends State<MediaThumbnail> {
  int? _durationSeconds;

  @override
  void initState() {
    super.initState();
    _loadDuration();
  }

  @override
  void didUpdateWidget(covariant MediaThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.mediaId != widget.item.mediaId) {
      _loadDuration();
    }
  }

  Future<void> _loadDuration() async {
    if (!widget.item.isVideo) return;
    final seconds = await MediaDurationCache.instance.resolve(widget.item);
    if (!mounted || seconds == null || seconds <= 0) return;
    setState(() => _durationSeconds = seconds);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final hero = item.heroImageUrl;
    if (!item.isPlayable && (hero == null || hero.isEmpty)) {
      return const SizedBox.shrink();
    }

    final durationLabel = _durationLabel();

    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (hero != null && hero.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: CachedNetworkImage(
                imageUrl: hero,
                httpHeaders: MediaPlayback.needsApiAuth(hero)
                    ? MediaPlayback.apiHeaders()
                    : null,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _PlayablePlaceholder(
                  item: item,
                  borderRadius: widget.borderRadius,
                ),
              ),
            )
          else
            _PlayablePlaceholder(
              item: item,
              borderRadius: widget.borderRadius,
            ),
          if (item.isPlayable)
            _PlayOverlay(
              onTap: widget.onTap,
              borderRadius: widget.borderRadius,
            ),
          if (durationLabel != null)
            Positioned(
              right: 8,
              bottom: 8,
              child: _DurationBadge(label: durationLabel),
            ),
        ],
      ),
    );
  }

  String? _durationLabel() {
    final stored = widget.item.durationSeconds;
    if (stored != null && stored > 0) {
      return MediaDurationFormat.formatSeconds(stored);
    }
    if (_durationSeconds != null && _durationSeconds! > 0) {
      return MediaDurationFormat.formatSeconds(_durationSeconds);
    }
    return null;
  }
}

class _DurationBadge extends StatelessWidget {
  const _DurationBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.72),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
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

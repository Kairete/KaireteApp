import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/media/models/media_item.dart';
import 'package:kairete/features/media/widgets/media_thumbnail.dart';
import 'package:kairete/features/media/widgets/media_video_player.dart';

class MediaViewerPage extends StatelessWidget {
  const MediaViewerPage({super.key, required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    final url = item.openMediaUrl;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(item.displayTitle),
      ),
      body: Center(
        child: url == null || url.isEmpty
            ? const Text(
                'Media non disponibile.',
                style: TextStyle(color: Colors.white),
              )
            : item.isPlayable
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: MediaVideoPlayer(item: item),
                  )
                : InteractiveViewer(
                    child: CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      errorWidget: (_, __, ___) => const Icon(
                        Icons.broken_image,
                        color: Colors.white54,
                        size: 64,
                      ),
                    ),
                  ),
      ),
    );
  }
}

class MediaDetailBody extends StatelessWidget {
  const MediaDetailBody({
    super.key,
    required this.item,
    this.onThumbnailTap,
  });

  final MediaItem item;
  final VoidCallback? onThumbnailTap;

  @override
  Widget build(BuildContext context) {
    final description = item.description?.trim() ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.displayTitle,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppTheme.accent,
            ),
          ),
          if (item.isPlayable) ...[
            const SizedBox(height: 10),
            MediaVideoPlayer(item: item),
          ] else if (item.heroImageUrl != null) ...[
            const SizedBox(height: 10),
            MediaThumbnail(item: item, onTap: onThumbnailTap),
          ],
          if (description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

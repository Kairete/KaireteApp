import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/media/models/media_item.dart';

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
            : item.isVideo
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.videocam, color: Colors.white, size: 64),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          url,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Apri il link dal browser per il video.',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ],
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
    final hero = item.heroImageUrl;
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
          if (hero != null) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: onThumbnailTap,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: CachedNetworkImage(
                      imageUrl: hero,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                  if (item.isVideo)
                    const Icon(
                      Icons.play_circle_fill,
                      color: Colors.white,
                      size: 56,
                    ),
                ],
              ),
            ),
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

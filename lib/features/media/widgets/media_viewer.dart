import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:video_player/video_player.dart';
import 'package:kairete/features/media/models/media_item.dart';

class MediaViewerPage extends StatefulWidget {
  const MediaViewerPage({super.key, required this.item});

  final MediaItem item;

  @override
  State<MediaViewerPage> createState() => _MediaViewerPageState();
}

class _MediaViewerPageState extends State<MediaViewerPage> {
  VideoPlayerController? _videoController;
  bool _videoReady = false;
  bool _videoError = false;

  @override
  void initState() {
    super.initState();
    if (widget.item.isVideo) {
      _initVideo();
    }
  }

  Future<void> _initVideo() async {
    final url = widget.item.openMediaUrl;
    if (url == null || url.isEmpty) {
      if (mounted) setState(() => _videoError = true);
      return;
    }
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    try {
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _videoController = controller;
        _videoReady = true;
      });
      await controller.play();
    } catch (_) {
      await controller.dispose();
      if (mounted) setState(() => _videoError = true);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
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
                ? _buildVideoBody()
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

  Widget _buildVideoBody() {
    if (_videoError) {
      return const Text(
        'Impossibile riprodurre il video.',
        style: TextStyle(color: Colors.white70),
        textAlign: TextAlign.center,
      );
    }
    if (!_videoReady || _videoController == null) {
      return const CircularProgressIndicator(color: Colors.white);
    }

    final controller = _videoController!;
    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(controller),
          if (!controller.value.isPlaying)
            IconButton(
              iconSize: 64,
              color: Colors.white,
              onPressed: () => controller.play(),
              icon: const Icon(Icons.play_circle_fill),
            ),
        ],
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
          if (item.heroImageUrl != null) ...[
            const SizedBox(height: 10),
            _DetailThumbnail(item: item, onTap: onThumbnailTap),
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

class _DetailThumbnail extends StatelessWidget {
  const _DetailThumbnail({required this.item, this.onTap});

  final MediaItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hero = item.heroImageUrl!;
    return GestureDetector(
      onTap: onTap,
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
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: const Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 56,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

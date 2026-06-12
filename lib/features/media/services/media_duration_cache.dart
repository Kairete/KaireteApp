import 'package:kairete/core/utils/media_playback.dart';
import 'package:kairete/features/media/models/media_item.dart';
import 'package:video_player/video_player.dart';

/// Durata video letta dai metadati del file (XFMG non la espone in API).
class MediaDurationCache {
  MediaDurationCache._();

  static final instance = MediaDurationCache._();

  final _cache = <int, int>{};
  final _pending = <int, Future<int?>>{};

  int? cachedSeconds(int mediaId) => _cache[mediaId];

  Future<int?> resolve(MediaItem item) async {
    final stored = item.durationSeconds;
    if (stored != null && stored > 0) {
      _cache[item.mediaId] = stored;
      return stored;
    }
    if (!item.isVideo || item.mediaId <= 0) return null;

    final cached = _cache[item.mediaId];
    if (cached != null && cached > 0) return cached;

    final pending = _pending[item.mediaId];
    if (pending != null) return pending;

    final future = _probe(item);
    _pending[item.mediaId] = future;
    try {
      return await future;
    } finally {
      _pending.remove(item.mediaId);
    }
  }

  Future<int?> _probe(MediaItem item) async {
    final url = item.openMediaUrl;
    if (url == null || url.isEmpty) return null;

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(url),
      httpHeaders: MediaPlayback.apiHeaders(),
    );
    try {
      await controller.initialize();
      final seconds = controller.value.duration.inSeconds;
      if (seconds > 0) {
        _cache[item.mediaId] = seconds;
        return seconds;
      }
    } catch (_) {
    } finally {
      await controller.dispose();
    }
    return null;
  }
}

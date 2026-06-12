import 'package:flutter/material.dart';
import 'package:kairete/core/utils/media_duration_format.dart';
import 'package:kairete/core/utils/media_playback.dart';
import 'package:kairete/features/media/models/media_item.dart';
import 'package:video_player/video_player.dart';

const _playbackSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

/// Player inline/fullscreen con durata, seek e velocità (come HTML5 sul web).
class MediaVideoPlayer extends StatefulWidget {
  const MediaVideoPlayer({
    super.key,
    required this.item,
    this.autoPlay = true,
    this.borderRadius = 4,
  });

  final MediaItem item;
  final bool autoPlay;
  final double borderRadius;

  @override
  State<MediaVideoPlayer> createState() => _MediaVideoPlayerState();
}

class _MediaVideoPlayerState extends State<MediaVideoPlayer> {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _error = false;
  double _playbackSpeed = 1.0;
  bool _isScrubbing = false;
  double _scrubFraction = 0;

  @override
  void initState() {
    super.initState();
    if (widget.item.isPlayable) _init();
  }

  Future<void> _init() async {
    final url = widget.item.openMediaUrl;
    if (url == null || url.isEmpty) {
      if (mounted) setState(() => _error = true);
      return;
    }

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(url),
      httpHeaders: MediaPlayback.apiHeaders(),
    );
    controller.addListener(_onTick);

    try {
      await controller.initialize();
      if (!mounted) {
        controller.removeListener(_onTick);
        await controller.dispose();
        return;
      }
      await controller.setPlaybackSpeed(_playbackSpeed);
      setState(() {
        _controller = controller;
        _ready = true;
      });
      if (widget.autoPlay) await controller.play();
    } catch (_) {
      controller.removeListener(_onTick);
      await controller.dispose();
      if (mounted) setState(() => _error = true);
    }
  }

  void _onTick() {
    if (!mounted || _isScrubbing) return;
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.removeListener(_onTick);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _setSpeed(double speed) async {
    final controller = _controller;
    if (controller == null) return;
    await controller.setPlaybackSpeed(speed);
    if (!mounted) return;
    setState(() => _playbackSpeed = speed);
  }

  void _togglePlay() {
    final controller = _controller;
    if (controller == null) return;
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
    setState(() {});
  }

  Future<void> _seekToFraction(double fraction) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final duration = controller.value.duration;
    if (duration.inMilliseconds <= 0) return;
    final target = Duration(
      milliseconds:
          (duration.inMilliseconds * fraction.clamp(0.0, 1.0)).round(),
    );
    await controller.seekTo(target);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return _MessageBox(
        borderRadius: widget.borderRadius,
        child: Text(
          widget.item.isAudio
              ? 'Impossibile riprodurre l\'audio.'
              : 'Impossibile riprodurre il video.',
          style: const TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (!_ready || _controller == null) {
      return _MessageBox(
        borderRadius: widget.borderRadius,
        child: const CircularProgressIndicator(color: Colors.white),
      );
    }

    final controller = _controller!;
    final value = controller.value;
    final duration = value.duration;
    final position = value.position;
    final progress = duration.inMilliseconds > 0
        ? (_isScrubbing
            ? _scrubFraction
            : position.inMilliseconds / duration.inMilliseconds)
        : 0.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: ColoredBox(
        color: Colors.black,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: widget.item.isAudio
                  ? 16 / 9
                  : (value.aspectRatio > 0 ? value.aspectRatio : 16 / 9),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (widget.item.isAudio)
                    const Icon(
                      Icons.audiotrack,
                      color: Colors.white38,
                      size: 72,
                    )
                  else
                    VideoPlayer(controller),
                  if (!value.isPlaying)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _togglePlay,
                        child: Container(
                          color: Colors.black26,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.play_circle_fill,
                            color: Colors.white,
                            size: 64,
                          ),
                        ),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: _togglePlay,
                      behavior: HitTestBehavior.opaque,
                      child: const SizedBox.expand(),
                    ),
                ],
              ),
            ),
            _ControlsBar(
              isPlaying: value.isPlaying,
              progress: progress,
              positionLabel: MediaDurationFormat.formatDuration(position),
              durationLabel: MediaDurationFormat.formatDuration(duration),
              speedLabel: _speedLabel(_playbackSpeed),
              onPlayPause: _togglePlay,
              onSpeedSelected: _setSpeed,
              onScrubStart: () => setState(() {
                _isScrubbing = true;
                _scrubFraction = progress;
              }),
              onScrubUpdate: (fraction) =>
                  setState(() => _scrubFraction = fraction),
              onScrubEnd: (fraction) async {
                setState(() => _isScrubbing = false);
                await _seekToFraction(fraction);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _speedLabel(double speed) {
    if (speed == speed.roundToDouble()) {
      return '${speed.toStringAsFixed(0)}x';
    }
    return '${speed}x';
  }
}

class _ControlsBar extends StatelessWidget {
  const _ControlsBar({
    required this.isPlaying,
    required this.progress,
    required this.positionLabel,
    required this.durationLabel,
    required this.speedLabel,
    required this.onPlayPause,
    required this.onSpeedSelected,
    required this.onScrubStart,
    required this.onScrubUpdate,
    required this.onScrubEnd,
  });

  final bool isPlaying;
  final double progress;
  final String positionLabel;
  final String durationLabel;
  final String speedLabel;
  final VoidCallback onPlayPause;
  final ValueChanged<double> onSpeedSelected;
  final VoidCallback onScrubStart;
  final ValueChanged<double> onScrubUpdate;
  final ValueChanged<double> onScrubEnd;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF111111),
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: SliderComponentShape.noOverlay,
            ),
            child: Slider(
              value: progress.clamp(0.0, 1.0),
              onChangeStart: (_) => onScrubStart(),
              onChanged: onScrubUpdate,
              onChangeEnd: onScrubEnd,
              activeColor: Colors.white,
              inactiveColor: Colors.white24,
            ),
          ),
          Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed: onPlayPause,
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
              ),
              Text(
                durationLabel.isEmpty
                    ? positionLabel
                    : '$positionLabel / $durationLabel',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              PopupMenuButton<double>(
                tooltip: 'Velocità',
                onSelected: onSpeedSelected,
                color: const Color(0xFF2A2A2A),
                itemBuilder: (_) => _playbackSpeeds
                    .map(
                      (speed) => PopupMenuItem<double>(
                        value: speed,
                        child: Text(
                          speed == 1.0 ? 'Normale (1x)' : '${speed}x',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white38),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    speedLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MessageBox extends StatelessWidget {
  const _MessageBox({required this.child, required this.borderRadius});

  final Widget child;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: double.infinity,
        height: 200,
        color: const Color(0xFF1A1A1A),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

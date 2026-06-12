class MediaDurationFormat {
  MediaDurationFormat._();

  static String formatSeconds(int? totalSeconds) {
    if (totalSeconds == null || totalSeconds <= 0) return '';
    final total = Duration(seconds: totalSeconds);
    final hours = total.inHours;
    final minutes = total.inMinutes.remainder(60);
    final seconds = total.inSeconds.remainder(60);
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  static String formatDuration(Duration duration) {
    if (duration.inMilliseconds <= 0) return '0:00';
    return formatSeconds(duration.inSeconds);
  }
}

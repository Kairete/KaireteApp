enum MediaUploadKind { image, video, audio, unknown }

MediaUploadKind mediaUploadKindFromFilename(String filename) {
  final dot = filename.lastIndexOf('.');
  if (dot < 0 || dot >= filename.length - 1) return MediaUploadKind.unknown;
  final ext = filename.substring(dot + 1).toLowerCase();
  const video = {'mp4', 'mov', 'm4v', 'webm', 'mkv', '3gp', 'avi'};
  const audio = {'mp3', 'm4a', 'wav', 'aac', 'ogg', 'flac', 'opus'};
  const image = {'jpg', 'jpeg', 'png', 'gif', 'webp', 'heic', 'heif', 'bmp'};
  if (video.contains(ext)) return MediaUploadKind.video;
  if (audio.contains(ext)) return MediaUploadKind.audio;
  if (image.contains(ext)) return MediaUploadKind.image;
  return MediaUploadKind.unknown;
}

/// Rileva il tipo dal nome file e, in fallback, dal path temporaneo.
MediaUploadKind mediaUploadKindFromSources({
  required String filename,
  required String filePath,
}) {
  final fromName = mediaUploadKindFromFilename(filename);
  if (fromName != MediaUploadKind.unknown) return fromName;
  final pathName = filePath.split(RegExp(r'[/\\]')).last;
  return mediaUploadKindFromFilename(pathName);
}

String? mediaUploadMimeType(String filename) {
  return mediaUploadMimeTypeForKind(
    mediaUploadKindFromFilename(filename),
    filename,
  );
}

String? mediaUploadMimeTypeForKind(MediaUploadKind kind, String filename) {
  switch (kind) {
    case MediaUploadKind.video:
      final ext = filename.split('.').last.toLowerCase();
      switch (ext) {
        case 'mov':
          return 'video/quicktime';
        case 'webm':
          return 'video/webm';
        case 'mkv':
          return 'video/x-matroska';
        case '3gp':
          return 'video/3gpp';
        default:
          return 'video/mp4';
      }
    case MediaUploadKind.audio:
      final ext = filename.split('.').last.toLowerCase();
      switch (ext) {
        case 'm4a':
          return 'audio/mp4';
        case 'wav':
          return 'audio/wav';
        case 'ogg':
          return 'audio/ogg';
        case 'flac':
          return 'audio/flac';
        default:
          return 'audio/mpeg';
      }
    case MediaUploadKind.image:
      final ext = filename.split('.').last.toLowerCase();
      if (ext == 'png') return 'image/png';
      if (ext == 'gif') return 'image/gif';
      if (ext == 'webp') return 'image/webp';
      return 'image/jpeg';
    case MediaUploadKind.unknown:
      return null;
  }
}

String mediaUploadTypeField(MediaUploadKind kind) {
  switch (kind) {
    case MediaUploadKind.video:
      return 'video';
    case MediaUploadKind.audio:
      return 'audio';
    case MediaUploadKind.image:
      return 'image';
    case MediaUploadKind.unknown:
      return 'image';
  }
}

String mediaUploadPermissionHint(MediaUploadKind kind) {
  switch (kind) {
    case MediaUploadKind.video:
      return 'Non hai il permesso di caricare video. In ACP → Permessi → Media Gallery abilita «Carica video nell\'album» per il tuo gruppo.';
    case MediaUploadKind.audio:
      return 'Non hai il permesso di caricare audio. In ACP → Permessi → Media Gallery abilita «Carica audio nell\'album» per il tuo gruppo.';
    case MediaUploadKind.image:
      return 'Non hai il permesso di caricare immagini in questo album.';
    case MediaUploadKind.unknown:
      return 'Non hai il permesso di caricare questo file.';
  }
}

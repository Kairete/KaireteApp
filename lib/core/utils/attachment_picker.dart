import 'dart:io';

import 'package:file_picker/file_picker.dart';

class PickedAttachment {
  const PickedAttachment({
    required this.path,
    required this.displayName,
  });

  final String path;
  final String displayName;
}

const _imageExtensions = [
  'jpg',
  'jpeg',
  'png',
  'gif',
  'webp',
  'heic',
  'heif',
  'bmp',
];

const _mediaExtensions = [
  ..._imageExtensions,
  'mp4',
  'mov',
  'm4v',
  'webm',
  'mkv',
  '3gp',
  'mp3',
  'm4a',
  'wav',
  'aac',
  'ogg',
  'flac',
  'opus',
];

/// Seleziona immagini (post blog, forum, …).
Future<List<PickedAttachment>> pickAttachments({bool allowMultiple = true}) {
  return _pickFiles(
    allowMultiple: allowMultiple,
    extensions: _imageExtensions,
  );
}

/// Seleziona foto, video e audio per XFMG.
Future<List<PickedAttachment>> pickMediaAttachments({bool allowMultiple = false}) {
  return _pickFiles(
    allowMultiple: allowMultiple,
    extensions: _mediaExtensions,
    withData: false,
  );
}

Future<List<PickedAttachment>> _pickFiles({
  required bool allowMultiple,
  required List<String> extensions,
  bool withData = true,
}) async {
  final result = await FilePicker.platform.pickFiles(
    allowMultiple: allowMultiple,
    type: FileType.custom,
    allowedExtensions: extensions,
    withData: withData,
  );
  if (result == null || result.files.isEmpty) return const [];

  final picked = <PickedAttachment>[];
  for (final file in result.files) {
    final name = file.name.trim().isNotEmpty ? file.name : 'allegato';
    final path = file.path;
    if (path != null && path.isNotEmpty && File(path).existsSync()) {
      final stablePath = withData
          ? path
          : await _copyToAppTemp(path, name);
      picked.add(PickedAttachment(path: stablePath, displayName: name));
      continue;
    }
    final bytes = file.bytes;
    if (bytes != null && bytes.isNotEmpty) {
      final tempPath = await _writeTempFile(bytes, name);
      picked.add(PickedAttachment(path: tempPath, displayName: name));
    }
  }
  return picked;
}

Future<String> _copyToAppTemp(String sourcePath, String name) async {
  final safeName = name.replaceAll(RegExp(r'[^\w.\-]+'), '_');
  final dest = File(
    '${Directory.systemTemp.path}${Platform.pathSeparator}kairete_upload_${DateTime.now().millisecondsSinceEpoch}_$safeName',
  );
  await File(sourcePath).copy(dest.path);
  return dest.path;
}

Future<String> _writeTempFile(List<int> bytes, String name) async {
  final safeName = name.replaceAll(RegExp(r'[^\w.\-]+'), '_');
  final file = File(
    '${Directory.systemTemp.path}${Platform.pathSeparator}kairete_${DateTime.now().millisecondsSinceEpoch}_$safeName',
  );
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}

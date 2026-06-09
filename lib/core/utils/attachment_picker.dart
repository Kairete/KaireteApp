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

/// Seleziona file allegati; su Android copia in temp quando [PlatformFile.path] è assente.
Future<List<PickedAttachment>> pickAttachments({bool allowMultiple = true}) async {
  final result = await FilePicker.platform.pickFiles(
    allowMultiple: allowMultiple,
    type: FileType.image,
    withData: true,
  );
  if (result == null || result.files.isEmpty) return const [];

  final picked = <PickedAttachment>[];
  for (final file in result.files) {
    final name = file.name.trim().isNotEmpty ? file.name : 'allegato';
    final path = file.path;
    if (path != null && path.isNotEmpty && File(path).existsSync()) {
      picked.add(PickedAttachment(path: path, displayName: name));
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

Future<String> _writeTempFile(List<int> bytes, String name) async {
  final safeName = name.replaceAll(RegExp(r'[^\w.\-]+'), '_');
  final file = File(
    '${Directory.systemTemp.path}${Platform.pathSeparator}kairete_${DateTime.now().millisecondsSinceEpoch}_$safeName',
  );
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}

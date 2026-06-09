import 'package:dio/dio.dart';
import 'package:kairete/config/api_paths.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';

class AttachmentService {
  XenforoApi get _api => AppApi.instance.xenforo;

  Future<AttachmentSession> createProfilePostSession({
    required int profileUserId,
  }) async {
    return _createSession(
      type: 'profile_post',
      context: {'profile_user_id': profileUserId},
      composeContext: 'profile',
    );
  }

  Future<AttachmentSession> createForumPostSession({
    required int nodeId,
  }) async {
    return _createSession(
      type: 'post',
      context: {'node_id': nodeId},
    );
  }

  Future<AttachmentSession> _createSession({
    required String type,
    required Map<String, int> context,
    String? composeContext,
  }) async {
    await AppApi.instance.applySession();

    if (composeContext == 'profile') {
      final json = await _api.get(
        ApiPaths.newsfeedComposeAttachments,
        query: {'context': composeContext},
      );
      _throwIfError(json);
      final key = _readAttachmentKey(json);
      if (key.isEmpty) {
        throw AttachmentException('Impossibile preparare gli allegati.');
      }
      return AttachmentSession(key: key, type: type, context: context);
    }

    final fields = <String, dynamic>{
      'type': type,
      for (final entry in context.entries) 'context[${entry.key}]': entry.value,
    };
    final json = await _api.post('api/attachments/new-key', body: fields);
    _throwIfError(json);
    final key = _readAttachmentKey(json);
    if (key.isEmpty) {
      throw AttachmentException('Impossibile preparare gli allegati.');
    }
    return AttachmentSession(key: key, type: type, context: context);
  }

  String _readAttachmentKey(Map<String, dynamic> json) {
    return json['key']?.toString() ??
        json['hash']?.toString() ??
        json['attachment_key']?.toString() ??
        '';
  }

  Future<void> uploadFile({
    required AttachmentSession session,
    required String filePath,
    String? filename,
  }) async {
    await AppApi.instance.applySession();
    final name = filename ?? filePath.split(RegExp(r'[/\\]')).last;
    final fields = <String, dynamic>{
      'type': session.type,
      'key': session.key,
      for (final entry in session.context.entries)
        'context[${entry.key}]': entry.value,
    };
    final json = await _api.postMultipart(
      ApiPaths.attachments,
      fields: fields,
      files: {
        'upload': MultipartFile.fromFileSync(filePath, filename: name),
      },
    );
    _throwIfError(json);
  }

  void _throwIfError(Map<String, dynamic> json) {
    final err = XenforoApi.firstErrorMessage(json);
    if (err != null) throw AttachmentException(err);
  }
}

class AttachmentSession {
  const AttachmentSession({
    required this.key,
    required this.type,
    required this.context,
  });

  final String key;
  final String type;
  final Map<String, int> context;
}

class AttachmentException implements Exception {
  AttachmentException(this.message);
  final String message;

  @override
  String toString() => message;
}

import 'package:dio/dio.dart';
import 'package:kairete/config/api_paths.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';

class AttachmentService {
  static const _newKeyPath = 'api/attachments/new-key';

  XenforoApi get _api => AppApi.instance.xenforo;

  Future<AttachmentSession> createProfilePostSession({
    required int profileUserId,
  }) {
    return _createSession(
      type: 'profile_post',
      context: {'profile_user_id': profileUserId},
    );
  }

  Future<AttachmentSession> createForumPostSession({
    required int nodeId,
  }) {
    return _createSession(
      type: 'post',
      context: {'node_id': nodeId},
    );
  }

  Future<AttachmentSession> createBlogPostSession({
    required int blogId,
  }) {
    return _createSession(
      type: 'blog_post',
      context: {'blog_id': blogId},
    );
  }

  Future<AttachmentSession> _createSession({
    required String type,
    required Map<String, int> context,
  }) async {
    await AppApi.instance.applySession();

    final fields = <String, dynamic>{
      'type': type,
      for (final entry in context.entries) 'context[${entry.key}]': entry.value,
    };
    final json = await _api.post(
      _newKeyPath,
      body: fields,
      query: fields,
    );
    _throwIfError(json);
    final key = _readToken(json, const ['key', 'attachment_key']);
    if (key == null || key.isEmpty) {
      throw AttachmentException('Impossibile preparare gli allegati.');
    }
    final hash = _readToken(json, const ['hash']) ?? key;
    return AttachmentSession(key: key, hash: hash, type: type, context: context);
  }

  Future<AttachmentSession> uploadProfileFiles({
    required int profileUserId,
    required List<({String path, String filename})> files,
  }) {
    return uploadFiles(
      session: AttachmentSession(
        key: '',
        hash: '',
        type: 'profile_post',
        context: {'profile_user_id': profileUserId},
      ),
      files: files,
    );
  }

  Future<AttachmentSession> uploadForumFiles({
    required int nodeId,
    required List<({String path, String filename})> files,
  }) {
    return uploadFiles(
      session: AttachmentSession(
        key: '',
        hash: '',
        type: 'post',
        context: {'node_id': nodeId},
      ),
      files: files,
    );
  }

  Future<AttachmentSession> uploadBlogFiles({
    required int blogId,
    required List<({String path, String filename})> files,
  }) {
    return uploadFiles(
      session: AttachmentSession(
        key: '',
        hash: '',
        type: 'blog_post',
        context: {'blog_id': blogId},
      ),
      files: files,
    );
  }

  /// Carica uno o più file e restituisce la sessione con la chiave API aggiornata.
  Future<AttachmentSession> uploadFiles({
    required AttachmentSession session,
    required List<({String path, String filename})> files,
  }) async {
    if (files.isEmpty) return session;

    await AppApi.instance.applySession();
    var key = session.key;
    var hash = session.hash;

    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      if (i == 0) {
        final json = await _uploadViaNewKey(
          session: session,
          filePath: file.path,
          filename: file.filename,
        );
        _throwIfError(json);
        key = _readToken(json, const ['key', 'attachment_key']) ?? key;
        hash = _readToken(json, const ['hash']) ?? hash;
      } else {
        final json = await _uploadViaAttachments(
          session: session.copyWith(key: key, hash: hash),
          filePath: file.path,
          filename: file.filename,
        );
        _throwIfError(json);
      }
    }

    return session.copyWith(key: key, hash: hash);
  }

  Future<void> uploadFile({
    required AttachmentSession session,
    required String filePath,
    String? filename,
  }) async {
    await uploadFiles(
      session: session,
      files: [
        (
          path: filePath,
          filename: filename ?? filePath.split(RegExp(r'[/\\]')).last,
        ),
      ],
    );
  }

  Future<Map<String, dynamic>> _uploadViaNewKey({
    required AttachmentSession session,
    required String filePath,
    required String filename,
  }) async {
    final fields = _sessionFields(session);
    return _api.postMultipart(
      _newKeyPath,
      fields: fields,
      query: fields,
      files: {
        'attachment': MultipartFile.fromFileSync(filePath, filename: filename),
      },
    );
  }

  Future<Map<String, dynamic>> _uploadViaAttachments({
    required AttachmentSession session,
    required String filePath,
    required String filename,
  }) async {
    final fields = {
      ..._sessionFields(session),
      'attachment_key': session.key,
    };
    return _api.postMultipart(
      ApiPaths.attachments,
      fields: fields,
      files: {
        'attachment': MultipartFile.fromFileSync(filePath, filename: filename),
      },
    );
  }

  Map<String, dynamic> _sessionFields(AttachmentSession session) {
    return {
      'type': session.type,
      for (final entry in session.context.entries)
        'context[${entry.key}]': entry.value,
    };
  }

  String? _readToken(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  void _throwIfError(Map<String, dynamic> json) {
    final err = XenforoApi.firstErrorMessage(json);
    if (err != null) throw AttachmentException(err);
  }
}

class AttachmentSession {
  const AttachmentSession({
    required this.key,
    required this.hash,
    required this.type,
    required this.context,
  });

  final String key;
  final String hash;
  final String type;
  final Map<String, int> context;

  AttachmentSession copyWith({
    String? key,
    String? hash,
    String? type,
    Map<String, int>? context,
  }) {
    return AttachmentSession(
      key: key ?? this.key,
      hash: hash ?? this.hash,
      type: type ?? this.type,
      context: context ?? this.context,
    );
  }
}

class AttachmentException implements Exception {
  AttachmentException(this.message);
  final String message;

  @override
  String toString() => message;
}

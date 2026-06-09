import 'package:dio/dio.dart';
import 'package:kairete/config/api_paths.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';

class AttachmentService {
  XenforoApi get _api => AppApi.instance.xenforo;

  Future<ProfileAttachmentSession> createProfilePostSession({
    required int profileUserId,
  }) async {
    await AppApi.instance.applySession();
    final json = await _api.get(
      ApiPaths.newsfeedComposeAttachments,
      query: {'context': 'profile'},
    );
    _throwIfError(json);

    final hash = json['hash']?.toString() ?? '';
    if (hash.isEmpty) {
      throw AttachmentException('Impossibile preparare gli allegati.');
    }

    return ProfileAttachmentSession(
      hash: hash,
      profileUserId: profileUserId,
    );
  }

  Future<void> uploadProfilePostFile({
    required ProfileAttachmentSession session,
    required String filePath,
    String? filename,
  }) async {
    await AppApi.instance.applySession();
    final name = filename ?? filePath.split(RegExp(r'[/\\]')).last;
    final json = await _api.postMultipart(
      ApiPaths.attachments,
      fields: {
        'type': 'profile_post',
        'hash': session.hash,
        'context[profile_user_id]': session.profileUserId,
      },
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

class ProfileAttachmentSession {
  const ProfileAttachmentSession({
    required this.hash,
    required this.profileUserId,
  });

  final String hash;
  final int profileUserId;
}

class AttachmentException implements Exception {
  AttachmentException(this.message);
  final String message;

  @override
  String toString() => message;
}

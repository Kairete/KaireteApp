import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kairete/helper/user.dart';

Future<MultipartFile> getMultipartFile({required String path}) async {
  print(path);
  String fileName = path.split('/').last;
  return MultipartFile.fromFileSync(path, filename: fileName);
}

Future getMultipartFiles({required List<XFile> files}) async {
  var formData = FormData.fromMap({
    'type': 'profile_post',
    'context[profile_user_id]': UserManager.instance.userId,
  });
  List<String> filepath = files.map((e) => e.path).toList();
  for (var file in filepath) {
    formData.files
        .add(MapEntry("attachment", MultipartFile.fromFileSync(file)));
  }
  return formData;
}

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kairete/helper/user.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';

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

Future getMultipartFilesNew({required List<XFile> files, dynamic body}) async {
  // Chuyển đổi List<XFile> thành List<MultipartFile>
  final multipartFiles = await creatPartFiles(files: files);

  final data = body ??
      {
        "attachment": multipartFiles,
        'type': 'profile_post',
        'context[profile_user_id]': UserManager.instance.userId,
      };
  // Tạo FormData
  FormData formData = FormData.fromMap(
    data,
  );
  return formData;
}

Future creatPartFiles({required List<XFile> files}) async {
  List<MultipartFile> multipartFiles = [];

  for (var file in files) {
    // Đọc file từ đường dẫn của XFile
    final compressedBytes = await compressFile(file.path);

    // Tạo MultipartFile từ dữ liệu byte, với tên file có phần mở rộng là .jpg
    multipartFiles.add(MultipartFile.fromBytes(
      compressedBytes,
      filename: path.basenameWithoutExtension(file.name) +
          '.jpeg', // Đặt tên file với .jpg
      contentType: MediaType('image', 'jpeg'), // Kiểu nội dung image/jpeg
    ));
  }

  return multipartFiles;
}

Future<List<int>> compressFile(String filePath) async {
  final result = await FlutterImageCompress.compressWithFile(
    filePath,
    minWidth: 800,
    minHeight: 600,
    quality: 85,
  );
  return result ?? File(filePath).readAsBytesSync();
}

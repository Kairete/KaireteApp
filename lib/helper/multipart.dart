import 'package:dio/dio.dart';

Future<MultipartFile> getMultipartFile({required String path}) async {
  String fileName = path.split('/').last;
  return MultipartFile.fromFileSync(path, filename: fileName);
}

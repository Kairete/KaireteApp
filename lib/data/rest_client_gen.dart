import 'package:dio/dio.dart';
import 'dart:async';

import 'error.dart';

class RestClient {
  Dio dio;
  CancelToken cancelToken;

  RestClient({required this.dio, required this.cancelToken});

  Future requestApi(
      {Map<String, dynamic>? body,
      int? offset,
      int? limit,
      required String path,
      HttpMethodCustom? method = HttpMethodCustom.POST}) async {
    {
      final queryParameters = <String, dynamic>{};
      final _data = <String, dynamic>{};
      if (body != null) {
        if (method == HttpMethodCustom.GET) {
          queryParameters.addAll(body);
          queryParameters.removeWhere((k, v) => v == null);
        } else {
          _data.addAll(body);
        }
      }
      FormData formData = FormData.fromMap(_data);
      final _result = await dio.request(path,
          queryParameters: queryParameters,
          options: Options(
            method: method.toString().split('.').last,
          ),
          data: formData,
          cancelToken: cancelToken);
      final data = _result.data;
      return data;
    }
  }

  Future<dynamic> uploadFile(
      {dynamic body,
      required String path,
      HttpMethodCustom? method = HttpMethodCustom.POST}) async {
    FormData formData = FormData.fromMap(body);
    final _result = await dio.request(path,
        options: Options(
          method: method.toString().split('.').last,
        ),
        data: formData,
        cancelToken: cancelToken);
    final data = _result.data;
    return data;
  }
}

enum HttpMethodCustom { GET, POST, DELETE, PATCH, PUT, UPDATE }

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'dart:async';

import 'package:kairete/helper/user.dart';

class RestClient {
  Dio dio;
  CancelToken cancelToken;
  CacheOptions cacheInterceptor;

  RestClient({
    required this.dio,
    required this.cancelToken,
    required this.cacheInterceptor,
  });

  Future requestApi({
    Map<String, dynamic>? body,
    Map<String, dynamic>? parameters,
    int? offset,
    int? limit,
    required String path,
    HttpMethodCustom? method = HttpMethodCustom.POST,
    String? userId,
  }) async {
    {
      final queryParameters = <String, dynamic>{};
      final _data = <String, dynamic>{};
      if (userId != null) {
        dio.options.headers['XF-Api-User'] = userId;
      }
      if (body != null) {
        if (method == HttpMethodCustom.GET) {
          queryParameters.addAll(body);
          queryParameters.removeWhere((k, v) => v == null);
        } else {
          _data.addAll(body);
        }
      }
      queryParameters['limit'] = 20;
      if (parameters != null) {
        queryParameters.addAll(parameters);
        queryParameters.removeWhere((k, v) => v == null);
      }

      FormData formData = FormData.fromMap(_data);
      final _result = await dio.request(path,
          queryParameters: queryParameters,
          options: Options(
            method: method.toString().split('.').last,
            // extra: cacheInterceptor
            //     .copyWith(policy: CachePolicy.forceCache)
            //     .toExtra(),
          ),
          data: formData,
          cancelToken: cancelToken);
      final data = _result.data;
      return data;
    }
  }

  Future<dynamic> uploadFile({
    dynamic body,
    required String path,
    HttpMethodCustom? method = HttpMethodCustom.POST,
    FormData? formData,
  }) async {
    // dio.options.headers['XF-Api-User'] = '1';
    final _result = await dio.request(
      path,
      options: Options(
        method: method.toString().split('.').last,
      ),
      data: body,
      queryParameters: {
        'type': 'profile_post',
        'context[profile_user_id]': UserManager.instance.userId
      },
      cancelToken: cancelToken,
    );
    final data = _result.data;
    return data;
  }
}

enum HttpMethodCustom { GET, POST, DELETE, PATCH, PUT, UPDATE }

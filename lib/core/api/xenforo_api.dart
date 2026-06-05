import 'package:dio/dio.dart';
import 'package:kairete/config/app_config.dart';

class XenforoApi {
  XenforoApi() {
    _dio.options.baseUrl = AppConfig.apiBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 20);
    _dio.options.sendTimeout = const Duration(seconds: 20);
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['XF-Api-Key'] = AppConfig.xenforoApiKey;
    _dio.options.headers['X-Kairete-App-Id'] = AppConfig.mobileAppId;
    _applyUserHeader();
  }

  final Dio _dio = Dio();
  int? _userId;

  void setUserId(int? userId) {
    _userId = userId;
    _applyUserHeader();
  }

  void _applyUserHeader() {
    _dio.options.headers['XF-Api-User'] = (_userId ?? 0).toString();
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      path,
      data: FormData.fromMap(body ?? {}),
      queryParameters: _withLimit(query),
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
  }) async {
    final params = _withLimit(query);
    if (body != null) {
      body.forEach((key, value) {
        if (value != null) params[key] = value;
      });
    }
    final response = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: params,
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final response = await _dio.delete<Map<String, dynamic>>(
      path,
      queryParameters: _withLimit(null),
    );
    return response.data ?? {};
  }

  Map<String, dynamic> _withLimit(Map<String, dynamic>? query) {
    return {'limit': 10, ...?query};
  }

  static String? firstErrorMessage(Map<String, dynamic> json) {
    final errors = json['errors'];
    if (errors is List && errors.isNotEmpty) {
      final first = errors.first;
      if (first is Map) return first['message']?.toString();
      return first.toString();
    }
    return null;
  }
}

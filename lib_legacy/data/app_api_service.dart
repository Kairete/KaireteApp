import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:kairete/components/kairete_popup.dart';
import 'package:kairete/helper/user.dart';
import '../config/app_config.dart';
import '../constants/color_constant.dart';
import 'rest_client_gen.dart';

class AppApiService {
  static String get apiDomain => AppConfig.apiBaseUrl;

  RestClient? client;
  final Dio dio = Dio();

  AppApiService();

  CancelToken cancelToken = CancelToken();

  final options = CacheOptions(
    // A default store is required for interceptor.
    store: MemCacheStore(),

    // All subsequent fields are optional.

    // Default.
    policy: CachePolicy.refreshForceCache,
    // Returns a cached response on error but for statuses 401 & 403.
    // Also allows to return a cached response on network errors (e.g. offline usage).
    // Defaults to [null].
    hitCacheOnErrorExcept: [401, 403],
    // Overrides any HTTP directive to delete entry past this duration.
    // Useful only when origin server has no cache config or custom behaviour is desired.
    // Defaults to [null].
    maxStale: const Duration(days: 7),
    // Default. Allows 3 cache sets and ease cleanup.
    priority: CachePriority.normal,
    // Default. Body and headers encryption with your own algorithm.
    cipher: null,
    // Default. Key builder to retrieve requests.
    keyBuilder: CacheOptions.defaultCacheKeyBuilder,
    // Default. Allows to cache POST requests.
    // Overriding [keyBuilder] is strongly recommended when [true].
    allowPostMethod: false,
  );

  void create(
      {bool isShowErrorPopup = true,
      String? userId,
      bool isShowloading = true}) {
    // dio.interceptors.add(RequestsInspectorInterceptor());

    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.circle
      ..backgroundColor = kTextPrimaryColor
      ..indicatorColor = Colors.white;
    addDioHeader(userId: userId);
    final cacheInterceptor = DioCacheInterceptor(options: options);
    client = RestClient(
      dio: dio,
      cancelToken: cancelToken,
      cacheInterceptor: options,
    );
    dio.interceptors.add(cacheInterceptor);
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (isShowloading) {
            EasyLoading.show(status: 'loading...', dismissOnTap: false);
          }
          print(
              '''[api-${DateFormat('mm:ss').format(DateTime.now())}]-> Request  \t${options.method}}''');
          print('''[api-Request]-> Url  \t${options.baseUrl}''');
          print('''[api-Request]-> Body  \t${options.data}''');
          print('''[api-Request]-> Parameter  \t${options.queryParameters}''');
          print('''[api-Request]-> Header  \t${options.headers}''');
          return handler.next(options);
        },
        onResponse: (response, handler) async {
          print(response.realUri);
          print(
              '''[api-${DateFormat('mm:ss').format(DateTime.now())}]-> Response \t${response.requestOptions.baseUrl} [${response.requestOptions.path}] ${response.statusCode} ''');
          final jsonData = response.data;
          final prettyString =
              const JsonEncoder.withIndent('  ').convert(jsonData);
          log(prettyString);
          if (isShowloading) {
            EasyLoading.dismiss();
          }

          return handler.next(response);
        },
        onError: (error, handler) async {
          print(
              '''[api-${DateFormat('mm:ss').format(DateTime.now())}]-> Error    \turl:[${error.requestOptions.baseUrl}${error.requestOptions.path}] type:${error.type} message: ${error.message}''');
          print('''[api-error]-> response  \t${error.response}''');
          if (isShowloading) {
            EasyLoading.dismiss();
          }
          return hanlderError(error, handler, isShowErrorPopup);
        },
      ),
    );
  }

  void addDioHeader({Map<String, String>? headers, String? userId}) async {
    dio.options.headers.clear();
    dio.options.headers['content-type'] = 'application/json';
    dio.options.headers['accept'] = 'application/json';
    dio.options.headers['XF-Api-Key'] = AppConfig.xenforoApiKey;
    dio.options.headers[AppConfig.appIdHeader] = AppConfig.mobileAppId;
    dio.options.headers['XF-Api-User'] =
        userId ?? UserManager.instance.userId ?? '1';
    // dio.options.connectTimeout = 50000;
    // dio.options.receiveTimeout = 50000;
    dio.options.baseUrl = apiDomain;
  }

  hanlderError(
      DioError error, ErrorInterceptorHandler handler, bool isShowErrorPopup) {
    if (error.response!.statusCode == 401) {
      cancelToken.cancel('cancelled');
      return;
    }
    if (isShowErrorPopup) {
      showKairetePopup(
        onTapDone: () {},
        title: 'Notice',
        content: error.response?.data["errors"][0]['message'],
      );
    }
  }
}

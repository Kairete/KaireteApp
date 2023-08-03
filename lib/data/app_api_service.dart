import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:kairete/components/kairete_popup.dart';
import 'package:kairete/helper/user.dart';
import '../constants/color_constant.dart';
import '../constants/key_constant.dart';
import '../local/data_local.dart';
import 'rest_client_gen.dart';

class AppApiService {
  static const String apiDomain = "https://www.kairete.net/";

  RestClient? client;
  final Dio dio = Dio();

  AppApiService();

  CancelToken cancelToken = CancelToken();

  void create(
      {bool isShowErrorPopup = true,
      String? userId,
      bool isShowloading = true}) {
    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.circle
      ..backgroundColor = kTextPrimaryColor
      ..indicatorColor = Colors.white;
    addDioHeader(userId: userId);
    client = RestClient(dio: dio, cancelToken: cancelToken);
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
    dio.options.headers['XF-Api-Key'] = 'Bj-iF2DqxqJcBEolg9H6Qjp94ekWVM1Y';
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

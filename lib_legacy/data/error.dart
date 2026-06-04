import 'package:dio/dio.dart';

class ErorrModel {
  String? title;
  String? message;
  int? errorCode;
  ErrorType? type;
  dynamic customError;

  ErorrModel(
      {this.title, this.message, this.errorCode, this.type, this.customError});

  String getTitleButtonError() {
    switch (type) {
      case ErrorType.external:
        return 'Retry';
      default:
        return 'Close';
    }
  }

  ErorrModel.fromDioError(DioError error) {
    final errorModel = ErrorManager.instance.getError(error);
    customError = error.response?.data;
    title = errorModel.title;
    message = errorModel.message;
    errorCode = errorModel.errorCode;
    type = errorModel.type;
  }
}

class ErrorManager {
  static ErrorManager? _instance;

  ErrorManager._();

  static ErrorManager get instance => _instance ??= ErrorManager._();

  ErorrModel getError(DioError error) {
    final response = error.response;
    final message = response?.data["errors"][0]['message'];
    print(message);
    final item = ErorrModel(
        errorCode: error.response?.statusCode,
        title: message,
        type: ErrorType.normal);
    print(item.message);
    return item;
  }
}

enum ErrorType { external, normal, custom }

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:kairete/config/app_config.dart';

class XenforoApi {
  XenforoApi() {
    _dio.options.baseUrl = AppConfig.apiBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 20);
    _dio.options.sendTimeout = const Duration(seconds: 20);
    _dio.options.validateStatus = (status) => status != null && status < 500;
    _dio.options.headers['Accept'] = 'application/json';
    // Never embed a privileged XF API key in a distributable APK.
    // Login, verify and logout use narrowly unauthenticated mobile endpoints.
    _dio.options.headers['X-Kairete-App-Id'] = AppConfig.mobileAppId;
    _applyTenantHeader();
    _applyUserHeader();
  }

  final Dio _dio = Dio();
  int? _userId;

  void setUserId(int? userId) {
    _userId = userId;
    _applyUserHeader();
  }

  /// Esegue [action] impersonando [userId] su XF-Api-User (come app legacy profilo).
  Future<T> runAsUser<T>(int userId, Future<T> Function() action) async {
    if (userId <= 0) return action();
    final previous = _userId;
    setUserId(userId);
    try {
      return await action();
    } finally {
      setUserId(previous);
    }
  }

  void _applyUserHeader() {
    // User IDs are not credentials; never send XF-Api-User without a
    // server-authenticated super-user context (not available to the app).
    _dio.options.headers.remove('XF-Api-User');
  }

  void _applyTenantHeader() {
    if (AppConfig.isTenantApp && AppConfig.tenantId > 0) {
      _dio.options.headers[AppConfig.tenantHeader] =
          AppConfig.tenantId.toString();
    } else {
      _dio.options.headers.remove(AppConfig.tenantHeader);
    }
  }

  /// Dopo [AppBranding.ensureFromPackage] aggiorna header app/tenant.
  void syncAppIdentity() {
    _dio.options.headers['X-Kairete-App-Id'] = AppConfig.mobileAppId;
    _applyTenantHeader();
  }

  /// Mobile login endpoints may return HTML (PHP/host errors). Retrieve raw
  /// bytes as text first to avoid DioExceptionType.unknown during JSON decode.
  /// Never expose response bodies: they may contain sensitive server details.
  Future<Map<String, dynamic>> postMobileAuth(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    // Apache/XenForo can issue 301 redirects for API URLs. Automatic
    // redirects may turn a credential POST into GET. Follow only safe HTTPS
    // redirects within the Kairete .net API and explicitly POST again.
    Uri destination = Uri.parse(AppConfig.apiBaseUrl).resolve(path);
    Response<String>? response;
    for (var hop = 0; hop < 4; hop++) {
      try {
        response = await _dio.post<String>(
          destination.toString(),
          data: FormData.fromMap(body),
          options: Options(
            responseType: ResponseType.plain,
            followRedirects: false,
            validateStatus: (status) => status != null && status < 600,
            headers: {'Accept': 'application/json'},
          ),
        );
      } on DioException catch (e) {
        throw MobileAuthApiException(
          'Rete: ${e.type.name}; causa: ${e.error?.runtimeType ?? 'non disponibile'}.',
        );
      }
      final code = response.statusCode ?? 0;
      if (code != 301 && code != 302 && code != 303 &&
          code != 307 && code != 308) {
        break;
      }
      if (hop == 3) {
        throw const MobileAuthApiException('Troppi redirect HTTP sul login.');
      }
      final location = response.headers.value('location');
      if (location == null || location.isEmpty) {
        throw MobileAuthApiException('HTTP $code — redirect senza destinazione.');
      }
      final next = destination.resolve(location);
      final host = next.host.toLowerCase();
      final pathAllowed = next.path == '/api/ms-auth-login' ||
          next.path == '/api/ms-auth-login/' ||
          next.path == '/api/ms-auth-verify' ||
          next.path == '/api/ms-auth-verify/' ||
          next.path == '/api/ms-auth-logout' ||
          next.path == '/api/ms-auth-logout/';
      if (next.scheme != 'https' ||
          (host != 'www.kairete.net' && host != 'kairete.net') ||
          next.userInfo.isNotEmpty ||
          (next.hasPort && next.port != 443) ||
          !pathAllowed) {
        throw MobileAuthApiException(
          'HTTP $code — redirect non sicuro o verso una route inattesa.',
        );
      }
      destination = next;
    }
    if (response == null) {
      throw const MobileAuthApiException('Nessuna risposta del server.');
    }

    final status = response.statusCode ?? 0;
    final contentType = response.headers.value('content-type') ?? 'assente';
    final raw = response.data ?? '';
    Map<String, dynamic>? json;
    try {
      final parsed = jsonDecode(raw);
      if (parsed is Map) json = Map<String, dynamic>.from(parsed);
    } catch (_) {}

    if (json == null) {
      final type = contentType.split(';').first.trim();
      throw MobileAuthApiException(
        'HTTP $status — il server ha restituito una risposta non JSON '
        '(Content-Type: $type).',
      );
    }
    final errorCode = json['errors'];
    if (errorCode is List && errorCode.isNotEmpty) {
      final first = errorCode.first;
      if (first is Map) {
        final code = first['code']?.toString() ?? 'api_error';
        final message = first['message']?.toString() ?? 'Richiesta respinta';
        throw MobileAuthApiException('HTTP $status — $code: $message');
      }
      throw MobileAuthApiException('HTTP $status — richiesta rifiutata.');
    }
    if (status >= 400) {
      throw MobileAuthApiException('HTTP $status — errore del server XenForo.');
    }
    return json;
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
  }) async {
    final form = FormData();
    (body ?? {}).forEach((key, value) {
      if (value == null) return;
      if (value is List) {
        // XF API array fields (es. tags[]): ripeti la chiave con [].
        for (final item in value) {
          if (item == null) continue;
          form.fields.add(MapEntry('$key[]', item.toString()));
        }
      } else {
        form.fields.add(MapEntry(key, value.toString()));
      }
    });
    final response = await _dio.post<Map<String, dynamic>>(
      path,
      data: form,
      queryParameters: query,
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    Map<String, dynamic>? fields,
    Map<String, dynamic>? query,
    Map<String, MultipartFile>? files,
    Duration? sendTimeout,
    Duration? receiveTimeout,
  }) async {
    final form = FormData();
    files?.forEach((key, file) {
      form.files.add(MapEntry(key, file));
    });
    fields?.forEach((key, value) {
      if (value != null) form.fields.add(MapEntry(key, value.toString()));
    });
    final response = await _dio.post<Map<String, dynamic>>(
      path,
      data: form,
      queryParameters: query,
      options: Options(
        sendTimeout: sendTimeout ?? const Duration(minutes: 5),
        receiveTimeout: receiveTimeout ?? const Duration(minutes: 5),
        followRedirects: false,
        validateStatus: (status) => status != null && status < 500,
      ),
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

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _dio.delete<Map<String, dynamic>>(
      path,
      data: body != null ? FormData.fromMap(body) : null,
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

  /// Messaggio leggibile per errori di rete (timeout, DNS, certificato, ecc.).
  static String connectionMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final apiMsg = firstErrorMessage(data);
      if (apiMsg != null && apiMsg.isNotEmpty) return apiMsg;
    }
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connessione lenta o assente. Riprova.';
      case DioExceptionType.connectionError:
        return 'Impossibile raggiungere il server. Controlla la rete.';
      case DioExceptionType.badCertificate:
        return 'Certificato del server non valido.';
      default:
        return 'Errore di connessione. Riprova.';
    }
  }
}

class MobileAuthApiException implements Exception {
  const MobileAuthApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

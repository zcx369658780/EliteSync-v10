import 'package:dio/dio.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';

String? _rawAuthority(String value) =>
    RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*://([^/?#]*)').firstMatch(value)?.group(1);

/// Plain HTTP is reserved for explicit development loopback connections.
String validateApiBaseUrl(String raw, {bool allowLocalInsecure = false}) {
  final value = raw.trim();
  if (value.isEmpty || RegExp(r'[\s\\\x00-\x1f\x7f]').hasMatch(value)) {
    throw const FormatException('Invalid API base URL');
  }
  final uri = Uri.tryParse(value);
  // Uri canonicalizes away an empty user-info/port delimiter. Validate the
  // original authority too, before accepting the canonical representation.
  final authority = _rawAuthority(value);
  if (uri == null ||
      !uri.hasAuthority ||
      uri.host.isEmpty ||
      authority == null ||
      authority.contains('@') ||
      authority.endsWith(':') ||
      uri.hasQuery ||
      uri.hasFragment ||
      uri.port < 1 ||
      uri.port > 65535) {
    throw const FormatException('Invalid API base URL');
  }
  final localHost = uri.host.toLowerCase().replaceAll(RegExp(r'[\[\]]'), '');
  final localHttp =
      allowLocalInsecure &&
      uri.scheme == 'http' &&
      const {'127.0.0.1', 'localhost', '::1', '10.0.2.2'}.contains(localHost);
  if (uri.scheme != 'https' && !localHttp) {
    throw const FormatException('API requires HTTPS');
  }
  final normalized = uri.normalizePath().toString();
  return normalized.endsWith('/') ? normalized : '$normalized/';
}

/// Must precede authentication so rejected targets never receive credentials.
void configureApiTransport(Dio dio, {required AppEnv env}) {
  final base = validateApiBaseUrl(
    env.apiBaseUrl,
    allowLocalInsecure: env.isDev,
  );
  dio.options.baseUrl = base;
  dio.options.followRedirects = false;
  dio.options.maxRedirects = 0;
  dio.interceptors.removeWhere((item) => item is _ApiOriginInterceptor);
  dio.interceptors.insert(0, _ApiOriginInterceptor(Uri.parse(base)));
}

class _ApiOriginInterceptor extends Interceptor {
  _ApiOriginInterceptor(this.origin);
  final Uri origin;

  bool _sameOrigin(Uri target) =>
      target.userInfo.isEmpty &&
      !target.authority.contains('@') &&
      target.scheme == origin.scheme &&
      target.host.toLowerCase() == origin.host.toLowerCase() &&
      target.port == origin.port;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.followRedirects = false;
    options.maxRedirects = 0;
    try {
      final rawTarget = Uri.parse(options.path);
      final rawAuthority = _rawAuthority(options.path);
      // Dio treats some scheme-relative paths as ordinary paths. Reject them
      // explicitly rather than letting another adapter interpret them differently.
      if (options.path.contains('\\') ||
          (rawTarget.hasAuthority && !rawTarget.hasScheme) ||
          (rawTarget.hasScheme &&
              (rawAuthority == null ||
                  rawAuthority.contains('@') ||
                  rawAuthority.endsWith(':') ||
                  !_sameOrigin(rawTarget))) ||
          !_sameOrigin(options.uri)) {
        throw const FormatException('API target must match configured origin');
      }
    } on FormatException {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.cancel,
          message: 'API target must match configured origin',
        ),
      );
      return;
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (const {301, 302, 303, 307, 308}.contains(response.statusCode)) {
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'API redirects are disabled',
        ),
      );
      return;
    }
    handler.next(response);
  }
}

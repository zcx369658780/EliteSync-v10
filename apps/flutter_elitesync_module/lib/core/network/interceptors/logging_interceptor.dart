import 'package:dio/dio.dart';
import 'package:flutter_elitesync_module/core/logging/app_logger.dart';

class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({required AppLogger logger}) : _logger = logger;

  final AppLogger _logger;

  // URLs, payloads, and raw exceptions can contain private data or credentials.
  // Only fixed metadata is eligible for network diagnostics.
  String _method(RequestOptions options) =>
      switch (options.method.toUpperCase()) {
        'GET' ||
        'POST' ||
        'PUT' ||
        'PATCH' ||
        'DELETE' ||
        'HEAD' ||
        'OPTIONS' ||
        'CONNECT' ||
        'TRACE' => options.method.toUpperCase(),
        _ => 'OTHER',
      };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.debug('[REQ] ${_method(options)}', tag: 'NETWORK');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.debug(
      '[RES] ${response.statusCode ?? '-'} ${_method(response.requestOptions)}',
      tag: 'NETWORK',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.warning(
      '[ERR] ${err.response?.statusCode ?? '-'} ${_method(err.requestOptions)} ${err.type.name}',
      tag: 'NETWORK',
    );
    super.onError(err, handler);
  }
}

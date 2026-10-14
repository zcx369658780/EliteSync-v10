import 'package:dio/dio.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/core/logging/app_logger.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/logging_interceptor.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/retry_interceptor.dart';

class DioFactory {
  DioFactory({
    required AppEnv env,
    required AppLogger logger,
    required AccessTokenProvider accessTokenProvider,
    RefreshAccessToken? refreshAccessToken,
    Future<void> Function(String rejectedToken)? onSessionRejected,
  }) : _env = env,
       _logger = logger,
       _accessTokenProvider = accessTokenProvider,
       _refreshAccessToken = refreshAccessToken,
       _onSessionRejected = onSessionRejected;

  final AppEnv _env;
  final AppLogger _logger;
  final AccessTokenProvider _accessTokenProvider;
  final RefreshAccessToken? _refreshAccessToken;
  final Future<void> Function(String rejectedToken)? _onSessionRejected;

  Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _env.apiBaseUrl,
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(
        accessTokenProvider: _accessTokenProvider,
        refreshAccessToken: _refreshAccessToken,
        onSessionRejected: _onSessionRejected,
      ),
      RetryInterceptor(),
      // Keep request logging on during the current astro-loading investigation.
      LoggingInterceptor(logger: _logger),
    ]);

    return dio;
  }
}

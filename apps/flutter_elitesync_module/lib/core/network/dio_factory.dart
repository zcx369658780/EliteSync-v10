import 'package:dio/dio.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/core/logging/app_logger.dart';
import 'package:flutter_elitesync_module/core/network/api_transport_policy.dart';
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
    String Function()? sessionIdentity,
  }) : _env = env,
       _logger = logger,
       _accessTokenProvider = accessTokenProvider,
       _refreshAccessToken = refreshAccessToken,
       _onSessionRejected = onSessionRejected,
       _sessionIdentity = sessionIdentity;

  final AppEnv _env;
  final AppLogger _logger;
  final AccessTokenProvider _accessTokenProvider;
  final RefreshAccessToken? _refreshAccessToken;
  final Future<void> Function(String rejectedToken)? _onSessionRejected;
  final String Function()? _sessionIdentity;

  Dio create() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    configureApiTransport(dio, env: _env);
    // Replays retain their explicit Authorization header and never re-enter
    // auth/refresh/retry/logging. They still cross the same transport boundary.
    final replayDio = Dio();
    configureApiTransport(replayDio, env: _env);
    replayDio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (!requestSessionIsCurrent(options)) {
            handler.reject(staleSessionRequest(options));
            return;
          }
          handler.next(options);
        },
      ),
    );
    Future<Response<dynamic>> replayRequest(RequestOptions options) {
      if (!requestSessionIsCurrent(options)) {
        return Future.error(staleSessionRequest(options));
      }
      // Follow adapter replacement in tests/configuration and share its pool.
      replayDio.httpClientAdapter = dio.httpClientAdapter;
      return replayDio.fetch<dynamic>(options);
    }

    dio.interceptors.addAll([
      AuthInterceptor(
        accessTokenProvider: _accessTokenProvider,
        refreshAccessToken: _refreshAccessToken,
        onSessionRejected: _onSessionRejected,
        sessionIdentity: _sessionIdentity,
        replayRequest: replayRequest,
      ),
      RetryInterceptor(replayRequest: replayRequest),
      // Keep request logging on during the current astro-loading investigation.
      LoggingInterceptor(logger: _logger),
    ]);

    return dio;
  }
}

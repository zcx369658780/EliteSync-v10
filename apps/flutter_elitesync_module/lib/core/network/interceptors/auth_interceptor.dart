import 'package:dio/dio.dart';

typedef AccessTokenProvider = Future<String?> Function();
typedef RefreshAccessToken = Future<String?> Function();

const requestSessionGuardKey = '__request_session_is_current__';

bool requestSessionIsCurrent(RequestOptions options) {
  final guard = options.extra[requestSessionGuardKey];
  if (guard == null) return true;
  if (guard is! bool Function()) return false;
  try {
    return guard();
  } catch (_) {
    return false;
  }
}

DioException staleSessionRequest(RequestOptions options) => DioException(
  requestOptions: options,
  type: DioExceptionType.cancel,
  message: 'Request session is no longer current',
);

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required AccessTokenProvider accessTokenProvider,
    RefreshAccessToken? refreshAccessToken,
    Future<void> Function(String rejectedToken)? onSessionRejected,
  }) : _accessTokenProvider = accessTokenProvider,
       _refreshAccessToken = refreshAccessToken,
       _onSessionRejected = onSessionRejected;

  final AccessTokenProvider _accessTokenProvider;
  final RefreshAccessToken? _refreshAccessToken;
  final Future<void> Function(String rejectedToken)? _onSessionRejected;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!requestSessionIsCurrent(options)) {
      handler.reject(staleSessionRequest(options));
      return;
    }
    final token = await _accessTokenProvider();
    if (!requestSessionIsCurrent(options)) {
      handler.reject(staleSessionRequest(options));
      return;
    }
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (!requestSessionIsCurrent(err.requestOptions)) {
      handler.reject(staleSessionRequest(err.requestOptions));
      return;
    }
    final path = err.requestOptions.path;
    final protectedProfile =
        path.startsWith('/api/v1/profile/') ||
        path == '/api/v1/auth/refresh' ||
        [
          '/api/v1/account/',
          '/api/v1/auth/account',
          '/api/v1/auth/logout',
          '/api/v1/connections/',
          '/api/v1/social',
          '/api/v1/profile-peers/',
          '/api/v1/privacy',
          '/api/v1/notifications',
          '/api/v1/status/',
          '/api/v1/media/',
        ].any(path.startsWith);
    final status = err.response?.statusCode;
    final data = err.response?.data;
    final disabled =
        data is Map &&
        data['error'] is Map &&
        data['error']['code'] == 'account_disabled';
    if (protectedProfile && (status == 401 || (status == 403 && disabled))) {
      String? token;
      try {
        token = await _accessTokenProvider();
      } catch (_) {
        // The session notifier checks in-memory identity if secure storage fails.
        final header = err.requestOptions.headers['Authorization']?.toString();
        if (header != null && header.startsWith('Bearer ')) {
          token = header.substring(7);
        }
      }
      if (token != null &&
          token.isNotEmpty &&
          err.requestOptions.headers['Authorization'] == 'Bearer $token') {
        try {
          await _onSessionRejected?.call(token);
        } catch (_) {
          /* Preserve the original server rejection even if local storage fails. */
        }
      }
      super.onError(err, handler);
      return;
    }
    if (err.response?.statusCode == 401 && _refreshAccessToken != null) {
      final req = err.requestOptions;
      final hasRetried = req.extra['__retried_401__'] == true;
      final currentAuthorization = req.headers['Authorization']?.toString();
      if (!hasRetried) {
        final refreshed = await _refreshAccessToken();
        if (!requestSessionIsCurrent(req)) {
          handler.reject(staleSessionRequest(req));
          return;
        }
        final nextAuthorization = (refreshed != null && refreshed.isNotEmpty)
            ? 'Bearer $refreshed'
            : null;
        if (nextAuthorization != null &&
            nextAuthorization.isNotEmpty &&
            nextAuthorization != currentAuthorization) {
          req.extra['__retried_401__'] = true;
          req.headers['Authorization'] = nextAuthorization;
          try {
            final response = await Dio().fetch(req);
            handler.resolve(response);
            return;
          } catch (_) {
            // fallback to original error
          }
        }
      }
    }

    super.onError(err, handler);
  }
}

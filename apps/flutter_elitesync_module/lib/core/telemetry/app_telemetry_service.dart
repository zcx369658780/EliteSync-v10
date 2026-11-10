import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/auth_interceptor.dart';

class AppTelemetryService {
  const AppTelemetryService({
    required this.apiClient,
    required this.appVersionProvider,
    this.sessionIdentity,
  });

  final ApiClient apiClient;
  final Future<String> Function() appVersionProvider;
  final String? Function()? sessionIdentity;

  bool Function() _captureSessionGuard() {
    final identity = sessionIdentity?.call();
    return () {
      try {
        return sessionIdentity == null || sessionIdentity!() == identity;
      } catch (_) {
        return false;
      }
    };
  }

  Future<NetworkResult<Map<String, dynamic>>> postEvent(
    String path, {
    required String sourcePage,
    Object? body,
  }) async {
    final current = _captureSessionGuard();
    final version = await appVersionProvider();
    if (!current()) {
      return const NetworkFailure(
        message: '登录会话已变化，旧操作未发送',
        code: 'SESSION_CHANGED',
      );
    }
    return apiClient.post(
      path,
      body: body,
      options: Options(
        headers: {'X-App-Version': version, 'X-Source-Page': sourcePage},
        extra: {requestSessionGuardKey: current},
      ),
    );
  }

  Future<NetworkResult<Map<String, dynamic>>> trackEvent(
    String eventName, {
    required String sourcePage,
    int? targetUserId,
    int? matchId,
    Map<String, dynamic>? payload,
  }) async {
    final body = <String, dynamic>{
      'event_name': eventName,
      'target_user_id': ?targetUserId,
      'match_id': ?matchId,
      if (payload != null && payload.isNotEmpty) 'payload': payload,
    };
    return postEvent(
      '/api/v1/telemetry/events',
      sourcePage: sourcePage,
      body: body,
    );
  }

  Future<NetworkResult<Map<String, dynamic>>> getEvent(
    String path, {
    required String sourcePage,
    Map<String, dynamic>? query,
  }) async {
    final current = _captureSessionGuard();
    final version = await appVersionProvider();
    if (!current()) {
      return const NetworkFailure(
        message: '登录会话已变化，旧读取未发送',
        code: 'SESSION_CHANGED',
      );
    }
    return apiClient.get(
      path,
      query: query,
      options: Options(
        headers: {'X-App-Version': version, 'X-Source-Page': sourcePage},
        extra: {requestSessionGuardKey: current},
      ),
    );
  }
}

final appVersionProvider = Provider<Future<String> Function()>((ref) {
  return () async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  };
});

final appTelemetryProvider = Provider<AppTelemetryService>((ref) {
  return AppTelemetryService(
    apiClient: ref.watch(apiClientProvider),
    appVersionProvider: ref.watch(appVersionProvider),
    sessionIdentity: () {
      final session = ref.read(sessionProvider).asData?.value;
      return '${session?.accessToken}:${session?.user?.id}:${session?.status}';
    },
  );
});

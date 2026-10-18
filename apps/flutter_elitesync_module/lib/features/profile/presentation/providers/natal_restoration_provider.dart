import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

class NatalRequestException implements Exception {
  const NatalRequestException(this.message, [this.statusCode]);
  final String message;
  final int? statusCode;
  @override
  String toString() => message;
}

bool natalSessionMatches(SessionState expected, SessionState? current) =>
    identical(expected, current) &&
    expected.isLoggedIn &&
    current?.status == expected.status &&
    current?.user?.id == expected.user?.id &&
    current?.accessToken == expected.accessToken;

Options natalSessionOptions(bool Function() isCurrent) =>
    Options(extra: {requestSessionGuardKey: isCurrent});

/// Private calculation data is fetched afresh and never logged or cached locally.
final natalRestorationProvider =
    FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
      var active = true;
      ref.onDispose(() => active = false);
      final requestLifetime = ref.keepAlive();
      try {
        final session = await ref.watch(sessionProvider.future);
        if (!session.isLoggedIn) {
          throw const NatalRequestException('请先登录。', 401);
        }
        bool current() =>
            active &&
            natalSessionMatches(
              session,
              ref.read(sessionProvider).asData?.value,
            );
        if (!current()) throw const NatalRequestException('登录身份已变化，请重新读取。');
        final response = await ref
            .read(apiClientProvider)
            .get(
              '/api/v1/profile/natal',
              options: natalSessionOptions(current),
            );
        if (!current()) throw const NatalRequestException('登录身份已变化，请重新读取。');
        return natalProfileFromResponse(response);
      } finally {
        requestLifetime.close();
      }
    });

Map<String, dynamic>? natalProfileFromResponse(
  NetworkResult<Map<String, dynamic>> response,
) {
  if (response is NetworkFailure<Map<String, dynamic>>) {
    throw NatalRequestException(
      response.statusCode == 409
          ? '资料已在其他位置更新，请重新读取后再编辑。'
          : response.statusCode == 422
          ? '输入或计算规则未通过校验，请检查日期、时区、夏令时选择和坐标。'
          : '本命资料请求失败，请检查登录和网络后重试。',
      response.statusCode,
    );
  }
  final body = (response as NetworkSuccess<Map<String, dynamic>>).data;
  if (body['exists'] == false) return null;
  if (body['exists'] != true || body['profile'] is! Map) {
    throw const NatalRequestException('服务器返回的资料格式不完整。');
  }
  return Map<String, dynamic>.from(body['profile'] as Map);
}

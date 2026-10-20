import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class RelationshipAuthorityEpoch extends Notifier<int> {
  @override
  int build() => 0;
  void invalidate() => state++;
}

final relationshipAuthorityEpochProvider =
    NotifierProvider<RelationshipAuthorityEpoch, int>(
      RelationshipAuthorityEpoch.new,
    );

final relationshipApiProvider = Provider<RelationshipApi>(
  (ref) => RelationshipApi(
    ref.watch(apiClientProvider),
    identity: () => ref.read(sessionProvider).asData?.value.accessToken,
  ),
);

// Restricted receipt/revocation traffic must never inherit another account's
// credentials, auto-refresh, retry, or request-body logging.
final restrictedAccountClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(
    dio: Dio(
      BaseOptions(
        baseUrl: ref.watch(appEnvProvider).apiBaseUrl,
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 20),
        contentType: 'application/json',
      ),
    ),
  ),
);

class RelationshipApi {
  RelationshipApi(this.client, {this.identity});
  final ApiClient client;
  final String? Function()? identity;

  Future<Map<String, dynamic>> call(
    String method,
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    final initialIdentity = identity?.call();
    final options = Options(
      extra: {
        if (identity != null)
          requestSessionGuardKey: () => identity!() == initialIdentity,
      },
    );
    final result = await switch (method) {
      'POST' => client.post('/api/v1$path', body: body, options: options),
      'PUT' => client.put('/api/v1$path', body: body, options: options),
      'DELETE' => client.delete('/api/v1$path', body: body, options: options),
      _ => client.get('/api/v1$path', options: options),
    };
    if (result is NetworkFailure<Map<String, dynamic>>) {
      throw RelationshipFailure(result.message, code: result.code);
    }
    final data = (result as NetworkSuccess<Map<String, dynamic>>).data;
    if (data['ok'] == false) {
      throw RelationshipFailure(data['message']?.toString() ?? '操作未完成');
    }
    return data['data'] is Map
        ? Map<String, dynamic>.from(data['data'] as Map)
        : data;
  }
}

class RelationshipFailure implements Exception {
  const RelationshipFailure(this.message, {this.code});
  final String message;
  final String? code;
  @override
  String toString() => message;
}

List<Map<String, dynamic>> rows(Object? value) => value is List
    ? value.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : const [];

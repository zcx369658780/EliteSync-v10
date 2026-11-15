import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/core/storage/private_cache_service.dart';
import 'package:flutter_elitesync_module/features/auth/data/datasource/auth_local_data_source.dart';
import 'package:flutter_elitesync_module/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/auth/data/mapper/auth_mapper.dart';
import 'package:flutter_elitesync_module/features/auth/data/repository/auth_repository_impl.dart';
import 'lifestyle_private_resume_test.dart' show MemorySecure;

class RegistrationApi extends ApiClient {
  RegistrationApi() : super(dio: Dio());
  Map<String, dynamic>? sent;
  @override
  Future<NetworkResult<Map<String, dynamic>>> post(
    String path, {
    Object? body,
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    expect(path, '/api/v1/auth/register');
    sent = Map<String, dynamic>.from(body as Map);
    final now = DateTime.now().toUtc();
    return NetworkSuccess({
      'user': {'id': 42, 'phone': '19900115001', 'role': 'user'},
      'access_token': 'fictional-access',
      'refresh_token': 'fictional-refresh',
      'session_retention': {
        'user_id': 42,
        'device_id': sent!['device_id'],
        'session_id': 'registration-family',
        'login_at': now.toIso8601String(),
        'server_now': now.toIso8601String(),
        'online_expires_at': now
            .add(const Duration(days: 15))
            .toIso8601String(),
        'purge_at': now.add(const Duration(days: 30)).toIso8601String(),
      },
    });
  }
}

void main() {
  test(
    'registration consumes returned session with device binding and no identity claims',
    () async {
      SharedPreferences.setMockInitialValues({});
      final secure = MemorySecure();
      final api = RegistrationApi();
      final repository = AuthRepositoryImpl(
        remote: AuthRemoteDataSource(apiClient: api, useMockAuth: false),
        local: AuthLocalDataSource(
          secureStorage: secure,
          localStorage: LocalStorageService(secureStorage: secure),
        ),
        mapper: const AuthMapper(),
      );
      final session = await repository.register(
        phone: '19900115001',
        password: 'Fictional115pass',
      );
      expect(session.user.id, 42);
      expect(session.accessToken, 'fictional-access');
      expect(api.sent!['device_id'], isNotEmpty);
      expect(api.sent!.containsKey('realname_verified'), false);
      expect(api.sent!.containsKey('birthday'), false);
      expect(PrivateCacheService.forStorage(secure).accountId, 42);
    },
  );
}

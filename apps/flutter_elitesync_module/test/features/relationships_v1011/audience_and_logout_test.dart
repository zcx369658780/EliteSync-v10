import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/storage/secure_storage_service.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/pending_logout_store.dart';
import 'package:flutter_elitesync_module/features/status/data/datasource/status_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/status/domain/entities/status_post_entity.dart';

class _Secure extends SecureStorageService {
  final values = <String, String>{};
  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }
}

class _Api extends ApiClient {
  _Api() : super(dio: Dio());
  Object? sent;
  @override
  Future<NetworkResult<Map<String, dynamic>>> post(
    String path, {
    Object? body,
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    sent = body;
    return NetworkSuccess({
      'item': {'id': 1, 'audience': (body as Map)['audience']},
    });
  }
}

void main() {
  test(
    'pending logout queue preserves other accounts and migrates legacy credential',
    () async {
      final secure = _Secure();
      secure.values['pending_logout_token'] = 'legacy';
      await Future.wait([
        PendingLogoutStore.add(secure, 'a'),
        PendingLogoutStore.add(secure, 'b'),
      ]);
      await PendingLogoutStore.remove(secure, 'a');
      expect(await PendingLogoutStore.read(secure), ['legacy', 'b']);
      expect(secure.values.containsKey('pending_logout_token'), false);
    },
  );
  test('new post defaults SELF and explicit FRIENDS reaches server', () async {
    final api = _Api();
    final source = StatusRemoteDataSource(apiClient: api, useMock: false);
    await source.createStatusPost(title: 't', body: 'b');
    expect((api.sent as Map)['audience'], 'SELF');
    final result = await source.createStatusPost(
      title: 't',
      body: 'b',
      audience: 'FRIENDS',
    );
    expect((api.sent as Map)['audience'], 'FRIENDS');
    expect(result.visibilityLabel, '双向好友可见');
    expect(
      StatusPostEntity.fromJson({'visibility': 'public'}).audience,
      'SELF',
    );
  });
}

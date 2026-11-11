import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/features/profile/data/datasource/profile_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

class _Adapter implements HttpClientAdapter {
  final calls = <RequestOptions>[];
  String name = '新昵称';
  int postStatus = 200;
  int getStatus = 200;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancelFuture,
  ) async {
    calls.add(options);
    final status = options.method == 'POST' ? postStatus : getStatus;
    return ResponseBody.fromString(
      jsonEncode(
        status == 200 ? {'ok': true, 'name': name} : {'message': '拒绝请求'},
      ),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _Adapter adapter;
  late ProfileRemoteDataSource remote;
  setUp(() {
    adapter = _Adapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://fictional.invalid'));
    dio.httpClientAdapter = adapter;
    remote = ProfileRemoteDataSource(
      apiClient: ApiClient(dio: dio),
      useMock: false,
    );
  });
  test(
    'nickname only mutation and fresh readback need no birth inputs',
    () async {
      final confirmed = await remote.saveNickname(' 新昵称 ');
      expect(confirmed.nickname, '新昵称');
      expect(adapter.calls.map((r) => '${r.method} ${r.path}'), [
        'POST /api/v1/profile/nickname',
        'GET /api/v1/profile/basic',
      ]);
      expect(adapter.calls.first.data, {'name': '新昵称'});
    },
  );
  test('blank or oversized nickname makes no request', () async {
    for (final name in ['', '   ', List.filled(256, '名').join()]) {
      await expectLater(remote.saveNickname(name), throwsArgumentError);
    }
    expect(adapter.calls, isEmpty);
  });
  test('post rejection never confirms or reads', () async {
    adapter.postStatus = 403;
    await expectLater(remote.saveNickname('新昵称'), throwsException);
    expect(adapter.calls.length, 1);
  });
  test('failed or mismatched readback cannot confirm draft', () async {
    adapter.getStatus = 500;
    await expectLater(remote.saveNickname('新昵称'), throwsException);
    adapter.getStatus = 200;
    adapter.name = '旧昵称';
    await expectLater(remote.saveNickname('新昵称'), throwsStateError);
  });
  test('mock cannot perform nickname mutation', () async {
    final mock = ProfileRemoteDataSource(
      apiClient: ApiClient(dio: Dio()),
      useMock: true,
    );
    await expectLater(mock.saveNickname('新昵称'), throwsStateError);
  });
}

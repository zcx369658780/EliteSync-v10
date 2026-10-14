import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/features/profile/data/datasource/profile_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

class _Adapter implements HttpClientAdapter {
  final calls = <RequestOptions>[];
  bool connectionFails = false;
  int postStatus = 200;
  int getStatus = 200;
  String city = '新城市';
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancelFuture,
  ) async {
    calls.add(options);
    if (connectionFails) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );
    }
    final status = options.method == 'POST' ? postStatus : getStatus;
    return ResponseBody.fromString(
      jsonEncode(
        status == 200
            ? {'city': city, 'nickname': '虚构用户'}
            : {'message': '拒绝请求'},
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
    'city save sends only city and reads fresh basic profile, never full save',
    () async {
      final detail = await remote.saveCity(' 新城市 ');
      expect(detail.city, '新城市');
      expect(adapter.calls.map((r) => '${r.method} ${r.path}'), [
        'POST /api/v1/profile/city',
        'GET /api/v1/profile/basic',
      ]);
      expect(adapter.calls.first.data, {'city': '新城市'});
    },
  );
  test('connection failure cannot be reported as saved', () async {
    adapter.connectionFails = true;
    await expectLater(remote.saveCity('新城市'), throwsException);
    expect(adapter.calls.length, 1);
  });
  test('invalid cities perform no request', () async {
    for (final city in ['', '   ', List.filled(65, '城').join()]) {
      await expectLater(remote.saveCity(city), throwsArgumentError);
    }
    expect(adapter.calls, isEmpty);
  });
  for (final status in [401, 403, 422, 500]) {
    test('POST $status is failure and never reads or confirms cache', () async {
      adapter.postStatus = status;
      await expectLater(remote.saveCity('新城市'), throwsException);
      expect(adapter.calls.length, 1);
    });
  }
  test('failed readback does not confirm successful POST', () async {
    adapter.getStatus = 403;
    await expectLater(remote.saveCity('新城市'), throwsException);
    expect(adapter.calls.length, 2);
  });
  test(
    'mismatching readback fails rather than using submitted draft',
    () async {
      adapter.city = '旧城市';
      await expectLater(remote.saveCity('新城市'), throwsStateError);
    },
  );
  test('mock is explicitly rejected for city mutation', () async {
    final mock = ProfileRemoteDataSource(
      apiClient: ApiClient(dio: Dio()),
      useMock: true,
    );
    await expectLater(mock.saveCity('新城市'), throwsStateError);
    expect(adapter.calls, isEmpty);
  });
}

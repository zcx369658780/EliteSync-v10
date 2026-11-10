import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/core/logging/app_logger.dart';
import 'package:flutter_elitesync_module/core/network/api_transport_policy.dart';
import 'package:flutter_elitesync_module/core/network/dio_factory.dart';

AppEnv _env(String base, {bool dev = false}) => AppEnv(
  flavor: dev ? AppFlavor.dev : AppFlavor.prod,
  appName: 'transport-test',
  apiBaseUrl: base,
  useMockData: false,
);

class _Adapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  int status = 200;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      '{"ok":true}',
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
        if (status == 302) 'location': ['http://other.invalid/stolen'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('HTTPS base is normalized and keeps its path', () {
    expect(
      validateApiBaseUrl('HTTPS://API.EXAMPLE.COM/v1'),
      'https://api.example.com/v1/',
    );
    expect(
      validateApiBaseUrl('https://api.example.com:443/'),
      'https://api.example.com/',
    );
  });

  for (final host in ['127.0.0.1', 'localhost', '[::1]', '10.0.2.2']) {
    test('HTTP $host requires explicit development mode', () {
      final url = 'http://$host:8080/api';
      expect(() => validateApiBaseUrl(url), throwsFormatException);
      expect(validateApiBaseUrl(url, allowLocalInsecure: true), '$url/');
    });
  }

  for (final value in [
    '',
    '/api',
    'https:///api',
    'ftp://api.example.com',
    'http://api.example.com',
    'http://localhost.evil.invalid',
    'http://127.0.0.2',
    'http://192.168.1.5',
    'https://user:pass@api.example.com',
    'https://@api.example.com',
    'https://api.example.com?key=value',
    'https://api.example.com#fragment',
    'https://api.example.com:',
    'https://api.example.com:0',
    'https://api.example.com:65536',
    'https://api.example.com:wrong',
    'https://api.example.com/a b',
    r'https://api.example.com\other',
  ]) {
    test('rejects invalid base $value', () {
      expect(
        () => validateApiBaseUrl(value, allowLocalInsecure: true),
        throwsFormatException,
      );
    });
  }

  test('invalid factory base fails without token lookup', () {
    var tokens = 0;
    expect(
      () => DioFactory(
        env: _env('http://localhost'),
        logger: const AppLogger(enableDebugLogs: false),
        accessTokenProvider: () async {
          tokens++;
          return 'synthetic';
        },
      ).create(),
      throwsFormatException,
    );
    expect(tokens, 0);
  });

  for (final target in [
    'https://other.invalid/api',
    'http://api.example.com/api',
    'https://api.example.com:444/api',
    '//other.invalid/api',
    'https://user@api.example.com/api',
    'https://@api.example.com/api',
    'https://api.example.com:/api',
    'ftp://api.example.com/api',
    r'https://api.example.com\@other.invalid/api',
  ]) {
    test(
      'rejects off-origin $target before credentials and transport',
      () async {
        var tokens = 0;
        final adapter = _Adapter();
        final dio = DioFactory(
          env: _env('https://api.example.com'),
          logger: const AppLogger(enableDebugLogs: false),
          accessTokenProvider: () async {
            tokens++;
            return 'synthetic';
          },
        ).create()..httpClientAdapter = adapter;
        addTearDown(() => dio.close(force: true));
        await expectLater(
          dio.get<dynamic>(target),
          throwsA(isA<DioException>()),
        );
        expect(tokens, 0);
        expect(adapter.requests, isEmpty);
      },
    );
  }

  test('mutating base URL cannot change configured origin', () async {
    var tokens = 0;
    final adapter = _Adapter();
    final dio = DioFactory(
      env: _env('https://api.example.com'),
      logger: const AppLogger(enableDebugLogs: false),
      accessTokenProvider: () async {
        tokens++;
        return 'synthetic';
      },
    ).create()..httpClientAdapter = adapter;
    addTearDown(() => dio.close(force: true));
    dio.options.baseUrl = 'https://other.invalid';
    await expectLater(dio.get<dynamic>('/api'), throwsA(isA<DioException>()));
    expect(tokens, 0);
    expect(adapter.requests, isEmpty);
  });

  for (final base in ['https://api.example.com', 'http://10.0.2.2:8080']) {
    test('approved origin $base permits queries and authentication', () async {
      var tokens = 0;
      final adapter = _Adapter();
      final dio = DioFactory(
        env: _env(base, dev: base.startsWith('http:')),
        logger: const AppLogger(enableDebugLogs: false),
        accessTokenProvider: () async {
          tokens++;
          return 'synthetic';
        },
      ).create()..httpClientAdapter = adapter;
      addTearDown(() => dio.close(force: true));
      await dio.get<dynamic>(
        '/api/messages',
        queryParameters: {'cursor': 'a+b'},
      );
      expect(tokens, 1);
      expect(adapter.requests.single.uri.queryParameters['cursor'], 'a+b');
      expect(
        adapter.requests.single.headers['Authorization'],
        'Bearer synthetic',
      );
    });
  }

  test('request cannot opt into redirects, including a downgrade', () async {
    final adapter = _Adapter()..status = 302;
    final dio = DioFactory(
      env: _env('https://api.example.com'),
      logger: const AppLogger(enableDebugLogs: false),
      accessTokenProvider: () async => 'synthetic',
    ).create()..httpClientAdapter = adapter;
    addTearDown(() => dio.close(force: true));
    await expectLater(
      dio.get<dynamic>(
        '/api',
        options: Options(
          followRedirects: true,
          maxRedirects: 10,
          validateStatus: (_) => true,
        ),
      ),
      throwsA(
        isA<DioException>().having(
          (error) => error.type,
          'type',
          DioExceptionType.badResponse,
        ),
      ),
    );
    expect(adapter.requests, hasLength(1));
    expect(adapter.requests.single.followRedirects, isFalse);
    expect(adapter.requests.single.maxRedirects, 0);
  });

  test(
    'bare restricted transport does not add credential or retry handlers',
    () async {
      final adapter = _Adapter();
      final dio = Dio()..httpClientAdapter = adapter;
      final initialInterceptorCount = dio.interceptors.length;
      addTearDown(() => dio.close(force: true));
      configureApiTransport(dio, env: _env('https://api.example.com'));
      configureApiTransport(dio, env: _env('https://api.example.com'));
      await dio.get<dynamic>('/api/revoke?receipt=synthetic');
      expect(adapter.requests, hasLength(1));
      expect(
        adapter.requests.single.headers.containsKey('Authorization'),
        isFalse,
      );
      expect(dio.interceptors, hasLength(initialInterceptorCount + 1));
    },
  );
}

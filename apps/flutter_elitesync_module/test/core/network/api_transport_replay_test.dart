import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/core/logging/app_logger.dart';
import 'package:flutter_elitesync_module/core/network/dio_factory.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/retry_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

ResponseBody _reply(int status) => ResponseBody.fromString(
  '{"ok":true}',
  status,
  headers: {
    Headers.contentTypeHeader: ['application/json'],
    if (status == 302) 'location': ['http://untrusted.invalid/stolen'],
  },
);

Never _connectionFailure(RequestOptions options) => throw DioException(
  requestOptions: options,
  type: DioExceptionType.connectionError,
);

class _Adapter implements HttpClientAdapter {
  _Adapter(this.respond);
  final FutureOr<ResponseBody> Function(RequestOptions options, int call)
  respond;
  int calls = 0;
  final authorizations = <Object?>[];
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    authorizations.add(options.headers['Authorization']);
    return respond(options, calls);
  }

  @override
  void close({bool force = false}) {}
}

Dio _factory(
  _Adapter adapter, {
  RefreshAccessToken? refresh,
  String Function()? identity,
  AccessTokenProvider? token,
}) => DioFactory(
  env: const AppEnv(
    flavor: AppFlavor.prod,
    appName: 'replay test',
    apiBaseUrl: 'https://api.example.com',
    useMockData: false,
  ),
  logger: const AppLogger(enableDebugLogs: false),
  accessTokenProvider: token ?? () async => 'synthetic-old',
  refreshAccessToken: refresh,
  sessionIdentity: identity,
).create()..httpClientAdapter = adapter;

void main() {
  test(
    'replay follows adapter replacement instead of retaining an old pool',
    () async {
      final replacement = _Adapter((_, _) => _reply(200));
      late Dio dio;
      final initial = _Adapter((options, _) {
        dio.httpClientAdapter = replacement;
        _connectionFailure(options);
      });
      dio = _factory(initial);
      addTearDown(() => dio.close(force: true));
      final result = await dio.get<dynamic>('/api/v1/public/bootstrap');
      expect(result.statusCode, 200);
      expect(initial.calls, 1);
      expect(replacement.calls, 1);
      expect(replacement.authorizations, ['Bearer synthetic-old']);
    },
  );

  test(
    'GET retries once on the current shared adapter, without reauth',
    () async {
      var tokens = 0;
      final adapter = _Adapter((options, call) {
        if (call == 1) _connectionFailure(options);
        return _reply(200);
      });
      final dio = _factory(
        adapter,
        token: () async {
          tokens++;
          return 'synthetic-old';
        },
      );
      addTearDown(() => dio.close(force: true));
      final result = await dio.get<dynamic>('/api/v1/public/bootstrap');
      expect(result.statusCode, 200);
      expect(adapter.calls, 2);
      expect(tokens, 1);
      expect(adapter.authorizations, [
        'Bearer synthetic-old',
        'Bearer synthetic-old',
      ]);
    },
  );

  test(
    'failed replay does not recursively increase original retry count',
    () async {
      final adapter = _Adapter((options, _) => _connectionFailure(options));
      final dio = _factory(adapter);
      addTearDown(() => dio.close(force: true));
      await expectLater(
        dio.get<dynamic>('/api/v1/public/bootstrap'),
        throwsA(isA<DioException>()),
      );
      expect(adapter.calls, 2);
    },
  );

  test('POST connection failure is never retried', () async {
    final adapter = _Adapter((options, _) => _connectionFailure(options));
    final dio = _factory(adapter);
    addTearDown(() => dio.close(force: true));
    await expectLater(
      dio.post<dynamic>('/api/v1/public/bootstrap'),
      throwsA(isA<DioException>()),
    );
    expect(adapter.calls, 1);
  });

  test(
    'refresh replay preserves new Bearer when token provider remains old',
    () async {
      var refreshes = 0;
      var tokens = 0;
      final adapter = _Adapter((_, call) => _reply(call == 1 ? 401 : 200));
      final dio = _factory(
        adapter,
        token: () async {
          tokens++;
          return 'synthetic-old';
        },
        refresh: () async {
          refreshes++;
          return 'synthetic-refreshed';
        },
      );
      addTearDown(() => dio.close(force: true));
      final result = await dio.get<dynamic>('/api/v1/public/bootstrap');
      expect(result.statusCode, 200);
      expect(tokens, 1);
      expect(refreshes, 1);
      expect(adapter.authorizations, [
        'Bearer synthetic-old',
        'Bearer synthetic-refreshed',
      ]);
    },
  );

  for (final refresh in [false, true]) {
    for (final mutation in ['host', 'port', 'scheme']) {
      test(
        '${refresh ? 'refresh' : 'retry'} replay rejects changed $mutation',
        () async {
          final adapter = _Adapter((options, call) {
            if (call > 1) return _reply(200);
            switch (mutation) {
              case 'host':
                options.path = 'https://untrusted.invalid/api';
              case 'port':
                options.baseUrl = 'https://api.example.com:444';
              case 'scheme':
                options.baseUrl = 'http://api.example.com';
            }
            options.followRedirects = true;
            options.maxRedirects = 10;
            if (refresh) return _reply(401);
            _connectionFailure(options);
          });
          final dio = _factory(
            adapter,
            refresh: () async => 'synthetic-refreshed',
          );
          addTearDown(() => dio.close(force: true));
          await expectLater(
            dio.get<dynamic>('/api/v1/public/bootstrap'),
            throwsA(isA<DioException>()),
          );
          expect(adapter.calls, 1);
        },
      );
    }
  }

  test(
    'replay cannot reenable redirects even with permissive status validation',
    () async {
      final adapter = _Adapter((options, call) {
        if (call == 1) {
          options.followRedirects = true;
          options.maxRedirects = 10;
          _connectionFailure(options);
        }
        expect(options.followRedirects, isFalse);
        expect(options.maxRedirects, 0);
        return _reply(302);
      });
      final dio = _factory(adapter);
      addTearDown(() => dio.close(force: true));
      await expectLater(
        dio.get<dynamic>(
          '/api/v1/public/bootstrap',
          options: Options(validateStatus: (_) => true),
        ),
        throwsA(isA<DioException>()),
      );
      expect(adapter.calls, 2);
    },
  );

  test('account switch during retry delay prevents late dispatch', () async {
    var identity = 'A';
    final firstFailure = Completer<void>();
    final adapter = _Adapter((options, _) {
      firstFailure.complete();
      _connectionFailure(options);
    });
    final dio = _factory(adapter, identity: () => identity);
    addTearDown(() => dio.close(force: true));
    final result = dio.get<dynamic>('/api/v1/public/bootstrap');
    final expectation = expectLater(
      result,
      throwsA(
        isA<DioException>().having(
          (error) => error.type,
          'type',
          DioExceptionType.cancel,
        ),
      ),
    );
    await firstFailure.future;
    identity = 'B';
    await expectation;
    expect(adapter.calls, 1);
  });

  test('account switch during refresh prevents late dispatch', () async {
    var identity = 'A';
    final refreshStarted = Completer<void>();
    final refreshed = Completer<String?>();
    final adapter = _Adapter((_, _) => _reply(401));
    final dio = _factory(
      adapter,
      identity: () => identity,
      refresh: () {
        refreshStarted.complete();
        return refreshed.future;
      },
    );
    addTearDown(() => dio.close(force: true));
    final result = dio.get<dynamic>('/api/v1/public/bootstrap');
    final expectation = expectLater(
      result,
      throwsA(
        isA<DioException>().having(
          (error) => error.type,
          'type',
          DioExceptionType.cancel,
        ),
      ),
    );
    await refreshStarted.future;
    identity = 'B';
    refreshed.complete('synthetic-refreshed');
    await expectation;
    expect(adapter.calls, 1);
  });

  for (final refresh in [false, true]) {
    test(
      '${refresh ? 'refresh' : 'retry'} replay response after switch is rejected',
      () async {
        var identity = 'A';
        final adapter = _Adapter((options, call) {
          if (call == 1) {
            if (refresh) return _reply(401);
            _connectionFailure(options);
          }
          identity = 'B';
          return _reply(200);
        });
        final dio = _factory(
          adapter,
          identity: () => identity,
          refresh: () async => 'synthetic-refreshed',
        );
        addTearDown(() => dio.close(force: true));
        await expectLater(
          dio.get<dynamic>('/api/v1/public/bootstrap'),
          throwsA(
            isA<DioException>().having(
              (error) => error.type,
              'type',
              DioExceptionType.cancel,
            ),
          ),
        );
        expect(adapter.calls, 2);
      },
    );
  }

  for (final refresh in [false, true]) {
    test(
      'standalone ${refresh ? 'auth' : 'retry'} without replay never uses bare Dio',
      () async {
        final adapter = _Adapter((options, _) {
          if (refresh) return _reply(401);
          _connectionFailure(options);
        });
        final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'))
          ..httpClientAdapter = adapter;
        dio.interceptors.add(
          refresh
              ? AuthInterceptor(
                  accessTokenProvider: () async => 'synthetic-old',
                  refreshAccessToken: () async => 'synthetic-refreshed',
                )
              : RetryInterceptor(),
        );
        addTearDown(() => dio.close(force: true));
        await expectLater(
          dio.get<dynamic>('/api/v1/public/bootstrap'),
          throwsA(isA<DioException>()),
        );
        expect(adapter.calls, 1);
      },
    );
  }
}

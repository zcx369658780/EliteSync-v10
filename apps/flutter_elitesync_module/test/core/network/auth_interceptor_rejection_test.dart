import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

class _Adapter implements HttpClientAdapter {
  int status = 401;
  bool disabled = false;
  void Function()? beforeResponse;
  RequestOptions? sent;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancelFuture,
  ) async {
    sent = options;
    beforeResponse?.call();
    return ResponseBody.fromString(
      jsonEncode({
        'message': 'fictional rejection',
        if (disabled) 'error': {'code': 'account_disabled'},
      }),
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
  late Dio dio;
  late _Adapter adapter;
  late String token;
  late List<String> rejected;
  bool callbackFails = false;
  bool tokenReadFails = false;
  setUp(() {
    token = 'fixture-old';
    rejected = [];
    callbackFails = false;
    tokenReadFails = false;
    adapter = _Adapter();
    dio = Dio(BaseOptions(baseUrl: 'http://fictional.invalid'))
      ..httpClientAdapter = adapter;
    dio.interceptors.add(
      AuthInterceptor(
        accessTokenProvider: () async {
          if (tokenReadFails) throw StateError('fixture secure read failure');
          return token;
        },
        onSessionRejected: (value) async {
          rejected.add(value);
          if (callbackFails) throw StateError('fixture storage failure');
        },
      ),
    );
  });
  tearDown(() => dio.close());
  for (final path in [
    '/api/v1/profile/basic',
    '/api/v1/profile/city',
    '/api/v1/auth/refresh',
    '/api/v1/account/sessions',
    '/api/v1/auth/account',
    '/api/v1/auth/logout-all',
    '/api/v1/connections/2',
    '/api/v1/social',
    '/api/v1/profile-peers/2',
    '/api/v1/privacy',
    '/api/v1/media/99/content',
    '/api/v1/notifications',
  ]) {
    test(
      '$path 401 rejects matching token and propagates original response',
      () async {
        await expectLater(
          dio.post(path).timeout(const Duration(seconds: 2)),
          throwsA(
            isA<DioException>().having(
              (e) => e.response?.statusCode,
              'status',
              401,
            ),
          ),
        );
        expect(rejected, ['fixture-old']);
        expect(adapter.sent?.headers['Authorization'], 'Bearer fixture-old');
      },
    );
  }
  test('account_disabled403 clears, ordinary permission403 does not', () async {
    adapter.status = 403;
    await expectLater(
      dio.get('/api/v1/profile/basic'),
      throwsA(isA<DioException>()),
    );
    expect(rejected, isEmpty);
    adapter.disabled = true;
    await expectLater(
      dio.get('/api/v1/profile/basic'),
      throwsA(isA<DioException>()),
    );
    expect(rejected, ['fixture-old']);
  });
  test('login422 and login403 do not reject existing session', () async {
    for (final status in [422, 403]) {
      adapter.status = status;
      adapter.disabled = true;
      await expectLater(
        dio.post('/api/v1/auth/login'),
        throwsA(isA<DioException>()),
      );
    }
    expect(rejected, isEmpty);
  });
  test('stale old-token rejection cannot clear new session', () async {
    adapter.beforeResponse = () => token = 'fixture-new';
    await expectLater(
      dio.get('/api/v1/profile/basic'),
      throwsA(isA<DioException>()),
    );
    expect(adapter.sent?.headers['Authorization'], 'Bearer fixture-old');
    expect(rejected, isEmpty);
  });
  test(
    'secure read failure after response still rejects and never hangs',
    () async {
      adapter.beforeResponse = () => tokenReadFails = true;
      await expectLater(
        dio.get('/api/v1/profile/basic').timeout(const Duration(seconds: 2)),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'status',
            401,
          ),
        ),
      );
      expect(rejected, ['fixture-old']);
    },
  );
  test(
    'callback storage failure completes with original Dio rejection, never hangs',
    () async {
      callbackFails = true;
      await expectLater(
        dio.get('/api/v1/profile/basic').timeout(const Duration(seconds: 2)),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'status',
            401,
          ),
        ),
      );
      expect(rejected, ['fixture-old']);
    },
  );
}

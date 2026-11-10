import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/core/logging/app_logger.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/dio_factory.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';

class _Adapter implements HttpClientAdapter {
  final entered = Completer<void>();
  final reply = Completer<void>();
  int requests = 0;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancelFuture,
  ) async {
    requests++;
    if (!entered.isCompleted) entered.complete();
    await reply.future;
    return ResponseBody.fromString(
      '{"private_body":"synthetic account A content"}',
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  for (final switchAccount in [false, true]) {
    test(
      'HTTP200 response ${switchAccount ? 'after account switch is rejected' : 'in the same session is accepted'}',
      () async {
        var identity = 'synthetic-account-A:session-1';
        final adapter = _Adapter();
        final dio = DioFactory(
          env: const AppEnv(
            flavor: AppFlavor.dev,
            appName: 'test',
            apiBaseUrl: 'http://unused.invalid',
            useMockData: false,
          ),
          logger: const AppLogger(enableDebugLogs: false),
          accessTokenProvider: () async => 'synthetic-token-only',
          sessionIdentity: () => identity,
        ).create()..httpClientAdapter = adapter;
        final response = ApiClient(dio: dio).get('/api/v1/messages');
        await adapter.entered.future;
        if (switchAccount) identity = 'synthetic-account-B:session-2';
        adapter.reply.complete();
        final result = await response;
        if (switchAccount) {
          expect(result, isA<NetworkFailure<Map<String, dynamic>>>());
          final failure = result as NetworkFailure<Map<String, dynamic>>;
          expect(failure.message, 'Request cancelled');
          expect(
            failure.error,
            isA<DioException>().having(
              (e) => e.type,
              'type',
              DioExceptionType.cancel,
            ),
          );
          expect(result.isSuccess, isFalse);
        } else {
          expect(
            (result as NetworkSuccess<Map<String, dynamic>>)
                .data['private_body'],
            'synthetic account A content',
          );
        }
        expect(adapter.requests, 1);
        dio.close(force: true);
      },
    );
  }

  test(
    'account switch while obtaining credentials prevents transport dispatch',
    () async {
      var identity = 'synthetic-account-A:session-1';
      final tokenRequested = Completer<void>();
      final token = Completer<String?>();
      final adapter = _Adapter();
      final dio = DioFactory(
        env: const AppEnv(
          flavor: AppFlavor.dev,
          appName: 'test',
          apiBaseUrl: 'http://unused.invalid',
          useMockData: false,
        ),
        logger: const AppLogger(enableDebugLogs: false),
        accessTokenProvider: () {
          tokenRequested.complete();
          return token.future;
        },
        sessionIdentity: () => identity,
      ).create()..httpClientAdapter = adapter;
      final request = ApiClient(dio: dio).get('/api/v1/media/1/content');
      await tokenRequested.future;
      identity = 'synthetic-account-B:session-2';
      token.complete('synthetic-obsolete-token');
      expect(await request, isA<NetworkFailure<Map<String, dynamic>>>());
      expect(adapter.requests, 0);
      dio.close(force: true);
    },
  );
}

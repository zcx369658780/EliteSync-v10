import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/core/logging/app_logger.dart';
import 'package:flutter_elitesync_module/core/network/dio_factory.dart';
import 'package:flutter_test/flutter_test.dart';

class _PendingReplayAdapter implements HttpClientAdapter {
  _PendingReplayAdapter(this.refresh);
  final bool refresh;
  final entered = Completer<void>();
  final release = Completer<void>();
  final authorizations = <Object?>[];
  int requests = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? body,
    Future<void>? cancel,
  ) async {
    requests++;
    authorizations.add(options.headers['Authorization']);
    if (requests == 1) {
      if (refresh) return ResponseBody.fromString('{}', 401);
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );
    }
    // The real factory replay must use this same adapter and transport policy.
    expect(options.followRedirects, isFalse);
    expect(options.maxRedirects, 0);
    expect(options.uri.origin, 'https://api.example.com');
    entered.complete();
    await release.future;
    return ResponseBody.fromString(
      '{"private":"account-A"}',
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
  for (final refresh in [false, true]) {
    for (final switched in [false, true]) {
      test(
        '${refresh ? 'refresh' : 'GET network'} retry '
        '${switched ? 'rejects switched account' : 'permits current account'}',
        () async {
          var epoch = 1;
          var tokenReads = 0;
          var refreshes = 0;
          final adapter = _PendingReplayAdapter(refresh);
          final dio = DioFactory(
            env: const AppEnv(
              flavor: AppFlavor.prod,
              appName: 'Session replay test',
              apiBaseUrl: 'https://api.example.com',
              useMockData: false,
            ),
            logger: const AppLogger(enableDebugLogs: false),
            accessTokenProvider: () async {
              tokenReads++;
              return 'synthetic-token';
            },
            sessionIdentity: () => '$epoch',
            refreshAccessToken: refresh
                ? () async {
                    refreshes++;
                    return 'synthetic-new-token';
                  }
                : null,
          ).create()..httpClientAdapter = adapter;
          try {
            final future = dio.get<dynamic>('/retry-test');
            final assertion = switched
                ? expectLater(
                    future,
                    throwsA(
                      isA<DioException>().having(
                        (error) => error.type,
                        'type',
                        DioExceptionType.cancel,
                      ),
                    ),
                  )
                : expectLater(
                    future,
                    completion(
                      isA<Response<dynamic>>().having(
                        (response) => response.data,
                        'account-scoped body',
                        {'private': 'account-A'},
                      ),
                    ),
                  );
            await adapter.entered.future.timeout(const Duration(seconds: 2));
            // Preserve the original late-response boundary: the replay has
            // already been dispatched, but account A's data is still pending.
            if (switched) epoch = 2;
            adapter.release.complete();
            await assertion;
            expect(adapter.requests, 2);
            expect(tokenReads, 1);
            expect(refreshes, refresh ? 1 : 0);
            expect(adapter.authorizations, [
              'Bearer synthetic-token',
              refresh ? 'Bearer synthetic-new-token' : 'Bearer synthetic-token',
            ]);
          } finally {
            if (!adapter.release.isCompleted) adapter.release.complete();
            dio.close(force: true);
          }
        },
      );
    }
  }
}

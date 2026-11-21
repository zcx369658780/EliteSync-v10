import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/app/config/chat_socket_endpoint.dart';
import 'package:flutter_elitesync_module/core/network/api_transport_policy.dart';
import 'package:flutter_elitesync_module/features/chat/data/datasource/chat_socket_data_source.dart';
import 'package:flutter_elitesync_module/main_dev.dart' as dev;
import 'package:flutter_elitesync_module/main_prod.dart' as prod;

void main() {
  final certificate = Platform.environment['ELITESYNC_FUNCTION_TLS_DER'];
  test(
    'V2 HTTPS uses the fixture trust anchor and refuses other origins',
    () async {
      final bound = Dio();
      final defaults = Dio();
      addTearDown(bound.close);
      addTearDown(defaults.close);
      AppEnv env(String? tls) => AppEnv(
        flavor: AppFlavor.dev,
        appName: 'V2 function',
        apiBaseUrl: functionApiOrigin,
        useMockData: false,
        functionTlsCertificate: tls,
      );
      configureApiTransport(bound, env: env(certificate!));
      configureApiTransport(defaults, env: env(null));
      final options = Options(validateStatus: (status) => status == 401);
      expect(
        (await bound.get<void>(
          '/api/v1/profile/basic',
          options: options,
        )).statusCode,
        401,
      );
      await expectLater(
        bound.get<void>(
          'https://different-origin.invalid/api/v1/profile/basic',
        ),
        throwsA(
          isA<DioException>().having(
            (e) => e.type,
            'type',
            DioExceptionType.cancel,
          ),
        ),
      );
      await expectLater(
        defaults.get<void>('/api/v1/profile/basic', options: options),
        throwsA(
          isA<DioException>().having(
            (e) => e.response,
            'HTTP response',
            isNull,
          ),
        ),
      );
    },
    skip: certificate == null,
  );

  test(
    'V2 cold start requires the same explicit HTTPS endpoint on both sides',
    () {
      const fixture = 'https://127.0.0.1:18444/';
      expect(
        prod.resolveApiBaseUrl(
          hostBootstrap: {'apiBaseUrl': fixture},
          functionBuild: true,
          compiledOrigin: fixture,
        ),
        fixture,
      );
      for (final origin in [
        '',
        'http://127.0.0.1:18444/',
        'https://api.example.invalid/',
      ]) {
        expect(
          () => prod.resolveApiBaseUrl(
            hostBootstrap: {'apiBaseUrl': origin},
            functionBuild: true,
            compiledOrigin: fixture,
          ),
          throwsStateError,
        );
        expect(
          () => prod.resolveApiBaseUrl(
            hostBootstrap: {'apiBaseUrl': fixture},
            functionBuild: true,
            compiledOrigin: origin,
          ),
          throwsStateError,
        );
      }
    },
  );
  test(
    'dev file bootstrap and explicit environment wire the separate local gateway',
    () {
      expect(
        dev.resolveDevWsBaseUrl(
          apiBaseUrl: 'http://127.0.0.1:49572/',
          fileBootstrap: {'elitesync_ws_base_url': 'ws://127.0.0.1:49573'},
          environmentOverride: '',
        ),
        'ws://127.0.0.1:49573',
      );
      expect(
        dev.resolveDevWsBaseUrl(
          apiBaseUrl: 'http://127.0.0.1:49572/',
          fileBootstrap: {'elitesync_ws_base_url': 'ws://127.0.0.1:49573'},
          environmentOverride: 'ws://127.0.0.1:49574',
        ),
        'ws://127.0.0.1:49574',
      );
    },
  );
  test('prod host bootstrap keeps WSS authority and non-default port', () {
    expect(
      prod.resolveWsBaseUrl(
        apiBaseUrl: 'https://api.example.invalid:8443/',
        hostBootstrap: {'wsBaseUrl': 'wss://api.example.invalid:9443'},
        flavor: AppFlavor.prod,
        environmentOverride: '',
      ),
      'wss://api.example.invalid:9443',
    );
    expect(
      resolveChatSocketBaseUrl(apiBaseUrl: 'https://api.example.invalid:8443/'),
      'wss://api.example.invalid:8443',
    );
  });
  test('local restoration through prod entry requires actual dev flavor', () {
    expect(
      prod.resolveWsBaseUrl(
        apiBaseUrl: 'http://127.0.0.1:49572/',
        hostBootstrap: {'wsBaseUrl': 'ws://127.0.0.1:49573'},
        flavor: AppFlavor.dev,
        environmentOverride: '',
      ),
      'ws://127.0.0.1:49573',
    );
    expect(
      () => prod.resolveWsBaseUrl(
        apiBaseUrl: 'http://127.0.0.1:49572/',
        hostBootstrap: {'wsBaseUrl': 'ws://127.0.0.1:49573'},
        flavor: AppFlavor.prod,
        environmentOverride: '',
      ),
      throwsStateError,
    );
  });
  for (final bad in [
    'ws://api.example.invalid',
    'wss://other.example.invalid',
    'wss://a@api.example.invalid',
    'wss://api.example.invalid/?token=x',
    'wss://api.example.invalid/#x',
    'https://api.example.invalid',
    'wss://api.example.invalid/custom',
  ]) {
    test('reject unsafe endpoint $bad before bearer dispatch', () {
      expect(
        () => resolveChatSocketBaseUrl(
          apiBaseUrl: 'https://api.example.invalid/',
          override: bad,
        ),
        throwsStateError,
      );
    });
  }
  test('unqualified legacy public HTTP cannot infer a bearer destination', () {
    expect(
      resolveChatSocketBaseUrl(apiBaseUrl: 'http://legacy.example.invalid/'),
      '',
    );
    expect(
      () => buildChatSocketUri(
        apiBaseUrl: 'http://legacy.example.invalid/',
        selfId: 1,
        peerId: 2,
      ),
      throwsStateError,
    );
    expect(
      () => resolveChatSocketBaseUrl(
        apiBaseUrl: 'http://legacy.example.invalid/',
        override: 'ws://legacy.example.invalid',
        allowLocalInsecure: true,
      ),
      throwsStateError,
    );
  });
  test('local fallback preserves its documented socket port and peer URI', () {
    final uri = buildChatSocketUri(
      apiBaseUrl: 'http://127.0.0.1:49572/',
      selfId: 1,
      peerId: 2,
    );
    expect(uri.port, 8081);
    expect(uri.path, '/api/v1/messages/ws/1');
    expect(uri.queryParameters, {'peer_id': '2'});
  });
  test('malformed API and actor do not silently fall back to localhost', () {
    for (final api in [
      'not a URL',
      'https://a@api.example.invalid/',
      'ftp://api.example.invalid',
    ]) {
      expect(
        () => buildChatSocketUri(apiBaseUrl: api, selfId: 1),
        throwsStateError,
      );
    }
    expect(
      () => buildChatSocketUri(
        apiBaseUrl: 'https://api.example.invalid/',
        selfId: 0,
      ),
      throwsStateError,
    );
  });
}

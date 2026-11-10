import 'dart:async';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_elitesync_module/features/rtc/data/datasource/rtc_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/entities/rtc_session_entity.dart';
import 'package:flutter_elitesync_module/features/rtc/presentation/providers/rtc_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'rtc_test_session.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.respond);
  final Future<ResponseBody> Function(RequestOptions) respond;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancelFuture,
  ) => respond(options);
  @override
  void close({bool force = false}) {}
}

class _PendingSource extends RtcRemoteDataSource {
  _PendingSource() : super(apiClient: ApiClient(dio: Dio()));
  final calls = <Completer<RtcSessionEntity>>[];
  @override
  Future<RtcSessionEntity> fetchCall(int id) {
    final request = Completer<RtcSessionEntity>();
    calls.add(request);
    return request.future;
  }
}

void main() {
  final actions = <String, Future<Object?> Function(RtcRemoteDataSource)>{
    'list': (s) => s.fetchCalls(),
    'fetch': (s) => s.fetchCall(71),
    'create': (s) => s.createCall(peerUserId: 2),
    'accept': (s) => s.acceptCall(71),
    'connect': (s) => s.connectCall(71),
    'reject': (s) => s.rejectCall(71),
    'end': (s) => s.endCall(71),
    'heartbeat': (s) => s.heartbeatCall(71),
    'join': (s) => s.fetchLiveKitJoinInfo(71),
  };
  for (final entry in actions.entries) {
    test(
      'RTC ${entry.key} started by A never sends B credentials after suspended token read',
      () async {
        var current = true;
        var sent = 0;
        final tokenRead = Completer<String?>();
        final tokenStarted = Completer<void>();
        final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
        dio.interceptors.add(
          AuthInterceptor(
            accessTokenProvider: () {
              tokenStarted.complete();
              return tokenRead.future;
            },
          ),
        );
        dio.httpClientAdapter = _Adapter((_) async {
          sent++;
          return ResponseBody.fromString('{}', 200);
        });
        final source = RtcRemoteDataSource(
          apiClient: ApiClient(dio: dio),
          isCurrent: () => current,
        );
        final assertion = expectLater(entry.value(source), throwsA(anything));
        await tokenStarted.future;
        // Account B is also a participant of call 71; that never grants A's old action.
        current = false;
        tokenRead.complete('B-fixture-token');
        await assertion;
        expect(sent, 0);
        dio.close();
      },
    );
    test(
      'RTC ${entry.key} rejects late A response after session changes',
      () async {
        var current = true;
        final sent = Completer<void>();
        final response = Completer<ResponseBody>();
        final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
        dio.httpClientAdapter = _Adapter((_) {
          sent.complete();
          return response.future;
        });
        final source = RtcRemoteDataSource(
          apiClient: ApiClient(dio: dio),
          isCurrent: () => current,
        );
        final assertion = expectLater(
          entry.value(source),
          throwsA(isA<StateError>()),
        );
        await sent.future;
        current = false;
        response.complete(
          ResponseBody.fromString(
            '{"items":[],"session":{"id":71},"livekit":{}}',
            200,
            headers: {
              'content-type': ['application/json'],
            },
          ),
        );
        await assertion;
        dio.close();
      },
    );
  }
  test(
    'call provider does not publish late A projection into B for the same call',
    () async {
      final source = _PendingSource();
      final container = ProviderContainer(
        overrides: [
          sessionProvider.overrideWith(RtcTestSession.new),
          rtcRemoteDataSourceProvider.overrideWithValue(source),
        ],
      );
      addTearDown(container.dispose);
      await container.read(sessionProvider.future);
      final subscription = container.listen(rtcCallProvider(71), (_, _) {});
      addTearDown(subscription.close);
      await Future<void>.delayed(Duration.zero);
      expect(source.calls, hasLength(1));
      (container.read(sessionProvider.notifier) as RtcTestSession).change(2);
      await Future<void>.delayed(Duration.zero);
      expect(source.calls, hasLength(2));
      expect(container.read(rtcCallProvider(71)).isLoading, true);
      source.calls[1].complete(
        RtcSessionEntity.fromJson({'id': 71, 'title': 'B_CURRENT'}),
      );
      await container.read(rtcCallProvider(71).future);
      source.calls[0].complete(
        RtcSessionEntity.fromJson({'id': 71, 'title': 'A_PRIVATE'}),
      );
      await Future<void>.delayed(Duration.zero);
      expect(
        container.read(rtcCallProvider(71)).asData?.value.title,
        'B_CURRENT',
      );
    },
  );
}

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/features/rtc/data/datasource/rtc_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/entities/rtc_livekit_join_info_entity.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/services/rtc_livekit_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _DeniedRtcSource extends RtcRemoteDataSource {
  _DeniedRtcSource({this.unavailable = false})
    : super(apiClient: ApiClient(dio: Dio()));
  final bool unavailable;
  int requests = 0;

  @override
  Future<RtcLiveKitJoinInfoEntity> fetchLiveKitJoinInfo(int callId) async {
    requests++;
    if (!unavailable) throw StateError('permission denied');
    return RtcLiveKitJoinInfoEntity.fromJson({'enabled': false});
  }
}

class _PendingRtcSource extends _DeniedRtcSource {
  final reply = Completer<RtcLiveKitJoinInfoEntity>();

  @override
  Future<RtcLiveKitJoinInfoEntity> fetchLiveKitJoinInfo(int callId) =>
      reply.future;
}

RtcLiveKitService _service(_DeniedRtcSource source, {bool enabled = true}) =>
    RtcLiveKitService(
      remoteDataSource: source,
      appEnv: AppEnv(
        flavor: AppFlavor.dev,
        appName: 'RTC unit test',
        apiBaseUrl: 'http://127.0.0.1',
        useMockData: false,
        useLiveKitRtc: enabled,
      ),
    );

void main() {
  test('disabled RTC does not request join credentials', () async {
    final source = _DeniedRtcSource();
    final service = _service(source, enabled: false);
    await service.ensureConnected(1);
    expect(source.requests, 0);
    expect(service.isConnected, false);
    service.dispose();
  });

  test('authorization failure never creates a media connection', () async {
    final source = _DeniedRtcSource();
    final service = _service(source);
    await expectLater(service.ensureConnected(1), throwsStateError);
    expect(source.requests, 1);
    expect(service.isConnected, false);
    expect(service.connectedCallId, isNull);
    expect(service.localVideoTrack, isNull);
    expect(service.remoteVideoTrack, isNull);
    expect(service.failureMessage, isNotNull);
    service.dispose();
  });

  test(
    'unavailable join information fails closed before device capture',
    () async {
      final service = _service(_DeniedRtcSource(unavailable: true));
      await expectLater(service.ensureConnected(1), throwsStateError);
      expect(service.isConnected, false);
      expect(service.cameraEnabled, false);
      expect(service.remoteAudioTrack, isNull);
      service.dispose();
    },
  );
  test(
    'leaving during credential request prevents late device capture',
    () async {
      final source = _PendingRtcSource();
      final service = _service(source);
      final connection = service.ensureConnected(19);
      await service.leave(callId: 19);
      source.reply.complete(
        RtcLiveKitJoinInfoEntity.fromJson({
          'enabled': true,
          'url': 'ws://127.0.0.1',
          'token': 'unit-test-placeholder',
          'mode': 'video',
        }),
      );
      await connection;
      expect(service.isConnected, false);
      expect(service.connectedCallId, isNull);
      expect(service.cameraEnabled, false);
      service.dispose();
    },
  );
}

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
import 'package:livekit_client/livekit_client.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/core/audio/communication_audio_focus.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/features/rtc/data/datasource/rtc_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/entities/rtc_livekit_join_info_entity.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/services/rtc_livekit_service.dart';

class _ReadySource extends RtcRemoteDataSource {
  _ReadySource() : super(apiClient: ApiClient(dio: Dio()));

  @override
  Future<RtcLiveKitJoinInfoEntity> fetchLiveKitJoinInfo(int callId) async =>
      const RtcLiveKitJoinInfoEntity(
        enabled: true,
        url: 'ws://127.0.0.1:7880',
        token: 'fixture-join-token',
        roomName: 'fixture-room',
        identity: 'fixture-user',
        participantName: 'Fixture',
        mode: 'voice',
        expiresAt: '',
      );
}

/// The injected initial room is released before Android engine initialization.
/// Cancellation returns before a real Room or native capture can be created.
class _InitialRoom implements Room {
  @override
  final events = EventsEmitter<RoomEvent>();

  @override
  LocalParticipant? get localParticipant => null;

  @override
  void removeListener(VoidCallback listener) {}

  @override
  Future<void> disconnect() async {}

  @override
  Future<bool> dispose() async {
    await events.dispose();
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'capture cancellation during Android initialization releases RTC audio focus',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      webrtc.WebRTC.initialized = false;
      const channel = MethodChannel('FlutterWebRTC.Method');
      final started = Completer<void>();
      final initialization = Completer<void>();
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'initialize');
        if (!started.isCompleted) started.complete();
        await initialization.future;
        return null;
      });
      final service = RtcLiveKitService.mediaControlTest(
        remoteDataSource: _ReadySource(),
        appEnv: const AppEnv(
          flavor: AppFlavor.dev,
          appName: 'Audio focus cancellation fixture',
          apiBaseUrl: 'http://127.0.0.1',
          useMockData: false,
          useLiveKitRtc: true,
        ),
        room: _InitialRoom(),
        microphonePermission: () async => true,
        cameraPermission: () async => true,
      );
      addTearDown(() async {
        if (!initialization.isCompleted) initialization.complete();
        await service.leave();
        service.dispose();
        webrtc.WebRTC.initialized = false;
        debugDefaultTargetPlatformOverride = null;
        messenger.setMockMethodCallHandler(channel, null);
      });
      final connecting = service.ensureConnected(42);
      await started.future.timeout(const Duration(seconds: 2));
      expect(service.isConnecting, isTrue);
      expect(service.connectedCallId, isNull);
      expect(CommunicationAudioFocus.voiceAllowed, isFalse);
      await service.suspendCapture();
      initialization.complete();
      await connecting;
      expect(service.isConnecting, isFalse);
      expect(service.connectedCallId, isNull);
      await service.leave(callId: 42);
      expect(CommunicationAudioFocus.voiceAllowed, isTrue);
      final voiceOwner = Object();
      expect(
        await CommunicationAudioFocus.claimVoice(voiceOwner, () async {}),
        isTrue,
      );
      CommunicationAudioFocus.releaseVoice(voiceOwner);
    },
  );
}

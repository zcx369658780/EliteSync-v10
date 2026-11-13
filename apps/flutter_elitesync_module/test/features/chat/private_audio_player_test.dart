import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/audio/communication_audio_focus.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/widgets/private_audio_player.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

class _Session extends SessionNotifier {
  @override
  SessionState build() => const SessionState(
    status: AuthStatus.authenticated,
    accessToken: 'fixture-audio-session',
  );
}

class _RangeAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromBytes(
      [0],
      206,
      headers: {
        'content-type': ['audio/mp4'],
        'content-range': ['bytes 0-0/1000'],
        'content-length': ['1'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'native playback failure releases audio and shows stopped feedback',
    (tester) async {
      const channel = MethodChannel('elitesync/voice_memo');
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      final calls = <MethodCall>[];
      var playbackFailed = false;
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        return {
          'recording': false,
          'previewPath': null,
          'durationMs': 0,
          'sizeBytes': 0,
          'recordingElapsedMs': 0,
          'playbackState': call.method == 'play' ? 'playing' : 'idle',
          'positionMs': 0,
          'playbackDurationMs': 2000,
          'errorCode': call.method == 'status' && playbackFailed
              ? 'playback_failed'
              : null,
        };
      });
      final adapter = _RangeAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8021'))
        ..httpClientAdapter = adapter;
      dio.interceptors.add(
        AuthInterceptor(
          accessTokenProvider: () async => 'fixture-audio-session',
        ),
      );
      final container = ProviderContainer(
        overrides: [
          sessionProvider.overrideWith(_Session.new),
          dioProvider.overrideWithValue(dio),
        ],
      );
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox());
        await tester.pump();
        container.dispose();
        dio.close();
        messenger.setMockMethodCallHandler(channel, null);
      });
      await container.read(sessionProvider.future);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: PrivateAudioPlayer(assetId: 42)),
          ),
        ),
      );
      expect(calls, isEmpty);
      expect(find.text('播放'), findsOneWidget);
      await tester.tap(find.text('播放'));
      for (var frame = 0; frame < 10; frame++) {
        await tester.pump(const Duration(milliseconds: 10));
      }
      expect(adapter.requests, hasLength(1));
      expect(adapter.requests.single.path, '/api/v1/media/42/content');
      expect(adapter.requests.single.headers['Range'], 'bytes=0-0');
      expect(
        adapter.requests.single.headers['Authorization'],
        'Bearer fixture-audio-session',
      );
      final play = calls.singleWhere((call) => call.method == 'play');
      expect(play.arguments, {
        'source': 'http://127.0.0.1:8021/api/v1/media/42/content',
        'headers': {'Authorization': 'Bearer fixture-audio-session'},
      });
      expect(find.text('暂停'), findsOneWidget);
      playbackFailed = true;
      await tester.pump(const Duration(milliseconds: 250));
      for (var frame = 0; frame < 5; frame++) {
        await tester.pump(const Duration(milliseconds: 10));
      }
      expect(calls.where((call) => call.method == 'status'), isNotEmpty);
      expect(calls.where((call) => call.method == 'release'), hasLength(1));
      expect(find.textContaining('语音已停止'), findsOneWidget);
      expect(find.text('播放'), findsNothing);
      expect(find.text('暂停'), findsNothing);
      expect(CommunicationAudioFocus.voiceAllowed, isTrue);
    },
  );
}

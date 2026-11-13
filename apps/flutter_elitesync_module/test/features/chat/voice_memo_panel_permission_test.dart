import 'dart:async';
import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_elitesync_module/core/audio/communication_audio_focus.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/widgets/voice_memo_panel.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

class _Session extends SessionNotifier {
  @override
  SessionState build() => const SessionState(
    status: AuthStatus.authenticated,
    accessToken: 'fixture-permission-session',
  );
}

class _AllowedApi extends ApiClient {
  _AllowedApi() : super(dio: Dio());
  int authorizations = 0;

  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    expect(path, '/api/v1/connections/17');
    authorizations++;
    return const NetworkSuccess({
      'peer_id': 17,
      'gates': {'live_read_allowed': true, 'live_send_allowed': true},
    });
  }
}

FilledButton _button(WidgetTester tester, String label) =>
    tester.widget<FilledButton>(
      find.ancestor(
        of: find.text(label),
        matching: find.byWidgetPredicate((widget) => widget is FilledButton),
      ),
    );

Future<void> _flush(WidgetTester tester) async {
  for (var frame = 0; frame < 5; frame++) {
    await tester.runAsync(() async {
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pump(const Duration(milliseconds: 10));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const permissionChannel = MethodChannel(
    'flutter.baseflow.com/permissions/methods',
  );
  const voiceChannel = MethodChannel('elitesync/voice_memo');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final permissionReplies = Queue<Completer<Map<int, int>>>();
  final voiceCalls = <MethodCall>[];
  var recording = false;

  setUpAll(() async {
    // Initialize the singleton's completed barrier outside a widget fake-time
    // zone so later test cases do not await another test's microtask queue.
    final owner = Object();
    await CommunicationAudioFocus.claimVoice(owner, () async {});
    CommunicationAudioFocus.releaseVoice(owner);
  });

  setUp(() {
    permissionReplies.clear();
    voiceCalls.clear();
    recording = false;
    messenger.setMockMethodCallHandler(permissionChannel, (call) async {
      expect(call.method, 'requestPermissions');
      expect(call.arguments, [Permission.microphone.value]);
      return permissionReplies.removeFirst().future;
    });
    messenger.setMockMethodCallHandler(voiceChannel, (call) async {
      voiceCalls.add(call);
      if (call.method == 'start') recording = true;
      if (call.method == 'release' || call.method == 'stop') recording = false;
      return {
        'recording': recording,
        'previewPath': null,
        'durationMs': 0,
        'sizeBytes': 0,
        'recordingElapsedMs': recording ? 100 : 0,
        'playbackState': 'idle',
        'positionMs': 0,
        'playbackDurationMs': 0,
        'errorCode': null,
      };
    });
  });

  Future<_AllowedApi> mount(WidgetTester tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    final api = _AllowedApi();
    final container = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith(_Session.new),
        apiClientProvider.overrideWithValue(api),
      ],
    );
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      await _flush(tester);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      container.dispose();
      messenger.setMockMethodCallHandler(permissionChannel, null);
      messenger.setMockMethodCallHandler(voiceChannel, null);
    });
    await container.read(sessionProvider.future);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: VoiceMemoPanel(
              peerId: 17,
              onSend: (_) async {
                fail('A permission response must not send a message');
              },
            ),
          ),
        ),
      ),
    );
    await _flush(tester);
    expect(
      _button(tester, '开始录制').onPressed,
      isNotNull,
      reason:
          'Panel did not finish initialization after ${api.authorizations} '
          'authorizations. Visible feedback: '
          '${tester.widgetList<Text>(find.byType(Text)).map((text) => text.data).toList()}',
    );
    return api;
  }

  testWidgets(
    'denial allows retry and grant waits for resumed before recording',
    (tester) async {
      final denied = Completer<Map<int, int>>();
      final granted = Completer<Map<int, int>>();
      permissionReplies.addAll([denied, granted]);
      final api = await mount(tester);
      await tester.tap(find.text('开始录制'));
      await tester.pump();
      denied.complete({
        Permission.microphone.value: PermissionStatus.denied.index,
      });
      await _flush(tester);
      expect(find.textContaining('麦克风权限未允许'), findsOneWidget);
      expect(_button(tester, '开始录制').onPressed, isNotNull);
      expect(voiceCalls.where((call) => call.method == 'start'), isEmpty);

      await tester.tap(find.text('开始录制'));
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      granted.complete({
        Permission.microphone.value: PermissionStatus.granted.index,
      });
      await _flush(tester);
      expect(voiceCalls.where((call) => call.method == 'start'), isEmpty);
      expect(api.authorizations, 1);
      expect(_button(tester, '开始录制').onPressed, isNull);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await _flush(tester);
      expect(api.authorizations, 2);
      expect(voiceCalls.where((call) => call.method == 'start'), hasLength(1));
      expect(find.text('停止录制'), findsOneWidget);
      expect(_button(tester, '停止录制').onPressed, isNotNull);
      expect(find.textContaining('正在录制'), findsOneWidget);
      expect(permissionReplies, isEmpty);
    },
  );

  testWidgets(
    'a granted result after background pause cannot start recording',
    (tester) async {
      final granted = Completer<Map<int, int>>();
      permissionReplies.add(granted);
      final api = await mount(tester);
      await tester.tap(find.text('开始录制'));
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      granted.complete({
        Permission.microphone.value: PermissionStatus.granted.index,
      });
      await _flush(tester);
      expect(voiceCalls.where((call) => call.method == 'start'), isEmpty);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await _flush(tester);
      expect(voiceCalls.where((call) => call.method == 'start'), isEmpty);
      expect(
        voiceCalls.where((call) => call.method == 'release'),
        hasLength(1),
      );
      expect(api.authorizations, 1);
      expect(find.textContaining('离开前台后语音已停止'), findsOneWidget);
      expect(find.text('开始录制'), findsNothing);
    },
  );
}

import 'package:flutter/services.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/services/rtc_android_audio_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('FlutterWebRTC.Method');
  final calls = <MethodCall>[];
  var rejectInitialization = false;

  setUp(() {
    calls.clear();
    rejectInitialization = false;
    webrtc.WebRTC.initialized = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (rejectInitialization) {
            throw PlatformException(code: 'audio_engine_unavailable');
          }
          return null;
        });
  });

  tearDown(() {
    webrtc.WebRTC.initialized = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('first Android voice engine requests software processing', () async {
    await initializeRtcAndroidAudioEngine();

    expect(calls, hasLength(1));
    expect(calls.single.method, 'initialize');
    expect(calls.single.arguments, {
      'options': {
        'bypassVoiceProcessing': false,
        'androidUseHardwareAudioProcessing': false,
      },
    });
    expect(webrtc.WebRTC.initialized, isTrue);
  });

  test(
    'later calls keep the existing engine without reinitializing it',
    () async {
      await initializeRtcAndroidAudioEngine();
      await initializeRtcAndroidAudioEngine();

      expect(calls, hasLength(1));
    },
  );

  test(
    'native initialization failure is surfaced without claiming success',
    () async {
      rejectInitialization = true;

      await expectLater(
        initializeRtcAndroidAudioEngine(),
        throwsA(isA<PlatformException>()),
      );

      expect(webrtc.WebRTC.initialized, isFalse);
    },
  );
}

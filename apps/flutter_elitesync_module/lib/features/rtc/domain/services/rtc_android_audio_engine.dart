import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;

/// Must run before the first Room creates the shared Android audio engine.
Future<void> initializeRtcAndroidAudioEngine() async {
  final alreadyInitialized = webrtc.WebRTC.initialized;
  // flutter_webrtc 1.6.0 exposes this initialization policy for devices with
  // unreliable platform AEC/NS. Keep WebRTC voice processing enabled.
  await webrtc.WebRTC.initialize(
    options: const {
      'bypassVoiceProcessing': false,
      'androidUseHardwareAudioProcessing': false,
    },
  );
  // A request/initialization receipt is not proof of effective native AEC.
  // Existing engines cannot be reconfigured by a later initialize() call.
  debugPrint(
    'RTC_AUDIO_ENGINE hardwareProcessingRequested=false '
    'engineWasAlreadyInitialized=$alreadyInitialized effectiveMode=unverified',
  );
}

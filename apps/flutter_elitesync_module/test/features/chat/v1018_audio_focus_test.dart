import 'dart:async';

import 'package:flutter_elitesync_module/core/audio/communication_audio_focus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final voiceOwners = <Object>[];
  final rtcOwners = <Object>[];

  Object voiceOwner() {
    final owner = Object();
    voiceOwners.add(owner);
    return owner;
  }

  Object rtcOwner() {
    final owner = Object();
    rtcOwners.add(owner);
    return owner;
  }

  tearDown(() {
    for (final owner in voiceOwners) {
      CommunicationAudioFocus.releaseVoice(owner);
    }
    for (final owner in rtcOwners) {
      CommunicationAudioFocus.releaseRtc(owner);
    }
    voiceOwners.clear();
    rtcOwners.clear();
  });

  test('RTC acquisition waits for the native voice stop future', () async {
    final stopped = Completer<void>();
    var stopCalls = 0;
    final voice = voiceOwner();
    final rtc = rtcOwner();
    expect(
      await CommunicationAudioFocus.claimVoice(voice, () {
        stopCalls++;
        return stopped.future;
      }),
      isTrue,
    );
    var rtcReady = false;
    final acquisition = CommunicationAudioFocus.acquireRtc(rtc).then((_) {
      rtcReady = true;
    });
    await Future<void>.delayed(Duration.zero);
    expect(stopCalls, 1);
    expect(rtcReady, isFalse);
    expect(CommunicationAudioFocus.voiceAllowed, isFalse);
    expect(CommunicationAudioFocus.ownsVoice(voice), isFalse);
    stopped.complete();
    await acquisition;
    expect(rtcReady, isTrue);
  });

  test('voice cannot claim resources while RTC owns audio', () async {
    final rtc = rtcOwner();
    await CommunicationAudioFocus.acquireRtc(rtc);
    final voice = voiceOwner();
    expect(
      await CommunicationAudioFocus.claimVoice(voice, () async {}),
      isFalse,
    );
    expect(CommunicationAudioFocus.ownsVoice(voice), isFalse);
  });

  test('voice is available only after the last RTC owner releases', () async {
    final first = rtcOwner();
    final second = rtcOwner();
    await CommunicationAudioFocus.acquireRtc(first);
    await CommunicationAudioFocus.acquireRtc(second);
    CommunicationAudioFocus.releaseRtc(first);
    expect(CommunicationAudioFocus.voiceAllowed, isFalse);
    CommunicationAudioFocus.releaseRtc(second);
    expect(CommunicationAudioFocus.voiceAllowed, isTrue);
    final voice = voiceOwner();
    expect(
      await CommunicationAudioFocus.claimVoice(voice, () async {}),
      isTrue,
    );
    expect(CommunicationAudioFocus.ownsVoice(voice), isTrue);
  });

  test(
    'the same voice owner does not stop itself or replace its callback',
    () async {
      final voice = voiceOwner();
      var originalStops = 0;
      var replacementStops = 0;
      expect(
        await CommunicationAudioFocus.claimVoice(voice, () async {
          originalStops++;
        }),
        isTrue,
      );
      expect(
        await CommunicationAudioFocus.claimVoice(voice, () async {
          replacementStops++;
        }),
        isTrue,
      );
      expect(originalStops, 0);
      expect(replacementStops, 0);
      await CommunicationAudioFocus.acquireRtc(rtcOwner());
      expect(originalStops, 1);
      expect(replacementStops, 0);
    },
  );

  test('an old owner release cannot cancel its replacement', () async {
    final first = voiceOwner();
    final second = voiceOwner();
    var stopped = 0;
    await CommunicationAudioFocus.claimVoice(first, () async {
      stopped++;
    });
    expect(
      await CommunicationAudioFocus.claimVoice(second, () async {}),
      isTrue,
    );
    expect(stopped, 1);
    CommunicationAudioFocus.releaseVoice(first);
    expect(CommunicationAudioFocus.ownsVoice(second), isTrue);
    expect(CommunicationAudioFocus.ownsVoice(first), isFalse);
  });

  test('concurrent RTC owners await the same pending native stop', () async {
    final stopped = Completer<void>();
    var stopCalls = 0;
    await CommunicationAudioFocus.claimVoice(voiceOwner(), () {
      stopCalls++;
      return stopped.future;
    });
    var ready = 0;
    final first = CommunicationAudioFocus.acquireRtc(rtcOwner()).then((_) {
      ready++;
    });
    final second = CommunicationAudioFocus.acquireRtc(rtcOwner()).then((_) {
      ready++;
    });
    await Future<void>.delayed(Duration.zero);
    expect(stopCalls, 1);
    expect(ready, 0);
    stopped.complete();
    await Future.wait([first, second]);
    expect(ready, 2);
  });
}

/// Serializes the shared native voice resources against current RTC owners.
class CommunicationAudioFocus {
  CommunicationAudioFocus._();

  static final Set<Object> rtcOwners = <Object>{};
  static Object? _voiceOwner;
  static Future<void> Function()? _stopVoice;
  static Future<void> _stoppingVoice = Future<void>.value();
  static int _generation = 0;

  static bool get voiceAllowed => rtcOwners.isEmpty;

  static bool ownsVoice(Object owner) =>
      voiceAllowed && identical(_voiceOwner, owner);

  static Future<bool> claimVoice(
    Object owner,
    Future<void> Function() stop,
  ) async {
    if (!voiceAllowed) return false;
    if (identical(_voiceOwner, owner)) return true;
    final generation = ++_generation;
    final previous = _stopVoice;
    _voiceOwner = null;
    _stopVoice = null;
    if (previous != null) {
      _stoppingVoice = _stoppingVoice.then((_) => previous());
    }
    await _stoppingVoice;
    if (!voiceAllowed || generation != _generation) return false;
    _voiceOwner = owner;
    _stopVoice = stop;
    return true;
  }

  static void releaseVoice(Object owner) {
    if (!identical(_voiceOwner, owner)) return;
    _voiceOwner = null;
    _stopVoice = null;
    _generation++;
  }

  static Future<void> acquireRtc(Object owner) async {
    rtcOwners.add(owner);
    _generation++;
    final stop = _stopVoice;
    _voiceOwner = null;
    _stopVoice = null;
    if (stop != null) {
      _stoppingVoice = _stoppingVoice.then((_) => stop());
    }
    await _stoppingVoice;
  }

  static void releaseRtc(Object owner) {
    rtcOwners.remove(owner);
  }
}

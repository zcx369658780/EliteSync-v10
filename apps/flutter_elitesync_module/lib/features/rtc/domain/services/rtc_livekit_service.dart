// ignore_for_file: invalid_use_of_internal_member

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/features/rtc/data/datasource/rtc_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/entities/rtc_livekit_join_info_entity.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/services/rtc_permission_service.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/services/rtc_android_audio_engine.dart';

class RtcLiveKitService extends ChangeNotifier {
  RtcLiveKitService({required this.remoteDataSource, required this.appEnv})
    : _microphonePermission = const PermissionHandlerRtcPermissionService()
          .ensureVoiceCallPermission,
      _cameraPermission =
          const PermissionHandlerRtcPermissionService().ensureCameraPermission;

  @visibleForTesting
  RtcLiveKitService.mediaControlTest({
    required this.remoteDataSource,
    required this.appEnv,
    required Room room,
    required Future<bool> Function() microphonePermission,
    required Future<bool> Function() cameraPermission,
  }) : _room = room,
       _microphonePermission = microphonePermission,
       _cameraPermission = cameraPermission;

  final Future<bool> Function() _microphonePermission;
  final Future<bool> Function() _cameraPermission;

  final RtcRemoteDataSource remoteDataSource;
  final AppEnv appEnv;

  Room? _room;
  int? _connectedCallId;
  bool _connecting = false;
  int? _pendingCallId;
  int _connectionGeneration = 0;
  bool _microphoneEnabled = true;
  bool _cameraEnabled = false;
  bool _frontCamera = true;
  bool _disposed = false;
  String? _failureMessage;

  bool get microphoneEnabled => _microphoneEnabled;
  bool get cameraEnabled => _cameraEnabled;
  String? get failureMessage => _failureMessage;
  LocalVideoTrack? get localVideoTrack {
    for (final publication
        in _room?.localParticipant?.videoTrackPublications ??
            <LocalTrackPublication<LocalVideoTrack>>[]) {
      if (!publication.muted) return publication.track;
    }
    return null;
  }

  VideoTrack? get remoteVideoTrack {
    for (final participant
        in _room?.remoteParticipants.values ?? <RemoteParticipant>[]) {
      for (final publication in participant.videoTrackPublications) {
        if (publication.subscribed && !publication.muted) {
          return publication.track;
        }
      }
    }
    return null;
  }

  void _mediaChanged() {
    if (!_disposed) notifyListeners();
  }

  Future<void> setMicrophoneEnabled(bool enabled) async {
    final room = _room;
    final participant = room?.localParticipant;
    final generation = _connectionGeneration;
    bool current() =>
        !_disposed &&
        generation == _connectionGeneration &&
        identical(_room, room);
    if (participant == null || !current()) return;
    if (enabled) {
      final granted = await _microphonePermission();
      if (!current()) return;
      if (!granted) throw StateError('需要麦克风权限');
    }
    if (!current()) return;
    await participant.setMicrophoneEnabled(enabled);
    if (!current()) return;
    _microphoneEnabled = enabled;
    _mediaChanged();
  }

  Future<void> setCameraEnabled(bool enabled) async {
    final room = _room;
    final participant = room?.localParticipant;
    final generation = _connectionGeneration;
    bool current() =>
        !_disposed &&
        generation == _connectionGeneration &&
        identical(_room, room);
    if (participant == null || !current()) return;
    if (enabled) {
      final granted = await _cameraPermission();
      if (!current()) return;
      if (!granted) throw StateError('需要摄像头权限');
    }
    if (!current()) return;
    await participant.setCameraEnabled(enabled);
    if (!current()) return;
    _cameraEnabled = enabled;
    _mediaChanged();
  }

  Future<void> switchCamera() async {
    final track = localVideoTrack;
    if (track == null) return;
    final nextFront = !_frontCamera;
    await track.setCameraPosition(
      nextFront ? CameraPosition.front : CameraPosition.back,
    );
    _frontCamera = nextFront;
    _mediaChanged();
  }

  Timer? _heartbeatTimer;
  Timer? _audioStatsTimer;
  CancelListenFunc? _cancelLocalAudioRenderer;
  bool _heartbeatInFlight = false;
  bool _audioPlaybackRetryRequested = false;
  bool _remoteAudioTrackFromEvent = false;
  AudioTrack? _remoteAudioTrack;
  String? _boundLocalAudioTrackId;
  final Stopwatch _audioDiagnosticClock = Stopwatch()..start();
  final Map<String, int> _localAudioLogAt = {};

  bool _shouldLogLocalAudioFrame(String trackId, String reason) {
    final key = '$trackId:$reason';
    final now = _audioDiagnosticClock.elapsedMilliseconds;
    final previous = _localAudioLogAt[key];
    if (previous != null && now - previous < 1000) return false;
    _localAudioLogAt[key] = now;
    return true;
  }

  bool get isEnabled => appEnv.useLiveKitRtc;
  bool get isConnecting => _connecting;
  bool get isConnected =>
      _room?.connectionState == ConnectionState.connected &&
      _connectedCallId != null;
  int? get connectedCallId => _connectedCallId;
  AudioTrack? get remoteAudioTrack => _remoteAudioTrack;

  String _platformLabel() => defaultTargetPlatform.name;

  void _logLifecycle(int? callId, String event) {
    debugPrint(
      'RTC_LIFECYCLE callId=${callId ?? -1} event=$event '
      'epochMs=${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  // Never log bearer material, even a prefix/suffix of a JWT or an SDK URL.
  void _logJoinInfo({
    required int callId,
    required RtcLiveKitJoinInfoEntity info,
  }) {
    debugPrint('RTC_LIVEKIT_JOIN_INFO callId=$callId mode=${info.mode}');
  }

  void _logRoomSnapshot(
    Room room, {
    required int callId,
    required String reason,
  }) {
    final localParticipant = room.localParticipant;
    debugPrint(
      'RTC_LIVEKIT_ROOM_SNAPSHOT '
      'device=${_platformLabel()} '
      'callId=$callId '
      'reason=$reason '
      'room=${room.name ?? "none"} '
      'remoteParticipants=${room.remoteParticipants.length} '
      'localAudioPubs=${localParticipant?.audioTrackPublications.length ?? 0} '
      'localVideoPubs=${localParticipant?.videoTrackPublications.length ?? 0}',
    );

    for (final participant in room.remoteParticipants.values) {
      final audioPubs = participant.audioTrackPublications
          .map((publication) {
            return 'sid=${publication.sid} kind=${publication.kind} source=${publication.source} '
                'subscribed=${publication.subscribed} muted=${publication.muted} '
                'track=${publication.track?.runtimeType}';
          })
          .join(' | ');
      debugPrint(
        'RTC_LIVEKIT_REMOTE_PARTICIPANT '
        'device=${_platformLabel()} '
        'callId=$callId '
        'identity=${participant.identity} '
        'sid=${participant.sid} '
        'state=${participant.state} '
        'isSpeaking=${participant.isSpeaking} '
        'audioLevel=${participant.audioLevel} '
        'audioPubs=${participant.audioTrackPublications.length} '
        '${audioPubs.isEmpty ? "" : audioPubs}',
      );
    }
  }

  void _startHeartbeat(int callId) {
    if (!isEnabled) return;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      unawaited(_sendHeartbeat(callId));
    });
    unawaited(_sendHeartbeat(callId));
  }

  Future<void> _sendHeartbeat(int callId) async {
    if (!isEnabled || _connectedCallId != callId) return;
    if (_heartbeatInFlight) return;
    _heartbeatInFlight = true;
    try {
      final session = await remoteDataSource.heartbeatCall(callId);
      debugPrint(
        'RTC_LIVEKIT_HEARTBEAT '
        'device=${_platformLabel()} '
        'callId=$callId '
        'status=${session.status} '
        'isTerminal=${session.isTerminal}',
      );
      if (session.isTerminal) {
        await leave(callId: callId);
      }
    } catch (error) {
      debugPrint(
        'RTC_LIVEKIT_HEARTBEAT_FAIL '
        'device=${_platformLabel()} '
        'callId=$callId '
        'errorType=${error.runtimeType}',
      );
      _failureMessage = '通话授权暂不可验证，媒体已关闭';
      await leave(callId: callId);
    } finally {
      _heartbeatInFlight = false;
    }
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _heartbeatInFlight = false;
  }

  void _startAudioStatsTimer(int callId) {
    _audioStatsTimer?.cancel();
    _audioStatsTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      unawaited(_logRemoteAudioStats(callId));
      unawaited(_logMediaStats(callId));
    });
    unawaited(_logRemoteAudioStats(callId));
  }

  void _stopAudioStatsTimer() {
    _audioStatsTimer?.cancel();
    _audioStatsTimer = null;
  }

  Future<void> _logMediaStats(int callId) async {
    final room = _room;
    if (room == null) return;
    for (final entry in {
      'outbound': room.engine.publisher?.pc,
      'inbound': room.engine.subscriber?.pc,
    }.entries) {
      try {
        final reports = await entry.value?.getStats();
        if (reports == null) continue;
        final selectedPairs = reports
            .where((r) => r.type == 'transport')
            .map((r) => r.values['selectedCandidatePairId'])
            .whereType<String>()
            .toSet();
        final byId = {for (final r in reports) r.id: r};
        for (final report in reports) {
          if (report.type == 'candidate-pair' &&
              (selectedPairs.contains(report.id) ||
                  report.values['selected'] == true ||
                  (report.values['nominated'] == true &&
                      report.values['state'] == 'succeeded'))) {
            final remote = byId[report.values['remoteCandidateId']]?.values;
            final protocol = remote?['protocol'];
            final transport = protocol == 'tcp' || protocol == 'udp'
                ? protocol
                : 'unknown';
            final address = remote?['address'] ?? remote?['ip'];
            final addressClass = address == null
                ? 'unknown'
                : address == '127.0.0.1' || address == '::1'
                ? 'loopback'
                : 'non_loopback';
            final selection = selectedPairs.contains(report.id)
                ? 'transport_selected'
                : report.values['selected'] == true
                ? 'selected_flag'
                : 'nominated_inference';
            // Log categories only; never expose candidate addresses, ports or IDs.
            debugPrint(
              'RTC_MEDIA_ICE callId=$callId direction=${entry.key} '
              'transport=$transport remoteAddressClass=$addressClass '
              'selection=$selection',
            );
          }
          if (report.type != '${entry.key}-rtp') continue;
          final v = report.values;
          // Explicit allowlist: exclude network candidates, addresses and credentials.
          debugPrint(
            'RTC_MEDIA_RTP callId=$callId direction=${entry.key} '
            'kind=${v['kind'] ?? v['mediaType']} bytes=${v['bytesSent'] ?? v['bytesReceived']} '
            'packets=${v['packetsSent'] ?? v['packetsReceived']} '
            'framesEncoded=${v['framesEncoded']} framesDecoded=${v['framesDecoded']} '
            'framesReceived=${v['framesReceived']} framesPerSecond=${v['framesPerSecond']}',
          );
        }
      } catch (error) {
        debugPrint(
          'RTC_MEDIA_STATS_UNAVAILABLE callId=$callId type=${error.runtimeType}',
        );
      }
    }
  }

  Future<void> _bindLocalAudioTrackDiagnostics(
    Room room, {
    required int callId,
    required String reason,
  }) async {
    final localParticipant = room.localParticipant;
    if (localParticipant == null) {
      if (!_shouldLogLocalAudioFrame('none', reason)) return;
      debugPrint(
        'RTC_LIVEKIT_LOCAL_AUDIO_FRAME '
        'device=${_platformLabel()} '
        'callId=$callId '
        'reason=$reason '
        'track=none '
        'localParticipant=none',
      );
      return;
    }

    AudioTrack? nextTrack;
    String? nextTrackId;
    for (final publication in localParticipant.audioTrackPublications) {
      final track = publication.track;
      if (track != null) {
        nextTrack = track;
        nextTrackId = track.mediaStreamTrack.id;
        break;
      }
    }

    if (nextTrack == null || nextTrackId == null) {
      if (!_shouldLogLocalAudioFrame('none', reason)) return;
      debugPrint(
        'RTC_LIVEKIT_LOCAL_AUDIO_FRAME '
        'device=${_platformLabel()} '
        'callId=$callId '
        'reason=$reason '
        'track=none '
        'audioPubs=${localParticipant.audioTrackPublications.length} '
        'boundTrack=${_boundLocalAudioTrackId ?? "none"}',
      );
      return;
    }

    if (_boundLocalAudioTrackId == nextTrackId) {
      return;
    }

    await _unbindLocalAudioTrackDiagnostics();
    _boundLocalAudioTrackId = nextTrackId;
    debugPrint(
      'RTC_LIVEKIT_LOCAL_AUDIO_BIND '
      'device=${_platformLabel()} '
      'callId=$callId '
      'reason=$reason '
      'trackId=$nextTrackId '
      'kind=${nextTrack.kind}',
    );

    try {
      _cancelLocalAudioRenderer = nextTrack.addAudioRenderer(
        onFrame: (frame) {
          if (!_shouldLogLocalAudioFrame(nextTrackId!, reason)) return;
          final sampleCount = frame.data.lengthInBytes ~/ 2;
          if (sampleCount <= 0) return;
          final samples = frame.data.buffer.asInt16List(
            frame.data.offsetInBytes,
            sampleCount,
          );
          final absAvg = samples.isEmpty
              ? 0.0
              : samples.fold<double>(
                      0.0,
                      (sum, sample) => sum + sample.abs().toDouble(),
                    ) /
                    samples.length /
                    32768.0;
          final peak = samples.isEmpty
              ? 0.0
              : samples
                        .map((sample) => sample.abs().toDouble())
                        .fold<double>(0.0, math.max) /
                    32768.0;
          {
            debugPrint(
              'RTC_LIVEKIT_LOCAL_AUDIO_FRAME '
              'device=${_platformLabel()} '
              'callId=$callId '
              'reason=$reason '
              'trackId=$nextTrackId '
              'sampleRate=${frame.sampleRate} '
              'channels=${frame.channels} '
              'bytes=${frame.data.lengthInBytes} '
              'absAvg=${absAvg.toStringAsFixed(4)} '
              'peak=${peak.toStringAsFixed(4)}',
            );
          }
        },
        options: const AudioRendererOptions(
          sampleRate: 24000,
          channels: 1,
          format: AudioFormat.Int16,
        ),
      );
    } catch (error) {
      debugPrint(
        'RTC_LIVEKIT_LOCAL_AUDIO_BIND_FAIL '
        'device=${_platformLabel()} '
        'callId=$callId '
        'reason=$reason '
        'trackId=$nextTrackId '
        'errorType=${error.runtimeType}',
      );
    }
  }

  Future<void> _unbindLocalAudioTrackDiagnostics() async {
    final cancel = _cancelLocalAudioRenderer;
    _cancelLocalAudioRenderer = null;
    _boundLocalAudioTrackId = null;
    if (cancel != null) {
      try {
        await cancel();
      } catch (_) {
        // best-effort only
      }
    }
  }

  Future<void> _logRemoteAudioStats(int callId) async {
    final room = _room;
    final track = _remoteAudioTrack;
    if (room == null) return;
    if (track == null) {
      debugPrint(
        'RTC_LIVEKIT_REMOTE_AUDIO_STATS '
        'device=${_platformLabel()} '
        'callId=$callId '
        'track=none '
        'remoteParticipants=${room.remoteParticipants.length}',
      );
      return;
    }

    final receiver = track.receiver;
    final trackId = track.mediaStreamTrack.id;
    final enabled = track.mediaStreamTrack.enabled;
    final muted = track.muted;
    final isActive = track.isActive;
    final receiverState = receiver == null ? 'none' : 'present';
    final trackLabel = track.mediaStreamTrack.label ?? 'unknown';
    final trackKind = track.mediaStreamTrack.kind ?? 'unknown';
    String statsSummary = 'stats=unavailable';

    if (receiver != null) {
      try {
        final reports = await receiver.getStats();
        for (final report in reports) {
          if (report.type == 'inbound-rtp') {
            final values = report.values;
            final bytesReceived = values['bytesReceived']?.toString();
            final packetsReceived = values['packetsReceived']?.toString();
            final totalAudioEnergy = values['totalAudioEnergy']?.toString();
            final totalSamplesDuration = values['totalSamplesDuration']
                ?.toString();
            statsSummary =
                'stats=inbound bytesReceived=$bytesReceived packetsReceived=$packetsReceived '
                'totalAudioEnergy=$totalAudioEnergy totalSamplesDuration=$totalSamplesDuration';
            break;
          }
        }
      } catch (error) {
        statsSummary = 'stats_error=${error.runtimeType}';
      }
    }

    debugPrint(
      'RTC_LIVEKIT_REMOTE_AUDIO_STATS '
      'device=${_platformLabel()} '
      'callId=$callId '
      'trackId=$trackId '
      'trackKind=$trackKind '
      'trackLabel=$trackLabel '
      'receiver=$receiverState '
      'enabled=$enabled '
      'muted=$muted '
      'active=$isActive '
      '$statsSummary',
    );
  }

  Future<void> _logPeerConnectionSnapshot(
    Room room, {
    required int callId,
    required String reason,
  }) async {
    Future<String> describePeer(dynamic pc) async {
      if (pc == null) return 'none';
      var signaling = 'unknown';
      try {
        signaling = (await pc.getSignalingState()).toString();
      } catch (error) {
        signaling = 'error:${error.runtimeType}';
      }
      return 'connection=${pc.connectionState} ice=${pc.iceConnectionState} signaling=$signaling';
    }

    final publisher = await describePeer(room.engine.publisher?.pc);
    final subscriber = await describePeer(room.engine.subscriber?.pc);
    debugPrint(
      'RTC_LIVEKIT_PEER_CONNECTION '
      'device=${_platformLabel()} '
      'callId=$callId '
      'reason=$reason '
      'roomConnection=${room.connectionState} '
      'engineConnection=${room.engine.connectionState} '
      'publisher={$publisher} '
      'subscriber={$subscriber}',
    );
  }

  Future<void> _ensureAudioPlayback(
    Room room, {
    required int callId,
    required String reason,
  }) async {
    try {
      try {
        await AudioManager.instance.setSpeakerOutputPreferred(
          true,
          force: true,
        );
      } catch (error) {
        debugPrint(
          'RTC_LIVEKIT_AUDIO_ROUTE_FORCE_FAIL '
          'device=${_platformLabel()} '
          'callId=$callId '
          'reason=$reason '
          'errorType=${error.runtimeType}',
        );
      }
      debugPrint(
        'RTC_LIVEKIT_AUDIO_PLAYBACK_START '
        'device=${_platformLabel()} '
        'callId=$callId '
        'reason=$reason '
        'canPlaybackBefore=${room.canPlaybackAudio}',
      );
      await room.startAudio();
      debugPrint(
        'RTC_LIVEKIT_AUDIO_PLAYBACK_READY '
        'device=${_platformLabel()} '
        'callId=$callId '
        'reason=$reason '
        'canPlaybackAfter=${room.canPlaybackAudio}',
      );
      _startAudioStatsTimer(callId);
    } catch (error) {
      debugPrint(
        'RTC_LIVEKIT_AUDIO_PLAYBACK_START_FAIL '
        'device=${_platformLabel()} '
        'callId=$callId '
        'reason=$reason '
        'errorType=${error.runtimeType}',
      );
    }
  }

  void _logLocalAudioSnapshot(
    Room room, {
    required int callId,
    required String reason,
  }) {
    final localParticipant = room.localParticipant;
    if (localParticipant == null) {
      debugPrint(
        'RTC_LIVEKIT_LOCAL_AUDIO '
        'device=${_platformLabel()} '
        'callId=$callId '
        'reason=$reason '
        'localParticipant=none',
      );
      return;
    }

    final pubs = localParticipant.audioTrackPublications
        .map((publication) {
          return 'sid=${publication.sid} source=${publication.source} muted=${publication.muted} '
              'subscribed=${publication.subscribed} track=${publication.track?.runtimeType}';
        })
        .join(' | ');

    debugPrint(
      'RTC_LIVEKIT_LOCAL_AUDIO '
      'device=${_platformLabel()} '
      'callId=$callId '
      'reason=$reason '
      'audioPubs=${localParticipant.audioTrackPublications.length} '
      '${pubs.isEmpty ? "" : pubs}',
    );
  }

  void _refreshRemoteAudioTrack(Room room, {String reason = 'unknown'}) {
    AudioTrack? nextTrack;
    String? nextParticipant;
    for (final participant in room.remoteParticipants.values) {
      for (final publication in participant.audioTrackPublications) {
        final track = publication.track;
        if (track != null && publication.subscribed) {
          nextTrack = track;
          nextParticipant = participant.identity;
          break;
        }
      }
      if (nextTrack != null) break;
    }

    final currentId = _remoteAudioTrack?.mediaStreamTrack.id;
    final nextId = nextTrack?.mediaStreamTrack.id;
    if (nextTrack == null) {
      debugPrint(
        'RTC_LIVEKIT_REMOTE_AUDIO_REFRESH reason=$reason '
        'device=${_platformLabel()} '
        'callId=${_connectedCallId ?? -1} '
        'participant=none '
        'trackId=${currentId ?? "none"} '
        'roomParticipants=${room.remoteParticipants.length} '
        'source=${_remoteAudioTrackFromEvent ? "event" : "scan"} '
        'preserved=${currentId != null ? "yes" : "no"}',
      );
      _remoteAudioTrack = null;
      _remoteAudioTrackFromEvent = false;
      if (currentId != null) _mediaChanged();
      return;
    }
    if (currentId == nextId) {
      return;
    }

    _remoteAudioTrack = nextTrack;
    _remoteAudioTrackFromEvent = false;
    debugPrint(
      'RTC_LIVEKIT_REMOTE_AUDIO_REFRESH reason=$reason '
      'device=${_platformLabel()} '
      'callId=${_connectedCallId ?? -1} '
      'participant=${nextParticipant ?? "none"} '
      'trackId=${nextId ?? "none"} '
      'roomParticipants=${room.remoteParticipants.length}',
    );
    _mediaChanged();
  }

  Future<void> ensureConnected(int callId) async {
    if (_disposed || !isEnabled || callId <= 0) return;
    if (_connectedCallId == callId && _room != null) return;
    if (_connecting) return;
    _connecting = true;
    _pendingCallId = callId;
    final requestedGeneration = _connectionGeneration;
    int? generation;
    try {
      final info = await _loadJoinInfo(callId);
      if (_disposed || requestedGeneration != _connectionGeneration) return;
      if (!info.isReady) throw StateError('通话服务当前不可用');
      if (!await _microphonePermission()) {
        throw StateError('需要麦克风权限');
      }
      if (info.mode == 'video' && !await _cameraPermission()) {
        throw StateError('需要摄像头权限');
      }
      if (_disposed || requestedGeneration != _connectionGeneration) return;
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        await initializeRtcAndroidAudioEngine();
        if (_disposed || requestedGeneration != _connectionGeneration) return;
      }
      _failureMessage = null;
      _logJoinInfo(callId: callId, info: info);
      final expectedAfterLeave = _connectionGeneration + 1;
      await leave();
      if (_disposed || _connectionGeneration != expectedAfterLeave) return;
      generation = _connectionGeneration;
      _connectedCallId = callId;
      debugPrint(
        'RTC_LIVEKIT_AUDIO_ROUTE_PRECONNECT '
        'device=${_platformLabel()} '
        'callId=$callId '
        'speakerOn=${AudioManager.instance.isSpeakerOutputPreferred} '
        'forceSpeaker=${AudioManager.instance.isSpeakerOutputForced}',
      );

      final room = Room(
        roomOptions: const RoomOptions(
          adaptiveStream: true,
          dynacast: true,
          // Keep AEC/NS enabled; AGC is enabled to support quiet speech. Android
          // engine policy is requested before the first Room is created.
          // https://docs.livekit.io/reference/client-sdk-flutter/livekit_client/AudioCaptureOptions-class.html
          defaultAudioCaptureOptions: AudioCaptureOptions(
            echoCancellation: true,
            noiseSuppression: true,
            autoGainControl: true,
            highPassFilter: true,
          ),
          defaultAudioOutputOptions: AudioOutputOptions(speakerOn: true),
        ),
      );
      _room = room;
      room.addListener(_mediaChanged);
      _startHeartbeat(callId);
      final connectOptions = ConnectOptions(
        // Explicit empty list prevents the SDK adopting SFU public STUN defaults.
        // Local restoration uses only the Owner-approved host candidate path.
        rtcConfiguration: appEnv.restorationLocalBuild
            ? const RTCConfiguration(iceServers: [])
            : const RTCConfiguration(),
        timeouts: const Timeouts(
          connection: Duration(seconds: 30),
          debounce: Duration(milliseconds: 20),
          publish: Duration(seconds: 30),
          subscribe: Duration(seconds: 30),
          peerConnection: Duration(seconds: 30),
          iceRestart: Duration(seconds: 30),
        ),
      );
      room.events
        ..on<RoomDisconnectedEvent>((event) {
          _logLifecycle(callId, 'room_disconnected');
          if (identical(_room, room)) unawaited(leave(callId: callId));
        })
        ..on<RoomReconnectingEvent>((event) {
          _logLifecycle(callId, 'room_reconnecting');
          // The trusted server gateway also re-authorizes every WS reconnect.
          unawaited(_sendHeartbeat(callId));
        })
        ..on<RoomReconnectedEvent>((event) {
          _logLifecycle(callId, 'room_reconnected');
          unawaited(_sendHeartbeat(callId));
          _mediaChanged();
        })
        ..on<RoomConnectedEvent>((event) {
          _refreshRemoteAudioTrack(room, reason: 'room_connected');
        })
        ..on<ParticipantConnectedEvent>((event) {
          _refreshRemoteAudioTrack(room, reason: 'participant_connected');
        })
        ..on<ParticipantDisconnectedEvent>((event) {
          _refreshRemoteAudioTrack(room, reason: 'participant_disconnected');
        })
        ..on<TrackSubscribedEvent>((event) {
          if (event.track is AudioTrack) {
            _remoteAudioTrack = event.track as AudioTrack;
            _remoteAudioTrackFromEvent = true;
            _mediaChanged();
            unawaited(
              _ensureAudioPlayback(
                room,
                callId: callId,
                reason: 'track_subscribed',
              ),
            );
          }
          unawaited(
            _logPeerConnectionSnapshot(
              room,
              callId: callId,
              reason: 'track_subscribed',
            ),
          );
          debugPrint(
            'RTC_LIVEKIT_TRACK_SUBSCRIBED callId=$callId '
            'device=${_platformLabel()} '
            'participant=${event.participant.identity} '
            'trackSid=${event.publication.sid} '
            'kind=${event.track.kind}',
          );
          _logRoomSnapshot(room, callId: callId, reason: 'track_subscribed');
        })
        ..on<TrackUnsubscribedEvent>((event) {
          if (_remoteAudioTrack?.mediaStreamTrack.id ==
              event.track.mediaStreamTrack.id) {
            _remoteAudioTrack = null;
            _remoteAudioTrackFromEvent = false;
            _mediaChanged();
          }
          _refreshRemoteAudioTrack(room, reason: 'track_unsubscribed');
        })
        ..on<TrackPublishedEvent>((event) {
          _refreshRemoteAudioTrack(room, reason: 'track_published');
          unawaited(
            _bindLocalAudioTrackDiagnostics(
              room,
              callId: callId,
              reason: 'track_published',
            ),
          );
        })
        ..on<TrackUnpublishedEvent>((event) {
          _refreshRemoteAudioTrack(room, reason: 'track_unpublished');
        })
        ..on<TrackMutedEvent>((event) {
          _refreshRemoteAudioTrack(room, reason: 'track_muted');
        })
        ..on<TrackUnmutedEvent>((event) {
          _refreshRemoteAudioTrack(room, reason: 'track_unmuted');
        })
        ..on<ParticipantStateUpdatedEvent>((event) {
          _refreshRemoteAudioTrack(room, reason: 'participant_state_updated');
        })
        ..on<AudioPlaybackStatusChanged>((event) {
          debugPrint(
            'RTC_LIVEKIT_AUDIO_PLAYBACK callId=$callId '
            'device=${_platformLabel()} '
            'isPlaying=${event.isPlaying} '
            'canPlayback=${room.canPlaybackAudio}',
          );
          if (!event.isPlaying && !_audioPlaybackRetryRequested) {
            _audioPlaybackRetryRequested = true;
            unawaited(
              Future<void>.delayed(const Duration(milliseconds: 300), () async {
                try {
                  await _ensureAudioPlayback(
                    room,
                    callId: callId,
                    reason: 'playback_status_retry',
                  );
                } finally {
                  _audioPlaybackRetryRequested = false;
                }
              }),
            );
          }
        })
        ..on<TrackSubscriptionExceptionEvent>((event) {
          debugPrint(
            'RTC_LIVEKIT_TRACK_SUBSCRIBE_FAILED callId=$callId '
            'device=${_platformLabel()} '
            'participant=${event.participant?.identity ?? "unknown"} '
            'trackSid=${event.sid} '
            'reason=${event.reason}',
          );
        });
      debugPrint(
        'RTC_LIVEKIT_CONNECT_TIMEOUTS '
        'device=${_platformLabel()} '
        'callId=$callId '
        'connection=30s publish=30s subscribe=30s '
        'peerConnection=30s iceRestart=30s',
      );
      debugPrint(
        'RTC_LIVEKIT_ROOM_CONNECT_START '
        'device=${_platformLabel()} '
        'callId=$callId '
        'room=${info.roomName} '
        'identity=${info.identity}',
      );
      await room.connect(info.url, info.token, connectOptions: connectOptions);
      if (generation != _connectionGeneration || !identical(_room, room)) {
        await room.disconnect();
        return;
      }
      debugPrint(
        'RTC_LIVEKIT_ROOM_CONNECT_OK '
        'device=${_platformLabel()} '
        'callId=$callId '
        'room=${room.name ?? info.roomName} '
        'remoteParticipants=${room.remoteParticipants.length}',
      );
      await _logPeerConnectionSnapshot(
        room,
        callId: callId,
        reason: 'after_connect',
      );
      _refreshRemoteAudioTrack(room, reason: 'after_connect');
      await _ensureAudioPlayback(room, callId: callId, reason: 'after_connect');
      debugPrint(
        'RTC_LIVEKIT_AUDIO_ROUTE '
        'device=${_platformLabel()} '
        'callId=$callId '
        'canPlaybackAudio=${room.canPlaybackAudio}',
      );
      _logLocalAudioSnapshot(room, callId: callId, reason: 'after_set_speaker');
      await room.localParticipant?.setMicrophoneEnabled(true);
      _microphoneEnabled = true;
      if (info.mode == 'video') {
        await room.localParticipant?.setCameraEnabled(true);
        _cameraEnabled = true;
      }
      if (generation != _connectionGeneration || !identical(_room, room)) {
        await room.disconnect();
        return;
      }
      _logLocalAudioSnapshot(
        room,
        callId: callId,
        reason: 'after_enable_microphone',
      );
      unawaited(
        _bindLocalAudioTrackDiagnostics(
          room,
          callId: callId,
          reason: 'after_enable_microphone',
        ),
      );

      _room = room;
      _connectedCallId = callId;
      _refreshRemoteAudioTrack(room, reason: 'after_enable_audio');
      unawaited(
        _bindLocalAudioTrackDiagnostics(
          room,
          callId: callId,
          reason: 'after_enable_audio',
        ),
      );
      _logRoomSnapshot(room, callId: callId, reason: 'after_enable_audio');
      _startHeartbeat(callId);
      _startAudioStatsTimer(callId);
      _mediaChanged();
    } catch (error) {
      _failureMessage ??= '通话连接失败，请检查权限及网络后重试';
      await leave(callId: callId);
      debugPrint(
        'RTC_LIVEKIT_ROOM_CONNECT_FAIL '
        'device=${_platformLabel()} '
        'callId=$callId '
        'errorType=${error.runtimeType}',
      );
      rethrow;
    } finally {
      _connecting = false;
      _pendingCallId = null;
    }
  }

  Future<void> leave({int? callId}) async {
    if (callId != null &&
        _connectedCallId != callId &&
        _pendingCallId != callId) {
      return;
    }
    final leavingCallId = callId ?? _connectedCallId ?? _pendingCallId;
    _connectionGeneration += 1;
    final room = _room;
    room?.removeListener(_mediaChanged);
    _room = null;
    _cameraEnabled = false;
    _connectedCallId = null;
    _remoteAudioTrack = null;
    _remoteAudioTrackFromEvent = false;
    _stopHeartbeat();
    _stopAudioStatsTimer();
    unawaited(_unbindLocalAudioTrackDiagnostics());
    _mediaChanged();
    if (room == null) {
      _logLifecycle(leavingCallId, 'leave_complete');
      return;
    }
    try {
      await room.disconnect();
      await room.dispose();
    } catch (_) {
      // leave should be best-effort only.
    }
    _logLifecycle(leavingCallId, 'leave_complete');
  }

  Future<RtcLiveKitJoinInfoEntity> _loadJoinInfo(int callId) =>
      remoteDataSource.fetchLiveKitJoinInfo(callId);

  @override
  void dispose() {
    _disposed = true;
    unawaited(leave());
    super.dispose();
  }
}

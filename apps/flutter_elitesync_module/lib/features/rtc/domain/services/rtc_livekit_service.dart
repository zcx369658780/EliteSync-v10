// ignore_for_file: invalid_use_of_internal_member

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/rtc_endpoint_policy.dart';
import 'package:flutter_elitesync_module/features/rtc/data/datasource/rtc_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/entities/rtc_livekit_join_info_entity.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/services/rtc_permission_service.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/services/rtc_android_audio_engine.dart';

class RtcLiveKitService extends ChangeNotifier {
  RtcLiveKitService({required this.remoteDataSource, required this.appEnv})
    : _setSpeakerRoute = AudioManager.instance.setSpeakerOutputPreferred,
      _startPlayback = _startRoomPlayback,
      _createCameraTrack = LocalVideoTrack.createCameraTrack,
      _createAudioTrack = LocalAudioTrack.create,
      _microphonePermission = const PermissionHandlerRtcPermissionService()
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
    Future<LocalVideoTrack> Function(CameraCaptureOptions)? cameraTrackFactory,
    Future<LocalAudioTrack> Function(AudioCaptureOptions)? audioTrackFactory,
    Future<void> Function(bool preferred, {bool force})? speakerRouteSetter,
    Future<bool> Function(Room room)? playbackStarter,
    int? callId,
  }) : _room = room,
       _connectedCallId = callId,
       _speakerPreferenceCallId = callId,
       _setSpeakerRoute =
           speakerRouteSetter ??
           AudioManager.instance.setSpeakerOutputPreferred,
       _startPlayback = playbackStarter ?? _startRoomPlayback,
       _createCameraTrack =
           cameraTrackFactory ?? LocalVideoTrack.createCameraTrack,
       _createAudioTrack = audioTrackFactory ?? LocalAudioTrack.create,
       _microphonePermission = microphonePermission,
       _cameraPermission = cameraPermission {
    _observeLocalPublications(room);
  }

  final Future<bool> Function() _microphonePermission;
  final Future<bool> Function() _cameraPermission;
  final Future<void> Function(bool preferred, {bool force}) _setSpeakerRoute;
  final Future<bool> Function(Room room) _startPlayback;
  final Future<LocalVideoTrack> Function(CameraCaptureOptions)
  _createCameraTrack;
  final Future<LocalAudioTrack> Function(AudioCaptureOptions) _createAudioTrack;
  // SDK reconnect temporarily clears publications before republishing tracks.
  final _localTracks = <LocalTrack, ({Room room, int captureGeneration})>{};
  Future<void> _cameraMutation = Future.value();
  Future<void> _microphoneMutation = Future.value();
  Future<void> _speakerMutation = Future.value();
  Future<void> _mediaOutputMutation = Future.value();
  Future<void>? _mediaOutputRetry;
  Future<void> _teardown = Future.value();
  Future<void> _captureStop = Future.value();
  int _captureGeneration = 0;
  bool _captureSuspended = false;

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
  bool _speakerOutputPreferred = true;
  int? _speakerPreferenceCallId;
  bool _disposed = false;
  String? _failureMessage;
  bool _speakerRouteFailed = false;
  bool _audioPlaybackFailed = false;
  static const _unknownMediaSubscription = '__unknown__';
  final _failedMediaSubscriptions = <String>{};

  bool get microphoneEnabled => _microphoneEnabled;
  bool get cameraEnabled => _cameraEnabled;
  bool get speakerOutputPreferred => _speakerOutputPreferred;
  bool get supportsSpeakerOutput =>
      isEnabled &&
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
  String? get failureMessage => _failureMessage;
  String? get mediaOutputFailureMessage {
    if (_speakerRouteFailed) return '声音输出切换失败，请重试。';
    if (_audioPlaybackFailed) return '声音播放暂不可用，请重试。';
    if (_failedMediaSubscriptions.isNotEmpty) {
      return '远端音视频接收暂不可用，请等待对方或重试。';
    }
    return null;
  }

  bool get isRetryingMediaOutput => _mediaOutputRetry != null;
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

  bool _ownsRoom(Room room, int generation) =>
      !_disposed &&
      generation == _connectionGeneration &&
      identical(_room, room);

  static Future<bool> _startRoomPlayback(Room room) async {
    await room.startAudio();
    return room.canPlaybackAudio;
  }

  @visibleForTesting
  void recordMediaPlaybackStatus(Room room, bool isPlaying) {
    if (!_ownsRoom(room, _connectionGeneration)) return;
    if (_audioPlaybackFailed == !isPlaying) return;
    _audioPlaybackFailed = !isPlaying;
    _mediaChanged();
  }

  @visibleForTesting
  void recordMediaSubscriptionFailure(Room room, String? sid) {
    if (!_ownsRoom(room, _connectionGeneration)) return;
    final key = sid == null || sid.isEmpty ? _unknownMediaSubscription : sid;
    if (_failedMediaSubscriptions.add(key)) _mediaChanged();
  }

  @visibleForTesting
  void recordMediaSubscriptionSuccess(Room room, String sid) {
    if (!_ownsRoom(room, _connectionGeneration) || sid.isEmpty) return;
    final removed = _failedMediaSubscriptions.remove(sid);
    final removedUnknown = _failedMediaSubscriptions.remove(
      _unknownMediaSubscription,
    );
    if (removed || removedUnknown) _mediaChanged();
  }

  @visibleForTesting
  void recordMediaSubscriptionUnpublished(Room room, String sid) {
    if (!_ownsRoom(room, _connectionGeneration)) return;
    if (_failedMediaSubscriptions.remove(sid)) _mediaChanged();
  }

  Future<void> retryMediaOutput(int callId) {
    final room = _room;
    if (_disposed ||
        !isEnabled ||
        room == null ||
        callId != _connectedCallId ||
        room.connectionState != ConnectionState.connected) {
      return Future.error(StateError('当前通话暂不可恢复声音'));
    }
    if (_mediaOutputRetry case final pending?) return pending;
    final retryAudioSubscription = _audioPlaybackFailed;
    final failedSubscriptions = Set<String>.of(_failedMediaSubscriptions);
    final retryUnknownSubscription = failedSubscriptions.contains(
      _unknownMediaSubscription,
    );
    final generation = _connectionGeneration;
    final captureGeneration = _captureGeneration;
    bool current() =>
        _ownsRoom(room, generation) &&
        captureGeneration == _captureGeneration &&
        callId == _connectedCallId &&
        room.connectionState == ConnectionState.connected;
    bool publicationIsCurrent(RemoteTrackPublication publication) =>
        room.remoteParticipants.values.any(
          (participant) => identical(
            participant.trackPublications[publication.sid],
            publication,
          ),
        );
    final operation = _mediaOutputMutation.then((_) async {
      if (!current()) return;
      await _restoreAudioOutput(
        room,
        callId: callId,
        reason: 'user_retry',
        generation: generation,
        captureGeneration: captureGeneration,
      );
      if (!current()) return;
      final publications = [
        for (final participant in room.remoteParticipants.values)
          for (final publication in participant.trackPublications.values)
            if ((publication.kind == TrackType.AUDIO ||
                    publication.kind == TrackType.VIDEO) &&
                (failedSubscriptions.contains(publication.sid) ||
                    (!publication.muted &&
                        (retryUnknownSubscription ||
                            (retryAudioSubscription &&
                                publication.kind == TrackType.AUDIO)))))
              publication,
      ];
      for (final publication in publications) {
        if (!current()) return;
        if (!publicationIsCurrent(publication)) continue;
        if (!publication.subscriptionAllowed) {
          recordMediaSubscriptionFailure(room, publication.sid);
          continue;
        }
        try {
          await publication.unsubscribe();
          if (!current()) return;
          if (!publicationIsCurrent(publication)) continue;
          if (!publication.subscriptionAllowed) {
            recordMediaSubscriptionFailure(room, publication.sid);
            continue;
          }
          // Sending a subscription request is not a received-track receipt.
          await publication.subscribe();
          if (!current()) return;
        } catch (error) {
          if (!current()) return;
          if (!publicationIsCurrent(publication)) continue;
          recordMediaSubscriptionFailure(room, publication.sid);
          debugPrint(
            'RTC_MEDIA_OUTPUT_SUBSCRIPTION_RETRY_FAIL '
            'callId=$callId errorType=${error.runtimeType}',
          );
        }
      }
    });
    _mediaOutputRetry = operation;
    void complete() {
      if (!identical(_mediaOutputRetry, operation)) return;
      _mediaOutputRetry = null;
      _mediaChanged();
    }

    _mediaOutputMutation = operation.then<void>(
      (_) => complete(),
      onError: (Object _, StackTrace _) => complete(),
    );
    _mediaChanged();
    return operation;
  }

  Future<void> setSpeakerOutputPreferred(bool preferred) async {
    if (!supportsSpeakerOutput) {
      throw UnsupportedError('当前设备不支持切换通话扬声器');
    }
    final room = _room;
    if (room == null || room.connectionState != ConnectionState.connected) {
      throw StateError('当前通话尚未连接');
    }
    await _applySpeakerOutput(
      room,
      generation: _connectionGeneration,
      captureGeneration: _captureGeneration,
      preferred: preferred,
    );
  }

  Future<void> _applySpeakerOutput(
    Room room, {
    required int generation,
    required int captureGeneration,
    bool? preferred,
  }) {
    bool current() =>
        _ownsRoom(room, generation) &&
        captureGeneration == _captureGeneration &&
        room.connectionState == ConnectionState.connected;
    final operation = _speakerMutation.then((_) async {
      if (!current()) return;
      // Playback retries resolve the last successful choice when they run.
      final selected = preferred ?? _speakerOutputPreferred;
      try {
        await _setSpeakerRoute(selected, force: selected);
      } catch (_) {
        if (current() && !_speakerRouteFailed) {
          _speakerRouteFailed = true;
          _mediaChanged();
        }
        rethrow;
      }
      if (!current()) return;
      final changed = _speakerRouteFailed || preferred != null;
      _speakerRouteFailed = false;
      if (preferred != null) _speakerOutputPreferred = selected;
      if (changed) _mediaChanged();
    });
    _speakerMutation = operation.then<void>((_) {}, onError: (Object _) {});
    return operation;
  }

  @visibleForTesting
  Future<void> reapplySpeakerOutput(Room room) => _applySpeakerOutput(
    room,
    generation: _connectionGeneration,
    captureGeneration: _captureGeneration,
  );

  Future<void> setMicrophoneEnabled(bool enabled) {
    final room = _room;
    final participant = room?.localParticipant;
    final generation = _connectionGeneration;
    final captureGeneration = _captureGeneration;
    if (enabled) _captureSuspended = false;
    bool current() =>
        !_disposed &&
        generation == _connectionGeneration &&
        captureGeneration == _captureGeneration &&
        identical(_room, room);
    final operation = _microphoneMutation.then((_) async {
      await _captureStop;
      if (participant == null || !current()) return;
      if (enabled) {
        final granted = await _microphonePermission();
        if (!current()) return;
        if (!granted) throw StateError('需要麦克风权限');
      }
      if (!current()) return;
      final existing = participant.getTrackPublicationBySource(
        TrackSource.microphone,
      );
      if (enabled &&
          existing != null &&
          !existing.muted &&
          existing.track?.isActive == true) {
        _microphoneEnabled = true;
        _mediaChanged();
        return;
      }
      if (!enabled) {
        await participant.setMicrophoneEnabled(false);
        if (!current()) return;
      } else {
        if (!await _removeLocalPublication(participant, existing, current)) {
          return;
        }
        final track = await _createAudioTrack(
          room!.roomOptions.defaultAudioCaptureOptions,
        );
        _localTracks[track] = (
          room: room,
          captureGeneration: captureGeneration,
        );
        var published = false;
        try {
          if (!current()) return;
          await participant.publishAudioTrack(track);
          if (!current()) return;
          published = true;
        } finally {
          if (!published) await _discardLocalTrack(room, track);
        }
      }
      _microphoneEnabled = enabled;
      _mediaChanged();
    });
    _microphoneMutation = operation.then<void>((_) {}, onError: (Object _) {});
    return operation;
  }

  Future<void> setCameraEnabled(bool enabled) {
    final room = _room;
    final participant = room?.localParticipant;
    final generation = _connectionGeneration;
    final captureGeneration = _captureGeneration;
    if (enabled) _captureSuspended = false;
    bool current() =>
        !_disposed &&
        generation == _connectionGeneration &&
        captureGeneration == _captureGeneration &&
        identical(_room, room);
    final operation = _cameraMutation.then((_) async {
      await _captureStop;
      if (participant == null || !current()) return;
      if (enabled) {
        final granted = await _cameraPermission();
        if (!current()) return;
        if (!granted) throw StateError('需要摄像头权限');
      }
      if (!current()) return;
      final existing = participant.getTrackPublicationBySource(
        TrackSource.camera,
      );
      if (enabled &&
          existing != null &&
          !existing.muted &&
          existing.track?.isActive == true) {
        _cameraEnabled = true;
        _mediaChanged();
        return;
      }
      if (!enabled) {
        await participant.setCameraEnabled(false);
        if (!current()) return;
      } else {
        if (!await _removeLocalPublication(participant, existing, current)) {
          return;
        }
        final captureOptions = room!.roomOptions.defaultCameraCaptureOptions;
        if (!await _publishCamera(room, participant, captureOptions, current)) {
          return;
        }
      }
      _cameraEnabled = enabled;
      _mediaChanged();
    });
    _cameraMutation = operation.then<void>((_) {}, onError: (Object _) {});
    return operation;
  }

  Future<void> switchCamera() {
    final room = _room;
    final generation = _connectionGeneration;
    final captureGeneration = _captureGeneration;
    bool current() =>
        room != null &&
        _ownsRoom(room, generation) &&
        captureGeneration == _captureGeneration &&
        !_captureSuspended;
    final operation = _cameraMutation.then((_) async {
      await _captureStop;
      if (!current()) return;
      final track = localVideoTrack;
      final participant = room!.localParticipant;
      if (track == null || participant == null) return;
      final options = track.currentOptions;
      if (options is! CameraCaptureOptions) return;
      final nextFront = !_frontCamera;
      _cameraEnabled = false;
      _mediaChanged();
      final existing = participant.getTrackPublicationBySource(
        TrackSource.camera,
      );
      if (!await _removeLocalPublication(participant, existing, current)) {
        return;
      }
      final nextOptions = CameraCaptureOptions(
        cameraPosition: nextFront ? CameraPosition.front : CameraPosition.back,
        deviceId: null,
        maxFrameRate: options.maxFrameRate,
        params: options.params,
      );
      if (!await _publishCamera(room, participant, nextOptions, current)) {
        return;
      }
      _cameraEnabled = true;
      _mediaChanged();
    });
    _cameraMutation = operation.then<void>((_) {}, onError: (Object _) {});
    return operation;
  }

  Future<bool> _removeLocalPublication(
    LocalParticipant participant,
    LocalTrackPublication? publication,
    bool Function() current,
  ) async {
    if (!current()) return false;
    if (publication == null) return true;
    final track = publication.track;
    if (track != null) await _suspendTrack(track);
    if (!current()) return false;
    await participant.removePublishedTrack(publication.sid);
    _localTracks.remove(track);
    return current();
  }

  Future<bool> _publishCamera(
    Room room,
    LocalParticipant participant,
    CameraCaptureOptions options,
    bool Function() current,
  ) async {
    if (!current()) return false;
    final track = await _createCameraTrack(options);
    _localTracks[track] = (room: room, captureGeneration: _captureGeneration);
    var published = false;
    try {
      if (!current()) return false;
      await participant.publishVideoTrack(track);
      if (!current()) return false;
      published = true;
      _frontCamera = options.cameraPosition == CameraPosition.front;
      return true;
    } finally {
      if (!published) await _discardLocalTrack(room, track);
    }
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
    if (_disposed || _connectedCallId != callId || _room == null) return;
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
    final generation = _connectionGeneration;
    if (!_ownsRoom(room, generation)) return;
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
    if (!_ownsRoom(room, generation)) return;
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
          if (!_ownsRoom(room, generation)) return;
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
  }) {
    final generation = _connectionGeneration;
    final captureGeneration = _captureGeneration;
    final operation = _mediaOutputMutation.then(
      (_) => _restoreAudioOutput(
        room,
        callId: callId,
        reason: reason,
        generation: generation,
        captureGeneration: captureGeneration,
      ),
    );
    _mediaOutputMutation = operation.then<void>((_) {}, onError: (Object _) {});
    return operation;
  }

  Future<void> _restoreAudioOutput(
    Room room, {
    required int callId,
    required String reason,
    required int generation,
    required int captureGeneration,
  }) async {
    bool current() =>
        _ownsRoom(room, generation) &&
        captureGeneration == _captureGeneration &&
        callId == _connectedCallId &&
        room.connectionState == ConnectionState.connected;
    if (!current()) return;
    try {
      try {
        await reapplySpeakerOutput(room);
      } catch (error) {
        debugPrint(
          'RTC_LIVEKIT_AUDIO_ROUTE_FORCE_FAIL '
          'device=${_platformLabel()} '
          'callId=$callId '
          'reason=$reason '
          'errorType=${error.runtimeType}',
        );
      }
      if (!current()) return;
      debugPrint(
        'RTC_LIVEKIT_AUDIO_PLAYBACK_START '
        'device=${_platformLabel()} '
        'callId=$callId '
        'reason=$reason '
        'lastPlaybackFailed=$_audioPlaybackFailed',
      );
      final playing = await _startPlayback(room);
      if (!current()) return;
      recordMediaPlaybackStatus(room, playing);
      debugPrint(
        'RTC_LIVEKIT_AUDIO_PLAYBACK_READY '
        'device=${_platformLabel()} '
        'callId=$callId '
        'reason=$reason '
        'canPlaybackAfter=$playing',
      );
      if (playing) _startAudioStatsTimer(callId);
    } catch (error) {
      if (!current()) return;
      recordMediaPlaybackStatus(room, false);
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
    if (!_ownsRoom(room, _connectionGeneration)) return;
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
    final captureGeneration = _captureGeneration;
    int? generation;
    try {
      final info = await _loadJoinInfo(callId);
      if (_disposed || requestedGeneration != _connectionGeneration) return;
      if (_captureSuspended || captureGeneration != _captureGeneration) return;
      if (!info.isReady) throw StateError('通话服务当前不可用');
      final gatewayUrl = validateRtcGatewayUrl(info.url, env: appEnv);
      if (!await _microphonePermission()) {
        throw StateError('需要麦克风权限');
      }
      if (_disposed || requestedGeneration != _connectionGeneration) return;
      if (_captureSuspended || captureGeneration != _captureGeneration) return;
      if (info.mode == 'video' && !await _cameraPermission()) {
        throw StateError('需要摄像头权限');
      }
      if (_disposed || requestedGeneration != _connectionGeneration) return;
      if (_captureSuspended || captureGeneration != _captureGeneration) return;
      _failureMessage = null;
      _logJoinInfo(callId: callId, info: info);
      final expectedAfterLeave = _connectionGeneration + 1;
      await leave();
      if (_disposed || _connectionGeneration != expectedAfterLeave) return;
      if (_captureSuspended || captureGeneration != _captureGeneration) return;
      await _speakerMutation;
      if (_disposed || _connectionGeneration != expectedAfterLeave) return;
      if (_captureSuspended || captureGeneration != _captureGeneration) return;
      // A reconnect keeps this call's choice; a different call starts on speaker.
      if (_speakerPreferenceCallId != callId) {
        _speakerPreferenceCallId = callId;
        _speakerOutputPreferred = true;
      }
      generation = _connectionGeneration;
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        await initializeRtcAndroidAudioEngine();
        if (_disposed || generation != _connectionGeneration) return;
        if (_captureSuspended || captureGeneration != _captureGeneration) {
          return;
        }
      }
      _connectedCallId = callId;
      debugPrint(
        'RTC_LIVEKIT_AUDIO_ROUTE_PRECONNECT '
        'device=${_platformLabel()} '
        'callId=$callId '
        'speakerOn=${AudioManager.instance.isSpeakerOutputPreferred} '
        'forceSpeaker=${AudioManager.instance.isSpeakerOutputForced}',
      );

      final room = Room(
        roomOptions: RoomOptions(
          adaptiveStream: true,
          dynacast: true,
          // Keep AEC/NS enabled; AGC is enabled to support quiet speech. Android
          // engine policy is requested before the first Room is created.
          // https://docs.livekit.io/reference/client-sdk-flutter/livekit_client/AudioCaptureOptions-class.html
          defaultAudioCaptureOptions: const AudioCaptureOptions(
            echoCancellation: true,
            noiseSuppression: true,
            autoGainControl: true,
            highPassFilter: true,
          ),
          defaultAudioOutputOptions: AudioOutputOptions(
            speakerOn: _speakerOutputPreferred,
          ),
        ),
      );
      _room = room;
      _observeLocalPublications(room);
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
          if (!_ownsRoom(room, generation!)) return;
          recordMediaSubscriptionSuccess(room, event.publication.sid);
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
          recordMediaSubscriptionUnpublished(room, event.publication.sid);
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
          if (!_ownsRoom(room, generation!)) return;
          recordMediaPlaybackStatus(room, event.isPlaying);
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
                  if (_ownsRoom(room, generation!)) {
                    _audioPlaybackRetryRequested = false;
                  }
                }
              }),
            );
          }
        })
        ..on<TrackSubscriptionExceptionEvent>((event) {
          if (!_ownsRoom(room, generation!)) return;
          recordMediaSubscriptionFailure(room, event.sid);
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
      await room.connect(
        gatewayUrl,
        info.token,
        connectOptions: connectOptions,
      );
      if (generation != _connectionGeneration || !identical(_room, room)) {
        await _releaseRoom(room);
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
      if (generation != _connectionGeneration || !identical(_room, room)) {
        return;
      }
      _refreshRemoteAudioTrack(room, reason: 'after_connect');
      await _ensureAudioPlayback(room, callId: callId, reason: 'after_connect');
      if (generation != _connectionGeneration || !identical(_room, room)) {
        return;
      }
      debugPrint(
        'RTC_LIVEKIT_AUDIO_ROUTE '
        'device=${_platformLabel()} '
        'callId=$callId '
        'canPlaybackAudio=${room.canPlaybackAudio}',
      );
      _logLocalAudioSnapshot(room, callId: callId, reason: 'after_set_speaker');
      if (_captureSuspended || captureGeneration != _captureGeneration) return;
      await setMicrophoneEnabled(true);
      if (generation != _connectionGeneration || !identical(_room, room)) {
        return;
      }
      if (_captureSuspended || captureGeneration != _captureGeneration) return;
      if (info.mode == 'video') {
        await setCameraEnabled(true);
      }
      if (generation != _connectionGeneration || !identical(_room, room)) {
        await _releaseRoom(room);
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

  Future<void> _stopTrack(LocalTrack track) async {
    try {
      await track.stop();
    } catch (_) {
      debugPrint('RTC_LOCAL_CAPTURE_STOP_FAILED');
    }
  }

  void resumeCapture() {
    _captureSuspended = false;
  }

  Future<void> _suspendTrack(LocalTrack track) async {
    try {
      await track.mute(stopOnMute: true);
    } catch (_) {
      debugPrint('RTC_LOCAL_CAPTURE_MUTE_FAILED');
    } finally {
      await _stopTrack(track);
    }
  }

  Future<void> _discardLocalTrack(Room? room, LocalTrack track) async {
    await _suspendTrack(track);
    final participant = room?.localParticipant;
    final publications =
        participant?.trackPublications.values.toList() ??
        <LocalTrackPublication>[];
    for (final publication in publications) {
      if (!identical(publication.track, track)) continue;
      try {
        await participant!.removePublishedTrack(publication.sid);
      } catch (_) {
        debugPrint('RTC_LOCAL_UNPUBLISH_FAILED');
      }
    }
    _localTracks.remove(track);
  }

  void _observeLocalPublications(Room room) {
    for (final publication
        in room.localParticipant?.trackPublications.values ??
            <LocalTrackPublication>[]) {
      final track = publication.track;
      if (track != null) {
        _localTracks[track] = (
          room: room,
          captureGeneration: _captureGeneration,
        );
      }
    }
    room.events.on<LocalTrackPublishedEvent>((event) {
      final track = event.publication.track;
      if (track == null) return;
      final owner = _localTracks[track];
      if (!identical(_room, room) ||
          _captureSuspended ||
          owner == null ||
          !identical(owner.room, room) ||
          owner.captureGeneration != _captureGeneration) {
        unawaited(_discardLocalTrack(room, track));
      }
    });
  }

  Future<void> suspendCapture() {
    _logLifecycle(_connectedCallId, 'capture_suspend_start');
    _captureGeneration++;
    _captureSuspended = true;
    _cameraEnabled = false;
    _microphoneEnabled = false;
    final room = _room;
    final tracks = <LocalTrack>{
      for (final entry in _localTracks.entries)
        if (identical(entry.value.room, room)) entry.key,
      for (final publication
          in room?.localParticipant?.trackPublications.values ??
              <LocalTrackPublication>[])
        ?publication.track,
    };
    final stopping =
        Future.wait(
          tracks.map((track) => _discardLocalTrack(room, track)),
        ).then<void>((_) {
          _logLifecycle(_connectedCallId, 'capture_suspend_complete');
        });
    _captureStop = Future.wait([_captureStop, stopping]).then<void>((_) {});
    _mediaChanged();
    return _captureStop;
  }

  Future<void> _releaseRoom(Room room) async {
    // Track.stop releases native capture independently of signaling teardown.
    final tracks = <LocalTrack>{
      for (final entry in _localTracks.entries)
        if (identical(entry.value.room, room)) entry.key,
      for (final publication
          in room.localParticipant?.trackPublications.values ??
              <LocalTrackPublication>[])
        ?publication.track,
    };
    await Future.wait(tracks.map(_stopTrack));
    _localTracks.removeWhere((track, owner) => identical(owner.room, room));
    try {
      await room.disconnect();
    } catch (_) {
      // Disposal must still release tracks if the signaling disconnect fails.
    }
    try {
      await room.dispose();
    } catch (_) {
      // Preserve best-effort cleanup across independent native failure points.
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
    _captureSuspended = false;
    final room = _room;
    room?.removeListener(_mediaChanged);
    _room = null;
    _cameraEnabled = false;
    _microphoneEnabled = false;
    _connectedCallId = null;
    _remoteAudioTrack = null;
    _remoteAudioTrackFromEvent = false;
    _speakerRouteFailed = false;
    _audioPlaybackFailed = false;
    _failedMediaSubscriptions.clear();
    _mediaOutputRetry = null;
    _mediaOutputMutation = Future.value();
    _audioPlaybackRetryRequested = false;
    _stopHeartbeat();
    _stopAudioStatsTimer();
    unawaited(_unbindLocalAudioTrackDiagnostics());
    _mediaChanged();
    if (room == null) {
      await _teardown;
      _logLifecycle(leavingCallId, 'leave_complete');
      return;
    }
    _teardown = Future.wait([_teardown, _releaseRoom(room)]).then<void>((_) {});
    await _teardown;
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

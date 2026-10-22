import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';

const iceDiagnosticRequested = bool.fromEnvironment(
  'ELITESYNC_ICE_DIAG_TEST_ONLY',
);

bool iceDiagnosticAllowed({
  required bool requested,
  required bool dartDebug,
  required bool localBuild,
  required bool r1Build,
  required bool nativeDebug,
  required bool nativeDiagnostic,
  required String? packageName,
  required bool localEndpoint,
}) =>
    requested &&
    dartDebug &&
    localBuild &&
    r1Build &&
    nativeDebug &&
    nativeDiagnostic &&
    packageName == 'com.elitesync.v1015icediag' &&
    localEndpoint;

Future<bool> verifyIceDiagnosticHost(AppEnv env) async {
  if (!iceDiagnosticRequested || !kDebugMode) return false;
  try {
    final host = await const MethodChannel('elitesync/bootstrap')
        .invokeMapMethod<dynamic, dynamic>('getBootstrap')
        .timeout(const Duration(seconds: 1));
    return iceDiagnosticAllowed(
      requested: iceDiagnosticRequested,
      dartDebug: kDebugMode,
      localBuild: const bool.fromEnvironment('ELITESYNC_V1015_LOCAL_BUILD'),
      r1Build: const bool.fromEnvironment('ELITESYNC_V1015_R1_LOCAL_BUILD'),
      nativeDebug: host?['debugBuild'] == 'true',
      nativeDiagnostic: host?['iceDiagnosticBuild'] == 'true',
      packageName: host?['applicationId'] as String?,
      localEndpoint:
          env.isDev &&
          env.restorationLocalBuild &&
          env.useLiveKitRtc &&
          env.apiBaseUrl == 'http://127.0.0.1:8031/' &&
          host?['apiBaseUrl'] == env.apiBaseUrl,
    );
  } catch (_) {
    return false;
  }
}

String _category(Object? value, Set<String> allowed) =>
    value is String && allowed.contains(value.toLowerCase())
    ? value.toLowerCase()
    : 'UNKNOWN';

String _pcState(Object? value) {
  var name = value is Enum
      ? value.name
      : value is String
      ? value
      : '';
  name = name.toLowerCase();
  for (final prefix in ['rtcpeerconnectionstate', 'rtciceconnectionstate']) {
    if (name.startsWith(prefix)) name = name.substring(prefix.length);
  }
  return _category(name, {
    'new',
    'connecting',
    'checking',
    'connected',
    'completed',
    'disconnected',
    'failed',
    'closed',
  });
}

Object _number(Object? value, {bool integer = false}) =>
    value is num &&
        value.isFinite &&
        value >= 0 &&
        value <= 9007199254740991 &&
        (!integer || value == value.truncateToDouble())
    ? value
    : 'NOT_AVAILABLE';

Map<String, String> _address(Object? raw) {
  if (raw is! String) {
    return const {'family': 'UNKNOWN', 'addressClass': 'UNKNOWN'};
  }
  final v4 = raw.split('.');
  if (v4.length == 4 &&
      v4.every(
        (v) => RegExp(r'^\d{1,3}$').hasMatch(v) && int.parse(v) <= 255,
      )) {
    return {
      'family': 'IPv4',
      'addressClass': v4.first == '127' ? 'loopback' : 'non_loopback',
    };
  }
  // URI parsing validates literals without DNS or exposing any address text.
  if (raw.contains(':') &&
      !raw.contains('%') &&
      !raw.contains('[') &&
      Uri.tryParse('http://[$raw]/') != null) {
    final normalized = raw.toLowerCase();
    final words = normalized.split(':');
    final loopback =
        int.tryParse(words.last, radix: 16) == 1 &&
        words
            .take(words.length - 1)
            .every(
              (word) => word.isEmpty || int.tryParse(word, radix: 16) == 0,
            );
    return {
      'family': 'IPv6',
      'addressClass': loopback ? 'loopback' : 'non_loopback',
    };
  }
  return const {'family': 'UNKNOWN', 'addressClass': 'UNKNOWN'};
}

/// A newly constructed whitelist, never a retained or forwarded StatsReport map.
final class IceDiagnosticSnapshot {
  IceDiagnosticSnapshot._(this._values);
  final Map<String, Object?> _values;
  Map<String, Object?> toJson() => Map.unmodifiable(_values);

  factory IceDiagnosticSnapshot.fromReports(
    List<StatsReport> reports, {
    Object? connectionState,
    Object? iceState,
  }) {
    final transports = reports
        .where((r) => r.type == 'transport')
        .take(8)
        .toList();
    final selected = transports
        .map((r) => r.values['selectedCandidatePairId'])
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet();
    final candidates = <Map<String, Object?>>[];
    for (final r
        in reports
            .where(
              (r) =>
                  r.type == 'local-candidate' || r.type == 'remote-candidate',
            )
            .take(32)) {
      final v = r.values;
      candidates.add({
        'side': r.type == 'local-candidate' ? 'local' : 'remote',
        'protocol': _category(v['protocol'], {'tcp', 'udp'}),
        'candidateType': _category(v['candidateType'], {
          'host',
          'srflx',
          'prflx',
          'relay',
        }),
        'tcpType': _category(v['tcpType'], {'active', 'passive', 'so'}),
        ..._address(v['address'] ?? v['ip']),
      });
    }
    final pairs = <Map<String, Object?>>[];
    for (final r in reports.where((r) => r.type == 'candidate-pair').take(16)) {
      final v = r.values;
      pairs.add({
        'state': _category(v['state'], {
          'frozen',
          'waiting',
          'in-progress',
          'failed',
          'succeeded',
          'cancelled',
        }),
        'selected': selected.contains(r.id)
            ? true
            : v['selected'] is bool
            ? v['selected']
            : selected.isNotEmpty
            ? false
            : 'UNKNOWN',
        'nominated': v['nominated'] is bool ? v['nominated'] : 'UNKNOWN',
        'requestsSent': _number(v['requestsSent'], integer: true),
        'responsesReceived': _number(v['responsesReceived'], integer: true),
        'currentRoundTripTime': _number(v['currentRoundTripTime']),
      });
    }
    return IceDiagnosticSnapshot._({
      'availability': 'REPORTS_AVAILABLE',
      'connection': _pcState(connectionState),
      'ice': _pcState(iceState),
      'candidates': candidates,
      'pairs': pairs,
      'transports': transports
          .map(
            (r) => <String, Object?>{
              'selectedPairReferencePresent':
                  r.values['selectedCandidatePairId'] is String &&
                  (r.values['selectedCandidatePairId'] as String).isNotEmpty,
              'dtlsState': _category(r.values['dtlsState'], {
                'new',
                'connecting',
                'connected',
                'closed',
                'failed',
              }),
              'iceRole': _category(r.values['iceRole'], {
                'controlling',
                'controlled',
              }),
            },
          )
          .toList(),
      'candidateLimitReached':
          reports
              .where(
                (r) =>
                    r.type == 'local-candidate' || r.type == 'remote-candidate',
              )
              .length >
          32,
      'pairLimitReached':
          reports.where((r) => r.type == 'candidate-pair').length > 16,
      'transportLimitReached':
          reports.where((r) => r.type == 'transport').length > 8,
      'checkCountersMeaning': 'AGGREGATE_ICE_COUNTERS_NOT_PACKET_PROOF',
      'stunPacketCapture': 'NOT_OBSERVABLE',
    });
  }
}

/// Bounded, non-overlapping reads of the currently created PCs; no event hooks
/// overwrite SDK callbacks. Late replies after any epoch boundary are discarded.
final class IcePreconnectObserver {
  IcePreconnectObserver({
    required this.enabled,
    required this.isCurrent,
    required this.read,
    required this.emit,
  });
  final bool enabled;
  final bool Function() isCurrent;
  final Future<IceDiagnosticSnapshot?> Function(String) read;
  final void Function(String) emit;
  static int _sequence = 0;
  final String _correlation = 'diag_${++_sequence}';
  final Stopwatch _clock = Stopwatch();
  Timer? _periodic;
  Timer? _deadline;
  Future<void>? _inFlight;
  final Map<String, Future<IceDiagnosticSnapshot?>> _pendingReads = {};
  final Map<String, int> _lastSnapshotAt = {};
  bool _active = false;

  bool get _current {
    try {
      return isCurrent();
    } catch (_) {
      return false;
    }
  }

  Future<T> during<T>(Future<T> Function() connect) async {
    if (!enabled) return connect();
    _active = true;
    _clock.start();
    _deadline = Timer(const Duration(seconds: 30), stop);
    _periodic = Timer.periodic(
      const Duration(seconds: 1),
      (_) => unawaited(_sample()),
    );
    unawaited(_sample());
    try {
      final result = await connect();
      await _inFlight;
      await _sample(); // Final no-media snapshot, only while current and bounded.
      return result;
    } catch (_) {
      // Do not extend the 30s sampling budget or call into a closing PC. This
      // terminal metadata explicitly distinguishes the last sample from failure.
      if (_current) {
        try {
          for (final side in ['publisher', 'subscriber']) {
            final last = _lastSnapshotAt[side];
            emit(
              'ICE_DIAG_TEST_ONLY ${jsonEncode({'correlation': _correlation, 'relativeMs': _clock.elapsedMilliseconds, 'peer': side, 'kind': 'terminal', 'outcome': 'CONNECT_FAILED', 'terminalSnapshot': 'NOT_CAPTURED', 'lastSnapshotAgeMs': last == null ? 'NOT_AVAILABLE' : _clock.elapsedMilliseconds - last})}',
            );
          }
        } catch (_) {
          /* Diagnostics must not replace the connect exception. */
        }
      }
      rethrow;
    } finally {
      stop();
      _clock.stop();
    }
  }

  Future<void> _sample() {
    if (!_active || !_current) {
      stop();
      return Future.value();
    }
    if (_inFlight != null) return _inFlight!;
    final future = _readBoth();
    _inFlight = future;
    return future.whenComplete(() {
      _inFlight = null;
    });
  }

  Future<void> _readBoth() async {
    for (final side in ['publisher', 'subscriber']) {
      if (!_active || !_current) {
        stop();
        return;
      }
      Map<String, Object?> data;
      try {
        if (_pendingReads.containsKey(side)) {
          data = {'availability': 'READ_PENDING'};
        } else {
          final request = Future<IceDiagnosticSnapshot?>.sync(() => read(side));
          _pendingReads[side] = request;
          void completed() {
            if (identical(_pendingReads[side], request)) {
              _pendingReads.remove(side);
            }
          }

          unawaited(
            request.then(
              (_) => completed(),
              onError: (Object error, StackTrace stack) => completed(),
            ),
          );
          final snapshot = await request.timeout(
            const Duration(milliseconds: 750),
          );
          data = snapshot?.toJson() ?? {'availability': 'NOT_INITIALIZED'};
          if (snapshot != null && _active && _current) {
            _lastSnapshotAt[side] = _clock.elapsedMilliseconds;
          }
        }
      } catch (error) {
        data = {
          'availability': 'NOT_AVAILABLE',
          'errorType': error is TimeoutException
              ? 'TimeoutException'
              : error is PlatformException
              ? 'PlatformException'
              : error is StateError
              ? 'StateError'
              : 'OTHER',
        };
      }
      if (!_active || !_current) {
        stop();
        return;
      }
      try {
        final header = Map<String, Object?>.of(data);
        final groups = <String, List>{};
        for (final key in ['candidates', 'pairs', 'transports']) {
          final values = header.remove(key);
          if (values is List) groups[key] = values;
        }
        final context = <String, Object?>{
          'correlation': _correlation,
          'relativeMs': _clock.elapsedMilliseconds,
          'peer': side,
        };
        emit(
          'ICE_DIAG_TEST_ONLY ${jsonEncode({...context, 'kind': 'summary', ...header})}',
        );
        for (final group in groups.entries) {
          for (var offset = 0; offset < group.value.length; offset += 2) {
            if (!_active || !_current) {
              stop();
              return;
            }
            emit(
              'ICE_DIAG_TEST_ONLY ${jsonEncode({...context, 'kind': group.key, 'offset': offset, 'values': group.value.skip(offset).take(2).toList()})}',
            );
          }
        }
      } catch (_) {
        stop();
        return;
      }
    }
  }

  void stop() {
    _active = false;
    _periodic?.cancel();
    _periodic = null;
    _deadline?.cancel();
    _deadline = null;
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/services/rtc_ice_diagnostic.dart';

StatsReport report(String id, String type, Map<String, dynamic> values) =>
    StatsReport(id, type, 0, values);

void main() {
  testWidgets(
    'timed out native reads stay single-flight per PC until completion',
    (tester) async {
      final connect = Completer<void>();
      final replies = <String, Completer<IceDiagnosticSnapshot?>>{};
      final reads = <String, int>{};
      final lines = <String>[];
      final observer = IcePreconnectObserver(
        enabled: true,
        isCurrent: () => true,
        read: (side) {
          reads[side] = (reads[side] ?? 0) + 1;
          return (replies[side] ??= Completer<IceDiagnosticSnapshot?>()).future;
        },
        emit: lines.add,
      );
      unawaited(observer.during(() => connect.future));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));
      await tester.pump(const Duration(milliseconds: 750));
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      expect(reads, {'publisher': 1, 'subscriber': 1});
      expect(lines.any((line) => line.contains('READ_PENDING')), true);
      observer.stop();
      for (final reply in replies.values) {
        reply.complete(IceDiagnosticSnapshot.fromReports([]));
      }
      await tester.pump();
      expect(lines.any((line) => line.contains('REPORTS_AVAILABLE')), false);
      connect.complete();
      await tester.pump();
    },
  );

  testWidgets(
    'failure labels the last sample as stale instead of a terminal snapshot',
    (tester) async {
      final connect = Completer<void>();
      final lines = <String>[];
      final observer = IcePreconnectObserver(
        enabled: true,
        isCurrent: () => true,
        read: (_) async => IceDiagnosticSnapshot.fromReports([]),
        emit: lines.add,
      );
      unawaited(
        observer
            .during(() => connect.future)
            .then((_) {}, onError: (Object _) {}),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      connect.completeError(StateError('PRIVATE_FAILURE'));
      await tester.pump();
      final terminal = lines
          .where((line) => line.contains('CONNECT_FAILED'))
          .map(
            (line) =>
                jsonDecode(line.substring('ICE_DIAG_TEST_ONLY '.length)) as Map,
          )
          .toList();
      expect(terminal.length, 2);
      expect(
        terminal.every((v) => v['terminalSnapshot'] == 'NOT_CAPTURED'),
        true,
      );
      // The observer uses a monotonic Stopwatch; pump advances fixture timers,
      // not physical elapsed time. Do not label the fixture's 250ms as elapsed.
      expect(
        terminal.every(
          (v) =>
              v['lastSnapshotAgeMs'] is int &&
              v['lastSnapshotAgeMs'] >= 0 &&
              v['lastSnapshotAgeMs'] <= v['relativeMs'],
        ),
        true,
      );
      expect(lines.join(), isNot(contains('PRIVATE_FAILURE')));
      final count = lines.length;
      await tester.pump(const Duration(seconds: 31));
      expect(lines.length, count);
    },
  );

  test('only explicit debug local R1 and native isolated identity can arm', () {
    bool allowed({
      bool flag = true,
      bool debug = true,
      bool local = true,
      bool r1 = true,
      bool nativeDebug = true,
      bool nativeDiag = true,
      String package = 'com.elitesync.v1015icediag',
    }) => iceDiagnosticAllowed(
      requested: flag,
      dartDebug: debug,
      localBuild: local,
      r1Build: r1,
      nativeDebug: nativeDebug,
      nativeDiagnostic: nativeDiag,
      packageName: package,
      localEndpoint: true,
    );
    expect(allowed(), isTrue);
    expect(allowed(flag: false), isFalse);
    expect(allowed(debug: false), isFalse);
    expect(allowed(local: false), isFalse);
    expect(allowed(r1: false), isFalse);
    expect(allowed(nativeDebug: false), isFalse);
    expect(allowed(nativeDiag: false), isFalse);
    expect(allowed(package: 'com.elitesync.v1015r1dev'), isFalse);
  });

  test(
    'whitelist never emits IDs, IPs, ports, SDP, token or unknown strings',
    () {
      final snapshot = IceDiagnosticSnapshot.fromReports([
        report('private-candidate-id', 'local-candidate', {
          'protocol': 'tcp',
          'candidateType': 'host',
          'tcpType': 'passive',
          'address': '192.0.2.10',
          'port': 45678,
          'usernameFragment': 'PRIVATE_UFRAG',
          'sdp': 'PRIVATE_SDP',
          'token': 'FAKE_SECRET_SENTINEL',
        }),
        report('remote-id', 'remote-candidate', {
          'protocol': 'udp',
          'candidateType': 'relay',
          'tcpType': 'UNTRUSTED_ROLE',
          'address': '::1',
        }),
        report('private-pair-id', 'candidate-pair', {
          'localCandidateId': 'private-candidate-id',
          'remoteCandidateId': 'remote-id',
          'state': 'succeeded',
          'nominated': true,
          'requestsSent': 3,
          'responsesReceived': 2,
          'currentRoundTripTime': 0.02,
        }),
        report('transport-id', 'transport', {
          'selectedCandidatePairId': 'private-pair-id',
          'dtlsState': 'connecting',
          'iceRole': 'controlling',
          'privateField': 'DO_NOT_FORWARD',
        }),
      ]);
      final value = snapshot.toJson();
      final encoded = jsonEncode(value);
      for (final secret in [
        'private-candidate-id',
        'private-pair-id',
        'remote-id',
        'transport-id',
        '192.0.2.10',
        '::1',
        '45678',
        'PRIVATE_UFRAG',
        'PRIVATE_SDP',
        'FAKE_SECRET_SENTINEL',
        'UNTRUSTED_ROLE',
        'DO_NOT_FORWARD',
      ]) {
        expect(encoded, isNot(contains(secret)));
      }
      expect((value['pairs'] as List).single['selected'], true);
      expect((value['pairs'] as List).single['nominated'], true);
      expect((value['pairs'] as List).single['requestsSent'], 3);
      expect((value['transports'] as List).single['dtlsState'], 'connecting');
      expect((value['candidates'] as List).first['tcpType'], 'passive');
      expect((value['candidates'] as List).last['tcpType'], 'UNKNOWN');
      expect(value['stunPacketCapture'], 'NOT_OBSERVABLE');
    },
  );

  test(
    'nominated succeeded does not invent selected; absent differs from false',
    () {
      final value = IceDiagnosticSnapshot.fromReports([
        report('p', 'candidate-pair', {
          'nominated': true,
          'state': 'succeeded',
        }),
        report('q', 'candidate-pair', {'nominated': false, 'selected': false}),
        report('r', 'candidate-pair', {
          'state': 'private-unknown',
          'requestsSent': double.nan,
          'responsesReceived': '4',
        }),
      ]).toJson();
      final pairs = value['pairs'] as List;
      expect(pairs[0]['selected'], 'UNKNOWN');
      expect(pairs[1]['selected'], false);
      expect(pairs[1]['nominated'], false);
      expect(pairs[2]['state'], 'UNKNOWN');
      expect(pairs[2]['requestsSent'], 'NOT_AVAILABLE');
      expect(pairs[2]['responsesReceived'], 'NOT_AVAILABLE');
    },
  );

  testWidgets('disabled observer never reads or logs a pending connect', (
    tester,
  ) async {
    var reads = 0;
    final lines = <String>[];
    final connect = Completer<void>();
    final observer = IcePreconnectObserver(
      enabled: false,
      isCurrent: () => true,
      read: (_) async {
        reads++;
        return null;
      },
      emit: lines.add,
    );
    unawaited(observer.during(() => connect.future));
    await tester.pump(const Duration(seconds: 31));
    expect(reads, 0);
    expect(lines, isEmpty);
    connect.complete();
    await tester.pump();
  });

  for (final terminal in ['success', 'failure', 'leave', 'epoch', 'dispose']) {
    testWidgets(
      'samples late PC during pending connect and stops at $terminal',
      (tester) async {
        final connect = Completer<void>();
        final lines = <String>[];
        var pcCreated = false;
        var current = true;
        var reads = 0;
        final observer = IcePreconnectObserver(
          enabled: true,
          isCurrent: () => current,
          read: (_) async {
            reads++;
            return pcCreated ? IceDiagnosticSnapshot.fromReports([]) : null;
          },
          emit: lines.add,
        );
        var finished = false;
        unawaited(
          observer
              .during(() {
                pcCreated = true;
                return connect.future;
              })
              .then(
                (_) {
                  finished = true;
                },
                onError: (Object _) {
                  finished = true;
                },
              ),
        );
        await tester.pump();
        expect(lines.any((x) => x.contains('NOT_INITIALIZED')), true);
        await tester.pump(const Duration(seconds: 1));
        expect(finished, false);
        expect(lines.any((x) => x.contains('REPORTS_AVAILABLE')), true);
        if (terminal == 'success') {
          connect.complete();
        }
        if (terminal == 'failure') {
          connect.completeError(StateError('PRIVATE_ERROR'));
        }
        if (terminal == 'leave' || terminal == 'dispose') {
          observer.stop();
        }
        if (terminal == 'epoch') {
          current = false;
        }
        await tester.pump();
        if (terminal == 'epoch') {
          await tester.pump(const Duration(seconds: 1));
        }
        final previous = reads;
        await tester.pump(const Duration(seconds: 35));
        expect(reads, previous);
        expect(lines.join(), isNot(contains('PRIVATE_ERROR')));
        if (!connect.isCompleted) {
          connect.complete();
        }
        await tester.pump();
      },
    );
  }

  testWidgets('30 second ceiling suppresses delayed stats replies', (
    tester,
  ) async {
    final replies = Completer<IceDiagnosticSnapshot?>();
    final connect = Completer<void>();
    final lines = <String>[];
    var reads = 0;
    final observer = IcePreconnectObserver(
      enabled: true,
      isCurrent: () => true,
      read: (_) {
        reads++;
        return replies.future;
      },
      emit: lines.add,
    );
    unawaited(observer.during(() => connect.future));
    await tester.pump(const Duration(seconds: 31));
    final previous = reads;
    replies.complete(IceDiagnosticSnapshot.fromReports([]));
    await tester.pump();
    await tester.pump(const Duration(seconds: 10));
    expect(reads, previous);
    expect(lines.any((x) => x.contains('REPORTS_AVAILABLE')), false);
    connect.complete();
    await tester.pump();
  });

  testWidgets(
    'large whitelisted snapshots use complete small JSON log records',
    (tester) async {
      final connect = Completer<void>();
      final lines = <String>[];
      final reports = [
        for (var i = 0; i < 40; i++)
          report('private-$i', 'local-candidate', {
            'protocol': 'tcp',
            'tcpType': 'active',
            'candidateType': 'host',
            'address': '192.0.2.10',
          }),
      ];
      final observer = IcePreconnectObserver(
        enabled: true,
        isCurrent: () => true,
        read: (_) async => IceDiagnosticSnapshot.fromReports(reports),
        emit: lines.add,
      );
      unawaited(observer.during(() => connect.future));
      await tester.pump();
      observer.stop();
      connect.complete();
      await tester.pump();
      expect(lines.length, greaterThan(2));
      for (final line in lines) {
        expect(line.length, lessThan(3000));
        expect(line, isNot(contains('192.0.2.10')));
        expect(
          jsonDecode(line.substring('ICE_DIAG_TEST_ONLY '.length)),
          isA<Map>(),
        );
      }
    },
  );
}

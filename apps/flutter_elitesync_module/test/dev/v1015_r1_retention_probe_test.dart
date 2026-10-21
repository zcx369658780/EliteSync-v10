import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/storage/secure_storage_service.dart';
import 'package:flutter_elitesync_module/dev/v1015_r1_retention_probe.dart';

class _MemoryStorage extends SecureStorageService {
  final values = <String, String>{};
  final deleted = <String>[];
  @override
  Future<void> write(String key, String value) async => values[key] = value;
  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> delete(String key) async {
    deleted.add(key);
    values.remove(key);
  }

  @override
  Future<void> deleteAll() async => fail('deleteAll is forbidden');
}

class _SyntheticApi implements RetentionProbeApi {
  Map<String, dynamic>? retention;
  int user = 0;
  bool closed = false;
  bool changeT0 = false;
  final calls = <String>[];

  @override
  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    calls.add('$method $path');
    if (path.endsWith('/login')) {
      user++;
      final t0 = DateTime.utc(2026, 10, 22);
      retention = {
        'user_id': user,
        'device_id': body!['device_id'],
        'session_id': 'synthetic-session-$user',
        'login_at': t0.toIso8601String(),
        'server_now': t0
            .add(const Duration(milliseconds: 850))
            .toIso8601String(),
        'online_expires_at': t0.add(const Duration(days: 15)).toIso8601String(),
        'purge_at': t0.add(const Duration(days: 30)).toIso8601String(),
      };
    } else if (path.endsWith('/refresh')) {
      expect(token, 'synthetic-refresh-never-log');
      if (changeT0) retention!['login_at'] = '2026-10-23T00:00:00Z';
    } else {
      expect(path, '/api/v1/conversations');
      expect(token, 'synthetic-access-never-log');
      return {'data': <Object>[]};
    }
    return {
      'user': {'id': user},
      'session_id': 'synthetic-session-$user',
      'session_retention': Map<String, dynamic>.from(retention!),
      'access_token': 'synthetic-access-never-log',
      'refresh_token': 'synthetic-refresh-never-log',
    };
  }

  @override
  void close() => closed = true;
}

void main() {
  test('probe gate requires both compile flags and native debug identity', () {
    for (final probe in [false, true]) {
      for (final local in [false, true]) {
        for (final host in [null, 'false', 'true']) {
          expect(
            retentionProbeAllowed(
              probeEnabled: probe,
              localBuild: local,
              hostDebugBuild: host,
            ),
            probe && local && host == 'true',
          );
        }
      }
    }
  });

  test('clock preserves server T0 offset and refuses backward movement', () {
    final t0 = DateTime.utc(2026, 10, 22);
    final clock = RetentionProbeClock(
      loginAt: t0,
      serverNow: t0.add(const Duration(milliseconds: 850)),
    );
    clock.atAge(const Duration(days: 15));
    expect(
      clock.serverNow.add(clock.elapsed),
      t0.add(const Duration(days: 15)),
    );
    expect(clock.wallNow().difference(clock.wallAnchor), clock.elapsed);
    expect(
      () => clock.atAge(const Duration(days: 14)),
      throwsA(isA<RetentionProbeFailure>()),
    );
  });

  test(
    'TEST_ONLY runner covers boundary/delete branches without secret output',
    () async {
      final storage = _MemoryStorage();
      storage.values['unrelated:protected'] = 'untouched';
      final api = _SyntheticApi();
      final receipts = <Map<String, dynamic>>[];
      await RetentionProbeRunner(
        storage: storage,
        api: api,
        onReceipt: receipts.add,
        evidenceMode: 'TEST_ONLY_MEMORY_STORAGE',
      ).run();
      expect(receipts.last['stage'], 'COMPLETE');
      expect(receipts.every((r) => r['passed'] == true), isTrue);
      expect(
        receipts.every((r) => r['mode'] == 'TEST_ONLY_MEMORY_STORAGE'),
        isTrue,
      );
      final success = receipts.singleWhere(
        (r) => r['stage'] == 'A_ACTUAL_PURGE_SUCCESS',
      );
      expect(success['native_delete_completions'], 2);
      expect(success['native_object_present_after'], isFalse);
      final failed = receipts.singleWhere(
        (r) => r['stage'] == 'B_ACTUAL_PURGE_FAILURE',
      );
      expect(failed['injected_delete_failures'], 1);
      expect(failed['native_delete_completions'], 0);
      expect(failed['native_object_present_after'], isTrue);
      expect(failed['locked'], isTrue);
      expect(storage.values['unrelated:protected'], 'untouched');
      expect(
        storage.values.length,
        4,
      ); // protected + B object/manifest + synthetic locator
      expect(
        storage.deleted.every((key) => key.startsWith('v1015_private:')),
        isTrue,
      );
      final output = jsonEncode(receipts);
      for (final forbidden in [
        '19900001511',
        '19900001512',
        'V1015R1-Test-Only-Password',
        'synthetic-access-never-log',
        'synthetic-refresh-never-log',
      ]) {
        expect(output.contains(forbidden), isFalse);
      }
      expect(api.closed, isTrue);
      expect(
        api.calls.where((call) => call == 'GET /api/v1/conversations').length,
        2,
      );
      final restartReceipts = <Map<String, dynamic>>[];
      await RetentionProbeRunner(
        storage: storage,
        api: _SyntheticApi(),
        onReceipt: restartReceipts.add,
        evidenceMode: 'TEST_ONLY_MEMORY_STORAGE',
      ).verifyRestartLock();
      expect(restartReceipts.single['stage'], 'RESTART_FRESH_SERVICE_LOCKED');
      expect(restartReceipts.single['passed'], isTrue);
      expect(restartReceipts.single['REAL_PHYSICAL_ELAPSED'], 'NOT_CLAIMED');
    },
  );

  test(
    'refresh T0 mutation stops before current-read or storage write',
    () async {
      final storage = _MemoryStorage();
      final api = _SyntheticApi()..changeT0 = true;
      final receipts = <Map<String, dynamic>>[];
      await RetentionProbeRunner(
        storage: storage,
        api: api,
        onReceipt: receipts.add,
        evidenceMode: 'TEST_ONLY_MEMORY_STORAGE',
      ).run();
      expect(receipts.last['stage'], 'STOPPED');
      expect(receipts.last['reason'], 'A_REFRESH_KEEPS_T0');
      expect(storage.values, isEmpty);
      expect(api.calls.any((call) => call.startsWith('GET')), isFalse);
      expect(api.closed, isTrue);
    },
  );
  test('restart locator cannot target an unrelated storage key', () async {
    final storage = _MemoryStorage();
    storage.values['v1015_r1_probe:last_failed_delete'] = jsonEncode({
      'namespace': 'unrelated',
      'object_key': 'unrelated:protected',
    });
    storage.values['unrelated:protected'] = 'untouched';
    final receipts = <Map<String, dynamic>>[];
    await RetentionProbeRunner(
      storage: storage,
      api: _SyntheticApi(),
      onReceipt: receipts.add,
      evidenceMode: 'TEST_ONLY_MEMORY_STORAGE',
    ).verifyRestartLock();
    expect(receipts.single['reason'], 'RESTART_LOCATOR_REJECTED');
    expect(storage.values['unrelated:protected'], 'untouched');
    expect(storage.deleted, isEmpty);
  });
}

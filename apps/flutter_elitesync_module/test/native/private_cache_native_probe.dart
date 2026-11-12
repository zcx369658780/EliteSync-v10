// Standalone Android test entry. Run in a fresh engine, then restore the app.
// Faults below are wrapper injections. All other storage IO uses the real plugin.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_elitesync_module/core/storage/private_cache_service.dart';
import 'package:flutter_elitesync_module/core/storage/secure_storage_service.dart';

const _owner = 'v1015_private:cleanup-owner';
const _namespace = 'v1015_private:a9001:dnative-probe-20261112';
const _object = '$_namespace:probe-object';
const _primary = '$_namespace:manifest';
const _recovery = '$_namespace:manifest-recovery';

class _NativeFaultStorage extends SecureStorageService {
  _NativeFaultStorage()
    : super(
        storage: const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
            sharedPreferencesName: 'v1015_native_probe_20261112',
            preferencesKeyPrefix: 'v1015_native_probe',
          ),
        ),
      );

  String? refusedDelete;
  bool refuseCompletionWrite = false;
  int injectedFailures = 0;

  @override
  Future<void> delete(String key) async {
    if (key == refusedDelete) {
      injectedFailures++;
      return;
    }
    await super.delete(key);
  }

  @override
  Future<void> write(String key, String value) async {
    if (key == _owner &&
        refuseCompletionWrite &&
        (jsonDecode(value) as Map)['version'] == 2) {
      injectedFailures++;
      return;
    }
    await super.write(key, value);
  }
}

void _check(bool result, String message) {
  if (!result) throw StateError(message);
}

Map<String, dynamic> _retention(DateTime login) => {
  'user_id': 9001,
  'device_id': 'native-probe-20261112',
  'session_id': 'native-probe-session',
  'login_at': login.toIso8601String(),
  'server_now': login.toIso8601String(),
  'online_expires_at': login.add(const Duration(days: 15)).toIso8601String(),
  'purge_at': login.add(const Duration(days: 30)).toIso8601String(),
};

Future<Map<String, dynamic>> _probe() async {
  final secure = _NativeFaultStorage();
  final phase = await secure.read('probe:phase');
  final results = <String, dynamic>{
    'entry': 'V1015_NATIVE_CACHE_PROBE_20261112',
    'storage': 'actual Android encrypted preferences plugin, isolated file',
    'faults': 'selective Dart wrapper injection',
    'clock': 'controlled wall and elapsed, synthetic retention receipt',
    'hardware_keystore': 'NOT_VERIFIED',
  };
  if (phase == 'restart-retry') {
    _check(
      await secure.read(_object) == null,
      'Object survived native restart',
    );
    _check(
      await secure.read(_primary) == null,
      'Primary survived native restart',
    );
    _check(
      await secure.read(_recovery) == null,
      'Recovery survived native restart',
    );
    final owner = jsonDecode((await secure.read(_owner))!) as Map;
    _check(
      owner['version'] == 2 && owner['objects_cleared'] == true,
      'Restart cleanup target was lost',
    );
    final cold = PrivateCacheService.forStorage(secure);
    _check(!cold.isUnlocked, 'Cold cleanup restored read authority');
    _check(
      await cold.readOffline('probe-object') == null,
      'Cold cache displayed',
    );
    final receipt = await cold.clearCurrentAccount();
    _check(
      receipt.status == PrivateCachePurgeStatus.completed,
      'Cold native cleanup retry failed',
    );
    _check(await secure.read(_owner) == null, 'Locator survived cleanup');
    await secure.write('probe:phase', 'complete');
    return {
      ...results,
      'status': 'NATIVE_COLD_RETRY_COMPLETED',
      'objects_deleted_again': receipt.deletedObjects,
      'unlocked': cold.isUnlocked,
    };
  }
  _check(phase == null, 'Probe already completed or has an unknown phase');
  _check(
    await secure.read(_owner) == null,
    'Unexpected pre-existing probe owner',
  );
  final login = DateTime.utc(2026, 11, 12);
  var elapsed = Duration.zero;
  final cache = PrivateCacheService.forTesting(
    secure,
    wallNow: () => login.add(elapsed),
    elapsed: () => elapsed,
  );
  Future<void> seed() async {
    elapsed = Duration.zero;
    _check(
      await cache.establishLogin(userId: 9001, retention: _retention(login)),
      'Probe login context failed',
    );
    _check(
      await cache.saveAuthorized('probe-object', {
        'text': 'TEST_ONLY_NATIVE_20261112',
      }),
      'Native cache save failed',
    );
    _check(
      await secure.read(_object) != null,
      'Native object was not persisted',
    );
  }

  await seed();
  elapsed = const Duration(days: 15) - const Duration(seconds: 1);
  _check(
    await cache.readOnlineAuthorized('probe-object') != null,
    '15-before online denied',
  );
  elapsed = const Duration(days: 15);
  _check(
    await cache.readOnlineAuthorized('probe-object') == null,
    '15-at online allowed',
  );
  cache.enterOffline();
  _check(
    await cache.readOffline('probe-object') != null,
    '15-at offline denied',
  );
  _check(
    !await cache.saveAuthorized('probe-object', {'text': 'forbidden'}),
    'Offline write allowed',
  );
  elapsed = const Duration(days: 30) - const Duration(seconds: 1);
  _check(
    await cache.readOffline('probe-object') != null,
    '30-before offline denied',
  );
  elapsed = const Duration(days: 30);
  _check(
    await cache.readOffline('probe-object') == null,
    '30-at offline allowed',
  );
  final expired = await cache.purgeExpired();
  _check(
    expired.status == PrivateCachePurgeStatus.completed &&
        expired.deletedObjects == 1,
    'Native 30-day controlled purge failed',
  );
  _check(
    await secure.read(_object) == null && await secure.read(_owner) == null,
    'Native expiry cleanup left owned records',
  );
  results['native_controlled_boundaries'] = [
    '15-before',
    '15-at',
    '30-before',
    '30-at',
  ];

  final faults = <String>[];
  for (final failure in [
    'object-delete',
    'completion-write',
    'primary-delete',
    'recovery-delete',
  ]) {
    await seed();
    secure.refusedDelete = switch (failure) {
      'object-delete' => _object,
      'primary-delete' => _primary,
      'recovery-delete' => _recovery,
      _ => null,
    };
    secure.refuseCompletionWrite = failure == 'completion-write';
    final failed = await cache.clearCurrentAccount();
    _check(
      failed.status == PrivateCachePurgeStatus.failed,
      '$failure falsely completed',
    );
    _check(
      !cache.isUnlocked && await secure.read(_owner) != null,
      '$failure lost locked retry target',
    );
    secure.refusedDelete = null;
    secure.refuseCompletionWrite = false;
    final retry = await PrivateCacheService.forStorage(
      secure,
    ).clearCurrentAccount();
    _check(
      retry.status == PrivateCachePurgeStatus.completed,
      '$failure retry failed',
    );
    _check(
      await secure.read(_object) == null && await secure.read(_owner) == null,
      '$failure retry left native records',
    );
    faults.add(failure);
  }
  await seed();
  // Consecutive failures advance only after the previous fault is removed.
  for (final key in [_object, _recovery, _owner]) {
    secure.refusedDelete = key;
    final failed = await cache.clearCurrentAccount();
    _check(
      failed.status == PrivateCachePurgeStatus.failed,
      'Multi-fault falsely completed',
    );
    _check(
      !cache.isUnlocked && await secure.read(_owner) != null,
      'Multi-fault lost retry target',
    );
  }
  await secure.write('probe:phase', 'restart-retry');
  return {
    ...results,
    'status': 'NATIVE_FAILURES_VERIFIED_RESTART_RETRY_PENDING',
    'single_faults': faults,
    'consecutive_faults': 3,
    'injected_failures': secure.injectedFailures,
  };
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Map<String, dynamic> result;
  try {
    result = await _probe();
  } catch (error) {
    result = {
      'entry': 'V1015_NATIVE_CACHE_PROBE_20261112',
      'status': 'FAILED',
      'error': error.toString(),
    };
  }
  debugPrint('V1015_NATIVE_CACHE_PROBE ${jsonEncode(result)}');
  runApp(
    MaterialApp(
      home: Scaffold(body: SafeArea(child: Text(jsonEncode(result)))),
    ),
  );
}

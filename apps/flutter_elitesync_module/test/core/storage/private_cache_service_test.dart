import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/storage/private_cache_service.dart';
import 'package:flutter_elitesync_module/core/storage/secure_storage_service.dart';

class _MemorySecure extends SecureStorageService {
  final values = <String, String>{};
  bool refuseDelete = false;
  @override
  Future<void> write(String key, String value) async => values[key] = value;
  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> delete(String key) async {
    if (!refuseDelete) values.remove(key);
  }
}

class _BlockingSecure extends _MemorySecure {
  Completer<void>? blockDelete;
  Completer<void>? deleteEntered;
  @override
  Future<void> delete(String key) async {
    if (key.endsWith(':queue-blocker') && blockDelete != null) {
      deleteEntered!.complete();
      await blockDelete!.future;
    }
    await super.delete(key);
  }
}

class _IndexFailureSecure extends _MemorySecure {
  bool failRecoveryWrite = false;
  bool refuseRecoveryDelete = false;
  @override
  Future<void> write(String key, String value) async {
    if (failRecoveryWrite && key.endsWith(':manifest-recovery')) {
      throw StateError('synthetic recovery write failure');
    }
    await super.write(key, value);
  }

  @override
  Future<void> delete(String key) async {
    if (refuseRecoveryDelete && key.endsWith(':manifest-recovery')) return;
    await super.delete(key);
  }
}

Map<String, dynamic> _receipt(DateTime now, {int account = 1}) => {
  'user_id': account,
  'device_id': 'synthetic-device',
  'session_id': 11,
  'login_at': now.toIso8601String(),
  'server_now': now.toIso8601String(),
  'online_expires_at': now.add(const Duration(days: 15)).toIso8601String(),
  'purge_at': now.add(const Duration(days: 30)).toIso8601String(),
};

void main() {
  const namespace = 'v1015_private:a1:dsynthetic-device';
  const primary = '$namespace:manifest';
  const recovery = '$namespace:manifest-recovery';

  for (final damaged in [primary, recovery]) {
    for (final missing in [true, false]) {
      test(
        'purge recovers ${missing ? 'missing' : 'corrupt'} index $damaged',
        () async {
          final secure = _MemorySecure();
          final now = DateTime.utc(2026, 11, 8);
          var elapsed = Duration.zero;
          final cache = PrivateCacheService.forTesting(
            secure,
            wallNow: () => now.add(elapsed),
            elapsed: () => elapsed,
          );
          expect(
            await cache.establishLogin(userId: 1, retention: _receipt(now)),
            isTrue,
          );
          expect(
            await cache.saveAuthorized('draft:one', {'text': 'synthetic one'}),
            isTrue,
          );
          expect(
            await cache.saveAuthorized('draft:two', {'text': 'synthetic two'}),
            isTrue,
          );
          secure.values['v1015_private:a2:dsynthetic-device:retained'] =
              'other account';
          secure.values['credential'] = 'must remain';
          if (missing) {
            secure.values.remove(damaged);
          } else {
            secure.values[damaged] = 'corrupt';
          }
          elapsed = const Duration(days: 30);
          final result = await cache.purgeExpired();
          expect(result.status, PrivateCachePurgeStatus.completed);
          expect(result.deletedObjects, 2);
          expect(secure.values, {
            'v1015_private:a2:dsynthetic-device:retained': 'other account',
            'credential': 'must remain',
          });
          expect(cache.isUnlocked, isFalse);
        },
      );
    }
  }

  test(
    'save after primary loss preserves the older recovery-owned object',
    () async {
      final secure = _MemorySecure();
      final now = DateTime.utc(2026, 11, 8);
      final cache = PrivateCacheService.forTesting(secure, wallNow: () => now);
      await cache.establishLogin(userId: 1, retention: _receipt(now));
      await cache.saveAuthorized('draft:one', {'text': 'older synthetic'});
      secure.values.remove(primary);
      expect(
        await cache.saveAuthorized('draft:two', {'text': 'new synthetic'}),
        isTrue,
      );
      final result = await cache.clearCurrentAccount();
      expect(result.status, PrivateCachePurgeStatus.completed);
      expect(result.deletedObjects, 2);
      expect(secure.values, isEmpty);
    },
  );

  test(
    'no valid index fails closed without falsely confirming deletion',
    () async {
      for (final values in [
        <String, String>{primary: 'bad'},
        <String, String>{recovery: 'bad'},
        <String, String>{primary: 'bad', recovery: 'also bad'},
      ]) {
        final secure = _MemorySecure()..values.addAll(values);
        secure.values['$namespace:draft%3Aone'] =
            'retained synthetic ciphertext';
        final now = DateTime.utc(2026, 11, 8);
        final cache = PrivateCacheService.forTesting(
          secure,
          wallNow: () => now,
        );
        expect(
          await cache.establishLogin(userId: 1, retention: _receipt(now)),
          isFalse,
        );
        expect(cache.isUnlocked, isFalse);
        expect(
          secure.values['$namespace:draft%3Aone'],
          'retained synthetic ciphertext',
        );
        expect(
          (await cache.clearCurrentAccount()).status,
          PrivateCachePurgeStatus.failed,
        );
      }
    },
  );

  test(
    'failed recovery deletion retains index for an explicit cleanup retry',
    () async {
      final secure = _IndexFailureSecure();
      final now = DateTime.utc(2026, 11, 8);
      final cache = PrivateCacheService.forTesting(secure, wallNow: () => now);
      await cache.establishLogin(userId: 1, retention: _receipt(now));
      await cache.saveAuthorized('draft:one', {'text': 'synthetic'});
      secure.refuseRecoveryDelete = true;
      expect(
        (await cache.clearCurrentAccount()).status,
        PrivateCachePurgeStatus.failed,
      );
      expect(cache.isUnlocked, isFalse);
      expect(secure.values.keys, [recovery]);
      secure.refuseRecoveryDelete = false;
      expect(
        (await cache.clearCurrentAccount()).status,
        PrivateCachePurgeStatus.completed,
      );
      expect(secure.values, isEmpty);
    },
  );

  test(
    'recovery index write failure cannot leave an unindexed new object',
    () async {
      final secure = _IndexFailureSecure();
      final now = DateTime.utc(2026, 11, 8);
      final cache = PrivateCacheService.forTesting(secure, wallNow: () => now);
      await cache.establishLogin(userId: 1, retention: _receipt(now));
      secure.failRecoveryWrite = true;
      expect(
        await cache.saveAuthorized('draft:one', {'text': 'must not be saved'}),
        isFalse,
      );
      expect(cache.isUnlocked, isFalse);
      expect(secure.values, isEmpty);
    },
  );

  test('control index names cannot be saved or removed as objects', () async {
    final secure = _MemorySecure();
    final now = DateTime.utc(2026, 11, 8);
    final cache = PrivateCacheService.forTesting(secure, wallNow: () => now);
    await cache.establishLogin(userId: 1, retention: _receipt(now));
    await cache.saveAuthorized('draft:one', {'text': 'synthetic'});
    final before = Map<String, String>.of(secure.values);
    for (final name in ['manifest', 'manifest-recovery']) {
      expect(
        await cache.saveAuthorized(name, {'text': 'must not overwrite'}),
        isFalse,
      );
      await cache.removeObject(name);
      expect(secure.values, before);
    }
  });

  test(
    'legacy primary-only index remains purgeable, poisoned control entries do not',
    () async {
      final now = DateTime.utc(2026, 11, 8);
      final secure = _MemorySecure();
      secure.values[primary] = jsonEncode(['draft:legacy']);
      secure.values['$namespace:draft%3Alegacy'] =
          'legacy synthetic ciphertext';
      final cache = PrivateCacheService.forTesting(secure, wallNow: () => now);
      expect(
        await cache.establishLogin(userId: 1, retention: _receipt(now)),
        isTrue,
      );
      expect(secure.values, isEmpty);
      secure.values[primary] = jsonEncode(['manifest']);
      expect(
        (await cache.clearCurrentAccount()).status,
        PrivateCachePurgeStatus.failed,
      );
      expect(secure.values[primary], jsonEncode(['manifest']));
    },
  );

  test(
    'old account save queued before a new login cannot write into the new context',
    () async {
      final secure = _BlockingSecure();
      final now = DateTime.utc(2026, 10, 21);
      final cache = PrivateCacheService.forTesting(secure, wallNow: () => now);
      await cache.establishLogin(userId: 1, retention: _receipt(now));
      secure.blockDelete = Completer<void>();
      secure.deleteEntered = Completer<void>();
      final blocker = cache.removeObject('queue-blocker');
      await secure.deleteEntered!.future;
      final oldSave = cache.saveAuthorized('old-A-content', {
        'text': 'synthetic account A only',
      });
      final nextLogin = cache.establishLogin(
        userId: 2,
        retention: _receipt(now, account: 2),
      );
      // Allow the new login to settle before releasing the deliberately held IO.
      await Future<void>.delayed(Duration.zero);
      secure.blockDelete!.complete();
      await blocker;
      expect(await oldSave, isFalse);
      expect(await nextLogin, isTrue);
      expect(await cache.readOnlineAuthorized('old-A-content'), isNull);
      expect(
        secure.values.values.any(
          (value) => value.contains('synthetic account A only'),
        ),
        isFalse,
      );
    },
  );
  test(
    'no login or process restart cannot unlock saved private content',
    () async {
      final secure = _MemorySecure();
      final now = DateTime.utc(2026, 10, 21);
      final cache = PrivateCacheService.forTesting(secure, wallNow: () => now);
      expect(await cache.readOnlineAuthorized('draft:one'), isNull);
      await cache.establishLogin(userId: 1, retention: _receipt(now));
      await cache.saveAuthorized('draft:one', {'text': 'synthetic private'});
      expect(await cache.readOnlineAuthorized('draft:one'), {
        'text': 'synthetic private',
      });
      final restarted = PrivateCacheService.forTesting(
        secure,
        wallNow: () => now,
      );
      expect(await restarted.readOnlineAuthorized('draft:one'), isNull);
      expect(await restarted.readOffline('draft:one'), isNull);
    },
  );

  test(
    '15 day offline window is read only and 30 day actual purge verifies deletion',
    () async {
      final secure = _MemorySecure();
      final now = DateTime.utc(2026, 10, 21);
      var elapsed = Duration.zero;
      final cache = PrivateCacheService.forTesting(
        secure,
        wallNow: () => now.add(elapsed),
        elapsed: () => elapsed,
      );
      await cache.establishLogin(userId: 1, retention: _receipt(now));
      await cache.saveAuthorized('draft:one', {'text': 'synthetic'});
      elapsed = const Duration(days: 15);
      expect(await cache.readOnlineAuthorized('draft:one'), isNull);
      cache.enterOffline();
      expect(await cache.readOffline('draft:one'), {'text': 'synthetic'});
      expect(
        await cache.saveAuthorized('draft:two', {'text': 'must not queue'}),
        isFalse,
      );
      elapsed = const Duration(days: 30);
      expect(await cache.readOffline('draft:one'), isNull);
      final purge = await cache.purgeExpired();
      expect(purge.status, PrivateCachePurgeStatus.completed);
      expect(purge.deletedObjects, 1);
      expect(secure.values, isEmpty);
    },
  );

  test(
    'silent delete failure remains locked and reports failed purge',
    () async {
      final secure = _MemorySecure();
      final now = DateTime.utc(2026, 10, 21);
      var elapsed = Duration.zero;
      final cache = PrivateCacheService.forTesting(
        secure,
        wallNow: () => now.add(elapsed),
        elapsed: () => elapsed,
      );
      await cache.establishLogin(userId: 1, retention: _receipt(now));
      await cache.saveAuthorized('draft:one', {'text': 'synthetic'});
      secure.refuseDelete = true;
      elapsed = const Duration(days: 30);
      expect(
        (await cache.purgeExpired()).status,
        PrivateCachePurgeStatus.failed,
      );
      expect(await cache.readOffline('draft:one'), isNull);
      expect(secure.values, isNotEmpty);
    },
  );

  test(
    'wrong account, time rollback, and corrupt ciphertext fail closed',
    () async {
      final secure = _MemorySecure();
      final now = DateTime.utc(2026, 10, 21);
      var wall = now;
      final cache = PrivateCacheService.forTesting(secure, wallNow: () => wall);
      expect(
        await cache.establishLogin(userId: 2, retention: _receipt(now)),
        isFalse,
      );
      await cache.establishLogin(userId: 1, retention: _receipt(now));
      await cache.saveAuthorized('draft:one', {'text': 'one'});
      wall = now.subtract(const Duration(minutes: 2));
      expect(await cache.readOnlineAuthorized('draft:one'), isNull);
      wall = now;
      await cache.establishLogin(
        userId: 2,
        retention: _receipt(now, account: 2),
      );
      expect(await cache.readOnlineAuthorized('draft:one'), isNull);
      await cache.saveAuthorized('draft:two', {'text': 'two'});
      final object = secure.values.keys.firstWhere(
        (key) => key.endsWith(':draft%3Atwo'),
      );
      secure.values[object] = 'not a valid encrypted envelope';
      expect(await cache.readOnlineAuthorized('draft:two'), isNull);
      expect(cache.isUnlocked, isFalse);
    },
  );
}

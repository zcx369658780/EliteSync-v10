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

const _ownerLocatorKey = 'v1015_private:cleanup-owner';

class _LocatorFailureSecure extends _MemorySecure {
  bool refuseLocatorDelete = false;
  bool refuseLocatorWrite = false;
  bool refuseCompletionWrite = false;
  bool refuseActiveOwnerWrite = false;
  @override
  Future<void> write(String key, String value) async {
    if (key == _ownerLocatorKey) {
      final version = (jsonDecode(value) as Map)['version'];
      if (refuseLocatorWrite ||
          (refuseCompletionWrite && version == 2) ||
          (refuseActiveOwnerWrite && version == 1)) {
        return;
      }
    }
    await super.write(key, value);
  }

  @override
  Future<void> delete(String key) async {
    if (refuseLocatorDelete && key == _ownerLocatorKey) return;
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

  test(
    'unconfirmed cleanup phase preserves indexes and retries after restart',
    () async {
      final secure = _LocatorFailureSecure();
      final now = DateTime.utc(2026, 11, 11);
      final cache = PrivateCacheService.forTesting(secure, wallNow: () => now);
      await cache.establishLogin(userId: 1, retention: _receipt(now));
      await cache.saveAuthorized('draft:one', {'text': 'private'});
      final owner = secure.values[_ownerLocatorKey];
      final first = secure.values[primary];
      final second = secure.values[recovery];
      secure.values['credential'] = 'retain';
      secure.refuseCompletionWrite = true;
      expect(
        (await cache.clearCurrentAccount()).status,
        PrivateCachePurgeStatus.failed,
      );
      expect(secure.values['$namespace:draft%3Aone'], isNull);
      expect(secure.values[primary], first);
      expect(secure.values[recovery], second);
      expect(secure.values[_ownerLocatorKey], owner);
      final restarted = PrivateCacheService.forTesting(
        secure,
        wallNow: () => now,
      );
      expect(
        (await restarted.clearCurrentAccount()).status,
        PrivateCachePurgeStatus.failed,
      );
      secure.refuseCompletionWrite = false;
      expect(
        (await restarted.clearCurrentAccount()).status,
        PrivateCachePurgeStatus.completed,
      );
      expect(secure.values, {'credential': 'retain'});
    },
  );

  test(
    'silent active-owner rewrite failure cannot write new private content',
    () async {
      final secure = _LocatorFailureSecure();
      final now = DateTime.utc(2026, 11, 11);
      final cache = PrivateCacheService.forTesting(secure, wallNow: () => now);
      await cache.establishLogin(userId: 1, retention: _receipt(now));
      await cache.saveAuthorized('draft:one', {'text': 'old'});
      expect(await cache.removeObject('draft:one'), isTrue);
      secure.values.remove(primary);
      secure.values.remove(recovery);
      final completed = jsonEncode({
        'version': 2,
        'account_id': 1,
        'device_id': 'synthetic-device',
        'objects_cleared': true,
      });
      secure.values[_ownerLocatorKey] = completed;
      secure.refuseActiveOwnerWrite = true;
      expect(
        await cache.saveAuthorized('draft:two', {
          'text': 'must not be written',
        }),
        isFalse,
      );
      expect(cache.isUnlocked, isFalse);
      expect(secure.values['$namespace:draft%3Atwo'], isNull);
      expect(secure.values[_ownerLocatorKey], completed);
      expect(secure.values[primary], jsonEncode(['draft:two']));
      expect(secure.values[recovery], jsonEncode(['draft:two']));
      final restarted = PrivateCacheService.forTesting(
        secure,
        wallNow: () => now,
      );
      expect(
        await restarted.readAfterCurrentAuthorization(
          'draft:two',
          expectedAccountId: 1,
          isCurrent: () => true,
        ),
        isNull,
      );
      secure.refuseActiveOwnerWrite = false;
      expect(
        (await restarted.clearCurrentAccount()).status,
        PrivateCachePurgeStatus.completed,
      );
      expect(secure.values, isEmpty);
    },
  );

  for (final action in ['logout', 'expiry', 'save', 'presence']) {
    test(
      'both missing indexes with a retained owner fail closed during $action',
      () async {
        final secure = _MemorySecure();
        final now = DateTime.utc(2026, 11, 11);
        var elapsed = Duration.zero;
        final cache = PrivateCacheService.forTesting(
          secure,
          wallNow: () => now.add(elapsed),
          elapsed: () => elapsed,
        );
        await cache.establishLogin(userId: 1, retention: _receipt(now));
        await cache.saveAuthorized('draft:one', {
          'text': 'must remain reachable for recovery',
        });
        secure.values['credential'] = 'keep';
        secure.values['v1015_private:a2:dother:retained'] = 'other account';
        secure.values.remove(primary);
        secure.values.remove(recovery);
        final before = Map<String, String>.from(secure.values);
        switch (action) {
          case 'logout':
            expect(
              (await cache.clearCurrentAccount()).status,
              PrivateCachePurgeStatus.failed,
            );
          case 'expiry':
            elapsed = const Duration(days: 30);
            expect(
              (await cache.purgeExpired()).status,
              PrivateCachePurgeStatus.failed,
            );
          case 'save':
            expect(
              await cache.saveAuthorized('draft:two', {
                'text': 'must not replace the index',
              }),
              isFalse,
            );
          case 'presence':
            expect(
              await cache.hasIndexedObject('draft:one', expectedAccountId: 1),
              isNull,
            );
        }
        expect(cache.isUnlocked, isFalse);
        expect(secure.values, before);
        expect(await cache.readOffline('draft:one'), isNull);
        expect(
          await cache.establishLogin(
            userId: 2,
            retention: _receipt(now.add(elapsed), account: 2),
          ),
          isFalse,
        );
        expect(secure.values, before);
        // Restore only fixture-known metadata to prove the retained target can
        // be retried; this is not an in-app recovery or enumeration mechanism.
        secure.values[recovery] = jsonEncode(['draft:one']);
        expect(
          (await cache.clearCurrentAccount()).status,
          PrivateCachePurgeStatus.completed,
        );
        expect(secure.values, {
          'credential': 'keep',
          'v1015_private:a2:dother:retained': 'other account',
        });
      },
    );
  }

  test(
    'current context reauthorizes only an open online login record',
    () async {
      final secure = _MemorySecure();
      final now = DateTime.utc(2026, 11, 11);
      final cache = PrivateCacheService.forTesting(secure, wallNow: () => now);
      await cache.establishLogin(userId: 1, retention: _receipt(now));
      await cache.saveAuthorized('draft:one', {'text': 'saved private draft'});
      cache.beginOnlineRevalidation();
      expect(await cache.readOnlineAuthorized('draft:one'), isNull);
      expect(
        await cache.readAfterCurrentAuthorization(
          'draft:one',
          expectedAccountId: 2,
          isCurrent: () => true,
        ),
        isNull,
      );
      expect(
        await cache.readAfterCurrentAuthorization(
          'draft:one',
          expectedAccountId: 1,
          isCurrent: () => false,
        ),
        isNull,
      );
      cache.enterOffline();
      expect(
        await cache.readAfterCurrentAuthorization(
          'draft:one',
          expectedAccountId: 1,
          isCurrent: () => true,
        ),
        isNull,
      );
      cache.beginOnlineRevalidation();
      expect(
        await cache.readAfterCurrentAuthorization(
          'draft:one',
          expectedAccountId: 1,
          isCurrent: () => true,
        ),
        {'text': 'saved private draft'},
      );
      final restarted = PrivateCacheService.forTesting(
        secure,
        wallNow: () => now,
      );
      expect(
        await restarted.readAfterCurrentAuthorization(
          'draft:one',
          expectedAccountId: 1,
          isCurrent: () => true,
        ),
        isNull,
      );
    },
  );

  test(
    'queued reauthorization cannot borrow a newer login generation',
    () async {
      final secure = _BlockingSecure();
      final now = DateTime.utc(2026, 11, 11);
      final cache = PrivateCacheService.forTesting(secure, wallNow: () => now);
      await cache.establishLogin(userId: 1, retention: _receipt(now));
      await cache.saveAuthorized('draft:one', {'text': 'saved private draft'});
      await cache.saveAuthorized('queue-blocker', {'text': 'blocker'});
      secure.blockDelete = Completer();
      secure.deleteEntered = Completer();
      final removal = cache.removeObject('queue-blocker');
      await secure.deleteEntered!.future;
      final pending = cache.readAfterCurrentAuthorization(
        'draft:one',
        expectedAccountId: 1,
        isCurrent: () => true,
      );
      cache.lock();
      secure.blockDelete!.complete();
      await removal;
      expect(await pending, isNull);
      expect(await cache.readOnlineAuthorized('draft:one'), isNull);
    },
  );

  test(
    'silent object deletion failure cannot acknowledge draft clearing',
    () async {
      final secure = _MemorySecure();
      final now = DateTime.utc(2026, 11, 11);
      final cache = PrivateCacheService.forTesting(secure, wallNow: () => now);
      await cache.establishLogin(userId: 1, retention: _receipt(now));
      await cache.saveAuthorized('draft:one', {'text': 'saved private draft'});
      secure.refuseDelete = true;
      await expectLater(cache.removeObject('draft:one'), throwsStateError);
      expect(secure.values['$namespace:draft%3Aone'], isNotNull);
    },
  );

  test('restart logout clears only the persisted cleanup owner', () async {
    final secure = _MemorySecure();
    final now = DateTime.utc(2026, 11, 10);
    final cache = PrivateCacheService.forTesting(secure, wallNow: () => now);
    expect(
      await cache.establishLogin(userId: 1, retention: _receipt(now)),
      isTrue,
    );
    expect(secure.values, isEmpty);
    await cache.saveAuthorized('draft:one', {'text': 'private one'});
    await cache.saveAuthorized('draft:two', {'text': 'private two'});
    expect(jsonDecode(secure.values[_ownerLocatorKey]!), {
      'version': 1,
      'account_id': 1,
      'device_id': 'synthetic-device',
    });
    final unrelated = {
      'credential': 'retain',
      'v1015_private:a9:dother:kept': 'unrelated',
    };
    secure.values.addAll(unrelated);
    final restarted = PrivateCacheService.forTesting(
      secure,
      wallNow: () => now,
    );
    expect(restarted.accountId, isNull);
    expect(await restarted.readOnlineAuthorized('draft:one'), isNull);
    expect(await restarted.readOffline('draft:one'), isNull);
    final receipt = await restarted.clearCurrentAccount();
    expect(receipt.status, PrivateCachePurgeStatus.completed);
    expect(receipt.deletedObjects, 2);
    expect(secure.values, unrelated);
    expect(restarted.isUnlocked, isFalse);
  });

  for (final (account, device) in [
    (2, 'synthetic-device'),
    (1, 'different-device'),
  ]) {
    test(
      'restart login cleans the old owner before opening $account/$device',
      () async {
        final secure = _MemorySecure();
        final now = DateTime.utc(2026, 11, 10);
        final cache = PrivateCacheService.forTesting(
          secure,
          wallNow: () => now,
        );
        await cache.establishLogin(userId: 1, retention: _receipt(now));
        await cache.saveAuthorized('draft:one', {'text': 'previous owner'});
        final restarted = PrivateCacheService.forTesting(
          secure,
          wallNow: () => now,
        );
        final login = {..._receipt(now, account: account), 'device_id': device};
        expect(
          await restarted.establishLogin(userId: account, retention: login),
          isTrue,
        );
        expect(secure.values, isEmpty);
        expect(await restarted.readOnlineAuthorized('draft:one'), isNull);
        expect(
          await restarted.saveAuthorized('draft:new', {'text': 'new owner'}),
          isTrue,
        );
        expect(jsonDecode(secure.values[_ownerLocatorKey]!), {
          'version': 1,
          'account_id': account,
          'device_id': device,
        });
        final secondRestart = PrivateCacheService.forTesting(
          secure,
          wallNow: () => now,
        );
        secondRestart.enterOffline();
        expect(secondRestart.isUnlocked, isFalse);
        expect(await secondRestart.readOffline('draft:new'), isNull);
      },
    );
  }

  test(
    'failed owner deletion remains retryable after restart without replacing owner identity',
    () async {
      final secure = _LocatorFailureSecure();
      final now = DateTime.utc(2026, 11, 10);
      final cache = PrivateCacheService.forTesting(secure, wallNow: () => now);
      await cache.establishLogin(userId: 1, retention: _receipt(now));
      await cache.saveAuthorized('draft:one', {'text': 'private'});
      final owner = secure.values[_ownerLocatorKey];
      secure.values['credential'] = 'retain';
      secure.refuseLocatorDelete = true;
      final restarted = PrivateCacheService.forTesting(
        secure,
        wallNow: () => now,
      );
      expect(
        await restarted.establishLogin(
          userId: 2,
          retention: _receipt(now, account: 2),
        ),
        isFalse,
      );
      expect(restarted.isUnlocked, isFalse);
      expect(secure.values.keys.toSet(), {_ownerLocatorKey, 'credential'});
      expect(jsonDecode(secure.values[_ownerLocatorKey]!), {
        ...jsonDecode(owner!) as Map,
        'version': 2,
        'objects_cleared': true,
      });
      expect(
        (await restarted.clearCurrentAccount()).status,
        PrivateCachePurgeStatus.failed,
      );
      secure.refuseLocatorDelete = false;
      expect(
        (await restarted.clearCurrentAccount()).status,
        PrivateCachePurgeStatus.completed,
      );
      expect(secure.values, {'credential': 'retain'});
    },
  );

  test('bad or absent cleanup owner never enumerates unrelated keys', () async {
    final now = DateTime.utc(2026, 11, 10);
    for (final owner in [
      'not JSON',
      jsonEncode({
        'version': 2,
        'account_id': 1,
        'device_id': 'synthetic-device',
      }),
      jsonEncode({
        'version': 1,
        'account_id': '1',
        'device_id': 'synthetic-device',
      }),
      jsonEncode({
        'version': 1,
        'account_id': 1,
        'device_id': 'synthetic-device',
        'namespace': 'credential',
      }),
    ]) {
      final secure = _MemorySecure();
      final cache = PrivateCacheService.forTesting(secure, wallNow: () => now);
      await cache.establishLogin(userId: 1, retention: _receipt(now));
      await cache.saveAuthorized('draft:one', {
        'text': 'retain on malformed owner',
      });
      secure.values[_ownerLocatorKey] = owner;
      secure.values['credential'] = 'retain';
      final before = Map<String, String>.from(secure.values);
      final restarted = PrivateCacheService.forTesting(
        secure,
        wallNow: () => now,
      );
      expect(
        (await restarted.clearCurrentAccount()).status,
        PrivateCachePurgeStatus.failed,
      );
      expect(
        await restarted.establishLogin(
          userId: 2,
          retention: _receipt(now, account: 2),
        ),
        isFalse,
      );
      expect(secure.values, before);
      expect(restarted.isUnlocked, isFalse);
    }
    final secure = _MemorySecure()
      ..values.addAll({
        'credential': 'retain',
        'v1015_private:a9:dunknown:kept': 'retain',
      });
    final before = Map<String, String>.from(secure.values);
    final noOwner = PrivateCacheService.forTesting(secure, wallNow: () => now);
    final result = await noOwner.clearCurrentAccount();
    expect(result.status, PrivateCachePurgeStatus.completed);
    expect(result.deletedObjects, 0);
    expect(secure.values, before);
  });

  test(
    'silent owner write failure cannot create unreachable private content',
    () async {
      final secure = _LocatorFailureSecure()..refuseLocatorWrite = true;
      final now = DateTime.utc(2026, 11, 10);
      final cache = PrivateCacheService.forTesting(secure, wallNow: () => now);
      await cache.establishLogin(userId: 1, retention: _receipt(now));
      expect(
        await cache.saveAuthorized('draft:one', {
          'text': 'must not be written',
        }),
        isFalse,
      );
      expect(cache.isUnlocked, isFalse);
      expect(secure.values.containsKey('$namespace:draft%3Aone'), isFalse);
      expect(
        secure.values.values.any(
          (value) => value.contains('must not be written'),
        ),
        isFalse,
      );
      expect(
        (await cache.clearCurrentAccount()).status,
        PrivateCachePurgeStatus.completed,
      );
      expect(secure.values, isEmpty);
      secure.refuseLocatorWrite = false;
      await cache.establishLogin(userId: 1, retention: _receipt(now));
      expect(
        await cache.saveAuthorized('draft:one', {'text': 'now reachable'}),
        isTrue,
      );
      final restarted = PrivateCacheService.forTesting(
        secure,
        wallNow: () => now,
      );
      expect(
        (await restarted.clearCurrentAccount()).status,
        PrivateCachePurgeStatus.completed,
      );
      expect(secure.values, isEmpty);
    },
  );

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
      expect(secure.values.keys.toSet(), {recovery, _ownerLocatorKey});
      expect(secure.values[recovery], jsonEncode(['draft:one']));
      expect(jsonDecode(secure.values[_ownerLocatorKey]!), {
        'version': 2,
        'account_id': 1,
        'device_id': 'synthetic-device',
        'objects_cleared': true,
      });
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

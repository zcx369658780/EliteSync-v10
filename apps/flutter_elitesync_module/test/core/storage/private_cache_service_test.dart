import 'dart:async';
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

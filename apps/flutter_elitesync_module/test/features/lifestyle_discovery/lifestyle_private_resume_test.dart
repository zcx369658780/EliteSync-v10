import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/storage/private_cache_service.dart';
import 'package:flutter_elitesync_module/core/storage/secure_storage_service.dart';

class MemorySecure extends SecureStorageService {
  final values = <String, String>{};
  @override
  Future<void> write(String key, String value) async => values[key] = value;
  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> delete(String key) async => values.remove(key);
}

void main() {
  test(
    'B1 pending survives only verified same-session restart and stays account bound',
    () async {
      final now = DateTime.utc(2026, 11, 15);
      final secure = MemorySecure();
      final receipt = {
        'user_id': 1,
        'device_id': 'synthetic-device',
        'session_id': 'family',
        'login_at': now.toIso8601String(),
        'server_now': now.toIso8601String(),
        'online_expires_at': now
            .add(const Duration(days: 15))
            .toIso8601String(),
        'purge_at': now.add(const Duration(days: 30)).toIso8601String(),
      };
      final cache = PrivateCacheService.forTesting(secure, wallNow: () => now);
      expect(await cache.establishLogin(userId: 1, retention: receipt), true);
      const key = 'lifestyle-discovery-draft:v1';
      final draft = {
        'pending': {'request_key': 'same-key', 'option_id': 'quiet'},
      };
      await cache.saveAuthorized(
        key,
        draft,
        expectedAccountId: 1,
        isCurrent: () => true,
      );
      cache.lock();
      final restarted = PrivateCacheService.forTesting(
        secure,
        wallNow: () => now,
      );
      expect(await restarted.readOnlineAuthorized(key), isNull);
      expect(
        await restarted.establishLogin(
          userId: 1,
          retention: receipt,
          verifiedResume: (sessionId: 'family', loginAt: now),
          isCurrent: () => true,
        ),
        true,
      );
      expect(await restarted.readOnlineAuthorized(key), isNull);
      expect(
        await restarted.readAfterCurrentAuthorization(
          key,
          expectedAccountId: 2,
          isCurrent: () => true,
        ),
        isNull,
      );
      expect(
        await restarted.readAfterCurrentAuthorization(
          key,
          expectedAccountId: 1,
          isCurrent: () => true,
        ),
        draft,
      );
      restarted.lock();
      expect(await restarted.readOnlineAuthorized(key), isNull);
    },
  );
}

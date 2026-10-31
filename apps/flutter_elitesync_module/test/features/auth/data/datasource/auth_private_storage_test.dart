import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/core/storage/private_cache_service.dart';
import 'package:flutter_elitesync_module/core/storage/secure_storage_service.dart';
import 'package:flutter_elitesync_module/features/auth/data/datasource/auth_local_data_source.dart';
import 'package:flutter_elitesync_module/features/auth/data/dto/login_response_dto.dart';
import 'package:flutter_elitesync_module/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_elitesync_module/features/auth/domain/entities/auth_user.dart';

class _Secure extends SecureStorageService {
  final values = <String, String>{};
  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> write(String key, String value) async => values[key] = value;
  @override
  Future<void> delete(String key) async => values.remove(key);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'real local adapter removes legacy plaintext and persists profile only through bound secure cache',
    () async {
      SharedPreferences.setMockInitialValues({
        '${CacheKeys.chatDraftPrefix}peer:2': 'old synthetic draft',
        CacheKeys.lastKnownProfile: '{"id":999}',
        CacheKeys.messagesConversationSnapshot: 'old synthetic',
        CacheKeys.homeSearchHistory: 'old synthetic search',
        'unrelated_preference': true,
      });
      final secure = _Secure();
      final local = LocalStorageService(secureStorage: secure);
      final source = AuthLocalDataSource(
        secureStorage: secure,
        localStorage: local,
      );
      final device = await source.getOrCreateDeviceId();
      expect(await source.getOrCreateDeviceId(), device);
      final now = DateTime.utc(2026, 10, 21);
      final retention = {
        'user_id': 1,
        'device_id': device,
        'session_id': 17,
        'login_at': now.toIso8601String(),
        'server_now': now.toIso8601String(),
        'online_expires_at': now
            .add(const Duration(days: 15))
            .toIso8601String(),
        'purge_at': now.add(const Duration(days: 30)).toIso8601String(),
      };
      final response = LoginResponseDto.fromJson({
        'access_token': 'synthetic',
        'session_retention': retention,
      });
      final epoch = source.beginLoginAttempt();
      await source.persistSession(
        const AuthSession(
          accessToken: 'synthetic',
          refreshToken: '',
          user: AuthUser(
            id: 1,
            phone: 'synthetic',
            role: 'user',
            nickname: '仅限密文测试',
          ),
        ),
        retention: response.sessionRetention,
        expectedEpoch: epoch,
        expectedDeviceId: device,
      );
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getKeys().where(CacheKeys.isPrivate), isEmpty);
      expect(prefs.getBool('unrelated_preference'), isTrue);
      expect((await local.getJson(CacheKeys.lastKnownProfile))?['id'], 1);
      expect(
        secure.values.keys.any((key) => key.startsWith('v1015_private:a1:')),
        isTrue,
      );
      PrivateCacheService.forStorage(secure).lock();
      expect(await local.getJson(CacheKeys.lastKnownProfile), isNull);
      expect(
        await local.setString('${CacheKeys.chatDraftPrefix}peer:2', 'refused'),
        isFalse,
      );
      expect(prefs.getKeys().where(CacheKeys.isPrivate), isEmpty);
    },
  );

  test(
    'obsolete login and mismatched device cannot replace stored credentials',
    () async {
      SharedPreferences.setMockInitialValues({});
      final secure = _Secure();
      final source = AuthLocalDataSource(
        secureStorage: secure,
        localStorage: LocalStorageService(secureStorage: secure),
      );
      final obsolete = source.beginLoginAttempt();
      source.beginLoginAttempt();
      const session = AuthSession(
        accessToken: 'obsolete-synthetic',
        refreshToken: '',
        user: AuthUser(id: 1, phone: 'synthetic', role: 'user'),
      );
      await expectLater(
        source.persistSession(session, expectedEpoch: obsolete),
        throwsStateError,
      );
      expect(secure.values[CacheKeys.accessToken], isNull);
      await expectLater(
        source.persistSession(
          session,
          retention: {'device_id': 'other'},
          expectedDeviceId: 'current',
        ),
        throwsStateError,
      );
      expect(secure.values[CacheKeys.accessToken], isNull);
    },
  );
}

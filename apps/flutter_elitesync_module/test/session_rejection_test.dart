import 'dart:async';

import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/storage/secure_storage_service.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Secure extends SecureStorageService {
  final values = <String, String>{};
  bool failDelete = false;
  bool failRead = false;
  Completer<void>? deleteGate;
  final deleteEntered = Completer<void>();
  @override
  Future<String?> read(String key) async {
    if (failRead) throw StateError('fixture read failure');
    return values[key];
  }

  @override
  Future<void> write(String key, String value) async => values[key] = value;
  @override
  Future<void> delete(String key) async {
    if (!deleteEntered.isCompleted) deleteEntered.complete();
    if (deleteGate != null) await deleteGate!.future;
    if (failDelete) throw StateError('fixture delete failure');
    values.remove(key);
  }
}

const oldUser = UserSummary(id: 1001, phone: 'fictional-old', city: '旧城市');
const newUser = UserSummary(id: 1002, phone: 'fictional-new', city: '新城市');
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Secure secure;
  late ProviderContainer container;
  late SessionNotifier notifier;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    secure = _Secure();
    container = ProviderContainer(
      overrides: [secureStorageProvider.overrideWithValue(secure)],
    );
    await container.read(sessionProvider.future);
    notifier = container.read(sessionProvider.notifier);
    await notifier.setAuthenticated(
      accessToken: 'fixture-old',
      refreshToken: 'fixture-refresh',
      user: oldUser,
    );
  });
  tearDown(() => container.dispose());
  test(
    'matching rejected token clears state, credentials and profile snapshots',
    () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(CacheKeys.profileDetailSnapshot, '{"city":"历史城市"}');
      await prefs.setString(
        CacheKeys.profileSummarySnapshot,
        '{"city":"历史城市"}',
      );
      await notifier
          .setUnauthenticated(notice: '账号已禁用', rejectedToken: 'fixture-old')
          .timeout(const Duration(seconds: 2));
      final state = container.read(sessionProvider).value!;
      expect(state.status, AuthStatus.unauthenticated);
      expect(state.notice, '账号已禁用');
      expect(container.read(sessionRejectionNoticeProvider), '账号已禁用');
      expect(state.user, isNull);
      expect(secure.values, isEmpty);
      for (final key in [
        CacheKeys.lastKnownProfile,
        CacheKeys.profileDetailSnapshot,
        CacheKeys.profileSummarySnapshot,
      ]) {
        expect(prefs.containsKey(key), false);
      }
    },
  );
  test('stale response cannot clear newer login token or profile', () async {
    await notifier.setAuthenticated(accessToken: 'fixture-new', user: newUser);
    await notifier
        .setUnauthenticated(rejectedToken: 'fixture-old')
        .timeout(const Duration(seconds: 2));
    expect(container.read(sessionProvider).value?.accessToken, 'fixture-new');
    expect(container.read(sessionProvider).value?.user?.id, 1002);
    expect(secure.values[CacheKeys.accessToken], 'fixture-new');
  });
  test(
    'storage delete failure stays unauthenticated and queue recovers',
    () async {
      secure.failDelete = true;
      await expectLater(
        notifier
            .setUnauthenticated(notice: '登录失效', rejectedToken: 'fixture-old')
            .timeout(const Duration(seconds: 2)),
        throwsStateError,
      );
      expect(
        container.read(sessionProvider).value?.status,
        AuthStatus.unauthenticated,
      );
      expect(container.read(sessionProvider).value?.accessToken, isNull);
      secure.failDelete = false;
      await notifier
          .setAuthenticated(accessToken: 'fixture-new', user: newUser)
          .timeout(const Duration(seconds: 2));
      expect(container.read(sessionProvider).value?.user?.id, 1002);
      expect(container.read(sessionRejectionNoticeProvider), isNull);
    },
  );
  test('rejection cleanup serializes before simultaneous new login', () async {
    secure.deleteGate = Completer<void>();
    final rejected = notifier.setUnauthenticated(rejectedToken: 'fixture-old');
    await secure.deleteEntered.future.timeout(const Duration(seconds: 2));
    final login = notifier.setAuthenticated(
      accessToken: 'fixture-new',
      user: newUser,
    );
    final update = notifier.updateProfile(
      const UserSummary(id: 1002, phone: 'fictional-new', city: '更新城市'),
    );
    expect(
      container.read(sessionProvider).value?.status,
      AuthStatus.unauthenticated,
    );
    secure.deleteGate!.complete();
    await Future.wait([
      rejected,
      login,
      update,
    ]).timeout(const Duration(seconds: 2));
    expect(secure.values[CacheKeys.accessToken], 'fixture-new');
    expect(container.read(sessionProvider).value?.user?.city, '更新城市');
  });
  test(
    'old account profile completion cannot contaminate newer login',
    () async {
      await notifier.setAuthenticated(
        accessToken: 'fixture-new',
        user: newUser,
      );
      await notifier.updateProfile(oldUser).timeout(const Duration(seconds: 2));
      expect(container.read(sessionProvider).value?.user?.id, 1002);
      expect(container.read(sessionProvider).value?.user?.city, '新城市');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(CacheKeys.lastKnownProfile), contains('1002'));
      expect(
        prefs.getString(CacheKeys.lastKnownProfile),
        isNot(contains('1001')),
      );
    },
  );
  test('late profile completion cannot resurrect rejected session', () async {
    await notifier.setUnauthenticated(rejectedToken: 'fixture-old');
    await notifier.updateProfile(oldUser).timeout(const Duration(seconds: 2));
    final state = container.read(sessionProvider).value!;
    expect(state.status, AuthStatus.unauthenticated);
    expect(state.user, isNull);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey(CacheKeys.lastKnownProfile), false);
  });
  test('read failure during rejection also fails closed', () async {
    secure.failRead = true;
    await expectLater(
      notifier
          .setUnauthenticated(rejectedToken: 'fixture-old')
          .timeout(const Duration(seconds: 2)),
      throwsStateError,
    );
    expect(
      container.read(sessionProvider).value?.status,
      AuthStatus.unauthenticated,
    );
  });
}

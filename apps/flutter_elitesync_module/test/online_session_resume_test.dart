import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/core/storage/private_cache_service.dart';
import 'package:flutter_elitesync_module/core/storage/secure_storage_service.dart';
import 'package:flutter_elitesync_module/features/auth/data/datasource/auth_local_data_source.dart';
import 'package:flutter_elitesync_module/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_elitesync_module/features/auth/domain/entities/auth_user.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/pending_logout_store.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Secure extends SecureStorageService {
  final values = <String, String>{};
  String? failRead;
  bool failWrite = false;
  String? writeFailureSuffix;
  String? deleteFailureSuffix;
  bool silentFailure = false;
  String? holdWriteSuffix;
  String? holdDeleteSuffix;
  Completer<void>? ioEntered;
  Completer<void>? ioRelease;
  final writes = <String>[];
  final deletes = <String>[];
  Future<void> _hold(String key, String? suffix) async {
    if (suffix == null || !key.endsWith(suffix)) return;
    if (!ioEntered!.isCompleted) ioEntered!.complete();
    await ioRelease!.future;
  }

  @override
  Future<String?> read(String key) async {
    if (key == failRead) throw StateError('synthetic read failure');
    return values[key];
  }

  @override
  Future<void> write(String key, String value) async {
    await _hold(key, holdWriteSuffix);
    writes.add(key);
    if (failWrite) throw StateError('synthetic write failure');
    if (writeFailureSuffix != null && key.endsWith(writeFailureSuffix!)) {
      if (silentFailure) return;
      throw StateError('synthetic selective write failure');
    }
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    await _hold(key, holdDeleteSuffix);
    deletes.add(key);
    if (deleteFailureSuffix != null && key.endsWith(deleteFailureSuffix!)) {
      if (silentFailure) return;
      throw StateError('synthetic selective delete failure');
    }
    values.remove(key);
  }
}

class _Api extends ApiClient {
  _Api() : super(dio: Dio());
  int calls = 0;
  final entered = Completer<void>();
  final reply = Completer<NetworkResult<Map<String, dynamic>>>();
  @override
  Future<NetworkResult<Map<String, dynamic>>> post(
    String path, {
    Object? body,
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) {
    calls++;
    expect(path, '/api/v1/auth/session/verify');
    expect(body, {'refresh_token': 'old-refresh'});
    expect(options?.headers?['Authorization'], 'Bearer old-access');
    if (!entered.isCompleted) entered.complete();
    return reply.future;
  }
}

class _HeldCleanup extends LocalStorageService {
  _HeldCleanup(_Secure secure) : super(secureStorage: secure);
  final entered = Completer<void>();
  final gate = Completer<bool>();
  int calls = 0;
  @override
  Future<bool> purgeLegacyPrivateCache() async {
    if (++calls != 1) return true;
    entered.complete();
    return gate.future;
  }
}

final _login = DateTime.utc(2026, 11, 1);
Map<String, dynamic> _retention() => {
  'user_id': 1,
  'device_id': 'old-device',
  'session_id': 'old-family',
  'login_at': _login.toIso8601String(),
  'server_now': _login.add(const Duration(days: 2)).toIso8601String(),
  'online_expires_at': _login.add(const Duration(days: 15)).toIso8601String(),
  'purge_at': _login.add(const Duration(days: 30)).toIso8601String(),
};
Map<String, dynamic> _reply() => {
  'verified': true,
  'session_id': 'old-family',
  'user': {
    'id': 1,
    'phone': 'fictional',
    'role': 'user',
    'nickname': 'fresh server',
  },
  'session_retention': _retention(),
};
Future<void> _settle(ProviderContainer container) async {
  for (var i = 0; i < 100; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 1));
    if (container.read(sessionProvider).asData?.value.status !=
        AuthStatus.unknown) {
      return;
    }
  }
  fail('Session did not settle');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Secure secure;
  late _Api api;
  ProviderContainer start({LocalStorageService? local}) {
    final container = ProviderContainer(
      overrides: [
        secureStorageProvider.overrideWithValue(secure),
        restrictedAccountClientProvider.overrideWithValue(api),
        if (local != null) localStorageProvider.overrideWithValue(local),
      ],
    );
    addTearDown(container.dispose);
    container.read(sessionProvider);
    return container;
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    secure = _Secure();
    api = _Api();
    secure.values[CacheKeys.privateDeviceBinding] = 'old-device';
    final source = AuthLocalDataSource(
      secureStorage: secure,
      localStorage: LocalStorageService(secureStorage: secure),
    );
    await source.persistSession(
      const AuthSession(
        accessToken: 'old-access',
        refreshToken: 'old-refresh',
        user: AuthUser(id: 1, phone: 'fictional', role: 'user'),
      ),
      retention: _retention(),
      expectedDeviceId: 'old-device',
    );
    await PrivateCacheService.forStorage(
      secure,
    ).saveAuthorized('old-message', {'text': 'old'});
    PrivateCacheService.forStorage(secure).lock();
  });

  const draftKey = 'live-chat-draft:2';
  const ns = 'v1015_private:a1:dold-device';
  final storedDraftKey = '$ns:${Uri.encodeComponent(draftKey)}';
  Future<void> seedDraft() async {
    final cache = PrivateCacheService.forStorage(secure);
    await cache.establishLogin(userId: 1, retention: _retention());
    expect(
      await cache.saveAuthorized(draftKey, {
        'text': 'unsent text',
        'pending_attempt': {
          'client_message_id': 'f10a7f10-84d2-4cba-b51a-c0b3ca87b005',
          'peer_user_id': 2,
          'content': 'unsent text',
          'attachment_ids': <int>[],
        },
      }),
      isTrue,
    );
    expect(await cache.saveAuthorized('old-message', {'text': 'old'}), isTrue);
    cache.lock();
  }

  for (final field in [
    'account_id',
    'session_id',
    'device_id',
    'login_at',
    'object_id',
    'malformed',
  ]) {
    test('verified resume does not retain a draft with wrong $field', () async {
      await seedDraft();
      final envelope = jsonDecode(secure.values[storedDraftKey]!) as Map;
      envelope[field] = field == 'account_id' ? 2 : 'wrong';
      secure.values[storedDraftKey] = field == 'malformed'
          ? '{'
          : jsonEncode(envelope);
      final container = start();
      await api.entered.future;
      api.reply.complete(NetworkSuccess(_reply()));
      await _settle(container);
      expect(container.read(sessionProvider).asData?.value.isLoggedIn, isTrue);
      expect(secure.values[storedDraftKey], isNull);
      expect(
        await PrivateCacheService.forStorage(
          secure,
        ).readAfterCurrentAuthorization(
          draftKey,
          expectedAccountId: 1,
          isCurrent: () => true,
        ),
        isNull,
      );
    });
  }

  for (final silent in [false, true]) {
    for (final target in ['recovery-index', 'primary-index', 'old-object']) {
      test(
        'resume $target silent=$silent fails locked with pending draft retained and cleanable',
        () async {
          await seedDraft();
          final saved = secure.values[storedDraftKey];
          secure.silentFailure = silent;
          if (target == 'old-object') {
            secure.deleteFailureSuffix = ':old-message';
          } else {
            secure.writeFailureSuffix = target == 'recovery-index'
                ? ':manifest-recovery'
                : ':manifest';
          }
          final container = start();
          await api.entered.future;
          api.reply.complete(NetworkSuccess(_reply()));
          await _settle(container);
          expect(
            container.read(sessionProvider).asData?.value.isLoggedIn,
            isFalse,
          );
          expect(PrivateCacheService.forStorage(secure).isUnlocked, isFalse);
          expect(secure.values[CacheKeys.privateResumeAllowed], isNull);
          expect(secure.values[storedDraftKey], saved);
          secure.writeFailureSuffix = null;
          secure.deleteFailureSuffix = null;
          expect(
            (await PrivateCacheService.forStorage(
              secure,
            ).clearCurrentAccount()).status,
            PrivateCachePurgeStatus.completed,
          );
          expect(secure.values[storedDraftKey], isNull);
        },
      );
    }
  }

  test(
    'verified resume rejects missing dual indexes without losing the draft',
    () async {
      await seedDraft();
      final saved = secure.values[storedDraftKey];
      final owner = secure.values['v1015_private:cleanup-owner'];
      secure.values.remove('$ns:manifest');
      secure.values.remove('$ns:manifest-recovery');
      final container = start();
      await api.entered.future;
      api.reply.complete(NetworkSuccess(_reply()));
      await _settle(container);
      expect(container.read(sessionProvider).asData?.value.isLoggedIn, isFalse);
      expect(PrivateCacheService.forStorage(secure).isUnlocked, isFalse);
      expect(secure.values[storedDraftKey], saved);
      expect(secure.values['v1015_private:cleanup-owner'], owner);
      expect(secure.values['$ns:manifest'], isNull);
      expect(secure.values['$ns:manifest-recovery'], isNull);
    },
  );

  test(
    '129 matching drafts in the index union fail before namespace mutations',
    () async {
      await seedDraft();
      final template = jsonDecode(secure.values[storedDraftKey]!) as Map;
      final keys = [
        for (var peer = 2; peer <= 130; peer++) 'live-chat-draft:$peer',
      ];
      for (final key in keys) {
        secure.values['$ns:${Uri.encodeComponent(key)}'] = jsonEncode({
          ...template,
          'object_id': key,
        });
      }
      secure.values['$ns:manifest'] = jsonEncode(keys.take(65).toList());
      secure.values['$ns:manifest-recovery'] = jsonEncode(
        keys.skip(65).toList(),
      );
      final before = Map<String, String>.fromEntries(
        secure.values.entries.where((e) => e.key.startsWith('$ns:')),
      );
      final writes = secure.writes.where((k) => k.startsWith('$ns:')).length;
      final deletes = secure.deletes.where((k) => k.startsWith('$ns:')).length;
      final container = start();
      await api.entered.future;
      api.reply.complete(NetworkSuccess(_reply()));
      await _settle(container);
      expect(container.read(sessionProvider).asData?.value.isLoggedIn, isFalse);
      expect(
        Map<String, String>.fromEntries(
          secure.values.entries.where((e) => e.key.startsWith('$ns:')),
        ),
        before,
      );
      expect(secure.writes.where((k) => k.startsWith('$ns:')).length, writes);
      expect(secure.deletes.where((k) => k.startsWith('$ns:')).length, deletes);
    },
  );

  for (final operation in ['delete', 'index-write']) {
    for (final action in ['logout', 'switch']) {
      test(
        '$action while verified resume awaits $operation cannot revive the old context',
        () async {
          await seedDraft();
          secure.ioEntered = Completer();
          secure.ioRelease = Completer();
          if (operation == 'delete') {
            secure.holdDeleteSuffix = ':old-message';
          } else {
            secure.holdWriteSuffix = ':manifest-recovery';
          }
          final container = start();
          await api.entered.future;
          api.reply.complete(NetworkSuccess(_reply()));
          await secure.ioEntered!.future;
          final notifier = container.read(sessionProvider.notifier);
          Future<void> next;
          if (action == 'logout') {
            next = notifier.setUnauthenticated();
          } else {
            final source = AuthLocalDataSource(
              secureStorage: secure,
              localStorage: LocalStorageService(secureStorage: secure),
            );
            next = source.persistSession(
              const AuthSession(
                accessToken: 'new-access',
                refreshToken: 'new-refresh',
                user: AuthUser(id: 2, phone: 'new-fictional', role: 'user'),
              ),
              retention: {
                ..._retention(),
                'user_id': 2,
                'session_id': 'new-family',
              },
              expectedEpoch: source.beginLoginAttempt(),
            );
          }
          secure.ioRelease!.complete();
          await next;
          if (action == 'switch') {
            await notifier.setAuthenticated(
              accessToken: 'new-access',
              refreshToken: 'new-refresh',
              user: const UserSummary(id: 2, phone: 'new-fictional'),
            );
            expect(container.read(sessionProvider).asData?.value.user?.id, 2);
            expect(secure.values[CacheKeys.accessToken], 'new-access');
            expect(PrivateCacheService.forStorage(secure).accountId, 2);
          } else {
            expect(
              container.read(sessionProvider).asData?.value.isLoggedIn,
              isFalse,
            );
            expect(PrivateCacheService.forStorage(secure).isUnlocked, isFalse);
            expect(secure.values[CacheKeys.privateResumeAllowed], isNull);
          }
          expect(secure.values[storedDraftKey], isNull);
        },
      );
    }
  }

  test(
    'explicit login still clears live text drafts with the same binding',
    () async {
      await seedDraft();
      final source = AuthLocalDataSource(
        secureStorage: secure,
        localStorage: LocalStorageService(secureStorage: secure),
      );
      await source.persistSession(
        const AuthSession(
          accessToken: 'old-access',
          refreshToken: 'old-refresh',
          user: AuthUser(id: 1, phone: 'fictional', role: 'user'),
        ),
        retention: _retention(),
        expectedDeviceId: 'old-device',
      );
      expect(secure.values[storedDraftKey], isNull);
    },
  );

  test(
    'fresh online verification restores once and discards old private objects',
    () async {
      final container = start();
      expect(
        container.read(sessionProvider).asData?.value.status,
        AuthStatus.unknown,
      );
      expect(PrivateCacheService.forStorage(secure).isUnlocked, isFalse);
      await api.entered.future;
      api.reply.complete(NetworkSuccess(_reply()));
      await _settle(container);
      expect(
        container.read(sessionProvider).asData?.value.user?.nickname,
        'fresh server',
      );
      expect(
        container.read(sessionProvider).asData?.value.accessToken,
        'old-access',
      );
      final binding =
          jsonDecode(secure.values[CacheKeys.privateResumeAllowed]!) as Map;
      expect(binding['login_at'], _login.toIso8601String());
      final cache = PrivateCacheService.forStorage(secure);
      expect(cache.isUnlocked, isTrue);
      expect(await cache.readOnlineAuthorized('old-message'), isNull);
      expect(api.calls, 1);
    },
  );

  test(
    'a resume hint without a trusted receipt cannot publish credentials',
    () async {
      await seedDraft();
      final before = secure.values[storedDraftKey];
      final source = AuthLocalDataSource(
        secureStorage: secure,
        localStorage: LocalStorageService(secureStorage: secure),
      );
      final epoch = source.beginLoginAttempt();
      await expectLater(
        source.persistSession(
          const AuthSession(
            accessToken: 'new-access',
            refreshToken: 'new-refresh',
            user: AuthUser(id: 1, phone: 'fictional', role: 'user'),
          ),
          expectedEpoch: epoch,
          expectedDeviceId: 'old-device',
          isCurrent: () => true,
          verifiedResume: (sessionId: 'old-family', loginAt: _login),
        ),
        throwsStateError,
      );
      expect(PrivateCacheService.forStorage(secure).isUnlocked, isFalse);
      expect(secure.values[CacheKeys.accessToken], 'old-access');
      expect(secure.values[storedDraftKey], before);
    },
  );

  for (final pending in [false, true]) {
    test(
      'same verified cold session retains only text draft pending=$pending',
      () async {
        final cache = PrivateCacheService.forStorage(secure);
        await cache.establishLogin(userId: 1, retention: _retention());
        final draft = <String, dynamic>{
          'text': 'unsent text',
          if (pending)
            'pending_attempt': {
              'client_message_id': 'f10a7f10-84d2-4cba-b51a-c0b3ca87b005',
              'peer_user_id': 2,
              'content': 'unsent text',
              'attachment_ids': <int>[],
            },
        };
        expect(await cache.saveAuthorized('live-chat-draft:2', draft), isTrue);
        expect(
          await cache.saveAuthorized('old-message', {'text': 'old'}),
          isTrue,
        );
        cache.lock();
        final container = start();
        await api.entered.future;
        expect(await cache.readOnlineAuthorized('live-chat-draft:2'), isNull);
        expect(await cache.readOffline('live-chat-draft:2'), isNull);
        api.reply.complete(NetworkSuccess(_reply()));
        await _settle(container);
        expect(
          container.read(sessionProvider).asData?.value.isLoggedIn,
          isTrue,
        );
        expect(await cache.readOnlineAuthorized('old-message'), isNull);
        expect(await cache.readOnlineAuthorized('live-chat-draft:2'), isNull);
        expect(
          await cache.readAfterCurrentAuthorization(
            'live-chat-draft:2',
            expectedAccountId: 2,
            isCurrent: () => true,
          ),
          isNull,
        );
        expect(
          await cache.readAfterCurrentAuthorization(
            'live-chat-draft:2',
            expectedAccountId: 1,
            isCurrent: () => false,
          ),
          isNull,
        );
        expect(
          await cache.readAfterCurrentAuthorization(
            'live-chat-draft:2',
            expectedAccountId: 1,
            isCurrent: () => true,
          ),
          draft,
        );
        final binding =
            jsonDecode(secure.values[CacheKeys.privateResumeAllowed]!) as Map;
        expect(binding['access_token'], 'old-access');
        expect(binding['refresh_token'], 'old-refresh');
        expect(binding['session_id'], 'old-family');
        expect(binding['login_at'], _login.toIso8601String());
        expect(api.calls, 1);
      },
    );
  }

  for (final field in [
    'user',
    'device',
    'session',
    't0',
    'expired',
    'missing',
    'unverified',
  ]) {
    test('bad $field response stays locked', () async {
      final container = start();
      await api.entered.future;
      final data = _reply();
      final retention = data['session_retention'] as Map<String, dynamic>;
      switch (field) {
        case 'user':
          data['user'] = {'id': 2};
          retention['user_id'] = 2;
        case 'device':
          retention['device_id'] = 'wrong';
        case 'session':
          data['session_id'] = retention['session_id'] = 'wrong';
        case 't0':
          retention['login_at'] = _login
              .add(const Duration(days: 1))
              .toIso8601String();
          retention['online_expires_at'] = _login
              .add(const Duration(days: 16))
              .toIso8601String();
          retention['purge_at'] = _login
              .add(const Duration(days: 31))
              .toIso8601String();
        case 'expired':
          retention['server_now'] = retention['online_expires_at'];
        case 'missing':
          data.remove('session_retention');
        case 'unverified':
          data['verified'] = false;
      }
      api.reply.complete(NetworkSuccess(data));
      await _settle(container);
      expect(container.read(sessionProvider).asData?.value.isLoggedIn, isFalse);
      expect(PrivateCacheService.forStorage(secure).isUnlocked, isFalse);
    });
  }
  test('offline failure stays locked with no automatic retry', () async {
    final container = start();
    await api.entered.future;
    api.reply.complete(const NetworkFailure(message: 'synthetic offline'));
    await _settle(container);
    expect(container.read(sessionProvider).asData?.value.isLoggedIn, isFalse);
    expect(api.calls, 1);
    expect(PrivateCacheService.forStorage(secure).isUnlocked, isFalse);
  });
  for (final reason in ['legacy', 'pending', 'pending-read', 'binding']) {
    test('$reason candidate is never sent online', () async {
      switch (reason) {
        case 'legacy':
          secure.values.remove(CacheKeys.privateResumeAllowed);
        case 'pending':
          await PendingLogoutStore.add(secure, 'old-refresh');
        case 'pending-read':
          secure.failRead = 'pending_logout_credentials';
        case 'binding':
          secure.values[CacheKeys.accessToken] = 'unbound-access';
      }
      final container = start();
      await _settle(container);
      expect(api.calls, 0);
      expect(container.read(sessionProvider).asData?.value.isLoggedIn, isFalse);
    });
  }
  test(
    'storage failure after verification never publishes authenticated',
    () async {
      final container = start();
      await api.entered.future;
      secure.failWrite = true;
      api.reply.complete(NetworkSuccess(_reply()));
      await _settle(container);
      expect(container.read(sessionProvider).asData?.value.isLoggedIn, isFalse);
      expect(PrivateCacheService.forStorage(secure).isUnlocked, isFalse);
    },
  );
  for (final success in [true, false]) {
    test(
      'late verification $success cannot replace or lock newer login',
      () async {
        final container = start();
        await api.entered.future;
        final notifier = container.read(sessionProvider.notifier);
        final source = AuthLocalDataSource(
          secureStorage: secure,
          localStorage: LocalStorageService(secureStorage: secure),
        );
        final retention = _retention()..['user_id'] = 2;
        retention['session_id'] = 'new-family';
        await source.persistSession(
          const AuthSession(
            accessToken: 'new-access',
            refreshToken: 'new-refresh',
            user: AuthUser(id: 2, phone: 'fictional-new', role: 'user'),
          ),
          retention: retention,
          expectedEpoch: source.beginLoginAttempt(),
        );
        await notifier.setAuthenticated(
          accessToken: 'new-access',
          user: const UserSummary(id: 2, phone: 'fictional-new'),
          refreshToken: 'new-refresh',
        );
        api.reply.complete(
          success
              ? NetworkSuccess(_reply())
              : const NetworkFailure(message: 'old failure'),
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(container.read(sessionProvider).asData?.value.user?.id, 2);
        expect(secure.values[CacheKeys.accessToken], 'new-access');
        expect(PrivateCacheService.forStorage(secure).isUnlocked, isTrue);
        expect(PrivateCacheService.forStorage(secure).accountId, 2);
        expect(
          jsonDecode(secure.values[CacheKeys.privateResumeAllowed]!)['user_id'],
          2,
        );
      },
    );
  }
  test('late verification cannot resurrect explicit logout', () async {
    final container = start();
    await api.entered.future;
    await container.read(sessionProvider.notifier).setUnauthenticated();
    api.reply.complete(NetworkSuccess(_reply()));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(container.read(sessionProvider).asData?.value.isLoggedIn, isFalse);
    expect(secure.values[CacheKeys.privateResumeAllowed], isNull);
    expect(PrivateCacheService.forStorage(secure).isUnlocked, isFalse);
  });
  test('disposed verifier cannot overwrite storage', () async {
    final container = ProviderContainer(
      overrides: [
        secureStorageProvider.overrideWithValue(secure),
        restrictedAccountClientProvider.overrideWithValue(api),
      ],
    );
    container.read(sessionProvider);
    await api.entered.future;
    container.dispose();
    api.reply.complete(NetworkSuccess(_reply()));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(PrivateCacheService.forStorage(secure).isUnlocked, isFalse);
    expect(secure.values[CacheKeys.accessToken], 'old-access');
  });
  test('late failed startup cleanup cannot overwrite explicit login', () async {
    final local = _HeldCleanup(secure);
    final container = start(local: local);
    await local.entered.future;
    await container
        .read(sessionProvider.notifier)
        .setAuthenticated(
          accessToken: 'new-access',
          user: const UserSummary(id: 2, phone: 'fictional-new'),
        );
    local.gate.complete(false);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(container.read(sessionProvider).asData?.value.user?.id, 2);
    expect(api.calls, 0);
  });
}

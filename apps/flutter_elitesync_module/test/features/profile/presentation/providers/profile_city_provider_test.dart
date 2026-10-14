import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/storage/secure_storage_service.dart';
import 'package:flutter_elitesync_module/features/profile/data/datasource/profile_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/profile/data/mapper/profile_mapper.dart';
import 'package:flutter_elitesync_module/features/profile/data/repository/profile_repository_impl.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_detail_entity.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Client extends ApiClient {
  _Client() : super(dio: Dio());
  String city = '旧城市';
  String? failure;
  bool postFails = false;
  final calls = <String>[];
  Completer<void>? requestGate;
  Completer<void>? requestEntered;
  String? pausedMethod;

  Future<void> pause(String method) async {
    if (pausedMethod != method) return;
    pausedMethod = null;
    requestEntered!.complete();
    await requestGate!.future;
  }

  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    calls.add('GET $path');
    final responseCity = city;
    await pause('GET');
    return failure == null
        ? NetworkSuccess({'city': responseCity})
        : NetworkFailure(message: failure!, statusCode: 401);
  }

  @override
  Future<NetworkResult<Map<String, dynamic>>> post(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    calls.add('POST $path');
    if (postFails) {
      return const NetworkFailure(message: '拒绝保存', statusCode: 403);
    }
    city = (body as Map)['city'] as String;
    final responseCity = city;
    await pause('POST');
    return NetworkSuccess({
      'ok': true,
      'user': {'city': responseCity},
    });
  }
}

const oldUser = UserSummary(id: 1001, phone: 'fictional-old', city: '旧城市');
const newUser = UserSummary(id: 1002, phone: 'fictional-new', city: '新账户城市');

class _Session extends SessionNotifier {
  @override
  Future<SessionState> build() async => const SessionState(
    status: AuthStatus.authenticated,
    accessToken: 'fixture-old',
    user: oldUser,
  );

  void switchAccount(bool login) {
    state = AsyncData(
      login
          ? const SessionState(
              status: AuthStatus.authenticated,
              accessToken: 'fixture-new',
              user: newUser,
            )
          : const SessionState(status: AuthStatus.unauthenticated),
    );
  }
}

class _Memory extends LocalStorageService {
  int writes = 0;
  final saved = <Map<String, dynamic>>[];
  final values = <String, Map<String, dynamic>>{};
  Completer<void>? writeGate;
  Completer<void>? writeEntered;
  String? pauseKey;
  @override
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    writes++;
    if (key == pauseKey) {
      pauseKey = null;
      writeEntered!.complete();
      await writeGate!.future;
    }
    values[key] = Map.of(value);
    saved.add(Map.of(value));
    return true;
  }

  @override
  Future<Map<String, dynamic>?> getJson(String key) async =>
      values[key] ?? {'city': '缓存城市'};
  @override
  Future<bool> remove(String key) async {
    values.remove(key);
    return true;
  }

  @override
  Future<Set<String>> getKeys() async => values.keys.toSet();
}

class _Secure extends SecureStorageService {
  final values = <String, String>{CacheKeys.accessToken: 'fixture-old'};
  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }
}

void main() {
  late _Client client;
  late _Memory memory;
  late ProviderContainer container;
  setUp(() {
    client = _Client();
    memory = _Memory();
    final remote = ProfileRemoteDataSource(apiClient: client, useMock: false);
    container = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith(_Session.new),
        localStorageProvider.overrideWithValue(memory),
        secureStorageProvider.overrideWithValue(_Secure()),
        profileRemoteDataSourceProvider.overrideWithValue(remote),
        profileRepositoryProvider.overrideWithValue(
          ProfileRepositoryImpl(remote: remote, mapper: const ProfileMapper()),
        ),
      ],
    );
  });
  tearDown(() => container.dispose());
  test(
    'notifier publishes server readback with no draft cache or astro action',
    () async {
      final subscription = container.listen(editProfileProvider, (_, _) {});
      addTearDown(subscription.close);
      await container.read(sessionProvider.future);
      await container.read(editProfileProvider.future);
      memory.writes = 0;
      client.calls.clear();
      final confirmed = await container
          .read(editProfileProvider.notifier)
          .saveCity('新城市');
      expect(confirmed.city, '新城市');
      expect(container.read(editProfileProvider).value?.detail?.city, '新城市');
      expect(client.calls, [
        'POST /api/v1/profile/city',
        'GET /api/v1/profile/basic',
      ]);
      expect(memory.writes, 0);
    },
  );
  test(
    'failed city preserves old detail only with explicit error and no writes',
    () async {
      final subscription = container.listen(editProfileProvider, (_, _) {});
      addTearDown(subscription.close);
      await container.read(sessionProvider.future);
      await container.read(editProfileProvider.future);
      memory.writes = 0;
      client.postFails = true;
      await expectLater(
        container.read(editProfileProvider.notifier).saveCity('新城市'),
        throwsException,
      );
      final state = container.read(editProfileProvider).value!;
      expect(state.detail?.city, '旧城市');
      expect(state.error, contains('拒绝保存'));
      expect(memory.writes, 0);
    },
  );
  test('authentication rejected read does not return cached profile', () async {
    client.failure = 'Unauthorized';
    await container.read(sessionProvider.future);
    final state = await container.read(editProfileProvider.future);
    expect(state.detail, isNull);
    expect(state.error, contains('登录已失效'));
    expect(memory.writes, 0);
  });
  for (final login in [false, true]) {
    for (final operation in ['city', 'full', 'detail']) {
      test(
        'late $operation after ${login ? 'new login' : 'logout'} cannot publish or cache old result',
        () async {
          final subscription = container.listen(editProfileProvider, (_, _) {});
          addTearDown(subscription.close);
          await container.read(sessionProvider.future);
          await container.read(editProfileProvider.future);
          client.requestGate = Completer<void>();
          client.requestEntered = Completer<void>();
          client.pausedMethod = operation == 'full' ? 'POST' : 'GET';
          Future<bool>? success;
          if (operation == 'detail') {
            client.city = '旧请求城市';
            container.invalidate(editProfileProvider);
            container
                .read(editProfileProvider.future)
                .then((_) {}, onError: (Object _) {});
          } else {
            final notifier = container.read(editProfileProvider.notifier);
            final pending = operation == 'city'
                ? notifier.saveCity('旧请求城市')
                : notifier.save(
                    const ProfileDetailEntity(
                      nickname: '旧用户',
                      gender: 'male',
                      birthday: '2000-01-01',
                      birthTime: '12:00',
                      city: '旧请求城市',
                      target: 'dating',
                    ),
                  );
            success = pending.then((_) => true, onError: (Object _) => false);
          }
          await client.requestEntered!.future.timeout(
            const Duration(seconds: 2),
          );
          client.city = login ? '新账户城市' : '';
          (container.read(sessionProvider.notifier) as _Session).switchAccount(
            login,
          );
          await container.read(editProfileProvider.future);
          memory.saved.clear();
          memory.writes = 0;
          client.requestGate!.complete();
          if (success != null) {
            expect(
              await success.timeout(const Duration(seconds: 2)),
              false,
              reason:
                  'late mutation cannot report server-confirmed success in changed session',
            );
          }
          await Future<void>.delayed(const Duration(milliseconds: 10));
          expect(
            memory.saved.where((item) => item['city'] == '旧请求城市'),
            isEmpty,
          );
          final session = container.read(sessionProvider).value!;
          expect(session.user?.id, login ? 1002 : null);
          expect(session.user?.city, login ? '新账户城市' : null);
          expect(
            container.read(editProfileProvider).value?.detail?.city,
            isNot('旧请求城市'),
          );
        },
      );
    }
  }
  for (final login in [false, true]) {
    test(
      'pending real cache write serializes with logout${login ? ' and new login' : ''}',
      () async {
        final subscription = container.listen(editProfileProvider, (_, _) {});
        addTearDown(subscription.close);
        await container.read(sessionProvider.future);
        await container.read(editProfileProvider.future);
        memory.pauseKey = CacheKeys.profileDetailSnapshot;
        memory.writeGate = Completer<void>();
        memory.writeEntered = Completer<void>();
        final saving = container
            .read(editProfileProvider.notifier)
            .save(
              const ProfileDetailEntity(
                nickname: '旧用户',
                gender: 'male',
                birthday: '2000-01-01',
                birthTime: '12:00',
                city: '旧请求城市',
                target: 'dating',
              ),
            )
            .then((_) => true, onError: (Object _) => false);
        await memory.writeEntered!.future.timeout(const Duration(seconds: 2));
        final session = container.read(sessionProvider.notifier);
        final logout = session.setUnauthenticated();
        final nextLogin = login
            ? session.setAuthenticated(
                accessToken: 'fixture-new',
                user: newUser,
              )
            : null;
        client.city = login ? '新账户城市' : '';
        // Never await logout before releasing this write: correct code queues it.
        memory.writeGate!.complete();
        await logout.timeout(const Duration(seconds: 2));
        if (nextLogin != null) {
          await nextLogin.timeout(const Duration(seconds: 2));
        }
        await saving.timeout(const Duration(seconds: 2));
        await container.read(editProfileProvider.future);
        expect(
          memory.values[CacheKeys.profileDetailSnapshot]?['city'],
          isNot('旧请求城市'),
        );
        expect(
          memory.values[CacheKeys.profileSummarySnapshot]?['city'],
          isNot('旧请求城市'),
        );
        final state = container.read(sessionProvider).value!;
        expect(state.user?.id, login ? 1002 : null);
        expect(state.user?.city, login ? '新账户城市' : null);
        if (!login) {
          expect(
            memory.values.containsKey(CacheKeys.profileDetailSnapshot),
            false,
          );
          expect(
            memory.values.containsKey(CacheKeys.profileSummarySnapshot),
            false,
          );
          expect(memory.values.containsKey(CacheKeys.lastKnownProfile), false);
        } else {
          expect(memory.values[CacheKeys.lastKnownProfile]?['id'], 1002);
        }
      },
    );
  }
}

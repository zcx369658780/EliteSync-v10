import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/core/storage/private_cache_service.dart';
import 'package:flutter_elitesync_module/core/storage/secure_storage_service.dart';
import 'package:flutter_elitesync_module/features/chat/data/datasource/chat_socket_data_source.dart';
import 'package:flutter_elitesync_module/features/chat/data/dto/message_dto.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/pages/live_chat_page.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/providers/chat_providers.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

class _Secure extends SecureStorageService {
  final data = <String, String>{};
  @override
  Future<String?> read(String key) async => data[key];
  @override
  Future<void> write(String key, String value) async {
    data[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    data.remove(key);
  }
}

class _Session extends SessionNotifier {
  @override
  Future<SessionState> build() async => const SessionState(
    status: AuthStatus.authenticated,
    user: UserSummary(id: 1, phone: 'synthetic'),
    accessToken: 'synthetic-a',
  );
  void switchAccount() {
    state = const AsyncData(
      SessionState(
        status: AuthStatus.authenticated,
        user: UserSummary(id: 3, phone: 'synthetic'),
        accessToken: 'synthetic-c',
      ),
    );
  }
}

class _Api extends ApiClient {
  _Api() : super(dio: Dio());
  int reads = 0;
  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    reads++;
    return const NetworkSuccess({'items': <dynamic>[]});
  }
}

class _SocketSource extends ChatSocketDataSource {
  _SocketSource()
    : super(
        apiClient: ApiClient(dio: Dio()),
        localStorage: LocalStorageService(),
        env: const AppEnv(
          flavor: AppFlavor.dev,
          appName: 'synthetic',
          apiBaseUrl: 'http://127.0.0.1:49572/',
          useMockData: false,
        ),
      );
  int canceled = 0;
  final channels = <StreamController<MessageDto>>[];
  @override
  Stream<MessageDto> observe(String conversationId) {
    final channel = StreamController<MessageDto>.broadcast(
      onCancel: () {
        canceled++;
      },
    );
    channels.add(channel);
    return channel.stream;
  }

  void frame(int channel) {
    channels[channel].add(
      const MessageDto(
        id: 'synthetic-invalidation',
        mine: false,
        text: '',
        time: '',
        attachments: [],
      ),
    );
  }

  Future<void> closeFixtures() async {
    for (final c in channels) {
      await c.close();
    }
  }
}

class _Fixture {
  _Fixture(this.container, this.api, this.socket);
  final ProviderContainer container;
  final _Api api;
  final _SocketSource socket;
}

Future<_Fixture> _mount(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final secure = _Secure();
  final api = _Api();
  final socket = _SocketSource();
  final now = DateTime.utc(2026, 10, 31);
  final cache = PrivateCacheService.forTesting(
    secure,
    wallNow: () => now,
    elapsed: () => Duration.zero,
  );
  await cache.establishLogin(
    userId: 1,
    retention: {
      'user_id': 1,
      'device_id': 'synthetic',
      'session_id': 1,
      'login_at': now.toIso8601String(),
      'server_now': now.toIso8601String(),
      'online_expires_at': now.add(const Duration(days: 15)).toIso8601String(),
      'purge_at': now.add(const Duration(days: 30)).toIso8601String(),
    },
  );
  final container = ProviderContainer(
    overrides: [
      secureStorageProvider.overrideWithValue(secure),
      apiClientProvider.overrideWithValue(api),
      sessionProvider.overrideWith(_Session.new),
      chatSocketDataSourceProvider.overrideWithValue(socket),
    ],
  );
  await container.read(sessionProvider.future);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: LiveChatPage(peerId: 2)),
    ),
  );
  await tester.pumpAndSettle();
  expect(socket.channels.length, 1);
  return _Fixture(container, api, socket);
}

Future<void> _dispose(WidgetTester tester, _Fixture f) async {
  await tester.pumpWidget(const SizedBox.shrink());
  f.container.dispose();
  await f.socket.closeFixtures();
}

void main() {
  testWidgets(
    'account change cancels subscription; old invalidation cannot read as new account',
    (tester) async {
      final f = await _mount(tester);
      final before = f.api.reads;
      (f.container.read(sessionProvider.notifier) as _Session).switchAccount();
      await tester.pump();
      expect(f.socket.canceled, 1);
      f.socket.frame(0);
      await tester.pump(const Duration(milliseconds: 20));
      expect(f.api.reads, before);
      expect(f.socket.channels.length, 1);
      await _dispose(tester, f);
    },
  );
  testWidgets(
    'authority epoch cancels old subscription before any next frame',
    (tester) async {
      final f = await _mount(tester);
      final before = f.api.reads;
      f.container
          .read(relationshipAuthorityEpochProvider.notifier)
          .invalidate();
      await tester.pump();
      expect(f.socket.canceled, 1);
      f.socket.frame(0);
      await tester.pump(const Duration(milliseconds: 20));
      expect(f.api.reads, before);
      await _dispose(tester, f);
    },
  );
  testWidgets(
    'pause cancels and resume subscribes only after current HTTP revalidation',
    (tester) async {
      final f = await _mount(tester);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(f.socket.canceled, 1);
      final before = f.api.reads;
      f.socket.frame(0);
      await tester.pump();
      expect(f.api.reads, before);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(f.socket.channels.length, 2);
      final fresh = f.api.reads;
      f.socket.frame(0);
      await tester.pump();
      expect(f.api.reads, fresh);
      f.socket.frame(1);
      await tester.pumpAndSettle();
      expect(f.api.reads, fresh + 1);
      await _dispose(tester, f);
      expect(f.socket.canceled, 2);
    },
  );
  testWidgets('page dispose cancels subscription and no late read remains', (
    tester,
  ) async {
    final f = await _mount(tester);
    final before = f.api.reads;
    await tester.pumpWidget(const SizedBox.shrink());
    expect(f.socket.canceled, 1);
    f.socket.frame(0);
    await tester.pump();
    expect(f.api.reads, before);
    f.container.dispose();
    await f.socket.closeFixtures();
  });
}

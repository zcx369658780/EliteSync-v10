import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/storage/private_cache_service.dart';
import 'package:flutter_elitesync_module/core/storage/secure_storage_service.dart';
import 'package:flutter_elitesync_module/features/chat/data/gateway/chat_media_gateway.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/pages/live_chat_page.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/pages/live_conversation_list_page.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

class _Secure extends SecureStorageService {
  final values = <String, String>{};
  Completer<void>? chatWrite;
  bool writeBlocked = false;
  bool failChatWrites = false;
  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> write(String key, String value) async {
    if (key.endsWith(':live-chat%3A2')) {
      final pending = chatWrite;
      chatWrite = null;
      if (pending != null) {
        writeBlocked = true;
        await pending.future;
      }
      if (failChatWrites) throw StateError('Synthetic encrypted-store failure');
    }
    values[key] = value;
  }
  @override
  Future<void> delete(String key) async => values.remove(key);
}

class _Session extends SessionNotifier {
  @override
  SessionState build() => const SessionState(
    status: AuthStatus.authenticated,
    user: UserSummary(id: 1, phone: 'synthetic'),
  );
  void switchAccount() => state = const AsyncData(SessionState(
    status: AuthStatus.authenticated,
    user: UserSummary(id: 2, phone: 'synthetic'),
  ));
}

class _Api extends ApiClient {
  _Api() : super(dio: Dio());
  Completer<NetworkResult<Map<String, dynamic>>>? listRead;
  int listReads = 0;
  final posts = <Map<String, dynamic>>[];
  static const listResponse = NetworkSuccess<Map<String, dynamic>>({
    'ok': true,
    'items': [
      {'peer_user_id': 2, 'conversation_id': 12, 'name': 'Synthetic peer',
       'last_message': 'Synthetic previous message', 'unread': 0},
    ],
  });
  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {CancelToken? cancelToken, Map<String, dynamic>? query,
    Options? options,
  }) async {
    if (path == '/api/v1/conversations') {
      listReads++;
      return listRead?.future ?? Future.value(listResponse);
    }
    if (path == '/api/v1/messages') {
      return const NetworkSuccess({'items': [
        {'id': 4, 'content': 'Synthetic previous message', 'attachments': <dynamic>[]},
      ]});
    }
    throw StateError('Unexpected synthetic GET: $path');
  }
  @override
  Future<NetworkResult<Map<String, dynamic>>> post(
    String path, {Object? body, CancelToken? cancelToken,
    Map<String, dynamic>? query, Options? options,
  }) async {
    if (path != '/api/v1/messages') throw StateError('Unexpected synthetic POST');
    final data = Map<String, dynamic>.from(body as Map);
    posts.add(data);
    return NetworkSuccess({'id': 18, 'client_message_id': data['client_message_id']});
  }
}

class _Gateway implements SessionBoundChatMediaGateway {
  final picked = Completer<ChatPickedMedia?>();
  final uploaded = Completer<ChatMediaUploadResponse>();
  int uploads = 0;
  @override
  Future<ChatPickedMedia?> pick(ChatAttachmentKind kind) => picked.future;
  @override
  Future<ChatMediaUploadResponse> upload(ChatAttachmentKind kind, ChatPickedMedia media) =>
      throw StateError('Unbound upload must not be called');
  @override
  Future<ChatMediaUploadResponse> uploadForSession(
    ChatAttachmentKind kind, ChatPickedMedia media, {
    required bool Function() isCurrent, required CancelToken cancelToken,
  }) {
    if (!isCurrent() || cancelToken.isCancelled) throw StateError('Stale upload');
    uploads++;
    return uploaded.future;
  }
}

class _Fixture {
  _Fixture(this.secure, this.cache, this.api, this.gateway, this.container, this.router);
  final _Secure secure;
  final PrivateCacheService cache;
  final _Api api;
  final _Gateway gateway;
  final ProviderContainer container;
  final GoRouter router;
}

Future<_Fixture> _mount(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final secure = _Secure();
  final api = _Api();
  final gateway = _Gateway();
  final now = DateTime.utc(2026, 11, 8);
  final cache = PrivateCacheService.forTesting(secure,
    wallNow: () => now, elapsed: () => Duration.zero);
  final container = ProviderContainer(overrides: [
    secureStorageProvider.overrideWithValue(secure),
    apiClientProvider.overrideWithValue(api),
    sessionProvider.overrideWith(_Session.new),
    liveChatMediaGatewayProvider.overrideWithValue(gateway),
  ]);
  await container.read(sessionProvider.future);
  await cache.establishLogin(userId: 1, retention: {
    'user_id': 1, 'device_id': 'synthetic-retained-device', 'session_id': 'synthetic-session',
    'login_at': now.toIso8601String(), 'server_now': now.toIso8601String(),
    'online_expires_at': now.add(const Duration(days: 15)).toIso8601String(),
    'purge_at': now.add(const Duration(days: 30)).toIso8601String(),
  });
  final router = GoRouter(routes: [
    GoRoute(path: '/', builder: (_, _) => const LiveConversationListPage()),
    GoRoute(path: '/live-chat/:peerId', builder: (_, state) =>
      LiveChatPage(peerId: int.parse(state.pathParameters['peerId']!))),
  ]);
  await tester.pumpWidget(UncontrolledProviderScope(container: container,
    child: MaterialApp.router(routerConfig: router)));
  await tester.pumpAndSettle();
  unawaited(router.push('/live-chat/2'));
  await tester.pumpAndSettle();
  expect(find.byType(LiveConversationListPage, skipOffstage: false), findsOneWidget);
  expect(find.byType(LiveChatPage), findsOneWidget);
  return _Fixture(secure, cache, api, gateway, container, router);
}

Future<void> _race(WidgetTester tester, _Fixture f, {bool failStore = false}) async {
  await tester.tap(find.byTooltip('发送图片'));
  await tester.pump();
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
  await tester.pump();
  final list = Completer<NetworkResult<Map<String, dynamic>>>();
  final store = Completer<void>();
  f.api.listRead = list;
  f.secure.chatWrite = store;
  f.secure.failChatWrites = failStore;
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  await tester.pump();
  await tester.pump();
  expect(f.secure.writeBlocked, isTrue);
  expect(f.api.listReads, greaterThan(1));
  f.gateway.picked.complete(const ChatPickedMedia(path: 'synthetic.jpg', name: 'synthetic.jpg'));
  await tester.pump();
  await tester.pump();
  expect(f.gateway.uploads, 1);
  // Complete the retained list GET while the foreground chat's actual
  // encrypted object write and uploaded-media response are both suspended.
  list.complete(_Api.listResponse);
  await tester.pump();
  store.complete();
  await tester.pumpAndSettle();
  f.gateway.uploaded.complete(const ChatMediaUploadResponse(assetId: 31, publicUrl: null, status: 'ready'));
  await tester.pumpAndSettle();
}

Future<void> _dispose(WidgetTester tester, _Fixture f) async {
  await tester.pumpWidget(const SizedBox.shrink());
  f.router.dispose();
  f.container.dispose();
}

void main() {
  testWidgets('retained list refresh cannot invalidate foreground chat cache save and attachment send', (tester) async {
    final f = await _mount(tester);
    try {
      await _race(tester, f);
      expect(find.text('会话已锁定'), findsNothing);
      expect(f.cache.isUnlocked, isTrue);
      expect(f.api.posts, hasLength(1));
      expect(f.api.posts.single['attachment_ids'], [31]);
    } finally {
      await _dispose(tester, f);
    }
  });

  testWidgets('retained list refresh cannot bypass real encrypted-store failure', (tester) async {
    final f = await _mount(tester);
    try {
      await _race(tester, f, failStore: true);
      expect(find.text('会话已锁定'), findsOneWidget);
      expect(f.api.posts, isEmpty);
    } finally {
      await _dispose(tester, f);
    }
  });
}

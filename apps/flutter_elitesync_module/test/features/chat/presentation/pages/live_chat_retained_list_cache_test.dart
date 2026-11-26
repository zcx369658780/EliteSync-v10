import 'dart:async';
import 'dart:io';
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
  Completer<void>? listWrite;
  bool writeBlocked = false;
  bool listWriteBlocked = false;
  bool failChatWrites = false;
  bool failDraftRead = false;
  @override
  Future<String?> read(String key) async {
    if (failDraftRead && key.endsWith(':live-chat-draft%3A2')) {
      throw StateError('Synthetic encrypted draft read failure');
    }
    return values[key];
  }

  @override
  Future<void> write(String key, String value) async {
    if (key.endsWith(':live-conversations%3Avisible') && listWrite != null) {
      final pending = listWrite!;
      listWrite = null;
      listWriteBlocked = true;
      await pending.future;
    }
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
  void switchAccount() => state = const AsyncData(
    SessionState(
      status: AuthStatus.authenticated,
      user: UserSummary(id: 2, phone: 'synthetic'),
    ),
  );
}

class _Api extends ApiClient {
  _Api() : super(dio: Dio());
  Completer<NetworkResult<Map<String, dynamic>>>? listRead;
  Completer<NetworkResult<Map<String, dynamic>>>? chatRead;
  bool offline = false;
  bool timeoutFirstSend = false;
  String roomKey = 'synthetic-room';
  int chatReads = 0;
  int listReads = 0;
  final posts = <Map<String, dynamic>>[];
  static const listResponse = NetworkSuccess<Map<String, dynamic>>({
    'ok': true,
    'items': [
      {
        'peer_user_id': 2,
        'conversation_id': 12,
        'name': 'Synthetic peer',
        'last_message': 'Synthetic previous message',
        'unread': 0,
      },
    ],
  });
  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    if (path == '/api/v1/conversations') {
      listReads++;
      if (offline) return unavailable(path);
      return listRead?.future ?? Future.value(listResponse);
    }
    if (path == '/api/v1/messages') {
      chatReads++;
      final pending = chatRead;
      if (pending != null) return pending.future;
      if (offline) return unavailable(path);
      return NetworkSuccess({
        'room_key': roomKey,
        'offline_text_grant': {
          'scope': 'conversation_text_v1',
          'account_id': 1,
          'peer_id': 2,
          'session_id': 'synthetic-session',
          'device_id': 'synthetic-retained-device',
          'room_key': roomKey,
          'issued_at': '2026-11-08T00:00:00Z',
          'expires_at': '2026-11-09T00:00:00Z',
        },
        'items': [
          {
            'id': 4,
            'room_id': roomKey,
            'sender_id': 2,
            'is_read': true,
            'message_type': 'text',
            'has_attachments': false,
            'content': roomKey == 'synthetic-room'
                ? 'Synthetic previous message'
                : 'Synthetic replacement message',
            'attachments': <dynamic>[],
          },
        ],
      });
    }
    throw StateError('Unexpected synthetic GET: $path');
  }

  static NetworkFailure<Map<String, dynamic>> unavailable(String path) =>
      NetworkFailure(
        message: 'Synthetic transport failure',
        error: DioException(
          requestOptions: RequestOptions(path: path),
          type: DioExceptionType.connectionTimeout,
        ),
      );

  @override
  Future<NetworkResult<Map<String, dynamic>>> post(
    String path, {
    Object? body,
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    if (path != '/api/v1/messages') {
      throw StateError('Unexpected synthetic POST');
    }
    final data = Map<String, dynamic>.from(body as Map);
    posts.add(data);
    if (timeoutFirstSend && posts.length == 1) return unavailable(path);
    return NetworkSuccess({
      'id': 18,
      'client_message_id': data['client_message_id'],
    });
  }
}

class _Gateway implements SessionBoundChatMediaGateway {
  final picked = Completer<ChatPickedMedia?>();
  final uploaded = Completer<ChatMediaUploadResponse>();
  int uploads = 0;
  @override
  Future<ChatPickedMedia?> pick(ChatAttachmentKind kind) => picked.future;
  @override
  Future<ChatMediaUploadResponse> upload(
    ChatAttachmentKind kind,
    ChatPickedMedia media,
  ) => throw StateError('Unbound upload must not be called');
  @override
  Future<ChatMediaUploadResponse> uploadForSession(
    ChatAttachmentKind kind,
    ChatPickedMedia media, {
    required bool Function() isCurrent,
    required CancelToken cancelToken,
  }) {
    if (!isCurrent() || cancelToken.isCancelled) {
      throw StateError('Stale upload');
    }
    uploads++;
    return uploaded.future;
  }
}

class _Fixture {
  _Fixture(
    this.secure,
    this.cache,
    this.api,
    this.gateway,
    this.container,
    this.router,
  );
  final _Secure secure;
  final PrivateCacheService cache;
  final _Api api;
  final _Gateway gateway;
  final ProviderContainer container;
  final GoRouter router;
}

Future<_Fixture> _mount(
  WidgetTester tester, {
  bool pendingInitialChat = false,
}) async {
  SharedPreferences.setMockInitialValues({});
  final secure = _Secure();
  final api = _Api();
  if (pendingInitialChat) api.chatRead = Completer();
  final gateway = _Gateway();
  final now = DateTime.utc(2026, 11, 8);
  final cache = PrivateCacheService.forTesting(
    secure,
    wallNow: () => now,
    elapsed: () => Duration.zero,
  );
  final container = ProviderContainer(
    overrides: [
      secureStorageProvider.overrideWithValue(secure),
      apiClientProvider.overrideWithValue(api),
      sessionProvider.overrideWith(_Session.new),
      liveChatMediaGatewayProvider.overrideWithValue(gateway),
    ],
  );
  await container.read(sessionProvider.future);
  await cache.establishLogin(
    userId: 1,
    retention: {
      'user_id': 1,
      'device_id': 'synthetic-retained-device',
      'session_id': 'synthetic-session',
      'login_at': now.toIso8601String(),
      'server_now': now.toIso8601String(),
      'online_expires_at': now.add(const Duration(days: 15)).toIso8601String(),
      'purge_at': now.add(const Duration(days: 30)).toIso8601String(),
    },
  );
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const LiveConversationListPage()),
      GoRoute(
        path: '/live-chat/:peerId',
        builder: (_, state) =>
            LiveChatPage(peerId: int.parse(state.pathParameters['peerId']!)),
      ),
    ],
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  unawaited(router.push('/live-chat/2'));
  await tester.pumpAndSettle();
  expect(
    find.byType(LiveConversationListPage, skipOffstage: false),
    findsOneWidget,
  );
  expect(find.byType(LiveChatPage), findsOneWidget);
  return _Fixture(secure, cache, api, gateway, container, router);
}

Future<void> _race(
  WidgetTester tester,
  _Fixture f, {
  bool failStore = false,
  bool failList = false,
}) async {
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
  f.gateway.picked.complete(
    const ChatPickedMedia(path: 'synthetic.jpg', name: 'synthetic.jpg'),
  );
  await tester.pump();
  await tester.pump();
  // The current attachment path reauthorizes/restores the encrypted draft before upload.
  // A suspended store write must not be bypassed by the retained list refresh.
  expect(f.gateway.uploads, 0);
  // Complete the retained list GET while the foreground chat's actual
  // encrypted object write and uploaded-media response are both suspended.
  list.complete(
    failList ? _Api.unavailable('/api/v1/conversations') : _Api.listResponse,
  );
  await tester.pump();
  store.complete();
  await tester.pumpAndSettle();
  expect(f.gateway.uploads, failStore ? 0 : 1);
  f.gateway.uploaded.complete(
    const ChatMediaUploadResponse(
      assetId: 31,
      publicUrl: null,
      status: 'ready',
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _dispose(WidgetTester tester, _Fixture f) async {
  await tester.pumpWidget(const SizedBox.shrink());
  f.router.dispose();
  f.container.dispose();
}

void _pause(WidgetTester tester) {
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
}

void _resume(WidgetTester tester) {
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
}

void main() {
  testWidgets('covered list timeout cannot invalidate a fresh chat grant', (
    tester,
  ) async {
    final f = await _mount(tester);
    try {
      final list = Completer<NetworkResult<Map<String, dynamic>>>();
      final store = Completer<void>();
      f.api.listRead = list;
      await tester.pump(const Duration(seconds: 5));
      expect(f.api.listReads, greaterThan(1));
      f.secure.chatWrite = store;
      await tester.tap(find.byTooltip('刷新对话'));
      await tester.pump();
      expect(f.secure.writeBlocked, isTrue);
      f.api.offline = true;
      list.complete(
        NetworkFailure(
          message: 'Covered list transport cut',
          error: DioException(
            requestOptions: RequestOptions(path: '/api/v1/conversations'),
            type: DioExceptionType.unknown,
            error: const HttpException('Connection closed while receiving data'),
          ),
        ),
      );
      await tester.pump();
      store.complete();
      await tester.pumpAndSettle();

      expect(f.cache.isUnlocked, isTrue);
      expect(find.text('Synthetic previous message'), findsOneWidget);
      await tester.tap(find.byTooltip('刷新对话'));
      await tester.pumpAndSettle();
      expect(find.text('Synthetic previous message'), findsOneWidget);
      expect(find.textContaining('离线只读'), findsOneWidget);
      expect(tester.widget<TextField>(find.byType(TextField)).readOnly, isTrue);
    } finally {
      await _dispose(tester, f);
    }
  });

  testWidgets(
    'a list generation change retires text while the chat is closed',
    (tester) async {
      final f = await _mount(tester);
      try {
        expect(find.text('Synthetic previous message'), findsOneWidget);
        f.router.pop();
        await tester.pumpAndSettle();
        expect(find.byType(LiveChatPage), findsNothing);

        f.api.listRead = Completer()
          ..complete(
            const NetworkSuccess({
              'ok': true,
              'items': [
                {
                  'peer_user_id': 2,
                  'conversation_id': 13,
                  'room_key': 'new-room',
                },
              ],
            }),
          );
        await tester.tap(find.byTooltip('刷新会话'));
        await tester.pumpAndSettle();
        expect(await f.cache.readOnlineAuthorized('live-chat:2'), isNull);

        f.api.chatRead = Completer()
          ..complete(_Api.unavailable('/api/v1/messages'));
        unawaited(f.router.push('/live-chat/2'));
        await tester.pumpAndSettle();
        expect(find.byType(LiveChatPage), findsOneWidget);
        expect(find.text('Synthetic previous message'), findsNothing);
        expect(find.textContaining('离线只读。当前只显示'), findsNothing);
      } finally {
        await _dispose(tester, f);
      }
    },
  );

  testWidgets('an encrypted draft read failure leaves the chat locked', (
    tester,
  ) async {
    final f = await _mount(tester);
    try {
      f.api.timeoutFirstSend = true;
      await tester.enterText(find.byType(TextField), 'Synthetic pending text');
      await tester.tap(find.text('发送'));
      await tester.pumpAndSettle();
      expect(f.api.posts, hasLength(1));

      f.secure.failDraftRead = true;
      await tester.tap(find.byTooltip('刷新对话'));
      await tester.pumpAndSettle();
      expect(f.cache.isUnlocked, isFalse);
      expect(find.text('会话已锁定'), findsOneWidget);
      expect(find.text('Synthetic previous message'), findsNothing);
      expect(find.text('使用原消息编号重试'), findsNothing);
    } finally {
      await _dispose(tester, f);
    }
  });

  testWidgets('a list response fences a late successful old-room chat read', (
    tester,
  ) async {
    final f = await _mount(tester);
    try {
      final previous = await f.api.get('/api/v1/messages');
      f.api.roomKey = 'replacement-room';
      final replacement = await f.api.get('/api/v1/messages');
      final oldChat = Completer<NetworkResult<Map<String, dynamic>>>();
      final newChat = Completer<NetworkResult<Map<String, dynamic>>>();
      final list = Completer<NetworkResult<Map<String, dynamic>>>();
      f.api.chatRead = oldChat;
      f.api.listRead = list;
      _pause(tester);
      _resume(tester);
      await tester.pumpAndSettle();
      final readsBeforeList = f.api.chatReads;

      f.api.chatRead = newChat;
      list.complete(
        const NetworkSuccess({
          'ok': true,
          'items': [
            {
              'peer_user_id': 2,
              'conversation_id': 13,
              'room_key': 'replacement-room',
            },
          ],
        }),
      );
      await tester.pumpAndSettle();
      expect(f.api.chatReads, greaterThan(readsBeforeList));
      oldChat.complete(previous);
      await tester.pumpAndSettle();
      expect(find.text('Synthetic previous message'), findsNothing);
      expect(await f.cache.readOnlineAuthorized('live-chat:2'), isNull);

      newChat.complete(replacement);
      await tester.pumpAndSettle();
      expect(find.text('Synthetic replacement message'), findsOneWidget);
      expect(
        (await f.cache.readOnlineAuthorized('live-chat:2'))?['room_key'],
        'replacement-room',
      );
    } finally {
      await _dispose(tester, f);
    }
  });

  testWidgets('an unknown unbound send cannot be retried in a confirmed room', (
    tester,
  ) async {
    final f = await _mount(tester, pendingInitialChat: true);
    final initialChat = f.api.chatRead!;
    try {
      f.api.timeoutFirstSend = true;
      await tester.enterText(find.byType(TextField), 'Synthetic unbound text');
      await tester.tap(find.text('发送'));
      await tester.pumpAndSettle();
      expect(f.api.posts, hasLength(1));
      expect(find.text('使用原消息编号重试'), findsOneWidget);

      _pause(tester);
      f.api.chatRead = null;
      f.api.roomKey = 'replacement-room';
      _resume(tester);
      await tester.pumpAndSettle();
      initialChat.complete(_Api.unavailable('/api/v1/messages'));
      await tester.pumpAndSettle();
      expect(find.text('Synthetic replacement message'), findsOneWidget);
      expect(find.text('使用原消息编号重试'), findsNothing);
      expect(find.text('Synthetic unbound text'), findsNothing);
      expect(f.api.posts, hasLength(1));
    } finally {
      await _dispose(tester, f);
    }
  });

  testWidgets(
    'same-process foreground return can reuse only the offline text grant',
    (tester) async {
      final f = await _mount(tester);
      try {
        f.api.offline = true;
        await tester.tap(find.byTooltip('刷新对话'));
        await tester.pumpAndSettle();
        expect(find.textContaining('离线只读'), findsOneWidget);
        expect(find.text('Synthetic previous message'), findsOneWidget);

        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.inactive,
        );
        await tester.pumpAndSettle();
        expect(find.text('Synthetic previous message'), findsNothing);
        _pause(tester);
        final readsBeforeResume = f.api.chatReads;

        _resume(tester);
        await tester.pumpAndSettle();
        expect(f.api.chatReads, greaterThan(readsBeforeResume));
        expect(find.textContaining('离线只读'), findsOneWidget);
        expect(find.text('Synthetic previous message'), findsOneWidget);
        expect(
          tester.widget<TextField>(find.byType(TextField)).readOnly,
          isTrue,
        );
        expect(await f.cache.readOffline('live-conversations:visible'), isNull);
        expect(await f.cache.readOffline('live-chat:2'), isNull);
        expect(f.api.posts, isEmpty);
      } finally {
        await _dispose(tester, f);
      }
    },
  );

  testWidgets('a late list update only revokes the changed peer while offline', (
    tester,
  ) async {
    final f = await _mount(tester);
    try {
      expect(await f.cache.saveAuthorizedChatText(
        3,
        {
          'room_key': 'other-old-room',
          'messages': [
            {'id': 5, 'content': 'Another synthetic conversation'},
          ],
          'offline_text_grant': {
            'scope': 'conversation_text_v1',
            'account_id': 1,
            'peer_id': 3,
            'session_id': 'synthetic-session',
            'device_id': 'synthetic-retained-device',
            'room_key': 'other-old-room',
            'issued_at': '2026-11-08T00:00:00Z',
            'expires_at': '2026-11-09T00:00:00Z',
          },
        },
        expectedAccountId: 1,
        isCurrent: () => true,
      ), isTrue);
      final list = Completer<NetworkResult<Map<String, dynamic>>>();
      final chat = Completer<NetworkResult<Map<String, dynamic>>>();
      f.api.listRead = list;
      f.api.chatRead = chat;
      _pause(tester);
      _resume(tester);
      await tester.pumpAndSettle();

      chat.complete(_Api.unavailable('/api/v1/messages'));
      await tester.pumpAndSettle();
      expect(find.text('Synthetic previous message'), findsOneWidget);
      expect(await f.cache.readOfflineChatText(3), isNotNull);
      list.complete(const NetworkSuccess({
        'ok': true,
        'items': [
          {'peer_user_id': 2, 'conversation_id': 12, 'room_key': 'synthetic-room'},
          {'peer_user_id': 3, 'conversation_id': 14, 'room_key': 'other-new-room'},
        ],
      }));
      await tester.pumpAndSettle();
      expect(f.cache.isOffline, isTrue);
      expect(await f.cache.readOfflineChatText(2), isNotNull);
      expect(await f.cache.readOfflineChatText(3), isNull);
      expect(find.text('Synthetic previous message'), findsOneWidget);
    } finally {
      await _dispose(tester, f);
    }
  });

  for (final listFirst in [true, false]) {
    testWidgets('new generation list response retires pre-background text '
        '${listFirst ? 'before' : 'after'} the chat transport fails', (
      tester,
    ) async {
      final f = await _mount(tester);
      try {
        final list = Completer<NetworkResult<Map<String, dynamic>>>();
        final chat = Completer<NetworkResult<Map<String, dynamic>>>();
        f.api.listRead = list;
        f.api.chatRead = chat;
        _pause(tester);
        _resume(tester);
        await tester.pumpAndSettle();
        expect(find.text('Synthetic previous message'), findsNothing);

        void newGenerationList() => list.complete(
          const NetworkSuccess({
            'ok': true,
            'items': [
              {
                'peer_user_id': 2,
                'conversation_id': 13,
                'room_key': 'new-room',
              },
            ],
          }),
        );
        void failChat() => chat.complete(_Api.unavailable('/api/v1/messages'));

        if (listFirst) {
          final save = Completer<void>();
          f.secure.listWrite = save;
          newGenerationList();
          await tester.pumpAndSettle();
          expect(f.secure.listWriteBlocked, isTrue);
          failChat();
          await tester.pumpAndSettle();
          save.complete();
        } else {
          failChat();
          await tester.pumpAndSettle();
          expect(find.textContaining('离线只读'), findsOneWidget);
          newGenerationList();
        }
        await tester.pumpAndSettle();
        expect(find.text('Synthetic previous message'), findsNothing);
        expect(find.textContaining('离线只读'), findsNothing);
        final listCopy = await f.cache.readOnlineAuthorized(
          'live-conversations:visible',
        );
        expect((listCopy?['items'] as List?)?.single['room_key'], 'new-room');
      } finally {
        await _dispose(tester, f);
      }
    });
  }

  testWidgets(
    'an unknown send cannot reappear after foreground room rotation',
    (tester) async {
      final f = await _mount(tester);
      try {
        f.api.timeoutFirstSend = true;
        await tester.enterText(
          find.byType(TextField),
          'Synthetic pending old text',
        );
        await tester.tap(find.text('发送'));
        await tester.pumpAndSettle();
        expect(f.api.posts, hasLength(1));
        expect(find.text('使用原消息编号重试'), findsOneWidget);

        _pause(tester);
        f.api.roomKey = 'replacement-room';
        _resume(tester);
        await tester.pumpAndSettle();
        expect(find.text('Synthetic replacement message'), findsOneWidget);
        expect(find.text('使用原消息编号重试'), findsNothing);
        expect(find.text('Synthetic pending old text'), findsNothing);
        expect(f.api.posts, hasLength(1));
      } finally {
        await _dispose(tester, f);
      }
    },
  );

  testWidgets('retained list without a grant cannot interrupt a chat save', (
    tester,
  ) async {
    final f = await _mount(tester);
    try {
      await _race(tester, f, failList: true);
      expect(find.text('会话已锁定'), findsNothing);
      expect(f.cache.isUnlocked, isTrue);
      expect(f.api.posts.single['attachment_ids'], [31]);
    } finally {
      await _dispose(tester, f);
    }
  });

  testWidgets(
    'retained list refresh cannot invalidate foreground chat cache save and attachment send',
    (tester) async {
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
    },
  );

  testWidgets(
    'retained list refresh cannot bypass real encrypted-store failure',
    (tester) async {
      final f = await _mount(tester);
      try {
        await _race(tester, f, failStore: true);
        expect(find.text('会话已锁定'), findsOneWidget);
        expect(f.api.posts, isEmpty);
      } finally {
        await _dispose(tester, f);
      }
    },
  );
}

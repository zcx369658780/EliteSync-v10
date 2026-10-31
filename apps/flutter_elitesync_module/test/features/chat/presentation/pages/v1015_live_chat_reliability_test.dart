import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/storage/private_cache_service.dart';
import 'package:flutter_elitesync_module/core/storage/secure_storage_service.dart';
import 'package:flutter_elitesync_module/features/chat/data/gateway/chat_media_gateway.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/pages/live_chat_page.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

class _Secure extends SecureStorageService {
  final values = <String, String>{};
  bool failWrites=false;
  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> write(String key, String value) async {
    if (failWrites) throw StateError('synthetic secure storage failure');
    values[key] = value;
  }
  @override
  Future<void> delete(String key) async => values.remove(key);
}

class _Session extends SessionNotifier {
  @override
  Future<SessionState> build() async => const SessionState(
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
  _Api(this.events) : super(dio: Dio());
  final List<String> events;
  String readMode = 'success';
  Completer<NetworkResult<Map<String,dynamic>>>? pendingRead;
  bool timeoutFirstSend = false;
  bool currentReadEchoesPendingSend = false;
  Completer<NetworkResult<Map<String, dynamic>>>? pendingFirstPost;
  int successfulPostAcknowledgements = 0;
  Completer<NetworkResult<Map<String, dynamic>>>? preflight;
  final posts = <Map<String, dynamic>>[];
  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    if (query?['limit'] == 1) {
      events.add('fresh-current-read-before-upload');
      return preflight?.future ??
          Future.value(const NetworkSuccess({'items': <dynamic>[]}));
    }
    events.add('message-read');
    if (pendingRead != null) return pendingRead!.future;
    if (readMode == 'non-network-failure') {
      return NetworkFailure(
        message: 'synthetic decoding error',
        error: const FormatException('synthetic'),
      );
    }
    if (readMode == 'malformed-response') {
      return const NetworkSuccess({'items': 'invalid list'});
    }
    if (currentReadEchoesPendingSend && posts.isNotEmpty) {
      return NetworkSuccess({
        'items': [
          {
            'id': 18,
            'client_message_id': posts.first['client_message_id'],
            'content': posts.first['content'],
            'attachments': <dynamic>[],
          },
        ],
      });
    }
    return const NetworkSuccess({
      'items': [
        {'id': 4, 'content': '此前合法保存的合成私密消息', 'attachments': <dynamic>[]},
      ],
    });
  }

  @override
  Future<NetworkResult<Map<String, dynamic>>> post(
    String path, {
    Object? body,
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    events.add('message-post');
    final data = Map<String, dynamic>.from(body as Map);
    posts.add(data);
    if (posts.length == 1 && pendingFirstPost != null) {
      return pendingFirstPost!.future;
    }
    if (timeoutFirstSend && posts.length == 1) {
      return NetworkFailure(
        message: 'synthetic timeout',
        error: TimeoutException('synthetic timeout'),
      );
    }
    successfulPostAcknowledgements++;
    return NetworkSuccess({
      'id': 18,
      'client_message_id': data['client_message_id'],
    });
  }
}

class _Gateway implements SessionBoundChatMediaGateway {
  _Gateway(this.events);
  final List<String> events;
  final picked = Completer<ChatPickedMedia?>();
  int uploads = 0;
  @override
  Future<ChatPickedMedia?> pick(ChatAttachmentKind kind) {
    events.add('native-picker-open');
    return picked.future;
  }

  @override
  Future<ChatMediaUploadResponse> upload(
    ChatAttachmentKind kind,
    ChatPickedMedia media,
  ) => throw StateError('Unbound upload must never be used.');
  @override
  Future<ChatMediaUploadResponse> uploadForSession(
    ChatAttachmentKind kind,
    ChatPickedMedia media, {
    required bool Function() isCurrent,
    required CancelToken cancelToken,
  }) async {
    uploads++;
    events.add('upload-dispatched');
    return const ChatMediaUploadResponse(
      assetId: 31,
      publicUrl: null,
      status: 'ready',
    );
  }
}

class _Fixture {
  _Fixture(this.api, this.gateway, this.cache, this.container, this.secure);
  final _Secure secure;
  final _Api api;
  final _Gateway gateway;
  final PrivateCacheService cache;
  final ProviderContainer container;
}

Future<_Fixture> _mount(
  WidgetTester tester, {
  DateTime Function()? wallNow,
  Duration Function()? elapsed,
}) async {
  SharedPreferences.setMockInitialValues({});
  final events = <String>[];
  final api = _Api(events);
  final gateway = _Gateway(events);
  final secure = _Secure();
  final now = DateTime.utc(2026, 10, 21);
  final cache = PrivateCacheService.forTesting(
    secure,
    wallNow: wallNow ?? () => now,
    elapsed: elapsed ?? () => Duration.zero,
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
      'device_id': 'synthetic-device',
      'session_id': 9,
      'login_at': now.toIso8601String(),
      'server_now': now.toIso8601String(),
      'online_expires_at': now.add(const Duration(days: 15)).toIso8601String(),
      'purge_at': now.add(const Duration(days: 30)).toIso8601String(),
    },
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: LiveChatPage(peerId: 2)),
    ),
  );
  await tester.pumpAndSettle();
  return _Fixture(api, gateway, cache, container, secure);
}

Future<void> _dispose(WidgetTester tester, _Fixture f) async {
  await tester.pumpWidget(const SizedBox.shrink());
  f.container.dispose();
}

// Flutter 3.41's tooltip finder may select RawTooltip. Inspect the actual
// IconButton so disabled-media assertions keep checking its callback.
Finder _mediaButton(String tooltip) => find.byWidgetPredicate(
      (widget) => widget is IconButton && widget.tooltip == tooltip,
    );

void main() {
  testWidgets('blank resume revalidation survives a legitimate slow current read', (tester) async {
    final f=await _mount(tester);f.api.pendingRead=Completer();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();await tester.pump(const Duration(seconds:4));
    expect(find.text('此前合法保存的合成私密消息'),findsNothing);
    f.api.pendingRead!.complete(const NetworkSuccess({'items':[{'id':98,'content':'FRESH_CURRENT_AFTER_SLOW_RESUME','attachments':<dynamic>[]}]}));
    await tester.pumpAndSettle();
    expect(find.text('FRESH_CURRENT_AFTER_SLOW_RESUME'),findsOneWidget);
    expect(find.byType(TextField),findsOneWidget);
    await _dispose(tester,f);
  });

  testWidgets('secure cache write failure after current HTTP200 locks rendered chat', (tester) async {
    final f=await _mount(tester);f.secure.failWrites=true;
    await tester.pump(const Duration(seconds:3));await tester.pumpAndSettle();
    expect(find.text('此前合法保存的合成私密消息'),findsNothing);
    expect(find.byType(TextField),findsNothing);
    expect(find.textContaining('私密内容已锁定'),findsOneWidget);
    await _dispose(tester,f);
  });

  testWidgets('authorized-before-expiry delayed HTTP200 never displays after the 15-day deadline', (tester) async {
    var age=Duration.zero;final anchor=DateTime.utc(2026,10,21);
    final f=await _mount(tester,wallNow:()=>anchor.add(age),elapsed:()=>age);
    f.api.pendingRead=Completer();
    await tester.pump(const Duration(seconds:3));
    age=const Duration(days:15);
    f.api.pendingRead!.complete(const NetworkSuccess({'items':[{'id':99,'content':'LATE_PRIVATE_AT_15_DAYS','attachments':<dynamic>[]}]}));
    await tester.pumpAndSettle();
    expect(find.text('LATE_PRIVATE_AT_15_DAYS'),findsNothing);
    expect(find.text('此前合法保存的合成私密消息'),findsNothing);
    expect(find.byType(TextField),findsNothing);
    await _dispose(tester,f);
  });

  testWidgets(
    'pending POST survives pause and resume with the same immutable retry',
    (tester) async {
      final f = await _mount(tester);
      f.api.pendingFirstPost = Completer();
      await tester.enterText(find.byType(TextField), '暂停前发送的合成消息');
      await tester.tap(find.text('发送'));
      await tester.pump();
      final original = Map<String, dynamic>.from(f.api.posts.single);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(find.byType(TextField), findsNothing);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      f.api.pendingFirstPost!.complete(NetworkFailure(
        message: 'synthetic response lost after pause',
        error: TimeoutException('synthetic'),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('使用原消息编号重试'));
      await tester.pumpAndSettle();
      expect(f.api.posts, hasLength(2));
      expect(f.api.posts.last, original);
      expect(find.text('服务器已确认此消息'), findsOneWidget);
      await _dispose(tester, f);
    },
  );


  testWidgets(
    'unknown result keeps immutable payload even if the controller is changed',
    (tester) async {
      final f = await _mount(tester);
      f.api.timeoutFirstSend = true;
      await tester.enterText(find.byType(TextField), '原始合成消息');
      await tester.tap(find.text('发送'));
      await tester.pumpAndSettle();
      final original = Map<String, dynamic>.from(f.api.posts.single);
      final input = tester.widget<TextField>(find.byType(TextField));
      expect(input.readOnly, isTrue);
      expect(tester.widget<TextButton>(find.widgetWithText(TextButton, '发送')).onPressed, isNull);
      expect(tester.widget<IconButton>(_mediaButton('发送图片')).onPressed, isNull);
      expect(tester.widget<IconButton>(_mediaButton('发送短视频')).onPressed, isNull);
      // Simulate a programmatic controller write that bypasses the read-only UI.
      input.controller!.text = '不得取代未确认尝试';
      await tester.tap(find.text('使用原消息编号重试'));
      await tester.pumpAndSettle();
      expect(f.api.posts, hasLength(2));
      expect(f.api.posts.last, original);
      expect(find.text('服务器已确认此消息'), findsOneWidget);
      expect(tester.widget<TextField>(find.byType(TextField)).readOnly, isFalse);
      await _dispose(tester, f);
    },
  );

  testWidgets(
    'unknown media result retries the same attachment without another upload',
    (tester) async {
      final f = await _mount(tester);
      f.api.timeoutFirstSend = true;
      f.gateway.picked.complete(const ChatPickedMedia(path: 'synthetic.png', name: 'synthetic.png'));
      await tester.tap(find.byTooltip('发送图片'));
      await tester.pumpAndSettle();
      expect(f.gateway.uploads, 1);
      final original = Map<String, dynamic>.from(f.api.posts.single);
      expect(original['attachment_ids'], [31]);
      expect(tester.widget<IconButton>(_mediaButton('发送图片')).onPressed, isNull);
      tester.widget<TextField>(find.byType(TextField)).controller!.text = '不得替换附件请求';
      await tester.tap(find.text('使用原消息编号重试'));
      await tester.pumpAndSettle();
      expect(f.api.posts, hasLength(2));
      expect(f.api.posts.last, original);
      expect(f.gateway.uploads, 1);
      await _dispose(tester, f);
    },
  );


  testWidgets(
    'current-authority read during pending POST cannot replace retry identity before receive timeout',
    (tester) async {
      final f = await _mount(tester);
      f.api.pendingFirstPost = Completer();
      f.api.currentReadEchoesPendingSend = true;
      const draft = '已入库但POST响应丢失的合成消息';
      await tester.enterText(find.byType(TextField), draft);
      await tester.tap(find.text('发送'));
      await tester.pumpAndSettle();
      expect(f.api.posts, hasLength(1));
      final originalKey = f.api.posts.single['client_message_id'];
      expect(originalKey, isA<String>());
      expect((originalKey as String).isNotEmpty, isTrue);
      expect(f.api.successfulPostAcknowledgements, 0);

      // A WS-triggered load and this GUI refresh share the same current-read
      // path. Server storage already contains the original key while its POST
      // response remains pending. The read must not discard the send attempt.
      final readsBefore = f.api.events.where((e) => e == 'message-read').length;
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();
      expect(
        f.api.events.where((e) => e == 'message-read').length,
        readsBefore + 1,
      );
      expect(f.api.pendingFirstPost!.isCompleted, isFalse);
      expect(find.text('服务器已确认此消息'), findsNothing);
      expect(find.text('发送中，等待服务器确认'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        draft,
      );

      f.api.pendingFirstPost!.complete(
        NetworkFailure(
          message: 'synthetic receive timeout after server commit',
          error: DioException(
            requestOptions: RequestOptions(path: '/api/v1/messages'),
            type: DioExceptionType.receiveTimeout,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('发送结果尚未确认'), findsOneWidget);
      expect(find.text('使用原消息编号重试'), findsOneWidget);
      expect(f.api.successfulPostAcknowledgements, 0);

      await tester.tap(find.text('使用原消息编号重试'));
      await tester.pumpAndSettle();
      expect(f.api.posts, hasLength(2));
      expect(f.api.posts.last['client_message_id'], originalKey);
      expect(f.api.posts.last, f.api.posts.first);
      expect(f.api.successfulPostAcknowledgements, 1);
      expect(find.text('服务器已确认此消息'), findsOneWidget);
      expect(find.text('使用原消息编号重试'), findsNothing);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      await tester.tap(find.text('发送'));
      await tester.pumpAndSettle();
      expect(f.api.posts, hasLength(2));
      await _dispose(tester, f);
    },
  );

  testWidgets(
    'actual chat timeout retries the same logical message ID and confirms only server identity',
    (tester) async {
      final f = await _mount(tester);
      f.api.timeoutFirstSend = true;
      await tester.enterText(find.byType(TextField), '超时结果未知的合成消息');
      await tester.tap(find.text('发送'));
      await tester.pumpAndSettle();
      expect(f.api.posts, hasLength(1));
      expect(find.textContaining('发送结果尚未确认'), findsOneWidget);
      expect(find.text('服务器已确认此消息'), findsNothing);
      await tester.tap(find.text('使用原消息编号重试'));
      await tester.pumpAndSettle();
      expect(f.api.posts, hasLength(2));
      expect(
        f.api.posts[0]['client_message_id'],
        f.api.posts[1]['client_message_id'],
      );
      expect(f.api.posts[0]['content'], f.api.posts[1]['content']);
      expect(find.text('服务器已确认此消息'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      await _dispose(tester, f);
    },
  );

  for (final mode in ['non-network-failure', 'malformed-response']) {
    testWidgets(
      'actual chat $mode cannot fall back to saved private messages',
      (tester) async {
        final f = await _mount(tester);
        expect(find.text('此前合法保存的合成私密消息'), findsOneWidget);
        f.api.readMode = mode;
        await tester.tap(find.byIcon(Icons.refresh));
        await tester.pumpAndSettle();
        expect(find.text('此前合法保存的合成私密消息'), findsNothing);
        expect(find.textContaining('离线只读'), findsNothing);
        expect(f.cache.isOffline, isFalse);
        await _dispose(tester, f);
      },
    );
  }

  testWidgets(
    'actual chat typed draft and old messages disappear on trusted clock anomaly',
    (tester) async {
      final now = DateTime.utc(2026, 10, 21);
      var wallOffset = Duration.zero;
      final f = await _mount(tester, wallNow: () => now.add(wallOffset));
      await tester.enterText(find.byType(TextField), '时间异常前的私密草稿');
      wallOffset = const Duration(minutes: -2);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.text('此前合法保存的合成私密消息'), findsNothing);
      expect(find.text('时间异常前的私密草稿'), findsNothing);
      expect(find.byType(TextField), findsNothing);
      expect(find.text('会话已锁定'), findsOneWidget);
      expect(f.api.posts, isEmpty);
      await _dispose(tester, f);
    },
  );

  testWidgets(
    'actual chat known authority invalidation clears typed draft before a future read',
    (tester) async {
      final f = await _mount(tester);
      await tester.enterText(find.byType(TextField), '撤权前的私密草稿');
      f.container
          .read(relationshipAuthorityEpochProvider.notifier)
          .invalidate();
      await tester.pump();
      expect(find.text('此前合法保存的合成私密消息'), findsNothing);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      expect(find.textContaining('授权已变化'), findsOneWidget);
      expect(f.api.posts, isEmpty);
      await _dispose(tester, f);
    },
  );

  testWidgets(
    'native picker pause resume requires fresh GET limit1 to finish before upload',
    (tester) async {
      final f = await _mount(tester);
      f.api.preflight = Completer();
      await tester.tap(find.byTooltip('发送图片'));
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      f.gateway.picked.complete(
        const ChatPickedMedia(path: 'synthetic.png', name: 'synthetic.png'),
      );
      await tester.pumpAndSettle();
      expect(f.api.events, contains('fresh-current-read-before-upload'));
      expect(f.gateway.uploads, 0);
      f.api.preflight!.complete(const NetworkSuccess({'items': <dynamic>[]}));
      await tester.pumpAndSettle();
      expect(f.gateway.uploads, 1);
      expect(
        f.api.events.indexOf('fresh-current-read-before-upload'),
        lessThan(f.api.events.indexOf('upload-dispatched')),
      );
      expect(f.api.posts, hasLength(1));
      await _dispose(tester, f);
    },
  );

  testWidgets(
    'returning from native picker after account switch performs zero uploads',
    (tester) async {
      final f = await _mount(tester);
      await tester.tap(find.byTooltip('发送图片'));
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      (f.container.read(sessionProvider.notifier) as _Session).switchAccount();
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      f.gateway.picked.complete(
        const ChatPickedMedia(path: 'synthetic.png', name: 'synthetic.png'),
      );
      await tester.pumpAndSettle();
      expect(f.gateway.uploads, 0);
      expect(f.api.posts, isEmpty);
      expect(find.text('会话已锁定'), findsOneWidget);
      await _dispose(tester, f);
    },
  );
}

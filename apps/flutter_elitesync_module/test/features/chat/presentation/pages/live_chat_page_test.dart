import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/features/profile/avatar/avatar_api.dart';
import 'package:flutter_elitesync_module/features/profile/avatar/authenticated_avatar.dart';
import '../../../../support/synthetic_private_login.dart';
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/storage/private_cache_service.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/pages/live_chat_page.dart';
import 'package:flutter_elitesync_module/features/chat/data/gateway/chat_media_gateway.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/auth_interceptor.dart';

class _Session extends SessionNotifier {
  void relogin() => state = AsyncData(
    SessionState(
      status: AuthStatus.authenticated,
      user: const UserSummary(id: 1, phone: 'fictional'),
    ),
  );
  @override
  SessionState build() => const SessionState(
    status: AuthStatus.authenticated,
    user: UserSummary(id: 1, phone: 'fictional'),
  );
}

class _AvatarSession extends _Session {
  @override
  SessionState build() => const SessionState(
    status: AuthStatus.authenticated,
    accessToken: 'fictional-avatar-session',
    user: UserSummary(id: 1, phone: 'fictional'),
  );
}

class _Api extends ApiClient {
  _Api() : super(dio: Dio());
  final pending = Completer<NetworkResult<Map<String, dynamic>>>();
  int posts = 0;
  bool allowAttachmentPreflight = false;
  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) => query?['limit'] == 1 && allowAttachmentPreflight
      ? Future.value(const NetworkSuccess({'items': <dynamic>[]}))
      : pending.future;
  @override
  Future<NetworkResult<Map<String, dynamic>>> post(
    String path, {
    Object? body,
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    posts++;
    return const NetworkFailure(message: 'revoked', statusCode: 403);
  }
}

class _UnknownSendApi extends ApiClient {
  _UnknownSendApi() : super(dio: Dio());
  final bodies = <Map<String, dynamic>>[];
  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async => const NetworkSuccess({'items': <dynamic>[]});
  @override
  Future<NetworkResult<Map<String, dynamic>>> post(
    String path, {
    Object? body,
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    bodies.add(Map<String, dynamic>.from(body as Map));
    return const NetworkFailure(
      message: 'upstream response lost',
      statusCode: 502,
    );
  }
}

class _Gateway implements SessionBoundChatMediaGateway {
  final uploaded = Completer<ChatMediaUploadResponse>();
  ChatAttachmentKind? pickedKind;
  @override
  Future<ChatPickedMedia?> pick(ChatAttachmentKind kind) async {
    pickedKind = kind;
    return ChatPickedMedia(
      path: 'fictional',
      name: kind == ChatAttachmentKind.video ? 'fixture.mp4' : 'fixture.png',
    );
  }

  @override
  Future<ChatMediaUploadResponse> upload(
    ChatAttachmentKind kind,
    ChatPickedMedia media,
  ) => uploaded.future;
  @override
  Future<ChatMediaUploadResponse> uploadForSession(
    ChatAttachmentKind kind,
    ChatPickedMedia media, {
    required bool Function() isCurrent,
    required CancelToken cancelToken,
  }) => uploaded.future;
}

class _MediaApi extends ApiClient {
  _MediaApi() : super(dio: Dio());
  bool unavailable = false;
  bool includeImage = false;
  int messageCount = 1;
  bool denied = false;
  final bodies = <Map<String, dynamic>>[];
  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async => denied
      ? const NetworkFailure(message: 'fictional denied', statusCode: 403)
      : unavailable
      ? NetworkFailure(
          message: 'fictional offline',
          error: TimeoutException('fictional'),
        )
      : NetworkSuccess({
          'items': [
            for (var i = 0; i < messageCount; i++)
              {
                'id': i + 1,
                'content': i == 0
                    ? 'retained conversation'
                    : 'later message $i',
                'attachments': [
                  if (includeImage && i == 0)
                    {
                      'media_asset': {'id': 42, 'media_type': 'image'},
                    },
                ],
              },
          ],
        });
  @override
  Future<NetworkResult<Map<String, dynamic>>> post(
    String path, {
    Object? body,
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    if (path == '/api/v1/media') {
      return const NetworkFailure(message: 'fictional denied', statusCode: 403);
    }
    final data = Map<String, dynamic>.from(body as Map);
    bodies.add(data);
    return NetworkSuccess({
      'id': 9,
      'client_message_id': data['client_message_id'],
    });
  }
}

class _RetryGateway implements SessionBoundChatMediaGateway {
  int picks = 0;
  int uploads = 0;
  Completer<ChatPickedMedia?>? picking;
  int? failureStatus = 422;
  Completer<ChatMediaUploadResponse>? pending;
  static const ready = ChatMediaUploadResponse(
    assetId: 42,
    publicUrl: null,
    status: 'ready',
  );
  @override
  Future<ChatPickedMedia?> pick(ChatAttachmentKind kind) async {
    picks++;
    if (picking != null) return picking!.future;
    return const ChatPickedMedia(path: 'fictional', name: 'fixture.png');
  }

  @override
  Future<ChatMediaUploadResponse> upload(
    ChatAttachmentKind kind,
    ChatPickedMedia media,
  ) => throw StateError('Unbound upload not used');
  @override
  Future<ChatMediaUploadResponse> uploadForSession(
    ChatAttachmentKind kind,
    ChatPickedMedia media, {
    required bool Function() isCurrent,
    required CancelToken cancelToken,
  }) async {
    uploads++;
    if (pending != null) return pending!.future;
    if (uploads == 1 && failureStatus != null) {
      throw ChatMediaGatewayException(statusCode: failureStatus);
    }
    return ready;
  }
}

class _DraftStore extends SyntheticPrivateStore {
  bool refuseDraftDelete = false;
  bool failDraftWrite = false;
  bool blockDraftDelete = false;
  Completer<void>? blockDelete;
  Completer<void>? deleteEntered;
  bool draftKey(String key) => key.contains(':live-chat-draft%3A');
  @override
  Future<void> write(String key, String value) async {
    if (draftKey(key) && failDraftWrite) {
      throw StateError('fictional write failure');
    }
    await super.write(key, value);
  }

  @override
  Future<void> delete(String key) async {
    if (blockDelete != null &&
        (key.endsWith(':queue-blocker') ||
            (blockDraftDelete && draftKey(key)))) {
      deleteEntered!.complete();
      await blockDelete!.future;
    }
    if (draftKey(key) && refuseDraftDelete) return;
    await super.delete(key);
  }
}

Future<_DraftStore> _draftStore() async {
  final secure = _DraftStore();
  final now = DateTime.now().toUtc();
  await PrivateCacheService.forStorage(secure).establishLogin(
    userId: 1,
    retention: {
      'user_id': 1,
      'device_id': 'draft-test-device',
      'session_id': 1,
      'login_at': now.toIso8601String(),
      'server_now': now.toIso8601String(),
      'online_expires_at': now.add(const Duration(days: 15)).toIso8601String(),
      'purge_at': now.add(const Duration(days: 30)).toIso8601String(),
    },
  );
  return secure;
}

class _PendingAckApi extends _MediaApi {
  final ack = Completer<NetworkResult<Map<String, dynamic>>>();
  @override
  Future<NetworkResult<Map<String, dynamic>>> post(
    String path, {
    Object? body,
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) {
    bodies.add(Map<String, dynamic>.from(body as Map));
    return ack.future;
  }
}

Future<void> _show(
  WidgetTester tester,
  ApiClient api, {
  ChatMediaGateway? gateway,
  Dio? dio,
  SyntheticPrivateStore? secureStore,
  int peerId = 2,
}) async {
  final secure = secureStore ?? await syntheticPrivateLogin();
  final container = ProviderContainer(
    overrides: [
      secureStorageProvider.overrideWithValue(secure),
      apiClientProvider.overrideWithValue(api),
      sessionProvider.overrideWith(_Session.new),
      if (gateway != null)
        liveChatMediaGatewayProvider.overrideWithValue(gateway),
      if (dio != null) dioProvider.overrideWithValue(dio),
    ],
  );
  addTearDown(container.dispose);
  await container.read(sessionProvider.future);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: LiveChatPage(peerId: peerId)),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets(
    'slow initial read cannot overwrite an existing unknown submission',
    (tester) async {
      final secure = await syntheticPrivateLogin();
      final first = _UnknownSendApi();
      await _show(tester, first, secureStore: secure);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'original pending text');
      await tester.tap(find.text('发送'));
      await tester.pumpAndSettle();
      final original = first.bodies.single;
      await tester.pumpWidget(const SizedBox());
      PrivateCacheService.forStorage(secure).beginOnlineRevalidation();
      final slow = _Api();
      final gateway = _RetryGateway();
      await _show(tester, slow, secureStore: secure, gateway: gateway);
      await tester.enterText(
        find.byType(TextField),
        'must not replace pending',
      );
      await tester.tap(find.text('发送'));
      await tester.pumpAndSettle();
      expect(slow.posts, 0);
      await tester.tap(find.byTooltip('发送图片'));
      await tester.pumpAndSettle();
      expect(gateway.picks, 0);
      expect(slow.posts, 0);
      final key = secure.values.keys.singleWhere(
        (key) => key.endsWith(':live-chat-draft%3A2'),
      );
      final stored = jsonDecode(
        secure.values[key]!,
      )['value']['pending_attempt'];
      expect(stored['client_message_id'], original['client_message_id']);
      expect(stored['content'], original['content']);
      slow.pending.complete(const NetworkSuccess({'items': <dynamic>[]}));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'original pending text',
      );
      expect(find.text('使用原消息编号重试'), findsOneWidget);
      expect(slow.posts, 0);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('unknown send reopens only as the same immutable manual retry', (
    tester,
  ) async {
    final secure = await syntheticPrivateLogin();
    final api = _UnknownSendApi();
    await _show(tester, api, secureStore: secure);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField),
      'retain original submission',
    );
    await tester.tap(find.text('发送'));
    await tester.pumpAndSettle();
    expect(api.bodies, hasLength(1));
    await tester.pumpWidget(const SizedBox());
    PrivateCacheService.forStorage(secure).beginOnlineRevalidation();
    await _show(tester, api, secureStore: secure);
    await tester.pumpAndSettle();
    expect(api.bodies, hasLength(1));
    expect(tester.widget<TextField>(find.byType(TextField)).readOnly, isTrue);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'retain original submission',
    );
    await tester.tap(find.text('使用原消息编号重试'));
    await tester.pumpAndSettle();
    expect(api.bodies, hasLength(2));
    expect(api.bodies[1], api.bodies[0]);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'clearing draft disables attachments and calls until completion',
    (tester) async {
      final secure = await _draftStore();
      final api = _MediaApi();
      final gateway = _RetryGateway();
      await _show(tester, api, secureStore: secure, gateway: gateway);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField),
        'do not send cleared text',
      );
      await tester.tap(find.text('保存草稿'));
      await tester.pumpAndSettle();
      secure.blockDraftDelete = true;
      secure.blockDelete = Completer();
      secure.deleteEntered = Completer();
      await tester.tap(find.text('清除草稿'));
      await tester.pump();
      await secure.deleteEntered!.future;
      for (final tip in ['发送图片', '发送短视频', '语音通话', '视频通话']) {
        expect(
          tester
              .widget<IconButton>(
                find.byWidgetPredicate(
                  (widget) => widget is IconButton && widget.tooltip == tip,
                ),
              )
              .onPressed,
          isNull,
        );
      }
      expect(gateway.picks, 0);
      expect(api.bodies, isEmpty);
      secure.blockDelete!.complete();
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '',
      );
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('submission receipt failure means no message was dispatched', (
    tester,
  ) async {
    final secure = await _draftStore();
    final api = _MediaApi();
    await _show(tester, api, secureStore: secure);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'not dispatched');
    secure.failDraftWrite = true;
    await tester.tap(find.text('发送'));
    await tester.pumpAndSettle();
    expect(api.bodies, isEmpty);
    expect(find.textContaining('消息尚未发送'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'acknowledged send with failed draft deletion stays confirmed and locked',
    (tester) async {
      final secure = await _draftStore();
      final api = _MediaApi();
      await _show(tester, api, secureStore: secure);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'server confirms once');
      secure.refuseDraftDelete = true;
      await tester.tap(find.text('发送'));
      await tester.pumpAndSettle();
      expect(api.bodies, hasLength(1));
      expect(find.textContaining('消息已确认，但本机草稿清理未完成'), findsOneWidget);
      expect(find.text('使用原消息编号重试'), findsNothing);
      expect(PrivateCacheService.forStorage(secure).isUnlocked, isFalse);
      expect(find.byType(TextField), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await _show(tester, api, secureStore: secure);
      await tester.pumpAndSettle();
      expect(api.bodies, hasLength(1));
      expect(find.byType(TextField), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('superseded queued ack cleanup cannot report draft removed', (
    tester,
  ) async {
    final secure = await _draftStore();
    final api = _PendingAckApi();
    final cache = PrivateCacheService.forStorage(secure);
    await cache.saveAuthorized('queue-blocker', {'text': 'blocker'});
    await _show(tester, api, secureStore: secure);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'queue-bound submission');
    await tester.tap(find.text('发送'));
    await tester.pumpAndSettle();
    expect(api.bodies, hasLength(1));
    secure.blockDelete = Completer();
    secure.deleteEntered = Completer();
    final blocked = cache.removeObject('queue-blocker');
    await secure.deleteEntered!.future;
    api.ack.complete(
      NetworkSuccess({
        'id': 9,
        'client_message_id': api.bodies.single['client_message_id'],
      }),
    );
    await tester.pump();
    cache.revokeObject('another-context');
    secure.blockDelete!.complete();
    await blocked;
    await tester.pumpAndSettle();
    expect(find.textContaining('消息已确认，但本机草稿清理未完成'), findsOneWidget);
    expect(cache.isUnlocked, isFalse);
    expect(api.bodies, hasLength(1));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('saved draft is peer scoped and denied reads never reveal it', (
    tester,
  ) async {
    final secure = await syntheticPrivateLogin();
    final api = _MediaApi();
    await _show(tester, api, secureStore: secure);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'only peer two');
    await tester.tap(find.text('保存草稿'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    await _show(tester, api, secureStore: secure, peerId: 3);
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );
    await tester.pumpWidget(const SizedBox());
    api.denied = true;
    await _show(tester, api, secureStore: secure);
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, '保存草稿'))
          .onPressed,
      isNull,
    );
    await tester.pumpWidget(const SizedBox());
    api.denied = false;
    await _show(tester, api, secureStore: secure);
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'only peer two',
    );
    expect(api.bodies, isEmpty);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('existing offline grant restores saved draft read only', (
    tester,
  ) async {
    final secure = await syntheticPrivateLogin();
    final api = _MediaApi();
    await _show(tester, api, secureStore: secure);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'offline saved text');
    await tester.tap(find.text('保存草稿'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    api.unavailable = true;
    await _show(tester, api, secureStore: secure);
    await tester.pumpAndSettle();
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, 'offline saved text');
    expect(field.readOnly, isTrue);
    for (final label in ['保存草稿', '清除草稿', '发送']) {
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, label))
            .onPressed,
        isNull,
      );
    }
    expect(api.bodies, isEmpty);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'confirmed send removes saved draft and never resends on reopen',
    (tester) async {
      final secure = await syntheticPrivateLogin();
      final api = _MediaApi();
      await _show(tester, api, secureStore: secure);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'explicitly sent text');
      await tester.tap(find.text('保存草稿'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('发送'));
      await tester.pumpAndSettle();
      expect(api.bodies, hasLength(1));
      await tester.pumpWidget(const SizedBox());
      await _show(tester, api, secureStore: secure);
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '',
      );
      expect(api.bodies, hasLength(1));
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('explicit private draft restores after current read and clears', (
    tester,
  ) async {
    final secure = await syntheticPrivateLogin();
    final api = _MediaApi();
    await _show(tester, api, secureStore: secure);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '明确保存的本人草稿');
    await tester.tap(find.text('保存草稿'));
    await tester.pumpAndSettle();
    expect(find.text('草稿已加密保存在本机，尚未发送。'), findsOneWidget);
    expect(api.bodies, isEmpty);
    await tester.pumpWidget(const SizedBox());
    PrivateCacheService.forStorage(secure).beginOnlineRevalidation();
    await _show(tester, api, secureStore: secure);
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '明确保存的本人草稿',
    );
    await tester.tap(find.text('清除草稿'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );
    await tester.pumpWidget(const SizedBox());
    await _show(tester, api, secureStore: secure);
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );
    expect(api.bodies, isEmpty);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('chat poll denial removes and evicts the peer avatar', (
    tester,
  ) async {
    final api = _MediaApi();
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path == '/api/v1/avatars/2') {
              handler.resolve(
                Response<Map<String, dynamic>>(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'revision': 1,
                    'avatar': {
                      'owner_user_id': 2,
                      'revision': 1,
                      'content_path': '/api/v1/avatars/2/1',
                    },
                  },
                ),
              );
            } else {
              handler.resolve(
                Response<List<int>>(
                  requestOptions: options,
                  statusCode: 200,
                  data: base64Decode(
                    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAC0lEQVR4nGNgAAIAAAUAAXpeqz8AAAAASUVORK5CYII=',
                  ),
                ),
              );
            }
          },
        ),
      );
    final secure = await syntheticPrivateLogin();
    final container = ProviderContainer(
      overrides: [
        secureStorageProvider.overrideWithValue(secure),
        apiClientProvider.overrideWithValue(api),
        sessionProvider.overrideWith(_AvatarSession.new),
        avatarApiProvider.overrideWithValue(AvatarApi(dio)),
        appEnvProvider.overrideWithValue(
          const AppEnv(
            flavor: AppFlavor.dev,
            appName: 'fixture',
            apiBaseUrl: 'https://fixture.invalid',
            useMockData: false,
            useMockChat: true,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: LiveChatPage(peerId: 2)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AuthenticatedAvatar), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    final oldImage = tester.widget<Image>(find.byType(Image)).image;
    api.denied = true;
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.textContaining('当前无法读取对话'), findsOneWidget);
    expect(find.byType(AuthenticatedAvatar), findsNothing);
    expect(find.byType(Image), findsNothing);
    expect(
      (await oldImage.obtainCacheStatus(
        configuration: ImageConfiguration.empty,
      ))?.tracked,
      isFalse,
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'manual chat refresh reauthorizes a removed avatar without polling downloads',
    (tester) async {
      final api = _MediaApi();
      var hasAvatar = true;
      var metadataReads = 0;
      var contentReads = 0;
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              if (options.path == '/api/v1/avatars/2') {
                metadataReads++;
                handler.resolve(
                  Response<Map<String, dynamic>>(
                    requestOptions: options,
                    statusCode: 200,
                    data: {
                      'revision': hasAvatar ? 1 : 2,
                      'avatar': hasAvatar
                          ? {
                              'owner_user_id': 2,
                              'revision': 1,
                              'content_path': '/api/v1/avatars/2/1',
                            }
                          : null,
                    },
                  ),
                );
              } else {
                contentReads++;
                handler.resolve(
                  Response<List<int>>(
                    requestOptions: options,
                    statusCode: 200,
                    data: base64Decode(
                      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAC0lEQVR4nGNgAAIAAAUAAXpeqz8AAAAASUVORK5CYII=',
                    ),
                  ),
                );
              }
            },
          ),
        );
      final secure = await syntheticPrivateLogin();
      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(secure),
          apiClientProvider.overrideWithValue(api),
          sessionProvider.overrideWith(_AvatarSession.new),
          avatarApiProvider.overrideWithValue(AvatarApi(dio)),
          appEnvProvider.overrideWithValue(
            const AppEnv(
              flavor: AppFlavor.dev,
              appName: 'fixture',
              apiBaseUrl: 'https://fixture.invalid',
              useMockData: false,
              useMockChat: true,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: LiveChatPage(peerId: 2)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AuthenticatedAvatar), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      final oldImage = tester.widget<Image>(find.byType(Image)).image;
      expect(metadataReads, 1);
      expect(contentReads, 1);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(metadataReads, 1);
      expect(contentReads, 1);
      hasAvatar = false;
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();
      expect(find.text('retained conversation'), findsOneWidget);
      expect(find.byType(AuthenticatedAvatar), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      expect(metadataReads, 2);
      expect(contentReads, 1);
      expect(find.byTooltip('刷新对话'), findsOneWidget);
      expect(
        (await oldImage.obtainCacheStatus(
          configuration: ImageConfiguration.empty,
        ))?.tracked,
        isFalse,
      );
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'authorized image opens zoomable preview, back closes it and denial removes it',
    (tester) async {
      final api = _MediaApi()
        ..includeImage = true
        ..messageCount = 20;
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.resolve(
                Response<List<int>>(
                  requestOptions: options,
                  statusCode: 200,
                  data: base64Decode(
                    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAC0lEQVR4nGNgAAIAAAUAAXpeqz8AAAAASUVORK5CYII=',
                  ),
                ),
              );
            },
          ),
        );
      await _show(tester, api, dio: dio);
      await tester.pumpAndSettle();
      final image = find.byKey(const ValueKey('live-chat-image-42'));
      await tester.scrollUntilVisible(
        image,
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await Scrollable.ensureVisible(tester.element(image), alignment: 0.4);
      await tester.pumpAndSettle();
      final positionBeforePreview = tester.getTopLeft(image).dy;
      await tester.tap(image);
      await tester.pumpAndSettle();
      expect(find.text('图片预览'), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);
      final previewSize = tester.getSize(find.byType(Image));
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('图片预览'), findsNothing);
      expect(find.text('retained conversation'), findsOneWidget);
      expect(tester.getTopLeft(image).dy, closeTo(positionBeforePreview, 1));
      expect(previewSize.width, greaterThan(300));
      await tester.tap(image);
      await tester.pumpAndSettle();
      api.denied = true;
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.text('图片预览'), findsNothing);
      expect(find.byType(Image), findsNothing);
      expect(find.textContaining('当前无法读取对话'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('a picker result cannot adopt the newly opened peer epoch', (
    tester,
  ) async {
    final api = _MediaApi();
    final gateway = _RetryGateway()
      ..picking = Completer()
      ..failureStatus = null;
    await _show(tester, api, gateway: gateway);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('发送图片'));
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(LiveChatPage)),
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: LiveChatPage(peerId: 3)),
      ),
    );
    await tester.pumpAndSettle();
    gateway.picking!.complete(
      const ChatPickedMedia(path: 'fictional', name: 'old-peer.png'),
    );
    await tester.pumpAndSettle();
    expect(gateway.uploads, 0);
    expect(api.bodies, isEmpty);
    expect(find.text('重试上传'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'recovery cannot reopen retry or remove while the original upload is pending',
    (tester) async {
      final api = _MediaApi();
      final gateway = _RetryGateway()..pending = Completer();
      await _show(tester, api, gateway: gateway);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('发送图片'));
      await tester.pumpAndSettle();
      api.unavailable = true;
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      api.unavailable = false;
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.text('重试上传'), findsNothing);
      expect(find.text('移除附件'), findsNothing);
      expect(tester.widget<TextField>(find.byType(TextField)).readOnly, isTrue);
      expect(gateway.uploads, 1);
      expect(api.bodies, isEmpty);
      gateway.pending!.complete(_RetryGateway.ready);
      await tester.pumpAndSettle();
      expect(gateway.uploads, 1);
      expect(api.bodies, hasLength(1));
      await tester.pumpWidget(const SizedBox());
    },
  );

  test(
    'platform gateway preserves a rejected upload status for page handling',
    () async {
      final gateway = PlatformChatMediaGateway(
        apiClient: _MediaApi(),
        formBuilder:
            ({
              required String mediaType,
              required String filePath,
              required String fileName,
              required Map<String, dynamic> metadata,
            }) async => FormData(),
      );
      await expectLater(
        gateway.uploadForSession(
          ChatAttachmentKind.image,
          const ChatPickedMedia(path: 'fictional', name: 'fixture.png'),
          isCurrent: () => true,
          cancelToken: CancelToken(),
        ),
        throwsA(
          isA<ChatMediaGatewayException>().having(
            (e) => e.statusCode,
            'status',
            403,
          ),
        ),
      );
    },
  );

  testWidgets('a late upload cannot be sent to a newly opened peer', (
    tester,
  ) async {
    final api = _MediaApi();
    final gateway = _RetryGateway()..pending = Completer();
    await _show(tester, api, gateway: gateway);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('发送图片'));
    await tester.pumpAndSettle();
    final oldState = tester.state(find.byType(LiveChatPage));
    final container = ProviderScope.containerOf(
      tester.element(find.byType(LiveChatPage)),
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: LiveChatPage(peerId: 3)),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      identical(oldState, tester.state(find.byType(LiveChatPage))),
      isTrue,
    );
    gateway.pending!.complete(_RetryGateway.ready);
    await tester.pumpAndSettle();
    expect(api.bodies, isEmpty);
    expect(find.text('重试上传'), findsNothing);
    expect(find.text('重试发送附件'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'upload failure retains conversation and draft; explicit retry reuses selected file',
    (tester) async {
      final api = _MediaApi();
      final gateway = _RetryGateway()..pending = Completer();
      await _show(tester, api, gateway: gateway);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'caption before upload');
      await tester.tap(find.byTooltip('发送图片'));
      await tester.pumpAndSettle();
      expect(find.text('正在上传图片，请稍候…'), findsOneWidget);
      expect(api.bodies, isEmpty);
      gateway.pending!.completeError(
        const ChatMediaGatewayException(statusCode: 422),
      );
      await tester.pumpAndSettle();
      expect(find.text('retained conversation'), findsOneWidget);
      expect(find.text('caption before upload'), findsOneWidget);
      expect(find.text('重试上传'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).readOnly,
        isFalse,
      );
      await tester.enterText(find.byType(TextField), 'caption after failure');
      gateway.pending = null;
      await tester.tap(find.text('重试上传'));
      await tester.pumpAndSettle();
      expect(gateway.picks, 1);
      expect(gateway.uploads, 2);
      expect(api.bodies.single['attachment_ids'], [42]);
      expect(api.bodies.single['content'], 'caption after failure');
      expect(find.text('重试上传'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('removing failed media preserves text and restores normal send', (
    tester,
  ) async {
    final api = _MediaApi();
    final gateway = _RetryGateway();
    await _show(tester, api, gateway: gateway);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField),
      'text kept after removing media',
    );
    await tester.tap(find.byTooltip('发送图片'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('移除附件'));
    await tester.pumpAndSettle();
    expect(find.text('text kept after removing media'), findsOneWidget);
    await tester.tap(find.text('发送'));
    await tester.pumpAndSettle();
    expect(api.bodies.single['content'], 'text kept after removing media');
    expect(api.bodies.single.containsKey('attachment_ids'), isFalse);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'revoked upload clears retained content instead of offering unsafe retry',
    (tester) async {
      final api = _MediaApi();
      final gateway = _RetryGateway()..failureStatus = 403;
      await _show(tester, api, gateway: gateway);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'revoked caption');
      await tester.tap(find.byTooltip('发送图片'));
      await tester.pumpAndSettle();
      expect(find.text('retained conversation'), findsNothing);
      expect(find.text('revoked caption'), findsNothing);
      expect(find.text('重试上传'), findsNothing);
      expect(api.bodies, isEmpty);
      expect(find.textContaining('当前无法发送附件'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'uploaded asset waits offline and explicit send retry does not upload again',
    (tester) async {
      final api = _MediaApi();
      final gateway = _RetryGateway()..pending = Completer();
      await _show(tester, api, gateway: gateway);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('发送图片'));
      await tester.pumpAndSettle();
      api.unavailable = true;
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      gateway.pending!.complete(_RetryGateway.ready);
      await tester.pumpAndSettle();
      expect(api.bodies, isEmpty);
      api.unavailable = false;
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(api.bodies, isEmpty);
      await tester.tap(find.text('重试发送附件'));
      await tester.pumpAndSettle();
      expect(gateway.uploads, 1);
      expect(gateway.picks, 1);
      expect(api.bodies.single['attachment_ids'], [42]);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('502 after possible commit retries same logical message key', (
    tester,
  ) async {
    final api = _UnknownSendApi();
    await _show(tester, api);
    await tester.enterText(
      find.byType(TextField),
      'synthetic unchanged payload',
    );
    await tester.tap(find.text('发送'));
    await tester.pump();
    await tester.pump();
    expect(api.bodies.length, 1);
    expect(find.textContaining('发送结果尚未确认'), findsOneWidget);
    await tester.tap(find.text('使用原消息编号重试'));
    await tester.pump();
    await tester.pump();
    expect(api.bodies.length, 2);
    expect(
      api.bodies[1]['client_message_id'],
      api.bodies[0]['client_message_id'],
    );
    expect(api.bodies[1]['content'], api.bodies[0]['content']);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
    'video attachment waits for real ready upload before message dispatch',
    (tester) async {
      final api = _Api()..allowAttachmentPreflight = true;
      final gateway = _Gateway();
      await _show(tester, api, gateway: gateway);
      await tester.tap(find.byTooltip('发送短视频'));
      await tester.pump();
      expect(gateway.pickedKind, ChatAttachmentKind.video);
      expect(api.posts, 0);
      gateway.uploaded.complete(
        const ChatMediaUploadResponse(
          assetId: 42,
          publicUrl: '/api/v1/media/42/content',
          status: 'ready',
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(api.posts, 1);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('processing video never becomes a sendable local ready asset', (
    tester,
  ) async {
    final api = _Api()..allowAttachmentPreflight = true;
    final gateway = _Gateway();
    await _show(tester, api, gateway: gateway);
    await tester.tap(find.byTooltip('发送短视频'));
    await tester.pump();
    gateway.uploaded.complete(
      const ChatMediaUploadResponse(
        assetId: 42,
        publicUrl: '/api/v1/media/42/content',
        status: 'processing',
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(api.posts, 0);
    expect(find.textContaining('附件上传或处理未完成'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'session switch during message token await dispatches no message',
    (tester) async {
      final entered = Completer<void>();
      final token = Completer<String?>();
      int tokenReads = 0;
      int posts = 0;
      final dio = Dio();
      dio.interceptors.add(
        AuthInterceptor(
          accessTokenProvider: () {
            tokenReads++;
            if (tokenReads == 1) return Future.value('test-fixture-only');
            if (!entered.isCompleted) entered.complete();
            return token.future;
          },
        ),
      );
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) {
            if (request.method == 'POST') posts++;
            handler.resolve(
              Response(
                requestOptions: request,
                statusCode: 200,
                data: <String, dynamic>{'items': <dynamic>[]},
              ),
            );
          },
        ),
      );
      await _show(tester, ApiClient(dio: dio));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 10));
      }
      await tester.pumpAndSettle();
      expect(tokenReads, 1);
      await tester.enterText(find.byType(TextField), '旧账户待发送');
      await tester.tap(find.text('发送'));
      await tester.pump();
      for (var i = 0; i < 10 && !entered.isCompleted; i++) {
        await tester.pump(const Duration(milliseconds: 10));
      }
      expect(entered.isCompleted, isTrue);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(LiveChatPage)),
      );
      (container.read(sessionProvider.notifier) as _Session).relogin();
      await tester.pump();
      token.complete('test-new-fixture-only');
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 10));
      }
      await tester.pumpAndSettle();
      expect(posts, 0);
      await tester.pumpWidget(const SizedBox());
    },
  );
  test('session switch during form preparation sends no upload', () async {
    final api = _Api();
    final form = Completer<FormData>();
    bool current = true;
    final gateway = PlatformChatMediaGateway(
      apiClient: api,
      formBuilder:
          ({
            required mediaType,
            required filePath,
            required fileName,
            required metadata,
          }) => form.future,
    );
    final upload = gateway.uploadForSession(
      ChatAttachmentKind.image,
      const ChatPickedMedia(path: 'fixture', name: 'fixture.png'),
      isCurrent: () => current,
      cancelToken: CancelToken(),
    );
    current = false;
    form.complete(FormData());
    await expectLater(upload, throwsA(isA<ChatMediaGatewayException>()));
    expect(api.posts, 0);
  });
  test(
    'session switch during async token acquisition cancels before dispatch',
    () async {
      final token = Completer<String?>();
      final entered = Completer<void>();
      bool current = true;
      int dispatched = 0;
      final dio = Dio();
      dio.interceptors.add(
        AuthInterceptor(
          accessTokenProvider: () {
            entered.complete();
            return token.future;
          },
        ),
      );
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) {
            dispatched++;
            handler.resolve(
              Response(
                requestOptions: request,
                statusCode: 200,
                data: <String, dynamic>{
                  'asset': {'id': 7, 'status': 'ready'},
                },
              ),
            );
          },
        ),
      );
      final gateway = PlatformChatMediaGateway(
        apiClient: ApiClient(dio: dio),
        formBuilder:
            ({
              required mediaType,
              required filePath,
              required fileName,
              required metadata,
            }) async => FormData(),
      );
      final upload = gateway.uploadForSession(
        ChatAttachmentKind.image,
        const ChatPickedMedia(path: 'fixture', name: 'fixture.png'),
        isCurrent: () => current,
        cancelToken: CancelToken(),
      );
      await entered.future;
      current = false;
      token.complete('test-fixture-only');
      await expectLater(upload, throwsA(isA<ChatMediaGatewayException>()));
      expect(dispatched, 0);
    },
  );
  testWidgets(
    'upload completion after same ID relogin cannot send attachment',
    (tester) async {
      final api = _Api();
      final gateway = _Gateway();
      await _show(tester, api, gateway: gateway);
      api.pending.complete(const NetworkSuccess({'items': []}));
      await tester.pump();
      await tester.tap(find.byTooltip('发送图片'));
      await tester.pump();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(LiveChatPage)),
      );
      (container.read(sessionProvider.notifier) as _Session).relogin();
      await tester.pump();
      gateway.uploaded.complete(
        const ChatMediaUploadResponse(
          assetId: 7,
          publicUrl: null,
          status: 'ready',
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(api.posts, 0);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'attachment authorization failure clears whole message projection',
    (tester) async {
      final api = _Api();
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response(requestOptions: options, statusCode: 403),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );
      await _show(tester, api, dio: dio);
      api.pending.complete(
        const NetworkSuccess({
          'items': [
            {
              'content': '附件已拒消息',
              'attachments': [
                {
                  'media_asset': {'id': 7, 'media_type': 'image'},
                },
              ],
            },
          ],
        }),
      );
      await tester.pumpAndSettle();
      expect(find.text('附件已拒消息'), findsNothing);
      expect(find.textContaining('当前无法读取消息或附件'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'delayed load cannot restore messages after send authorization rejection',
    (tester) async {
      final api = _Api();
      await _show(tester, api);
      await tester.enterText(find.byType(TextField), '拒绝发送');
      await tester.tap(find.text('发送'));
      await tester.pump();
      api.pending.complete(
        const NetworkSuccess({
          'items': [
            {'content': '拒绝前旧消息'},
          ],
        }),
      );
      await tester.pump();
      await tester.pump();
      expect(find.text('拒绝前旧消息'), findsNothing);
      expect(find.textContaining('发送未完成'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('same ID relogin invalidates old load identity', (tester) async {
    final api = _Api();
    await _show(tester, api);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(LiveChatPage)),
    );
    (container.read(sessionProvider.notifier) as _Session).relogin();
    await tester.pump();
    api.pending.complete(
      const NetworkSuccess({
        'items': [
          {'content': '旧登录消息'},
        ],
      }),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('旧登录消息'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
}

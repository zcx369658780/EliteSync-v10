import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
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
  Future<SessionState> build() async => const SessionState(
    status: AuthStatus.authenticated,
    user: UserSummary(id: 1, phone: 'fictional'),
  );
}

class _Api extends ApiClient {
  _Api() : super(dio: Dio());
  final pending = Completer<NetworkResult<Map<String, dynamic>>>();
  int posts = 0;
  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) => query?['limit'] == 1
      ? Future.value(const NetworkSuccess({'items': <Map<String, dynamic>>[]}))
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

Future<void> _show(
  WidgetTester tester,
  ApiClient api, {
  _Gateway? gateway,
  Dio? dio,
}) async {
  final container = ProviderContainer(
    overrides: [
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
      child: const MaterialApp(home: LiveChatPage(peerId: 2)),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets(
    'video attachment waits for real ready upload before message dispatch',
    (tester) async {
      final api = _Api();
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
    final api = _Api();
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

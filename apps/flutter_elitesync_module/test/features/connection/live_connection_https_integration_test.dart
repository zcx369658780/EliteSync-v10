import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/app/router/app_router.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/storage/private_cache_service.dart';
import 'package:flutter_elitesync_module/core/storage/secure_storage_service.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/chat/data/datasource/chat_socket_data_source.dart';
import 'package:flutter_elitesync_module/features/chat/data/dto/message_dto.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/providers/chat_providers.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/enums/match_status.dart';
import 'package:flutter_elitesync_module/shared/enums/questionnaire_status.dart';
import 'package:flutter_elitesync_module/shared/enums/verification_status.dart';
import 'package:flutter_elitesync_module/shared/models/navigation_snapshot.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/navigation_guard_provider.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/synthetic_private_login.dart';

const _origin = 'https://127.0.0.1:18444';

class _FixtureSession extends SessionNotifier {
  _FixtureSession(this.id, this.token);

  final int id;
  final String token;

  @override
  SessionState build() => SessionState(
    status: AuthStatus.authenticated,
    user: UserSummary(id: id, phone: ''),
    accessToken: token,
  );
}

class _LoopbackHttp extends HttpOverrides {}

class _NoSocket extends ChatSocketDataSource {
  _NoSocket({
    required super.apiClient,
    required super.localStorage,
    required super.env,
  });

  @override
  Stream<MessageDto> observe(String peerId) => const Stream.empty();
}

Dio _verifiedTransport(Uint8List certificate, String bearer) {
  final context = SecurityContext(withTrustedRoots: false)
    ..setTrustedCertificatesBytes(certificate);
  final dio = Dio(
    BaseOptions(
      baseUrl: _origin,
      connectTimeout: const Duration(seconds: 4),
      receiveTimeout: const Duration(seconds: 4),
      followRedirects: false,
      headers: {
        'Authorization': 'Bearer $bearer',
        'Accept': 'application/json',
        'Connection': 'close',
      },
    ),
  );
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () =>
        _LoopbackHttp().createHttpClient(context)..findProxy = (_) => 'DIRECT',
  );
  return dio;
}

Future<void> _until(
  WidgetTester tester,
  bool Function() ready,
  String description,
) async {
  for (var attempt = 0; attempt < 80; attempt++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (ready()) return;
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
  }
  expect(ready(), isTrue, reason: description);
}

Future<void> _visible(WidgetTester tester, Finder finder) =>
    _until(
      tester,
      () => finder.evaluate().isNotEmpty,
      finder.describeMatch(Plurality.many),
    );

Future<void> _mount(
  WidgetTester tester,
  int user,
  int peer,
  String token,
  Dio dio,
  SecureStorageService secure, {
  bool oldChatLink = false,
}) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appEnvProvider.overrideWithValue(
          AppEnv(
            flavor: AppFlavor.dev,
            appName: 'EliteSync local integration fixture',
            apiBaseUrl: _origin,
            useMockData: false,
            restorationLocalBuild: true,
            initialRoute: oldChatLink
                ? '/live-chat/$peer'
                : '/live-connection?peerId=$peer',
          ),
        ),
        apiClientProvider.overrideWithValue(ApiClient(dio: dio)),
        secureStorageProvider.overrideWithValue(secure),
        chatSocketDataSourceProvider.overrideWith(
          (ref) => _NoSocket(
            apiClient: ref.read(apiClientProvider),
            localStorage: ref.read(localStorageProvider),
            env: ref.read(appEnvProvider),
          ),
        ),
        sessionProvider.overrideWith(() => _FixtureSession(user, token)),
        navigationGuardProvider.overrideWithValue(
          const NavigationSnapshot(
            authStatus: AuthStatus.authenticated,
            verificationStatus: VerificationStatus.unknown,
            questionnaireStatus: QuestionnaireStatus.unknown,
            matchStatus: MatchStatus.unknown,
            canChat: false,
            readinessState: ReadinessGuardState.unknown,
            isBootstrapLoading: false,
          ),
        ),
      ],
      child: Consumer(
        builder: (_, ref, _) => MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: ref.watch(appRouterProvider),
        ),
      ),
    ),
  );
}

void main() {
  final raw = Platform.environment['ELITESYNC_FUNCTION_APP_FIXTURE'];
  testWidgets(
    'real app router drives Connection, consent, text and revoke over local HTTPS',
    (tester) async {
      final fixture = jsonDecode(raw!) as Map<String, dynamic>;
      final certificate = base64Decode(fixture['certificate'] as String);
      final a = fixture['a'] as int;
      final b = fixture['b'] as int;
      final tokenA = fixture['tokenA'] as String;
      final tokenB = fixture['tokenB'] as String;
      final dioA = _verifiedTransport(certificate, tokenA);
      final dioB = _verifiedTransport(certificate, tokenB);
      int? committedMessageId;
      int? rejectedSendStatus;
      int? receivedServerMessageId;
      int? rejectedReadStatus;
      int? deepLinkReadStatus;
      dioB.interceptors.add(
        InterceptorsWrapper(
          onResponse: (response, handler) {
            if (response.requestOptions.method == 'GET' &&
                response.requestOptions.path == '/api/v1/messages' &&
                response.data is Map) {
              for (final item in (response.data['items'] as List)) {
                if (item['id'] == committedMessageId) {
                  receivedServerMessageId = item['id'] as int;
                }
              }
            }
            handler.next(response);
          },
          onError: (error, handler) {
            if (error.requestOptions.method == 'GET' &&
                error.requestOptions.path == '/api/v1/messages') {
              rejectedReadStatus = error.response?.statusCode ?? -1;
            }
            handler.next(error);
          },
        ),
      );
      dioA.interceptors.add(
        InterceptorsWrapper(
          onResponse: (response, handler) {
            if (response.requestOptions.method == 'POST' &&
                response.requestOptions.path == '/api/v1/messages' &&
                response.statusCode == 200 &&
                response.data is Map) {
              committedMessageId = response.data['id'] as int?;
            }
            handler.next(response);
          },
          onError: (error, handler) {
            if (error.requestOptions.path == '/api/v1/messages') {
              final status = error.response?.statusCode ?? -1;
              if (error.requestOptions.method == 'POST') {
                rejectedSendStatus = status;
              } else if (error.requestOptions.method == 'GET') {
                deepLinkReadStatus = status;
              }
            }
            handler.next(error);
          },
        ),
      );
      addTearDown(dioA.close);
      addTearDown(dioB.close);
      final storageA = SyntheticPrivateStore();
      final storageB = SyntheticPrivateStore();
      expect(
        await PrivateCacheService.forStorage(storageA).establishLogin(
          userId: a,
          retention: fixture['retentionA'] as Map<String, dynamic>,
        ),
        isTrue,
      );
      expect(
        await PrivateCacheService.forStorage(storageB).establishLogin(
          userId: b,
          retention: fixture['retentionB'] as Map<String, dynamic>,
        ),
        isTrue,
      );
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(800, 1100);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      Future<void> click(String name) async {
        final item = find.text(name);
        await _visible(tester, item);
        await tester.ensureVisible(item);
        await _visible(tester, item.hitTestable());
        await tester.tap(item);
      }

      final chat = find.widgetWithText(FilledButton, '进入消息');
      Future<void> enterChat() async {
        await _until(
          tester,
          () => chat.evaluate().isNotEmpty &&
              tester.widget<FilledButton>(chat).onPressed != null,
          'wait for current read and send permission',
        );
        await click('进入消息');
      }

      await _mount(tester, a, b, tokenA, dioA, storageA);
      await click('请求连接');
      await _visible(tester, find.text('撤回连接请求'));
      await _mount(tester, b, a, tokenB, dioB, storageB);
      await click('接受连接');
      await click('请求消息同意');
      await _visible(tester, find.text('撤回消息同意请求'));

      await _mount(tester, a, b, tokenA, dioA, storageA);
      await click('接受消息同意');
      await _visible(tester, find.text('撤销消息同意'));
      await enterChat();
      await _visible(tester, find.byType(TextField).hitTestable());
      const message = 'Text from the isolated Flutter fixture';
      await tester.enterText(find.byType(TextField), message);
      await click('发送');
      await _until(
        tester,
        () => committedMessageId != null || rejectedSendStatus != null,
        'wait for the authoritative send receipt before switching accounts',
      );
      expect(rejectedSendStatus, isNull);
      expect(committedMessageId, greaterThan(0));
      await _visible(tester, find.text(message, findRichText: true));

      await _mount(tester, b, a, tokenB, dioB, storageB);
      await enterChat();
      await _until(
        tester,
        () => receivedServerMessageId != null || rejectedReadStatus != null,
        'wait for the recipient current authorized history read',
      );
      expect(rejectedReadStatus, isNull);
      expect(receivedServerMessageId, committedMessageId);
      expect(PrivateCacheService.forStorage(storageB).isUnlocked, isTrue);
      await _visible(tester, find.text(message, findRichText: true));
      await _mount(tester, b, a, tokenB, dioB, storageB);
      await click('撤销消息同意');
      await _visible(tester, find.text('重新请求消息同意'));
      expect(tester.widget<FilledButton>(chat).onPressed, isNull);

      await _mount(tester, a, b, tokenA, dioA, storageA);
      await _visible(tester, find.text('重新请求消息同意'));
      expect(tester.widget<FilledButton>(chat).onPressed, isNull);
      expect(find.text(message), findsNothing);
      await _mount(tester, a, b, tokenA, dioA, storageA, oldChatLink: true);
      await _visible(tester, find.textContaining('当前无法读取对话'));
      expect(deepLinkReadStatus, 404);
      expect(find.text(message), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      dioA.close(force: true);
      dioB.close(force: true);
      await tester.pump();
    },
    skip: raw == null,
  );
}

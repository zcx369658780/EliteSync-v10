import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/storage/private_cache_service.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/pages/live_chat_page.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

import '../../../../support/synthetic_private_login.dart';

class _Session extends SessionNotifier {
  @override
  SessionState build() => const SessionState(
    status: AuthStatus.authenticated,
    user: UserSummary(id: 1, phone: 'fictional'),
  );

  void switchAccount() => state = const AsyncData(
    SessionState(
      status: AuthStatus.authenticated,
      user: UserSummary(id: 3, phone: 'fictional'),
    ),
  );
}

class _Api extends ApiClient {
  _Api() : super(dio: Dio());
  int count = 7;
  bool includeSenders = false;
  bool unavailable = false;
  final deltas = <int>[];
  int? olderFailure;
  bool duplicateOlder = false;
  Completer<NetworkResult<Map<String, dynamic>>>? pendingOlder;
  Completer<NetworkResult<Map<String, dynamic>>>? pendingLatest;
  final cursors = <int>[];

  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    if (query?['latest'] == 1 && pendingLatest != null) {
      return pendingLatest!.future;
    }
    if (unavailable) {
      return NetworkFailure(
        message: 'fictional offline',
        error: TimeoutException('fictional'),
      );
    }
    final after = query?['after_id'] as int?;
    if (after != null) deltas.add(after);
    final before = query?['before_id'] as int?;
    if (before != null) {
      cursors.add(before);
      if (pendingOlder != null) return pendingOlder!.future;
      if (olderFailure != null) {
        final status = olderFailure;
        olderFailure = null;
        return NetworkFailure(message: 'fictional failure', statusCode: status);
      }
    }
    // Small server pages keep the widget test focused on paging behavior.
    final history =
        List.generate(
              count,
              (i) => <String, dynamic>{
                'id': i + 1,
                if (includeSenders)
                  'sender_id': i == 6 ? null : (i.isEven ? 2 : 1),
                'is_read': true,
                'content': 'fictional message ${i + 1}',
                'attachments': <dynamic>[],
              },
            )
            .where(
              (m) =>
                  (before == null || (m['id'] as int) < before) &&
                  (after == null || (m['id'] as int) > after),
            )
            .toList();
    final page = after != null
        ? history.take(3).toList()
        : history.skip(history.length > 3 ? history.length - 3 : 0).toList();
    return NetworkSuccess({
      'items': [
        ...page,
        if (before != null && duplicateOlder && page.isNotEmpty) page.last,
      ],
      'has_more': history.length > 3,
    });
  }
}

Future<(ProviderContainer, PrivateCacheService)> _mount(
  WidgetTester tester,
  _Api api,
) async {
  final secure = await syntheticPrivateLogin();
  final container = ProviderContainer(
    overrides: [
      secureStorageProvider.overrideWithValue(secure),
      apiClientProvider.overrideWithValue(api),
      sessionProvider.overrideWith(_Session.new),
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
  await tester.pumpAndSettle();
  return (container, PrivateCacheService.forStorage(secure));
}

Future<void> _older(WidgetTester tester) async {
  final button = find.byKey(const ValueKey('load-earlier-messages'));
  await tester.scrollUntilVisible(
    button,
    250,
    scrollable: find.descendant(
      of: find.byType(ListView),
      matching: find.byType(Scrollable),
    ),
  );
  await Scrollable.ensureVisible(tester.element(button), alignment: 0.5);
  await tester.pumpAndSettle();
  expect(button.hitTestable(), findsOneWidget);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'message direction uses current sender and unknown stays neutral',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final api = _Api()..includeSenders = true;
      await _mount(tester, api);
      expect(find.text('我 · 已读'), findsOneWidget);
      expect(find.text('对方'), findsOneWidget);
      expect(find.text('消息'), findsOneWidget);
      final own = find.byKey(const ValueKey('live-message-6'));
      final peer = find.byKey(const ValueKey('live-message-5'));
      expect(
        tester.getTopLeft(own).dx,
        greaterThan(tester.getTopLeft(peer).dx),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('another page recovering first does not lock the retained chat', (
    tester,
  ) async {
    final api = _Api();
    final (_, cache) = await _mount(tester, api);
    api.unavailable = true;
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();
    expect(find.textContaining('离线只读'), findsOneWidget);
    // The conversation list uses this same current-read transition.
    cache.beginOnlineRevalidation();
    expect(
      await cache.saveAuthorized('live-conversations:visible', {
        'items': <dynamic>[],
      }, expectedAccountId: 1),
      isTrue,
    );
    api.unavailable = false;
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(find.byType(TextField)).readOnly, isFalse);
    expect(find.text('fictional message 7'), findsOneWidget);
    expect(find.textContaining('私密内容已锁定'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('recovery offers older pages after a bounded offline copy', (
    tester,
  ) async {
    final api = _Api();
    final (_, cache) = await _mount(tester, api);
    await _older(tester);
    await _older(tester);
    // Offline snapshots intentionally retain a selected recent subset.
    expect(
      await cache.saveAuthorized('live-chat:2', {
        'messages': [
          {
            'id': 7,
            'content': 'fictional message 7',
            'attachments': <dynamic>[],
          },
        ],
        'images': <String, dynamic>{},
      }, expectedAccountId: 1),
      isTrue,
    );
    api.unavailable = true;
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();
    api.unavailable = false;
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();
    await _older(tester);
    expect(api.cursors, [5, 2, 5]);
    await tester.pumpWidget(const SizedBox());
  });

  for (final automatic in [true, false]) {
    testWidgets(
      'recovers from offline read-only ${automatic ? "automatically" : "on refresh"}',
      (tester) async {
        final api = _Api();
        await _mount(tester, api);
        api.unavailable = true;
        await tester.tap(find.byIcon(Icons.refresh));
        await tester.pumpAndSettle();
        expect(find.textContaining('离线只读'), findsOneWidget);
        expect(
          tester.widget<TextField>(find.byType(TextField)).readOnly,
          isTrue,
        );
        api.unavailable = false;
        if (automatic) {
          await tester.pump(const Duration(seconds: 3));
        } else {
          await tester.tap(find.byIcon(Icons.refresh));
        }
        await tester.pumpAndSettle();
        expect(find.textContaining('离线只读'), findsNothing);
        expect(find.textContaining('私密内容已锁定'), findsNothing);
        expect(
          tester.widget<TextField>(find.byType(TextField)).readOnly,
          isFalse,
        );
        expect(find.text('fictional message 7'), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  testWidgets(
    'older pages remain ordered and deduplicated after live refresh',
    (tester) async {
      final api = _Api()..duplicateOlder = true;
      final (_, cache) = await _mount(tester, api);
      expect(find.text('fictional message 7'), findsOneWidget);
      await _older(tester);
      await _older(tester);
      expect(api.cursors, [5, 2]);
      await tester.scrollUntilVisible(
        find.text('已显示全部消息'),
        250,
        scrollable: find.descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        ),
      );
      expect(find.text('fictional message 1'), findsOneWidget);
      api.count = 8;
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();
      final saved = await cache.readOnlineAuthorized('live-chat:2');
      final ids = (saved!['messages'] as List).map((m) => m['id']).toList();
      expect(ids, [1, 2, 3, 4, 5, 6, 7, 8]);
      api.count = 15;
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();
      final afterBurst = await cache.readOnlineAuthorized('live-chat:2');
      expect(
        (afterBurst!['messages'] as List).map((m) => m['id']),
        List.generate(15, (i) => i + 1),
      );
      expect(api.deltas, [8, 11]);
      await tester.drag(find.byType(ListView), const Offset(0, -3000));
      await tester.pumpAndSettle();
      expect(find.text('fictional message 15'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'history read failure preserves current messages and retries the same cursor',
    (tester) async {
      final api = _Api()..olderFailure = 503;
      await _mount(tester, api);
      await _older(tester);
      expect(find.text('较早消息加载失败，请重试。'), findsOneWidget);
      expect(find.text('fictional message 7'), findsOneWidget);
      await _older(tester);
      expect(api.cursors, [5, 5]);
      expect(find.text('较早消息加载失败，请重试。'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('delayed older page cannot render after switching account', (
    tester,
  ) async {
    final api = _Api()..pendingOlder = Completer();
    final (container, _) = await _mount(tester, api);
    await _older(tester);
    (container.read(sessionProvider.notifier) as _Session).switchAccount();
    await tester.pumpAndSettle();
    api.pendingOlder!.complete(
      const NetworkSuccess({
        'items': [
          {
            'id': 1,
            'content': 'old private history',
            'attachments': <dynamic>[],
          },
        ],
        'has_more': false,
      }),
    );
    await tester.pumpAndSettle();
    expect(find.text('old private history'), findsNothing);
    expect(find.text('会话已锁定'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('revoked history access clears the displayed conversation', (
    tester,
  ) async {
    final api = _Api()..olderFailure = 403;
    final (_, cache) = await _mount(tester, api);
    await _older(tester);
    expect(find.text('fictional message 7'), findsNothing);
    expect(await cache.readOnlineAuthorized('live-chat:2'), isNull);
    expect(find.textContaining('当前无法读取对话'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('older-page intent waits for a live read and coalesces taps', (
    tester,
  ) async {
    final api = _Api();
    await _mount(tester, api);
    api.pendingLatest = Completer();
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();
    await _older(tester);
    await _older(tester);
    expect(api.cursors, isEmpty);
    api.pendingLatest!.complete(
      const NetworkSuccess({
        'items': [
          {
            'id': 5,
            'content': 'fictional message 5',
            'attachments': <dynamic>[],
          },
          {
            'id': 6,
            'content': 'fictional message 6',
            'attachments': <dynamic>[],
          },
          {
            'id': 7,
            'content': 'fictional message 7',
            'attachments': <dynamic>[],
          },
        ],
        'has_more': true,
      }),
    );
    await tester.pumpAndSettle();
    expect(api.cursors, [5]);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('queued older-page intent is discarded on account switch', (
    tester,
  ) async {
    final api = _Api();
    final (container, _) = await _mount(tester, api);
    api.pendingLatest = Completer();
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();
    await _older(tester);
    (container.read(sessionProvider.notifier) as _Session).switchAccount();
    await tester.pumpAndSettle();
    api.pendingLatest!.complete(
      const NetworkSuccess({
        'items': [
          {
            'id': 7,
            'content': 'obsolete live result',
            'attachments': <dynamic>[],
          },
        ],
        'has_more': true,
      }),
    );
    await tester.pumpAndSettle();
    expect(api.cursors, isEmpty);
    expect(find.text('obsolete live result'), findsNothing);
    expect(find.text('会话已锁定'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'newest-window refresh cannot acknowledge an older-page failure',
    (tester) async {
      final api = _Api()..olderFailure = 503;
      await _mount(tester, api);
      await _older(tester);
      expect(find.text('较早消息加载失败，请重试。'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();
      expect(find.text('较早消息加载失败，请重试。'), findsOneWidget);
      expect(api.cursors, [5]);
      await _older(tester);
      expect(api.cursors, [5, 5]);
      expect(find.text('较早消息加载失败，请重试。'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('current read of all history resolves an obsolete page failure', (
    tester,
  ) async {
    final api = _Api()..olderFailure = 503;
    await _mount(tester, api);
    await _older(tester);
    api.count = 3;
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();
    expect(find.text('较早消息加载失败，请重试。'), findsNothing);
    expect(find.byKey(const ValueKey('load-earlier-messages')), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
}

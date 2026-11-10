import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/features/notification/presentation/pages/notification_preferences_page.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

class _Session extends SessionNotifier {
  @override
  SessionState build() => const SessionState(
    status: AuthStatus.authenticated,
    user: UserSummary(id: 1, phone: 'fictional'),
    accessToken: 'fictional-notification-session',
  );

  void switchAccount() => state = const AsyncData(
    SessionState(
      status: AuthStatus.authenticated,
      user: UserSummary(id: 2, phone: 'fictional'),
      accessToken: 'fictional-other-session',
    ),
  );
}

class _Api extends ApiClient {
  _Api() : super(dio: Dio());
  final categories = <String, bool>{'message': true};
  bool silent = false;
  int failuresRemaining = 1;
  int reads = 0;
  final pendingReads = <Completer<NetworkResult<Map<String, dynamic>>>>[];
  final puts = <Map<String, dynamic>>[];
  Completer<void>? beforeAcknowledge;

  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    reads++;
    if (pendingReads.isNotEmpty) return pendingReads.removeAt(0).future;
    return NetworkSuccess({'categories': Map.of(categories), 'silent': silent});
  }

  @override
  Future<NetworkResult<Map<String, dynamic>>> put(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    final payload = Map<String, dynamic>.from(body! as Map);
    puts.add(payload);
    if (failuresRemaining > 0) {
      failuresRemaining--;
      return const NetworkFailure(
        message: 'fictional unavailable',
        statusCode: 503,
      );
    }
    if (payload['categories'] case final Map changed) {
      categories.addAll(Map<String, bool>.from(changed));
    }
    if (payload.containsKey('silent')) silent = payload['silent'] as bool;
    await beforeAcknowledge?.future;
    return const NetworkSuccess({});
  }
}

Future<ProviderContainer> _mount(WidgetTester tester, _Api api) async {
  final container = ProviderContainer(
    overrides: [
      apiClientProvider.overrideWithValue(api),
      sessionProvider.overrideWith(_Session.new),
    ],
  );
  addTearDown(container.dispose);
  await container.read(sessionProvider.future);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: NotificationPreferencesPage()),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

Finder _toggle(String label) =>
    find.ancestor(of: find.text(label), matching: find.byType(SwitchListTile));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('flutter.baseflow.com/permissions/methods');
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => 0);
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  for (final label in ['消息', '静默提醒']) {
    testWidgets(
      '$label failed save survives successful old-value readback and retries its original payload',
      (tester) async {
        final api = _Api();
        await _mount(tester, api);
        await tester.tap(_toggle(label));
        await tester.pumpAndSettle();
        expect(api.reads, 2);
        expect(find.text('保存未完成，请重试。'), findsOneWidget);
        expect(find.text('重试保存'), findsOneWidget);
        expect(
          tester.widget<SwitchListTile>(_toggle(label)).value,
          label == '消息',
        );
        final original = label == '消息'
            ? {
                'categories': {'message': false},
              }
            : {'silent': true};
        expect(api.puts.single, original);
        api.beforeAcknowledge = Completer();
        await tester.tap(find.text('重试保存'));
        await tester.pumpAndSettle();
        expect(find.text('保存未完成，请重试。'), findsOneWidget);
        expect(
          tester
              .widget<TextButton>(find.widgetWithText(TextButton, '正在保存…'))
              .onPressed,
          isNull,
        );
        api.beforeAcknowledge!.complete();
        await tester.pumpAndSettle();
        expect(api.puts, [original, original]);
        expect(find.text('保存未完成，请重试。'), findsNothing);
        expect(find.text('重试保存'), findsNothing);
        expect(
          tester.widget<SwitchListTile>(_toggle(label)).value,
          label != '消息',
        );
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  testWidgets('a new user choice replaces the previous failed intent', (
    tester,
  ) async {
    final api = _Api();
    await _mount(tester, api);
    await tester.tap(_toggle('静默提醒'));
    await tester.pumpAndSettle();
    expect(find.text('重试保存'), findsOneWidget);
    await tester.tap(_toggle('消息'));
    await tester.pumpAndSettle();
    expect(api.puts, [
      {'silent': true},
      {
        'categories': {'message': false},
      },
    ]);
    expect(api.silent, isFalse);
    expect(api.categories['message'], isFalse);
    expect(find.text('重试保存'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('account switch clears the previous account failed save', (
    tester,
  ) async {
    final api = _Api();
    final container = await _mount(tester, api);
    await tester.tap(_toggle('消息'));
    await tester.pumpAndSettle();
    expect(find.text('重试保存'), findsOneWidget);
    (container.read(sessionProvider.notifier) as _Session).switchAccount();
    await tester.pumpAndSettle();
    expect(find.text('重试保存'), findsNothing);
    expect(find.text('保存未完成，请重试。'), findsNothing);
    expect(api.puts, hasLength(1));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('older read cannot restore a revoked system permission', (
    tester,
  ) async {
    var permission = 1;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => permission);
    final api = _Api();
    await _mount(tester, api);
    expect(find.text('已允许'), findsOneWidget);
    final older = Completer<NetworkResult<Map<String, dynamic>>>();
    final latest = Completer<NetworkResult<Map<String, dynamic>>>();
    api.pendingReads.addAll([older, latest]);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    permission = 0;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    latest.complete(
      const NetworkSuccess({
        'categories': {'message': false},
      }),
    );
    await tester.pumpAndSettle();
    older.complete(
      const NetworkSuccess({
        'categories': {'message': true},
      }),
    );
    await tester.pumpAndSettle();
    expect(find.text('已允许'), findsNothing);
    expect(find.text('未允许；消息和安全入口仍可使用'), findsOneWidget);
    expect(tester.widget<SwitchListTile>(_toggle('消息')).value, isFalse);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('revocation is visible before preference readback completes', (
    tester,
  ) async {
    var permission = 1;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => permission);
    final api = _Api();
    await _mount(tester, api);
    expect(find.text('已允许'), findsOneWidget);
    final read = Completer<NetworkResult<Map<String, dynamic>>>();
    api.pendingReads.add(read);
    permission = 0;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text('已允许'), findsNothing);
    expect(find.text('未允许；消息和安全入口仍可使用'), findsOneWidget);
    read.complete(const NetworkSuccess({'categories': {}}));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('one system permission request remains in flight', (
    tester,
  ) async {
    final request = Completer<Map<int, int>>();
    var requests = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'requestPermissions') {
            requests++;
            return request.future;
          }
          return 0;
        });
    await _mount(tester, _Api());
    final button = find.widgetWithText(TextButton, '请求授权');
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(tester.widget<TextButton>(button).onPressed, isNull);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(requests, 1);
    request.complete({17: 0});
    await tester.pumpAndSettle();
    expect(tester.widget<TextButton>(button).onPressed, isNotNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('permission request callback rereads the current OS state', (
    tester,
  ) async {
    final request = Completer<Map<int, int>>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          channel,
          (call) async =>
              call.method == 'requestPermissions' ? request.future : 0,
        );
    final api = _Api();
    await _mount(tester, api);
    await tester.tap(find.text('请求授权'));
    await tester.pumpAndSettle();
    // A granted dialog result may arrive after a newer OS revocation.
    request.complete({17: 1});
    await tester.pumpAndSettle();
    expect(find.text('已允许'), findsNothing);
    expect(find.text('未允许；消息和安全入口仍可使用'), findsOneWidget);
    expect(api.puts, isEmpty);
    await tester.pumpWidget(const SizedBox());
  });
}

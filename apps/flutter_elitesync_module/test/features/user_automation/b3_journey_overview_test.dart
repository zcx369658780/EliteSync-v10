import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/features/journey_integration/journey_overview_page.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import '../slow_dating_v1012/journey_pages_test.dart' show FakeApi, TestSession;
import 'user_state_page_test.dart' show snapshot;

Map<String, dynamic> stateFor(int id, {String action = 'view_journey'}) => {
  ...snapshot('OFF', 0),
  'contract_version': 'user_state_v1',
  'subject_user_id': id,
  'generated_at': '2026-11-16T01:00:00Z',
  'next_actions': [
    {'code': action},
    {'code': 'view_journey'},
  ],
};

Future<void> mount(
  WidgetTester tester,
  FakeApi api, {
  bool detailed = false,
  TestSession? session,
  bool settle = true,
}) async {
  tester.view.physicalSize = const Size(480, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        relationshipApiProvider.overrideWithValue(api),
        sessionProvider.overrideWith(() => session ?? TestSession()),
      ],
      child: MaterialApp(home: JourneyOverviewPage(detailed: detailed)),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

void main() {
  testWidgets(
    'existing CN MC and conversation remain independent of expired proposal eligibility',
    (tester) async {
      final paths = <String>[];
      await mount(
        tester,
        FakeApi((m, path, b) async {
          paths.add(path);
          if (path == '/user-state') return stateFor(1);
          if (path == '/journey')
            return {
              'proposal': {
                'peer_id': 2,
                'state': 'EXPIRED',
                'connection_eligible': false,
              },
            };
          if (path == '/connections/2')
            return {
              'connection': {'state': 'CN_ACTIVE'},
              'consent': {'state': 'MC_ACTIVE'},
              'gates': {'live_read_allowed': true},
            };
          if (path == '/conversations')
            return {
              'items': [
                {'peer_user_id': 2, 'conversation_id': 12},
              ],
            };
          return {'relationships': <dynamic>[]};
        }),
        detailed: true,
      );
      expect(paths, contains('/connections/2'));
      expect(find.text('Connection · 已连接'), findsOneWidget);
      expect(find.text('Messaging Consent · 已同意'), findsOneWidget);
      expect(find.text('进入有权会话'), findsOneWidget);
    },
  );

  testWidgets(
    'four branch route re-entry and push pop discard hidden reads and revalidate',
    (tester) async {
      final pending = Completer<Map<String, dynamic>>();
      var reads = 0;
      late StatefulNavigationShell shell;
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              shell = navigationShell;
              return navigationShell;
            },
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/home',
                    builder: (_, _) => const JourneyOverviewPage(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/progress',
                    builder: (_, _) =>
                        const Scaffold(body: Text('other branch')),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/messages',
                    builder: (_, _) => const SizedBox(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(path: '/me', builder: (_, _) => const SizedBox()),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/detail',
            builder: (_, _) => const Scaffold(body: Text('detail')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWith(TestSession.new),
            relationshipApiProvider.overrideWithValue(
              FakeApi((m, p, b) {
                reads++;
                return reads == 1
                    ? pending.future
                    : Future.value(stateFor(1, action: 'complete_lifestyle'));
              }),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pump();
      shell.goBranch(1);
      await tester.pumpAndSettle();
      pending.complete(stateFor(1, action: 'review_preparation'));
      await tester.pumpAndSettle();
      shell.goBranch(0);
      await tester.pumpAndSettle();
      expect(find.text('继续生活方式探索'), findsOneWidget);
      expect(find.text('查看必要准备'), findsNothing);
      final before = reads;
      router.push('/detail');
      await tester.pumpAndSettle();
      router.pop();
      await tester.pumpAndSettle();
      expect(reads, greaterThan(before));
      final beforeResume = reads;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(
        (tester.state(find.byType(JourneyOverviewPage)) as dynamic).data,
        isNull,
      );
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(reads, greaterThan(beforeResume));
      expect(find.text('继续生活方式探索'), findsOneWidget);
    },
  );

  testWidgets('Home reads B2 and maps one server primary action', (
    tester,
  ) async {
    final calls = <String>[];
    await mount(
      tester,
      FakeApi((method, path, body) async {
        calls.add('$method $path');
        return stateFor(1, action: 'complete_lifestyle');
      }),
    );
    expect(calls, ['GET /user-state']);
    expect(find.text('继续生活方式探索'), findsOneWidget);
    expect(find.text('已完成当前必要准备，可自行决定是否参与'), findsOneWidget);
    expect(find.byKey(const Key('home-primary-action')), findsOneWidget);
  });

  testWidgets('unknown next action has no inferred replacement action', (
    tester,
  ) async {
    await mount(
      tester,
      FakeApi((m, p, b) async => stateFor(1, action: 'future_code')),
    );
    expect(find.byKey(const Key('home-primary-action')), findsNothing);
    expect(find.text('下一步暂未识别，请刷新状态'), findsOneWidget);
  });

  testWidgets('wrong subject is rejected instead of showing private state', (
    tester,
  ) async {
    await mount(tester, FakeApi((m, p, b) async => stateFor(2)));
    expect(find.byKey(const Key('home-primary-action')), findsNothing);
    expect(find.byKey(const Key('server-error')), findsOneWidget);
  });

  testWidgets('late account read is discarded and new account is fetched', (
    tester,
  ) async {
    final first = Completer<Map<String, dynamic>>();
    final session = TestSession();
    var reads = 0;
    await mount(
      tester,
      FakeApi((m, p, b) {
        reads++;
        return reads == 1
            ? first.future
            : Future.value(stateFor(2, action: 'complete_lifestyle'));
      }),
      session: session,
      settle: false,
    );
    session.change(2);
    await tester.pumpAndSettle();
    first.complete(stateFor(1, action: 'review_preparation'));
    await tester.pumpAndSettle();
    expect(find.text('继续生活方式探索'), findsOneWidget);
    expect(find.text('查看必要准备'), findsNothing);
  });

  testWidgets(
    'Progress keeps independent domains and does not send commands on read',
    (tester) async {
      final calls = <String>[];
      await mount(
        tester,
        FakeApi((method, path, body) async {
          calls.add('$method $path');
          if (path == '/user-state') return stateFor(1);
          if (path == '/journey')
            return {
              'proposal': {
                'id': 'fixture',
                'peer_id': 2,
                'state': 'MUTUALLY_ACCEPTED',
                'connection_eligible': true,
                'decision_available': false,
                'withdraw_available': false,
              },
            };
          if (path == '/connections/2')
            return {
              'connection': {'state': 'CN_ACTIVE'},
              'consent': {'state': 'MC_PENDING', 'requester_id': 1},
              'gates': {'live_read_allowed': false},
            };
          if (path == '/conversations') return {'items': <dynamic>[]};
          if (path == '/formal-relationships')
            return {'relationships': <dynamic>[]};
          throw StateError(path);
        }),
        detailed: true,
      );
      expect(calls.every((call) => call.startsWith('GET ')), isTrue);
      expect(find.text('Connection · 已连接'), findsOneWidget);
      expect(find.text('Messaging Consent · 等待对方决定'), findsOneWidget);
      expect(find.text('进入有权会话'), findsNothing);
      expect(find.byKey(const Key('domain-formal')), findsOneWidget);
      expect(find.byKey(const Key('domain-conversation')), findsOneWidget);
    },
  );

  testWidgets('failed pair or relationship read remains unknown with retry', (
    tester,
  ) async {
    await mount(
      tester,
      FakeApi((m, path, b) async {
        if (path == '/user-state') return stateFor(1);
        if (path == '/journey')
          return {
            'proposal': {
              'peer_id': 2,
              'state': 'MUTUALLY_ACCEPTED',
              'connection_eligible': true,
            },
          };
        throw StateError('transport');
      }),
      detailed: true,
    );
    expect(find.text('Connection · 状态暂未确认'), findsOneWidget);
    expect(find.text('Messaging Consent · 状态暂未确认'), findsOneWidget);
    expect(find.text('进入有权会话'), findsNothing);
    expect(find.textContaining('正式关系读取未完成'), findsOneWidget);
  });
}

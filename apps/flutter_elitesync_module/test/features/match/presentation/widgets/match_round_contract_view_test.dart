import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_round_projection.dart';
import 'package:flutter_elitesync_module/features/match/presentation/providers/match_providers.dart';
import 'package:flutter_elitesync_module/features/match/presentation/widgets/match_round_contract_view.dart';

MatchRoundProjection _projection(
  MatchRoundBusinessState state, {
  DateTime? revealAt,
  String headline = '你们都愿意从一次轻松对话开始。',
  bool conversationAllowed = true,
  bool conversationCanSend = false,
  String? userAction,
}) {
  final now = DateTime.now().toUtc();
  return MatchRoundProjection(
    state: state,
    serverTime: now,
    receivedAt: now,
    contractVersion: 'match_round_v1',
    retryEligible: state == MatchRoundBusinessState.failed,
    userAction:
        userAction ??
        (state == MatchRoundBusinessState.revealed &&
                (conversationAllowed || conversationCanSend)
            ? 'open_messages'
            : state == MatchRoundBusinessState.failed
            ? 'retry'
            : 'wait'),
    projectionVersion: 1,
    updatedAt: now,
    nextTransitionAt: revealAt,
    roundKey: state == MatchRoundBusinessState.noRound ? null : 'round-1',
    stateVersion: state == MatchRoundBusinessState.noRound ? null : 1,
    revealAt: revealAt,
    reasonCode: 'internal_reason',
    nextActionCode: 'internal_action',
    result: state == MatchRoundBusinessState.revealed
        ? MatchRoundResult(matchId: 1, partnerId: 2, headline: headline)
        : null,
    conversationCapability: state == MatchRoundBusinessState.revealed
        ? MatchRoundConversationCapability(
            canCreate: conversationAllowed,
            canSend: conversationCanSend,
            canWebSocket: false,
          )
        : null,
  );
}

Widget _wrap(Future<MatchRoundProjection> Function(Ref) create) {
  return ProviderScope(
    key: UniqueKey(),
    overrides: [matchRoundProjectionProvider.overrideWith(create)],
    child: MaterialApp(
      theme: AppTheme.light,
      home: const MatchRoundContractView(),
    ),
  );
}

Future<void> _pumpProjection(
  WidgetTester tester,
  MatchRoundProjection projection,
) async {
  await tester.pumpWidget(_wrap((ref) async => projection));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  final expected =
      <MatchRoundBusinessState, ({String title, String body, String action})>{
        MatchRoundBusinessState.noRound: (
          title: '当前没有进行中的慢约会',
          body: '有新的轮次开放时，会在这里显示。',
          action: '返回首页',
        ),
        MatchRoundBusinessState.scheduled: (
          title: '本轮慢约会已安排',
          body: '请按服务器公布的时间等待下一次状态更新。',
          action: '刷新状态',
        ),
        MatchRoundBusinessState.preparing: (
          title: '正在为你匹配',
          body: '本轮匹配正在进行，请稍后刷新查看服务器状态。',
          action: '刷新状态',
        ),
        MatchRoundBusinessState.running: (
          title: '正在为你匹配',
          body: '本轮匹配正在进行，请稍后刷新查看服务器状态。',
          action: '刷新状态',
        ),
        MatchRoundBusinessState.revealed: (
          title: '本轮结果已公布',
          body: '你们都愿意从一次轻松对话开始。',
          action: '前往消息',
        ),
        MatchRoundBusinessState.noCandidate: (
          title: '本轮暂未匹配到合适的人',
          body: '这是本轮结果。可以返回首页，等待下一轮开放。',
          action: '返回首页',
        ),
        MatchRoundBusinessState.failed: (
          title: '本轮状态暂时无法更新',
          body: '请稍后重新加载；这不代表本轮暂未匹配到人。',
          action: '重新加载',
        ),
        MatchRoundBusinessState.closed: (
          title: '本轮已结束',
          body: '如已有可用消息，可从消息页查看。',
          action: '查看消息',
        ),
      };

  for (final entry in expected.entries) {
    testWidgets('renders truthful ${entry.key.key} state', (tester) async {
      final revealAt = entry.key == MatchRoundBusinessState.scheduled
          ? DateTime.now().toUtc().add(const Duration(hours: 2))
          : null;
      await _pumpProjection(tester, _projection(entry.key, revealAt: revealAt));

      expect(find.text('慢约会'), findsOneWidget);
      expect(find.text('查看当前状态和可用的下一步。'), findsOneWidget);
      expect(find.text(entry.value.title), findsOneWidget);
      expect(find.text(entry.value.body), findsOneWidget);
      expect(find.text(entry.value.action), findsOneWidget);
      expect(find.byType(AppPrimaryButton), findsOneWidget);
      expect(find.textContaining('404'), findsNothing);
      expect(find.textContaining('缓存'), findsNothing);
      expect(find.textContaining('服务端'), findsNothing);
      expect(find.textContaining('低压等待'), findsNothing);
      expect(find.textContaining('internal_reason'), findsNothing);
      expect(find.textContaining('internal_action'), findsNothing);
      expect(find.textContaining('match_round_v1'), findsNothing);
      expect(find.textContaining('round-1'), findsNothing);
    });
  }

  testWidgets('loading does not invent a round or countdown', (tester) async {
    final pending = Completer<MatchRoundProjection>();
    await tester.pumpWidget(_wrap((ref) => pending.future));
    await tester.pump();

    expect(find.byType(AppLoadingSkeleton), findsOneWidget);
    expect(find.text('等待本轮结果'), findsNothing);
    expect(find.textContaining('服务器更新时间'), findsNothing);
    expect(find.textContaining('小时'), findsNothing);
  });

  testWidgets('network error remains separate from no round', (tester) async {
    await tester.pumpWidget(_wrap((ref) async => throw StateError('offline')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('当前状态不可用'), findsOneWidget);
    expect(find.text('网络或服务暂时不可用，请重新连接后重试。'), findsOneWidget);
    expect(find.text('当前没有进行中的慢约会'), findsNothing);
    expect(find.text('等待本轮结果'), findsNothing);
    expect(find.textContaining('服务器更新时间'), findsNothing);
  });

  testWidgets('countdown is shown only for scheduled server transition', (
    tester,
  ) async {
    final revealAt = DateTime.now().toUtc().add(const Duration(hours: 2));
    await _pumpProjection(
      tester,
      _projection(MatchRoundBusinessState.scheduled, revealAt: revealAt),
    );

    expect(find.textContaining('小时'), findsOneWidget);
    expect(find.textContaining('服务器更新时间：'), findsOneWidget);

    await _pumpProjection(
      tester,
      _projection(MatchRoundBusinessState.scheduled),
    );
    expect(find.text('下一次状态更新时间尚未确定'), findsOneWidget);
    expect(find.text('服务器尚未公布下一次状态更新时间。'), findsOneWidget);
    expect(find.textContaining('服务器更新时间：'), findsNothing);
    expect(find.textContaining('小时'), findsNothing);

    await _pumpProjection(
      tester,
      _projection(
        MatchRoundBusinessState.scheduled,
        revealAt: DateTime.now().toUtc().subtract(const Duration(minutes: 1)),
      ),
    );
    expect(find.text('状态更新时间已到，正在等待服务器更新'), findsOneWidget);

    await _pumpProjection(
      tester,
      _projection(
        MatchRoundBusinessState.preparing,
        revealAt: DateTime.now().toUtc().add(const Duration(hours: 2)),
      ),
    );
    expect(find.textContaining('服务器更新时间：'), findsNothing);
    expect(find.textContaining('小时'), findsNothing);
  });

  testWidgets('revealed action follows supplied conversation capability', (
    tester,
  ) async {
    await _pumpProjection(
      tester,
      _projection(MatchRoundBusinessState.revealed, conversationAllowed: false),
    );

    expect(find.text('刷新结果'), findsOneWidget);
    expect(find.text('前往消息'), findsNothing);
    expect(find.text('当前没有可用的消息入口，请稍后刷新结果。'), findsOneWidget);

    await _pumpProjection(
      tester,
      _projection(MatchRoundBusinessState.revealed, headline: '   '),
    );
    expect(find.text('结果已经可以查看，请按当前可用操作继续。'), findsOneWidget);
    expect(find.text('前往消息'), findsOneWidget);
  });

  testWidgets(
    'pending refresh hides stale projection before rendering failure',
    (tester) async {
      var calls = 0;
      final pending = Completer<MatchRoundProjection>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            matchRoundProjectionProvider.overrideWith((ref) async {
              calls += 1;
              if (calls == 1) {
                return _projection(
                  MatchRoundBusinessState.scheduled,
                  revealAt: DateTime.now().toUtc().add(
                    const Duration(hours: 2),
                  ),
                );
              }
              return pending.future;
            }),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const MatchRoundContractView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('本轮慢约会已安排'), findsOneWidget);
      expect(find.textContaining('服务器更新时间：'), findsOneWidget);

      await tester.tap(find.text('刷新状态'));
      await tester.pump();
      expect(calls, 2);
      expect(find.byType(AppLoadingSkeleton), findsOneWidget);
      expect(find.text('本轮慢约会已安排'), findsNothing);
      expect(find.text('刷新状态'), findsNothing);
      expect(find.textContaining('服务器更新时间：'), findsNothing);
      expect(find.textContaining('小时'), findsNothing);

      pending.completeError(StateError('offline'));
      await tester.pumpAndSettle();
      expect(find.text('当前状态不可用'), findsOneWidget);
      expect(find.text('本轮慢约会已安排'), findsNothing);
      expect(find.textContaining('offline'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('header refresh is awaited and coalesces in-flight taps', (
    tester,
  ) async {
    var calls = 0;
    final pending = Completer<MatchRoundProjection>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          matchRoundProjectionProvider.overrideWith((ref) async {
            calls += 1;
            if (calls == 1) {
              return _projection(MatchRoundBusinessState.scheduled);
            }
            return pending.future;
          }),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MatchRoundContractView(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('刷新本轮状态'));
    await tester.pump();
    expect(calls, 2);
    expect(find.byType(AppLoadingSkeleton), findsOneWidget);
    expect(find.text('本轮慢约会已安排'), findsNothing);

    await tester.tap(find.byTooltip('刷新本轮状态'));
    await tester.pump();
    expect(calls, 2);

    pending.complete(_projection(MatchRoundBusinessState.noRound));
    await tester.pumpAndSettle();
    expect(find.text('当前没有进行中的慢约会'), findsOneWidget);
  });

  testWidgets('pull refresh failure is owned by provider error UI', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var calls = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          matchRoundProjectionProvider.overrideWith((ref) async {
            calls += 1;
            if (calls == 1) {
              return _projection(
                MatchRoundBusinessState.scheduled,
                revealAt: DateTime.now().toUtc().add(const Duration(hours: 2)),
              );
            }
            throw StateError('offline');
          }),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MatchRoundContractView(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(calls, 1);
    final listTopLeft = tester.getTopLeft(find.byType(ListView));
    await tester.dragFrom(
      listTopLeft + const Offset(100, 20),
      const Offset(0, 600),
    );
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.text('当前状态不可用'), findsOneWidget);
    expect(find.textContaining('offline'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('canSend alone enables the Messages action', (tester) async {
    await _pumpProjection(
      tester,
      _projection(
        MatchRoundBusinessState.revealed,
        conversationAllowed: false,
        conversationCanSend: true,
      ),
    );
    expect(find.text('前往消息'), findsOneWidget);
    expect(find.text('刷新结果'), findsNothing);
  });

  testWidgets('transport restoration refreshes truth without app restart', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          matchRoundProjectionProvider.overrideWith((ref) async {
            calls += 1;
            if (calls == 1) throw StateError('transport offline');
            return _projection(MatchRoundBusinessState.noRound);
          }),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MatchRoundContractView(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('当前状态不可用'), findsOneWidget);
    await tester.tap(find.text('重新加载'));
    await tester.pumpAndSettle();

    expect(calls, 2);
    expect(find.text('当前没有进行中的慢约会'), findsOneWidget);
    expect(find.text('当前状态不可用'), findsNothing);
  });

  testWidgets('server action cannot bypass denied conversation capability', (
    tester,
  ) async {
    await _pumpProjection(
      tester,
      _projection(
        MatchRoundBusinessState.revealed,
        conversationAllowed: false,
        conversationCanSend: false,
        userAction: 'open_messages',
      ),
    );

    expect(find.text('刷新结果'), findsOneWidget);
    expect(find.text('前往消息'), findsNothing);
  });

  testWidgets('capability-gated revealed action opens canonical Messages', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: AppRouteNames.match,
      routes: [
        GoRoute(
          path: AppRouteNames.match,
          builder: (_, _) => const MatchRoundContractView(),
        ),
        GoRoute(
          path: AppRouteNames.messages,
          builder: (_, _) => const Scaffold(body: Text('MESSAGES ROUTE')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          matchRoundProjectionProvider.overrideWith(
            (ref) async => _projection(MatchRoundBusinessState.revealed),
          ),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('前往消息'));
    await tester.pumpAndSettle();
    expect(find.text('MESSAGES ROUTE'), findsOneWidget);
  });

  testWidgets('primary and secondary actions keep canonical route boundaries', (
    tester,
  ) async {
    Future<GoRouter> pumpRouted(MatchRoundProjection projection) async {
      final router = GoRouter(
        initialLocation: AppRouteNames.match,
        routes: [
          GoRoute(
            path: AppRouteNames.match,
            builder: (_, _) => const MatchRoundContractView(),
          ),
          GoRoute(
            path: AppRouteNames.home,
            builder: (_, _) => const Scaffold(body: Text('HOME ROUTE')),
          ),
          GoRoute(
            path: AppRouteNames.messages,
            builder: (_, _) => const Scaffold(body: Text('MESSAGES ROUTE')),
          ),
          GoRoute(
            path: AppRouteNames.matchDetail,
            builder: (_, _) => const Scaffold(body: Text('MATCH DETAIL ROUTE')),
          ),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          key: UniqueKey(),
          overrides: [
            matchRoundProjectionProvider.overrideWith(
              (ref) async => projection,
            ),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      return router;
    }

    for (final state in [
      MatchRoundBusinessState.noRound,
      MatchRoundBusinessState.noCandidate,
    ]) {
      final router = await pumpRouted(_projection(state));
      await tester.tap(find.text('返回首页'));
      await tester.pumpAndSettle();
      expect(find.text('HOME ROUTE'), findsOneWidget);
      router.dispose();
    }

    final closedRouter = await pumpRouted(
      _projection(MatchRoundBusinessState.closed),
    );
    await tester.tap(find.text('查看消息'));
    await tester.pumpAndSettle();
    expect(find.text('MESSAGES ROUTE'), findsOneWidget);
    closedRouter.dispose();

    final deniedRouter = await pumpRouted(
      _projection(MatchRoundBusinessState.revealed, conversationAllowed: false),
    );
    await tester.tap(find.text('刷新结果'));
    await tester.pumpAndSettle();
    expect(find.text('刷新结果'), findsOneWidget);
    expect(find.text('MESSAGES ROUTE'), findsNothing);
    deniedRouter.dispose();

    expect(find.text('查看完整解释'), findsNothing);
  });
}

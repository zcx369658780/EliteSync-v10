import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/app/router/app_router.dart';
import 'package:flutter_elitesync_module/app/router/app_shell.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/telemetry/app_telemetry_service.dart';
import 'package:flutter_elitesync_module/core/telemetry/frontend_telemetry.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/state/conversation_access_state.dart';
import 'package:flutter_elitesync_module/features/connection/domain/product_connection_contract.dart';
import 'package:flutter_elitesync_module/features/connection/presentation/pages/connection_page.dart';
import 'package:flutter_elitesync_module/features/connection/presentation/providers/connection_presentation_provider.dart';
import 'package:flutter_elitesync_module/features/home/presentation/providers/calm_home_projection_provider.dart';
import 'package:flutter_elitesync_module/features/home/presentation/providers/home_provider.dart';
import 'package:flutter_elitesync_module/features/home/presentation/state/home_ui_state.dart';
import 'package:flutter_elitesync_module/features/home/presentation/state/calm_home_projection.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_round_projection.dart';
import 'package:flutter_elitesync_module/features/match/presentation/providers/match_providers.dart';
import 'package:flutter_elitesync_module/features/me/presentation/pages/me_purpose_pages.dart';
import 'package:flutter_elitesync_module/features/progress/presentation/pages/progress_page.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/enums/match_status.dart';
import 'package:flutter_elitesync_module/shared/enums/questionnaire_status.dart';
import 'package:flutter_elitesync_module/shared/enums/verification_status.dart';
import 'package:flutter_elitesync_module/shared/models/navigation_snapshot.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/navigation_guard_provider.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

NavigationSnapshot _snapshot({
  ReadinessGuardState readiness = ReadinessGuardState.ready,
  AuthStatus auth = AuthStatus.authenticated,
  VerificationStatus verification = VerificationStatus.unknown,
}) => NavigationSnapshot(
  authStatus: auth,
  verificationStatus: verification,
  questionnaireStatus: QuestionnaireStatus.unknown,
  matchStatus: MatchStatus.unknown,
  canChat: false,
  readinessState: readiness,
  isBootstrapLoading: false,
);

final _guard = StateProvider<NavigationSnapshot>((ref) => _snapshot());
final _match = StateProvider<Future<MatchRoundProjection>>(
  (ref) => Future.value(_round(MatchRoundBusinessState.revealed)),
);

MatchRoundProjection _round(MatchRoundBusinessState state) =>
    MatchRoundProjection(
      state: state,
      serverTime: DateTime.utc(2026, 10, 13),
      receivedAt: DateTime.utc(2026, 10, 13),
      updatedAt: DateTime.utc(2026, 10, 13),
      contractVersion: 'synthetic-test-v1',
      projectionVersion: 1,
      retryEligible: false,
      userAction: 'view',
      result: state == MatchRoundBusinessState.revealed
          ? const MatchRoundResult(
              matchId: 990000101,
              partnerId: 990000201,
              headline: 'Fictional test proposal',
            )
          : null,
    );

class _MemoryStorage extends LocalStorageService {
  int writes = 0;
  @override
  Future<String?> getString(String key) async =>
      key == CacheKeys.firstUseOnboardingV1Status ? 'completed' : null;
  @override
  Future<bool?> getBool(String key) async =>
      key == CacheKeys.performanceLiteMode ? true : null;
  @override
  Future<int?> getInt(String key) async => null;
  @override
  Future<Map<String, dynamic>?> getJson(String key) async => null;
  Never _write() {
    writes++;
    throw StateError('Storage writes forbidden in synthetic router test');
  }

  @override
  Future<bool> setString(String key, String value) async => _write();
  @override
  Future<bool> setBool(String key, bool value) async => _write();
  @override
  Future<bool> setInt(String key, int value) async => _write();
  @override
  Future<bool> setJson(String key, Map<String, dynamic> value) async =>
      _write();
  @override
  Future<bool> remove(String key) async => _write();
  @override
  Future<bool> clear() async => _write();
  @override
  Future<Set<String>> getKeys() async => {};
}

class _NoNetwork extends HttpOverrides {
  int attempts = 0;
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    attempts++;
    throw StateError('HttpClient forbidden in synthetic router test');
  }
}

class _UnusedHomeFeed extends HomeNotifier {
  @override
  Future<HomeUiState> build() async => const HomeUiState();
}

class _Harness {
  _Harness({
    String initial = AppRouteNames.progress,
    NavigationSnapshot? guard,
    AppFlavor flavor = AppFlavor.dev,
    bool synthetic = true,
    CalmHomeProjection? projection,
    this.textScale = 1,
  }) {
    container = ProviderContainer(
      overrides: [
        appEnvProvider.overrideWithValue(
          AppEnv(
            flavor: flavor,
            appName: 'Synthetic Guard test',
            apiBaseUrl: 'https://synthetic.invalid/',
            useMockData: true,
            useMockMatch: true,
            useSyntheticHomeProjection: synthetic,
            useSyntheticReadinessProjection: true,
            useSyntheticConnectionLifecycle: true,
            useSyntheticConversationLifecycle: true,
            initialRoute: initial,
          ),
        ),
        navigationGuardProvider.overrideWith((ref) => ref.watch(_guard)),
        authStatusProvider.overrideWith((ref) => ref.watch(_guard).authStatus),
        localStorageProvider.overrideWithValue(storage),
        secureStorageProvider.overrideWith((ref) => forbidden('secureStorage')),
        apiClientProvider.overrideWith((ref) => forbidden('apiClient')),
        dioProvider.overrideWith((ref) => forbidden('dio')),
        appTelemetryProvider.overrideWith((ref) => forbidden('appTelemetry')),
        frontendTelemetryProvider.overrideWith(
          (ref) => forbidden('frontendTelemetry'),
        ),
        if (projection != null)
          calmHomeProjectionProvider.overrideWithValue(projection),
        appShellRtcInviteWatcherEnabledProvider.overrideWithValue(false),
        matchRemoteDataSourceProvider.overrideWith(
          (ref) => forbidden('matchRemote'),
        ),
        matchRoundProjectionProvider.overrideWith((ref) {
          matchSourceReads++;
          return ref.watch(_match);
        }),
        homeProvider.overrideWith(_UnusedHomeFeed.new),
      ],
    );
    if (guard != null) update(guard);
  }
  late final ProviderContainer container;
  bool disposed = false;
  final storage = _MemoryStorage();
  int externalProviders = 0;
  int matchSourceReads = 0;
  final double textScale;
  Never forbidden(String name) {
    externalProviders++;
    throw StateError('External provider forbidden: $name');
  }

  GoRouter get router => container.read(appRouterProvider);
  String get path => router.state.uri.path;
  void update(NavigationSnapshot value) =>
      container.read(_guard.notifier).state = value;
  Future<void> mount(WidgetTester tester) async {
    addTearDown(() async {
      if (!disposed) await close(tester);
    });
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, ref, child) => MaterialApp.router(
            theme: AppTheme.light,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!,
            ),
            routerConfig: ref.watch(appRouterProvider),
          ),
        ),
      ),
    );
    await settle(tester);
  }

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    dispose();
    await tester.pump();
    expect(externalProviders, 0);
    expect(storage.writes, 0);
    debugPrint(
      'PROGRESS_SAFETY externalProviders=0 storageWrites=0 RTC=false; unmounted/disposed',
    );
  }

  void dispose() {
    if (disposed) return;
    disposed = true;
    container.dispose();
  }

  void expectIsolated(_NoNetwork network) {
    expect(externalProviders, 0);
    expect(network.attempts, 0);
    expect(storage.writes, 0);
    expect(container.read(appShellRtcInviteWatcherEnabledProvider), false);
  }
}

Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

Finder _stage(String domain) => find.byKey(ValueKey('progress-state-$domain'));
Finder _stageText(String domain, String text) =>
    find.descendant(of: _stage(domain), matching: find.text(text));

Future<void> _tapEntry(WidgetTester tester, Key key) async {
  final entry = find.byKey(key);
  // Returning from a pushed detail retains the previous scroll position.
  // Reset only the test viewport before locating entries in either direction.
  final scrollable = find
      .descendant(
        of: find.byType(ProgressPage),
        matching: find.byType(Scrollable),
      )
      .first;
  tester.state<ScrollableState>(scrollable).position.jumpTo(0);
  await tester.pump();
  await tester.scrollUntilVisible(
    entry,
    120,
    scrollable: find
        .descendant(
          of: find.byType(ProgressPage),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await Scrollable.ensureVisible(tester.element(entry), alignment: 0.25);
  await tester.pump();
  expect(entry.hitTestable(), findsOneWidget);
  await tester.tap(entry);
  await settle(tester);
}

void main() {
  late _NoNetwork network;
  setUp(() => network = _NoNetwork());
  void isolatedTest(String description, WidgetTesterCallback body) {
    testWidgets(description, (tester) async {
      await HttpOverrides.runZoned(() async {
        // Prove this inner zone overrides Flutter's own HTTP interception.
        expect(() => HttpClient(), throwsStateError);
        expect(network.attempts, 1);
        network.attempts = 0;
        try {
          await body(tester);
        } finally {
          expect(network.attempts, 0);
          debugPrint('PROGRESS_HTTP_SENTINEL probe=1 businessHTTP=0');
        }
      }, createHttpClient: network.createHttpClient);
    });
  }

  for (final config in [(AppFlavor.prod, true), (AppFlavor.dev, false)]) {
    isolatedTest(
      '${config.$1} synthetic=${config.$2} never starts business sources',
      (tester) async {
        final h = _Harness(flavor: config.$1, synthetic: config.$2);
        await h.mount(tester);
        expect(find.byType(AppShell), findsOneWidget);
        for (final domain in ['readiness', 'match', 'connection']) {
          expect(_stageText(domain, '当前无法确认'), findsOneWidget);
          expect(_stageText(domain, '来源：尚未建立'), findsOneWidget);
        }
        expect(h.matchSourceReads, 0);
        expect(h.container.exists(connectionPresentationProvider), false);
        expect(h.container.exists(conversationAccessProvider), false);
        expect(find.textContaining('开发演示（Synthetic）'), findsNothing);
        h.expectIsolated(network);
        await h.close(tester);
      },
    );
  }

  isolatedTest(
    'real Progress consumes Home three domains with explicit demo limits',
    (tester) async {
      final h = _Harness();
      await h.mount(tester);
      expect(find.byType(AppShell), findsOneWidget);
      expect(_stageText('readiness', '准备状态就绪'), findsOneWidget);
      expect(_stageText('match', '已有匹配提案'), findsOneWidget);
      for (final domain in ['readiness', 'match', 'connection']) {
        expect(_stageText(domain, '来源：开发演示（Synthetic）'), findsOneWidget);
      }
      expect(find.text('开发演示（Synthetic）· 非正式事实，不代表匹配、连接或消息权限'), findsOneWidget);
      expect(h.container.read(calmHomeProjectionProvider).summaries.length, 4);
      expect(
        find.byKey(const ValueKey('progress-state-conversation')),
        findsNothing,
      );
      expect(find.text('查看消息'), findsNothing);
      expect(find.text('前往消息同意'), findsNothing);
      expect(find.byKey(ProgressPage.matchEntryKey), findsOneWidget);
      expect(find.byKey(ProgressPage.connectionEntryKey), findsOneWidget);
      h.expectIsolated(network);
      await h.close(tester);
    },
  );

  for (final condition in [
    'loading',
    'error',
    'failed',
    'closed',
    'noCandidate',
    'noRound',
  ]) {
    isolatedTest(
      'same mount Match $condition clears old proposal without inventing reason',
      (tester) async {
        final h = _Harness();
        await h.mount(tester);
        final router = h.router;
        final shell = tester.state(find.byType(AppShell));
        final progress = tester.element(find.byType(ProgressPage));
        expect(_stageText('match', '已有匹配提案'), findsOneWidget);
        final failure = Completer<MatchRoundProjection>();
        h.container.read(_match.notifier).state = switch (condition) {
          'loading' => Completer<MatchRoundProjection>().future,
          'error' => failure.future,
          'failed' => Future.value(_round(MatchRoundBusinessState.failed)),
          'closed' => Future.value(_round(MatchRoundBusinessState.closed)),
          'noCandidate' => Future.value(
            _round(MatchRoundBusinessState.noCandidate),
          ),
          _ => Future.value(_round(MatchRoundBusinessState.noRound)),
        };
        if (condition == 'error') {
          await tester.pump();
          failure.completeError(StateError('Fictional unavailable'));
        }
        await settle(tester);
        expect(_stageText('match', '当前无法确认'), findsOneWidget);
        expect(_stageText('match', '已有匹配提案'), findsNothing);
        expect(_stageText('match', '匹配进行中'), findsNothing);
        final summary = h.container
            .read(calmHomeProjectionProvider)
            .summaries[1];
        expect(summary.stateCode, isNull);
        expect(
          summary.authority,
          condition == 'noCandidate' || condition == 'noRound'
              ? HomeProjectionAuthority.syntheticDevelopment
              : HomeProjectionAuthority.unknown,
        );
        expect(
          _stageText(
            'match',
            summary.authority == HomeProjectionAuthority.unknown
                ? '来源：未知'
                : '来源：开发演示（Synthetic）',
          ),
          findsOneWidget,
        );
        final copy = tester
            .widgetList<Text>(
              find.descendant(of: _stage('match'), matching: find.byType(Text)),
            )
            .map((text) => text.data ?? '')
            .join(' ');
        for (final invented in ['已完成', '已过期', '不合格', '匹配失败', '没有候选', '没有轮次']) {
          expect(copy, isNot(contains(invented)));
        }
        expect(h.router, same(router));
        expect(tester.state(find.byType(AppShell)), same(shell));
        expect(tester.element(find.byType(ProgressPage)), same(progress));
        router.go(AppRouteNames.home);
        await settle(tester);
        expect(find.byType(HomeShellPage), findsOneWidget);
        router.go(AppRouteNames.progress);
        await settle(tester);
        expect(_stageText('match', '当前无法确认'), findsOneWidget);
        h.expectIsolated(network);
        await h.close(tester);
      },
    );
  }

  for (final state in [
    MatchRoundBusinessState.scheduled,
    MatchRoundBusinessState.preparing,
    MatchRoundBusinessState.running,
  ]) {
    isolatedTest('Match $state displays only accepted active summary', (
      tester,
    ) async {
      final h = _Harness();
      h.container.read(_match.notifier).state = Future.value(_round(state));
      await h.mount(tester);
      expect(_stageText('match', '匹配进行中'), findsOneWidget);
      expect(_stageText('match', '已有匹配提案'), findsNothing);
      h.expectIsolated(network);
      await h.close(tester);
    });
  }

  isolatedTest(
    'Connection active paused closed updates immediately; unknown Readiness does not revoke it',
    (tester) async {
      final h = _Harness();
      await h.mount(tester);
      final connection = h.container.read(
        connectionPresentationProvider.notifier,
      );
      final router = h.router;
      final progress = tester.element(find.byType(ProgressPage));
      connection.apply(ConnectionLifecycleAction.request);
      connection.apply(ConnectionLifecycleAction.accept);
      await settle(tester);
      expect(_stageText('connection', '双方已同意连接'), findsOneWidget);
      h.update(_snapshot(readiness: ReadinessGuardState.unknown));
      await settle(tester);
      expect(_stageText('readiness', '当前无法确认'), findsOneWidget);
      expect(_stageText('readiness', '准备状态就绪'), findsNothing);
      expect(_stageText('connection', '双方已同意连接'), findsOneWidget);
      expect(
        h.container.read(connectionPresentationProvider).state,
        ProductConnectionState.active,
      );
      connection.apply(ConnectionLifecycleAction.pause);
      await settle(tester);
      expect(_stageText('connection', '连接已暂停'), findsOneWidget);
      expect(_stageText('connection', '双方已同意连接'), findsNothing);
      connection.apply(ConnectionLifecycleAction.close);
      await settle(tester);
      expect(_stageText('connection', '连接已关闭'), findsOneWidget);
      expect(_stageText('connection', '连接已暂停'), findsNothing);
      expect(_stageText('connection', '双方已同意连接'), findsNothing);
      expect(h.router, same(router));
      expect(tester.element(find.byType(ProgressPage)), same(progress));
      expect(find.text('查看消息'), findsNothing);
      expect(find.text('前往消息同意'), findsNothing);
      h.expectIsolated(network);
      await h.close(tester);
    },
  );

  isolatedTest(
    'actual three details and back consume current state; Match retains Guard fallback',
    (tester) async {
      final h = _Harness();
      await h.mount(tester);
      final router = h.router;
      await _tapEntry(tester, const ValueKey('progress-readiness-entry'));
      expect(h.path, AppRouteNames.meReadiness);
      expect(find.byType(ReadinessPurposePage), findsOneWidget);
      router.pop();
      await settle(tester);
      expect(find.byType(ProgressPage), findsOneWidget);
      await _tapEntry(tester, ProgressPage.matchEntryKey);
      expect(h.path, AppRouteNames.progressMatch);
      expect(find.byType(MatchShellPage), findsOneWidget);
      router.pop();
      await settle(tester);
      await _tapEntry(tester, ProgressPage.connectionEntryKey);
      expect(h.path, AppRouteNames.progressConnection);
      expect(find.byType(ConnectionPage), findsOneWidget);
      final connection = h.container.read(
        connectionPresentationProvider.notifier,
      );
      connection.apply(ConnectionLifecycleAction.request);
      connection.apply(ConnectionLifecycleAction.accept);
      connection.apply(ConnectionLifecycleAction.close);
      await settle(tester);
      router.pop();
      await settle(tester);
      expect(_stageText('connection', '连接已关闭'), findsOneWidget);
      h.update(_snapshot(readiness: ReadinessGuardState.unknown));
      await settle(tester);
      await _tapEntry(tester, ProgressPage.matchEntryKey);
      expect(h.path, AppRouteNames.meReadiness);
      expect(find.byType(ReadinessPurposePage), findsOneWidget);
      expect(find.byType(MatchShellPage), findsNothing);
      expect(h.router, same(router));
      h.expectIsolated(network);
      await h.close(tester);
    },
  );

  isolatedTest(
    '320px doubled text keeps actual detail entries tappable above dock',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final h = _Harness(textScale: 2);
      await h.mount(tester);
      expect(tester.takeException(), isNull);
      for (final domain in ['readiness', 'match', 'connection']) {
        await Scrollable.ensureVisible(
          tester.element(_stage(domain)),
          alignment: 0.1,
        );
        await tester.pump();
        expect(_stage(domain).hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
      for (final entry in [
        (const ValueKey('progress-readiness-entry'), AppRouteNames.meReadiness),
        (ProgressPage.matchEntryKey, AppRouteNames.progressMatch),
        (ProgressPage.connectionEntryKey, AppRouteNames.progressConnection),
      ]) {
        await _tapEntry(tester, entry.$1);
        expect(h.path, entry.$2);
        expect(tester.takeException(), isNull);
        h.router.pop();
        await settle(tester);
        expect(tester.takeException(), isNull);
      }
      h.expectIsolated(network);
      await h.close(tester);
    },
  );

  for (final authority in HomeProjectionAuthority.values) {
    isolatedTest('$authority cannot convert unrecognized codes to success', (
      tester,
    ) async {
      final h = _Harness(
        projection: CalmHomeProjection(
          summaries: [
            for (final domain in HomeProjectedDomain.values)
              HomeStateSummary(
                domain: domain,
                authority: authority,
                stateCode: 'UNRECOGNIZED',
              ),
          ],
          readinessAuthority: authority,
        ),
      );
      await h.mount(tester);
      for (final domain in ['readiness', 'match', 'connection']) {
        expect(_stageText(domain, '当前无法确认'), findsOneWidget);
      }
      expect(find.text('准备状态就绪'), findsNothing);
      expect(find.text('已有匹配提案'), findsNothing);
      expect(find.text('双方已同意连接'), findsNothing);
      h.expectIsolated(network);
      await h.close(tester);
    });
  }
}

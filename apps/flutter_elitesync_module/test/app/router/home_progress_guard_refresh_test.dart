import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/app/router/app_router.dart';
import 'package:flutter_elitesync_module/app/router/app_shell.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/design_system/components/brand/floating_dock_bottom_bar.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/chat/domain/product_conversation_contract.dart';
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
  _Harness({String initial = AppRouteNames.home, NavigationSnapshot? guard}) {
    container = ProviderContainer(
      overrides: [
        appEnvProvider.overrideWithValue(
          AppEnv(
            flavor: AppFlavor.dev,
            appName: 'Synthetic Guard test',
            apiBaseUrl: 'https://synthetic.invalid/',
            useMockData: true,
            useMockMatch: true,
            useSyntheticHomeProjection: true,
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
        appShellRtcInviteWatcherEnabledProvider.overrideWithValue(false),
        matchRemoteDataSourceProvider.overrideWith(
          (ref) => forbidden('matchRemote'),
        ),
        matchRoundProjectionProvider.overrideWith((ref) => ref.watch(_match)),
        homeProvider.overrideWith(_UnusedHomeFeed.new),
      ],
    );
    if (guard != null) update(guard);
  }
  late final ProviderContainer container;
  bool disposed = false;
  final storage = _MemoryStorage();
  int externalProviders = 0;
  Never forbidden(String name) {
    externalProviders++;
    throw StateError('External provider forbidden: $name');
  }

  GoRouter get router => container.read(appRouterProvider);
  String get path => router.routeInformationProvider.value.uri.path;
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

void main() {
  late _NoNetwork network;
  setUp(() => network = _NoNetwork());
  void isolatedTest(String description, WidgetTesterCallback body) {
    testWidgets(description, (tester) async {
      await HttpOverrides.runZoned(() async {
        // Flutter's test binding has a zonal override. A global override alone
        // would not intercept it: prove this inner sentinel owns HttpClient.
        expect(() => HttpClient(), throwsStateError);
        expect(network.attempts, 1);
        network.attempts = 0; // exclude the intentional interception probe
        try {
          await body(tester);
        } finally {
          expect(network.attempts, 0);
        }
      }, createHttpClient: network.createHttpClient);
    });
  }

  for (final readiness in [
    ReadinessGuardState.unknown,
    ReadinessGuardState.setupRequired,
  ]) {
    isolatedTest('initial $readiness cannot bypass Match readiness', (
      tester,
    ) async {
      final h = _Harness(
        initial: AppRouteNames.progressMatch,
        guard: _snapshot(readiness: readiness),
      );
      await h.mount(tester);
      expect(h.path, AppRouteNames.meReadiness);
      expect(find.byType(ReadinessPurposePage), findsOneWidget);
      h.expectIsolated(network);
      await h.close(tester);
    });
  }

  isolatedTest('unrelated Guard keeps live Progress query, page and router', (
    tester,
  ) async {
    final h = _Harness();
    await h.mount(tester);
    final router = h.router;
    router.go('${AppRouteNames.progress}?source=synthetic');
    await settle(tester);
    final shell = tester.state(find.byType(AppShell));
    final page = tester.element(find.byType(ProgressPage));
    h.update(_snapshot(verification: VerificationStatus.pendingReview));
    await settle(tester);
    expect(h.path, AppRouteNames.progress);
    expect(h.router, same(router));
    expect(router.routeInformationProvider.value.uri.query, 'source=synthetic');
    expect(tester.state(find.byType(AppShell)), same(shell));
    expect(tester.element(find.byType(ProgressPage)), same(page));
    h.expectIsolated(network);
    await h.close(tester);
  });

  isolatedTest('Match deep path loses readiness within same mounted router', (
    tester,
  ) async {
    final h = _Harness();
    await h.mount(tester);
    final router = h.router;
    for (final readiness in [
      ReadinessGuardState.unknown,
      ReadinessGuardState.setupRequired,
    ]) {
      h.update(_snapshot());
      await settle(tester);
      h.router.go('${AppRouteNames.progressMatch}?source=synthetic');
      await settle(tester);
      expect(find.byType(MatchShellPage), findsOneWidget);
      h.update(_snapshot(readiness: readiness));
      await settle(tester);
      expect(h.path, AppRouteNames.meReadiness);
      expect(h.router, same(router));
      expect(find.byType(ReadinessPurposePage), findsOneWidget);
      expect(find.byType(MatchShellPage), findsNothing);
      // Becoming Ready does not auto-restore a previously prohibited route.
      h.update(_snapshot());
      await settle(tester);
      expect(h.path, AppRouteNames.meReadiness);
    }
    h.expectIsolated(network);
    await h.close(tester);
  });

  isolatedTest('Auth loss redirects current Connection to actual login', (
    tester,
  ) async {
    final h = _Harness();
    await h.mount(tester);
    final router = h.router;
    router.go(AppRouteNames.progressConnection);
    await settle(tester);
    expect(find.byType(ConnectionPage), findsOneWidget);
    h.update(
      _snapshot(
        auth: AuthStatus.unauthenticated,
        readiness: ReadinessGuardState.unauthenticated,
      ),
    );
    await settle(tester);
    expect(h.router, same(router));
    expect(h.path, AppRouteNames.login);
    expect(find.text('账号登录'), findsOneWidget);
    expect(find.byType(ConnectionPage), findsNothing);
    h.expectIsolated(network);
    await h.close(tester);
  });

  isolatedTest('Home Progress Match Connection use actual UI entries', (
    tester,
  ) async {
    final h = _Harness();
    await h.mount(tester);
    final router = h.router;
    expect(find.byType(HomeShellPage), findsOneWidget);
    final dock = find.byType(FloatingDockBottomBar);
    await tester.tap(find.descendant(of: dock, matching: find.text('进展')));
    await settle(tester);
    expect(h.path, AppRouteNames.progress);
    await tester.tap(find.byKey(ProgressPage.matchEntryKey));
    await settle(tester);
    expect(h.path, AppRouteNames.progressMatch);
    expect(find.byType(MatchShellPage), findsOneWidget);
    router.pop();
    await settle(tester);
    expect(find.byType(ProgressPage), findsOneWidget);
    await tester.tap(find.byKey(ProgressPage.connectionEntryKey));
    await settle(tester);
    expect(h.path, AppRouteNames.progressConnection);
    expect(find.byType(ConnectionPage), findsOneWidget);
    h.update(_snapshot(verification: VerificationStatus.pendingReview));
    await settle(tester);
    expect(h.router, same(router));
    expect(h.path, AppRouteNames.progressConnection);
    router.pop();
    await settle(tester);
    expect(h.path, AppRouteNames.progress);
    expect(find.byType(ProgressPage), findsOneWidget);
    await tester.tap(find.descendant(of: dock, matching: find.text('首页')));
    await settle(tester);
    final next = find.byKey(const ValueKey('home-primary-next-decision'));
    await tester.ensureVisible(next);
    await tester.tap(next);
    await settle(tester);
    expect(h.path, AppRouteNames.progressConnection);
    h.expectIsolated(network);
    await h.close(tester);
  });

  isolatedTest('continuous updates and provider disposal detach old router', (
    tester,
  ) async {
    final h = _Harness();
    await h.mount(tester);
    final router = h.router;
    router.go(AppRouteNames.progress);
    await settle(tester);
    var refreshes = 0;
    router.routeInformationProvider.addListener(() => refreshes++);
    for (var i = 0; i < 12; i++) {
      h.update(
        _snapshot(
          verification: i.isEven
              ? VerificationStatus.pendingReview
              : VerificationStatus.unknown,
        ),
      );
      await settle(tester);
      expect(h.router, same(router));
      expect(h.path, AppRouteNames.progress);
    }
    expect(refreshes, greaterThan(0));
    h.expectIsolated(network);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    // Explicit invalidation releases the provider-owned instance, creates a new
    // one, and updates must never notify the detached old route provider.
    h.container.invalidate(appRouterProvider);
    final replacement = h.router;
    expect(replacement, isNot(same(router)));
    expect(() => router.routerDelegate.addListener(() {}), throwsFlutterError);
    final detachedCount = refreshes;
    await h.mount(tester);
    replacement.go(AppRouteNames.progressMatch);
    await settle(tester);
    expect(find.byType(MatchShellPage), findsOneWidget);
    h.update(_snapshot(readiness: ReadinessGuardState.unknown));
    await settle(tester);
    expect(h.path, AppRouteNames.meReadiness);
    expect(find.byType(ReadinessPurposePage), findsOneWidget);
    expect(refreshes, detachedCount);
    await h.close(tester);
    expect(
      () => replacement.routerDelegate.addListener(() {}),
      throwsFlutterError,
    );
    expect(tester.takeException(), isNull);
  });

  for (final condition in [
    'loading',
    'error',
    'failed',
    'closed',
    'noCandidate',
  ]) {
    isolatedTest('Home clears prior Match CTA for $condition in mounted shell', (
      tester,
    ) async {
      final h = _Harness();
      await h.mount(tester);
      final router = h.router;
      final shell = tester.state(find.byType(AppShell));
      expect(
        h.container.read(calmHomeProjectionProvider).nextDecision.label,
        '查看连接',
      );
      expect(find.text('查看连接'), findsOneWidget);
      final failure = Completer<MatchRoundProjection>();
      final next = switch (condition) {
        'loading' => Completer<MatchRoundProjection>().future,
        'error' => failure.future,
        'failed' => Future.value(_round(MatchRoundBusinessState.failed)),
        'closed' => Future.value(_round(MatchRoundBusinessState.closed)),
        _ => Future.value(_round(MatchRoundBusinessState.noCandidate)),
      };
      h.container.read(_match.notifier).state = next;
      if (condition == 'error') {
        // Attach the real FutureProvider listener before delivering the error.
        await tester.pump();
        failure.completeError(StateError('Synthetic unavailable'));
      }
      // Riverpod may retain previous data during recomputation; Home must treat
      // loading/error as UNKNOWN rather than reuse the old success CTA.
      await settle(tester);
      final projection = h.container.read(calmHomeProjectionProvider);
      final expected = condition == 'noCandidate' ? '查看匹配' : '查看进展';
      expect(projection.nextDecision.label, expected);
      expect(find.text(expected), findsOneWidget);
      expect(find.text('查看连接'), findsNothing);
      expect(find.text('查看消息'), findsNothing);
      expect(
        h.container.read(conversationAccessProvider).state,
        ProductConversationState.locked,
      );
      expect(h.router, same(router));
      expect(tester.state(find.byType(AppShell)), same(shell));
      // Page switching/back consumes the current snapshot, not stale success.
      router.go(AppRouteNames.progress);
      await settle(tester);
      router.go(AppRouteNames.home);
      await settle(tester);
      expect(find.text(expected), findsOneWidget);
      h.expectIsolated(network);
      await h.close(tester);
    });
  }

  for (final action in [
    ConnectionLifecycleAction.pause,
    ConnectionLifecycleAction.close,
  ]) {
    isolatedTest(
      'Connection $action clears synthetic consent and Home CTA immediately',
      (tester) async {
        final h = _Harness();
        await h.mount(tester);
        final connection = h.container.read(
          connectionPresentationProvider.notifier,
        );
        final conversation = h.container.read(
          conversationAccessProvider.notifier,
        );
        connection.apply(ConnectionLifecycleAction.request);
        connection.apply(ConnectionLifecycleAction.accept);
        await settle(tester);
        // An active Connection alone is not mutual messaging consent.
        expect(
          h.container.read(conversationAccessProvider).state,
          ProductConversationState.locked,
        );
        expect(find.text('前往消息同意'), findsOneWidget);
        conversation.apply(ConversationLifecycleAction.requestMessagingConsent);
        conversation.apply(ConversationLifecycleAction.acceptMessagingConsent);
        await settle(tester);
        expect(find.text('查看消息'), findsOneWidget);
        connection.apply(action);
        await settle(tester);
        expect(
          h.container.read(conversationAccessProvider).state,
          ProductConversationState.locked,
        );
        expect(conversation.hasLocalMutualConsent, false);
        expect(find.text('查看消息'), findsNothing);
        expect(find.text('前往消息同意'), findsNothing);
        expect(find.text('查看连接'), findsOneWidget);
        expect(h.path, AppRouteNames.home);
        h.expectIsolated(network);
        await h.close(tester);
      },
    );
  }

  isolatedTest(
    'Home unknown readiness clears next decision without inventing Connection revocation',
    (tester) async {
      final h = _Harness();
      await h.mount(tester);
      final connection = h.container.read(
        connectionPresentationProvider.notifier,
      );
      connection.apply(ConnectionLifecycleAction.request);
      connection.apply(ConnectionLifecycleAction.accept);
      await settle(tester);
      final router = h.router;
      h.update(_snapshot(readiness: ReadinessGuardState.unknown));
      await settle(tester);
      expect(h.path, AppRouteNames.home);
      expect(h.router, same(router));
      expect(find.text('前往消息同意'), findsNothing);
      expect(find.text('前往准备状态'), findsOneWidget);
      expect(
        h.container.read(calmHomeProjectionProvider).readinessAuthority,
        HomeProjectionAuthority.unknown,
      );
      // Existing semantics only: no policy claim that Readiness revokes Connection.
      expect(
        h.container.read(connectionPresentationProvider).state,
        ProductConnectionState.active,
      );
      expect(
        h.container.read(conversationAccessProvider).state,
        ProductConversationState.locked,
      );
      h.expectIsolated(network);
      await h.close(tester);
    },
  );
}

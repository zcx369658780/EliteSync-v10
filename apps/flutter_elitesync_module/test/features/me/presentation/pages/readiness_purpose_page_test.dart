import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/app/router/app_router.dart';
import 'package:flutter_elitesync_module/app/router/app_shell.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/core/telemetry/frontend_telemetry.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/home/presentation/providers/home_provider.dart';
import 'package:flutter_elitesync_module/features/home/presentation/state/home_ui_state.dart';
import 'package:flutter_elitesync_module/features/me/presentation/pages/me_landing_page.dart';
import 'package:flutter_elitesync_module/features/me/presentation/pages/me_purpose_pages.dart';
import 'package:flutter_elitesync_module/features/questionnaire/presentation/pages/questionnaire_page.dart';
import 'package:flutter_elitesync_module/features/questionnaire/presentation/providers/questionnaire_provider.dart';
import 'package:flutter_elitesync_module/features/questionnaire/presentation/state/questionnaire_state.dart';
import 'package:flutter_elitesync_module/features/verification/domain/entities/verification_state_entity.dart';
import 'package:flutter_elitesync_module/features/verification/presentation/pages/verification_status_page.dart';
import 'package:flutter_elitesync_module/features/verification/presentation/providers/verification_provider.dart';
import 'package:flutter_elitesync_module/features/verification/presentation/state/verification_ui_state.dart';
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

NavigationSnapshot snapshot(
  ReadinessGuardState state, {
  bool loggedIn = true,
}) => NavigationSnapshot(
  authStatus: loggedIn ? AuthStatus.authenticated : AuthStatus.unauthenticated,
  verificationStatus: VerificationStatus.unknown,
  questionnaireStatus: QuestionnaireStatus.unknown,
  matchStatus: MatchStatus.unknown,
  canChat: false,
  readinessState: state,
  isBootstrapLoading: false,
);

final guardFixture = StateProvider<NavigationSnapshot>(
  (ref) => snapshot(ReadinessGuardState.unknown),
);

class _Safety {
  int external = 0;
  int http = 0;
  int writes = 0;
  Never deny(String name) {
    external++;
    throw StateError('Forbidden external dependency: $name');
  }

  Never write() {
    writes++;
    throw StateError('Business/storage write forbidden');
  }

  HttpClient denyHttp(SecurityContext? context) {
    http++;
    throw StateError('HTTP forbidden');
  }

  void expectZero() {
    expect(external, 0);
    expect(http, 0);
    expect(writes, 0);
  }
}

class _MemoryStorage extends LocalStorageService {
  _MemoryStorage(this.safety);
  final _Safety safety;
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
  @override
  Future<Set<String>> getKeys() async => {};
  @override
  Future<bool> setString(String key, String value) async => safety.write();
  @override
  Future<bool> setBool(String key, bool value) async => safety.write();
  @override
  Future<bool> setInt(String key, int value) async => safety.write();
  @override
  Future<bool> setJson(String key, Map<String, dynamic> value) async =>
      safety.write();
  @override
  Future<bool> remove(String key) async => safety.write();
  @override
  Future<bool> clear() async => safety.write();
}

class _HomeFeed extends HomeNotifier {
  @override
  Future<HomeUiState> build() async => const HomeUiState();
}

class _Verification extends VerificationNotifier {
  _Verification(this.harness);
  final _Harness harness;
  @override
  Future<VerificationUiState> build() async {
    harness.verificationReads++;
    return const VerificationUiState(
      status: VerificationStateEntity(
        status: VerificationStatus.unverified,
        title: 'Fictional compatibility status',
        description: 'Synthetic fixture; no identity conclusion',
      ),
    );
  }

  @override
  Future<void> submit({
    required String realName,
    required String idNumber,
  }) async => harness.safety.write();
}

class _Questionnaire extends QuestionnaireNotifier {
  _Questionnaire(this.harness);
  final _Harness harness;
  @override
  Future<QuestionnaireState> build() async {
    harness.questionnaireReads++;
    return const QuestionnaireState();
  }
}

// Consume only the existing destination's local entry signal. No transport or
// telemetry service is constructed; every other call is a rejecting sentinel.
class _LocalTelemetry implements FrontendTelemetry {
  _LocalTelemetry(this.safety);
  final _Safety safety;
  int entrySignals = 0;
  @override
  void questionnaireEntryOpened({required String sourcePage}) => entrySignals++;
  @override
  dynamic noSuchMethod(Invocation invocation) => safety.deny('telemetry');
}

class _Harness {
  _Harness(
    this.safety, {
    AppFlavor flavor = AppFlavor.prod,
    bool flag = false,
    ReadinessGuardState readiness = ReadinessGuardState.unknown,
    bool loggedIn = true,
  }) {
    telemetry = _LocalTelemetry(safety);
    container = ProviderContainer(
      overrides: [
        appEnvProvider.overrideWithValue(
          AppEnv(
            flavor: flavor,
            appName: 'Readiness synthetic test',
            apiBaseUrl: 'https://synthetic.invalid/',
            useMockData: true,
            useSyntheticReadinessProjection: flag,
            initialRoute: AppRouteNames.me,
          ),
        ),
        navigationGuardProvider.overrideWith((ref) => ref.watch(guardFixture)),
        authStatusProvider.overrideWith(
          (ref) => ref.watch(guardFixture).authStatus,
        ),
        localStorageProvider.overrideWithValue(_MemoryStorage(safety)),
        secureStorageProvider.overrideWith(
          (ref) => safety.deny('secure storage'),
        ),
        apiClientProvider.overrideWith((ref) => safety.deny('API')),
        dioProvider.overrideWith((ref) => safety.deny('Dio')),
        appShellRtcInviteWatcherEnabledProvider.overrideWithValue(false),
        homeProvider.overrideWith(_HomeFeed.new),
        verificationProvider.overrideWith(() => _Verification(this)),
        questionnaireProvider.overrideWith(() => _Questionnaire(this)),
        frontendTelemetryProvider.overrideWithValue(telemetry),
      ],
    );
    update(readiness, loggedIn: loggedIn);
  }
  final _Safety safety;
  late final ProviderContainer container;
  late final _LocalTelemetry telemetry;
  int verificationReads = 0;
  int questionnaireReads = 0;
  bool disposed = false;
  void update(ReadinessGuardState value, {bool loggedIn = true}) =>
      container.read(guardFixture.notifier).state = snapshot(
        value,
        loggedIn: loggedIn,
      );
  String get path => container.read(appRouterProvider).state.uri.path;
  Future<void> mount(
    WidgetTester tester, {
    bool displayOnly = false,
    double scale = 1,
  }) async {
    addTearDown(() async {
      if (!disposed) await close(tester);
    });
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, ref, child) {
            if (displayOnly)
              return MaterialApp(
                theme: AppTheme.light,
                home: const ReadinessPurposePage(),
              );
            return MaterialApp.router(
              theme: AppTheme.light,
              routerConfig: ref.watch(appRouterProvider),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
            );
          },
        ),
      ),
    );
    await settle(tester);
    if (!displayOnly && container.read(guardFixture).isLoggedIn) {
      expect(find.byType(AppShell), findsOneWidget);
      expect(find.byType(MeLandingPage), findsOneWidget);
      await reveal(
        tester,
        find.byKey(MeLandingPage.readinessKey),
        find.byType(MeLandingPage),
      );
      await tester.tap(find.byKey(MeLandingPage.readinessKey));
      await settle(tester);
      expect(path, AppRouteNames.meReadiness);
      expect(find.byType(ReadinessPurposePage), findsOneWidget);
    }
  }

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    if (!disposed) {
      disposed = true;
      container.dispose();
    }
  }

  void expectNoPrefetch() {
    expect(verificationReads, 0);
    expect(questionnaireReads, 0);
    safety.expectZero();
  }
}

Future<void> reveal(WidgetTester tester, Finder target, Finder page) async {
  final scrollable = find
      .descendant(of: page, matching: find.byType(Scrollable))
      .first;
  await tester.scrollUntilVisible(target, 160, scrollable: scrollable);
  await Scrollable.ensureVisible(tester.element(target), alignment: 0.15);
  await tester.pump();
  expect(target.hitTestable(), findsOneWidget);
}

Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  void isolatedTest(
    String name,
    Future<void> Function(WidgetTester, _Safety) body,
  ) {
    testWidgets(name, (tester) async {
      final safety = _Safety();
      await HttpOverrides.runZoned(() async {
        expect(() => HttpClient(), throwsStateError);
        expect(safety.http, 1);
        safety.http = 0;
        try {
          await body(tester, safety);
        } finally {
          safety.expectZero();
        }
      }, createHttpClient: safety.denyHttp);
    });
  }

  isolatedTest(
    'production UNKNOWN separates missing source from ineligibility',
    (tester, safety) async {
      final h = _Harness(safety);
      await h.mount(tester);
      expect(
        find.byKey(const ValueKey('readiness-source-explanation')),
        findsOneWidget,
      );
      expect(find.text('正式准备条件尚未确定'), findsOneWidget);
      expect(find.textContaining('不表示你不合格'), findsOneWidget);
      expect(find.text('准备状态尚未确定'), findsOneWidget);
      expect(find.text('准备状态已由权威来源确认'), findsNothing);
      expect(find.textContaining('%'), findsNothing);
      expect(find.textContaining('身份证'), findsNothing);
      h.expectNoPrefetch();
      await h.close(tester);
    },
  );

  for (final fixture in [(AppFlavor.prod, true), (AppFlavor.dev, false)]) {
    isolatedTest(
      'injected READY without active dev flag remains unconfirmed $fixture',
      (tester, safety) async {
        final h = _Harness(
          safety,
          flavor: fixture.$1,
          flag: fixture.$2,
          readiness: ReadinessGuardState.ready,
        );
        await h.mount(tester);
        expect(find.text('准备状态已由权威来源确认'), findsNothing);
        expect(find.text('准备状态来源未确认'), findsOneWidget);
        expect(find.textContaining('不是正式资格'), findsNothing);
        expect(
          h.container.read(navigationGuardProvider).readinessState,
          ReadinessGuardState.ready,
        );
        expect(h.container.read(navigationGuardProvider).canChat, false);
        h.expectNoPrefetch();
        await h.close(tester);
      },
    );
  }

  isolatedTest('explicit dev READY is a labelled demonstration only', (
    tester,
    safety,
  ) async {
    final h = _Harness(
      safety,
      flavor: AppFlavor.dev,
      flag: true,
      readiness: ReadinessGuardState.ready,
    );
    await h.mount(tester);
    expect(find.text('Synthetic 准备状态已建立 · 开发演示'), findsOneWidget);
    expect(find.textContaining('不是正式资格'), findsOneWidget);
    expect(find.text('正式准备条件尚未确定'), findsOneWidget);
    h.expectNoPrefetch();
    await h.close(tester);
  });

  isolatedTest('same mounted page clears synthetic success on Guard changes', (
    tester,
    safety,
  ) async {
    final h = _Harness(
      safety,
      flavor: AppFlavor.dev,
      flag: true,
      readiness: ReadinessGuardState.ready,
    );
    await h.mount(tester);
    final router = h.container.read(appRouterProvider);
    final page = tester.element(find.byType(ReadinessPurposePage));
    for (final state in [
      ReadinessGuardState.unknown,
      ReadinessGuardState.setupRequired,
    ]) {
      h.update(ReadinessGuardState.ready);
      await settle(tester);
      expect(find.text('Synthetic 准备状态已建立 · 开发演示'), findsOneWidget);
      h.update(state);
      await settle(tester);
      expect(find.text('Synthetic 准备状态已建立 · 开发演示'), findsNothing);
      expect(h.container.read(appRouterProvider), same(router));
      expect(tester.element(find.byType(ReadinessPurposePage)), same(page));
      expect(find.text('正式准备条件尚未确定'), findsOneWidget);
    }
    h.update(ReadinessGuardState.unauthenticated, loggedIn: false);
    await settle(tester);
    expect(h.path, AppRouteNames.login);
    expect(find.text('账号登录'), findsOneWidget);
    expect(find.text('Synthetic 准备状态已建立 · 开发演示'), findsNothing);
    h.expectNoPrefetch();
    await h.close(tester);
  });

  isolatedTest(
    'unauthenticated display is explained without bypassing real Router',
    (tester, safety) async {
      final h = _Harness(
        safety,
        readiness: ReadinessGuardState.unauthenticated,
        loggedIn: false,
      );
      // Actual unauthenticated routing goes to login. This explicit display-only
      // supplement checks the page text and does not claim a route bypass.
      await h.mount(tester, displayOnly: true);
      expect(find.text('尚未登录'), findsOneWidget);
      expect(find.text('正式准备条件尚未确定'), findsOneWidget);
      h.expectNoPrefetch();
      await h.close(tester);
    },
  );

  isolatedTest(
    'both compatibility destinations and back preserve Guard and page',
    (tester, safety) async {
      final h = _Harness(safety);
      await h.mount(tester);
      final before = h.container.read(navigationGuardProvider);
      for (final entry in [
        ('查看兼容验证状态页', AppRouteNames.verificationStatus, VerificationStatusPage),
        ('继续兼容问卷页', AppRouteNames.questionnaire, QuestionnairePage),
      ]) {
        final button = find.widgetWithText(
          entry.$2 == AppRouteNames.verificationStatus
              ? FilledButton
              : OutlinedButton,
          entry.$1,
        );
        await reveal(tester, button, find.byType(ReadinessPurposePage));
        await tester.tap(button);
        await settle(tester);
        expect(h.path, entry.$2);
        expect(find.byType(entry.$3), findsOneWidget);
        h.container.read(appRouterProvider).pop();
        await settle(tester);
        expect(h.path, AppRouteNames.meReadiness);
        expect(find.byType(ReadinessPurposePage), findsOneWidget);
        expect(h.container.read(navigationGuardProvider), same(before));
      }
      expect(h.verificationReads, 1);
      expect(h.questionnaireReads, 1);
      expect(h.telemetry.entrySignals, 1);
      safety.expectZero();
      await h.close(tester);
    },
  );

  isolatedTest(
    'narrow screen and enlarged text keep explanation and actions readable',
    (tester, safety) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final h = _Harness(safety);
      await h.mount(tester, scale: 2);
      for (final text in ['正式准备条件尚未确定', '兼容验证状态查看', '兼容问卷继续设置']) {
        final target = find.text(text);
        await reveal(tester, target, find.byType(ReadinessPurposePage));
        await settle(tester);
        expect(target.hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
      for (final action in [
        find.widgetWithText(FilledButton, '查看兼容验证状态页'),
        find.widgetWithText(OutlinedButton, '继续兼容问卷页'),
      ]) {
        await reveal(tester, action, find.byType(ReadinessPurposePage));
        expect(action.hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
      h.expectNoPrefetch();
      await h.close(tester);
    },
  );
}

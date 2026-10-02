import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/app/router/app_router.dart';
import 'package:flutter_elitesync_module/app/router/app_shell.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/home/presentation/providers/home_provider.dart';
import 'package:flutter_elitesync_module/features/home/presentation/state/home_ui_state.dart';
import 'package:flutter_elitesync_module/features/me/presentation/pages/me_purpose_pages.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/enums/match_status.dart';
import 'package:flutter_elitesync_module/shared/enums/questionnaire_status.dart';
import 'package:flutter_elitesync_module/shared/enums/verification_status.dart';
import 'package:flutter_elitesync_module/shared/models/navigation_snapshot.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/navigation_guard_provider.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _CompletedFirstUseStorage extends LocalStorageService {
  @override
  Future<String?> getString(String key) async =>
      key == CacheKeys.firstUseOnboardingV1Status ? 'completed' : null;

  @override
  Future<bool?> getBool(String key) async =>
      key == CacheKeys.performanceLiteMode ? true : null;

  @override
  Future<Map<String, dynamic>?> getJson(String key) async => null;
}

class _FakeHomeNotifier extends HomeNotifier {
  @override
  Future<HomeUiState> build() async => const HomeUiState();
}

Widget _routerApp(String legacyPath, {required bool readinessReady}) {
  final navigation = NavigationSnapshot(
    authStatus: AuthStatus.authenticated,
    verificationStatus: VerificationStatus.unknown,
    questionnaireStatus: QuestionnaireStatus.unknown,
    matchStatus: MatchStatus.unknown,
    canChat: false,
    readinessState: readinessReady
        ? ReadinessGuardState.ready
        : ReadinessGuardState.unknown,
    isBootstrapLoading: false,
  );
  return ProviderScope(
    overrides: [
      appEnvProvider.overrideWithValue(
        AppEnv(
          flavor: AppFlavor.dev,
          appName: 'Synthetic Match router regression',
          apiBaseUrl: 'http://127.0.0.1:9/',
          useMockData: true,
          useMockMatch: true,
          initialRoute: legacyPath,
        ),
      ),
      authStatusProvider.overrideWithValue(AuthStatus.authenticated),
      navigationGuardProvider.overrideWithValue(navigation),
      localStorageProvider.overrideWithValue(_CompletedFirstUseStorage()),
      appShellRtcInviteWatcherEnabledProvider.overrideWithValue(false),
      homeProvider.overrideWith(_FakeHomeNotifier.new),
    ],
    child: Consumer(
      builder: (context, ref, child) => MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: ref.watch(appRouterProvider),
      ),
    ),
  );
}

String _currentPath(WidgetTester tester) {
  final context = tester.element(find.byType(MaterialApp));
  final router = ProviderScope.containerOf(context).read(appRouterProvider);
  return router.routeInformationProvider.value.uri.path;
}

void main() {
  const legacyMatchPaths = <String>[
    AppRouteNames.match,
    AppRouteNames.matchCountdown,
    AppRouteNames.matchResult,
    AppRouteNames.matchDetail,
    AppRouteNames.matchIntention,
    AppRouteNames.matchFeedback,
  ];

  for (final legacyPath in legacyMatchPaths) {
    testWidgets('$legacyPath redirects to the canonical Match portal', (
      tester,
    ) async {
      await tester.pumpWidget(_routerApp(legacyPath, readinessReady: true));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(_currentPath(tester), AppRouteNames.progressMatch);
      expect(find.byType(MatchShellPage), findsOneWidget);
      expect(find.byType(ReadinessPurposePage), findsNothing);
    });
  }

  testWidgets('readiness guard redirects a legacy Match entry to Readiness', (
    tester,
  ) async {
    await tester.pumpWidget(
      _routerApp(AppRouteNames.matchResult, readinessReady: false),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(_currentPath(tester), AppRouteNames.meReadiness);
    expect(find.byType(ReadinessPurposePage), findsOneWidget);
    expect(find.byType(MatchShellPage), findsNothing);
  });

  for (final legacyPath in legacyMatchPaths.where(
    (path) => path != AppRouteNames.matchResult,
  )) {
    testWidgets('$legacyPath without readiness opens Readiness', (
      tester,
    ) async {
      await tester.pumpWidget(_routerApp(legacyPath, readinessReady: false));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(_currentPath(tester), AppRouteNames.meReadiness);
      expect(find.byType(ReadinessPurposePage), findsOneWidget);
      expect(find.byType(MatchShellPage), findsNothing);
    });
  }

  testWidgets('canonical Match without readiness opens Readiness', (
    tester,
  ) async {
    await tester.pumpWidget(
      _routerApp(AppRouteNames.progressMatch, readinessReady: false),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(_currentPath(tester), AppRouteNames.meReadiness);
    expect(find.byType(ReadinessPurposePage), findsOneWidget);
    expect(find.byType(MatchShellPage), findsNothing);
  });
}

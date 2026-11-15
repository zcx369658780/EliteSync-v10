import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/app/router/app_shell.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/enums/verification_status.dart';
import 'package:flutter_elitesync_module/shared/enums/questionnaire_status.dart';
import 'package:flutter_elitesync_module/shared/enums/match_status.dart';
import 'package:flutter_elitesync_module/shared/models/navigation_snapshot.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/navigation_guard_provider.dart';

void main() {
  for (final entry in ['/discover', '/profile', '/match', '/missing-route']) {
    testWidgets('V10113 Splash resumes authenticated explicit entry $entry', (
      tester,
    ) async {
      final router = await _show(tester, entry: entry, authenticated: true);
      expect(router.routeInformationProvider.value.uri.path, entry);
    });
  }
  testWidgets('V10113 explicit entry still waits for login', (tester) async {
    final router = await _show(
      tester,
      entry: '/discover',
      authenticated: false,
    );
    expect(router.routeInformationProvider.value.uri.path, '/auth/login');
  });
  for (final entry in [null, '/splash', '/auth/login']) {
    testWidgets('V10113 default startup retains readiness for $entry', (
      tester,
    ) async {
      final router = await _show(tester, entry: entry, authenticated: true);
      expect(router.routeInformationProvider.value.uri.path, '/me/readiness');
    });
  }
}

Future<GoRouter> _show(
  WidgetTester tester, {
  String? entry,
  required bool authenticated,
}) async {
  final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashPage()),
      for (final path in [
        '/discover',
        '/profile',
        '/match',
        '/missing-route',
        '/auth/login',
        '/me/readiness',
      ])
        GoRoute(
          path: path,
          builder: (_, _) => Scaffold(body: Text(path)),
        ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appEnvProvider.overrideWithValue(
          AppEnv(
            flavor: AppFlavor.dev,
            appName: 'Test',
            apiBaseUrl: 'http://127.0.0.1:9/',
            useMockData: true,
            useMockMatch: true,
            initialRoute: entry,
          ),
        ),
        navigationGuardProvider.overrideWithValue(
          NavigationSnapshot(
            authStatus: authenticated
                ? AuthStatus.authenticated
                : AuthStatus.unauthenticated,
            verificationStatus: VerificationStatus.unknown,
            questionnaireStatus: QuestionnaireStatus.unknown,
            matchStatus: MatchStatus.unknown,
            canChat: false,
            readinessState: ReadinessGuardState.unknown,
            isBootstrapLoading: false,
          ),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

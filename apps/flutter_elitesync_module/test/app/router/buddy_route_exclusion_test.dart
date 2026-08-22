import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/app/router/app_router.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/buddy/presentation/pages/buddy_companion_page.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

ProviderContainer _container(AppFlavor flavor, {String? initialRoute}) {
  return ProviderContainer(
    overrides: [
      appEnvProvider.overrideWithValue(
        AppEnv(
          flavor: flavor,
          appName: 'EliteSync Router Test',
          apiBaseUrl: 'http://localhost',
          useMockData: false,
          initialRoute: initialRoute,
        ),
      ),
      authStatusProvider.overrideWithValue(AuthStatus.authenticated),
    ],
  );
}

Set<String> _registeredPaths(GoRouter router) {
  final paths = <String>{};

  void collect(List<RouteBase> routes) {
    for (final route in routes) {
      if (route is GoRoute) paths.add(route.path);
      collect(route.routes);
    }
  }

  collect(router.configuration.routes);
  return paths;
}

Widget _routerApp(
  AppFlavor flavor,
  String initialRoute, {
  AuthStatus authStatus = AuthStatus.authenticated,
}) {
  return ProviderScope(
    overrides: [
      appEnvProvider.overrideWithValue(
        AppEnv(
          flavor: flavor,
          appName: 'EliteSync Router Test',
          apiBaseUrl: 'http://localhost',
          useMockData: false,
          initialRoute: initialRoute,
        ),
      ),
      authStatusProvider.overrideWithValue(authStatus),
    ],
    child: Consumer(
      builder: (context, ref, child) {
        return MaterialApp.router(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          routerConfig: ref.watch(appRouterProvider),
        );
      },
    ),
  );
}

void main() {
  for (final flavor in [AppFlavor.dev, AppFlavor.prod]) {
    test(
      'Buddy route is absent while representative routes remain in ${flavor.name}',
      () {
        final container = _container(flavor);
        addTearDown(container.dispose);
        final router = container.read(appRouterProvider);
        addTearDown(router.dispose);

        final paths = _registeredPaths(router);

        expect(paths, isNot(contains(AppRouteNames.buddy)));
        expect(paths, contains(AppRouteNames.splash));
        expect(paths, contains(AppRouteNames.login));
        expect(paths, contains(AppRouteNames.discover));
        expect(paths, contains(AppRouteNames.profile));
      },
    );

    testWidgets(
      'direct Buddy path fails closed without building Buddy page in ${flavor.name}',
      (tester) async {
        await tester.pumpWidget(_routerApp(flavor, AppRouteNames.buddy));
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.byType(BuddyCompanionPage), findsNothing);
        expect(find.text('搭子精准陪伴'), findsNothing);
      },
    );

    testWidgets(
      'unrelated authentication guard still redirects profile to login in ${flavor.name}',
      (tester) async {
        await tester.pumpWidget(
          _routerApp(
            flavor,
            AppRouteNames.profile,
            authStatus: AuthStatus.unauthenticated,
          ),
        );
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.text('账号登录'), findsOneWidget);
        expect(find.byType(BuddyCompanionPage), findsNothing);
      },
    );
  }
}

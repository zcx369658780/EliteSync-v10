import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/app/router/app_router.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

const _removedPath = '/profile/astro/advanced-demo';

ProviderContainer _container(AppFlavor flavor) {
  return ProviderContainer(
    overrides: [
      appEnvProvider.overrideWithValue(
        AppEnv(
          flavor: flavor,
          appName: 'EliteSync Router Test',
          apiBaseUrl: 'http://localhost',
          useMockData: false,
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

Widget _routerApp(AppFlavor flavor, {required AuthStatus authStatus}) {
  return ProviderScope(
    overrides: [
      appEnvProvider.overrideWithValue(
        AppEnv(
          flavor: flavor,
          appName: 'EliteSync Router Test',
          apiBaseUrl: 'http://localhost',
          useMockData: false,
          initialRoute: _removedPath,
        ),
      ),
      authStatusProvider.overrideWithValue(authStatus),
    ],
    child: Consumer(
      builder: (context, ref, child) => MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: ref.watch(appRouterProvider),
      ),
    ),
  );
}

void main() {
  for (final flavor in [AppFlavor.dev, AppFlavor.prod]) {
    test('advanced demo route is excluded in ${flavor.name}', () {
      final container = _container(flavor);
      addTearDown(container.dispose);
      final router = container.read(appRouterProvider);
      addTearDown(router.dispose);
      final paths = _registeredPaths(router);

      expect(paths, isNot(contains(_removedPath)));
      expect(paths.where((path) => path.contains('advanced-demo')), isEmpty);
      expect(
        paths,
        containsAll(<String>{
          AppRouteNames.astroOverview,
          AppRouteNames.astroProfile,
          AppRouteNames.astroNatalChart,
          AppRouteNames.astroBazi,
          AppRouteNames.astroZiwei,
          AppRouteNames.astroAdvancedPreview,
          AppRouteNames.astroChartSettings,
        }),
      );
    });

    testWidgets(
      'authenticated direct advanced demo navigation fails closed in ${flavor.name}',
      (tester) async {
        await tester.pumpWidget(
          _routerApp(flavor, authStatus: AuthStatus.authenticated),
        );
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.text('高级时法演示'), findsNothing);
        expect(find.text('离线样例矩阵 / 路线对照 / 归档截图'), findsNothing);
      },
    );

    testWidgets(
      'unauthenticated removed path remains bounded by login in ${flavor.name}',
      (tester) async {
        await tester.pumpWidget(
          _routerApp(flavor, authStatus: AuthStatus.unauthenticated),
        );
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.text('账号登录'), findsOneWidget);
        expect(find.text('高级时法演示'), findsNothing);
      },
    );
  }
}

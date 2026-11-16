import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/me/presentation/pages/me_landing_page.dart';
import 'package:flutter_elitesync_module/features/me/presentation/pages/me_purpose_pages.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/personal_showcase_page.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _NoSession extends SessionNotifier {
  @override
  SessionState build() =>
      const SessionState(status: AuthStatus.unauthenticated);
}

void main() {
  const b3 = bool.fromEnvironment('ELITESYNC_V1017_LOCAL_BUILD');

  testWidgets(
    'B3 purpose entries and optional MBTI are reachable without scroll',
    (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final router = GoRouter(
        initialLocation: '/me',
        routes: [
          GoRoute(
            path: '/me',
            builder: (_, _) => const MeLandingPage(restorationLocalBuild: true),
            routes: [
              GoRoute(
                path: 'private-identity',
                builder: (_, _) => const Scaffold(body: Text('private editor')),
              ),
            ],
          ),
          GoRoute(
            path: AppRouteNames.mbtiCenter,
            builder: (_, _) => const Scaffold(body: Text('optional tool')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sessionProvider.overrideWith(_NoSession.new)],
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('生活方式探索'), findsOneWidget);
      expect(find.text('私密资料'), findsOneWidget);
      if (b3) {
        expect(
          find.byKey(MeLandingPage.privacySettingsKey).hitTestable(),
          findsOneWidget,
        );
        expect(find.text('可选 MBTI 测评').hitTestable(), findsOneWidget);
        expect(tester.getCenter(find.text('可选 MBTI 测评')).dy, lessThan(528));
        await tester.tap(find.text('可选 MBTI 测评'));
        await tester.pumpAndSettle();
        expect(find.text('optional tool'), findsOneWidget);
      } else {
        expect(find.text('个人资料'), findsOneWidget);
      }
    },
  );

  testWidgets('B3 purpose wrappers return the existing canonical editors', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    final context = tester.element(find.byType(SizedBox));
    final privatePage = const PrivateIdentityPurposePage().build(context);
    final showcasePage = const ShowcasePurposePage().build(context);
    if (b3) {
      expect(privatePage, isA<EditProfilePage>());
      expect(showcasePage, isA<PersonalShowcasePage>());
    } else {
      expect(privatePage, isNot(isA<EditProfilePage>()));
      expect(showcasePage, isNot(isA<PersonalShowcasePage>()));
    }
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/status/presentation/pages/status_author_page.dart';
import 'package:flutter_elitesync_module/features/status/presentation/providers/status_posts_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets(
    'direct status author route fails closed without reading profile provider',
    (tester) async {
      var providerReads = 0;
      final router = GoRouter(
        initialLocation: '/status/author/42?name=Payload%20Author',
        routes: [
          GoRoute(
            path: '/status/author/:userId',
            builder: (context, state) => const StatusAuthorPage(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            statusAuthorProvider.overrideWith((ref, userId) async {
              providerReads += 1;
              throw StateError('profile provider must not be read');
            }),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(providerReads, 0);
      expect(find.text('访问权限尚未建立'), findsOneWidget);
      expect(find.text('当前没有已建立的受众访问权限。为保护隐私，未加载任何作者或个人资料。'), findsOneWidget);
      expect(find.textContaining('Payload Author'), findsNothing);
      expect(find.textContaining('42'), findsNothing);
      expect(
        find.textContaining('profile provider must not be read'),
        findsNothing,
      );
    },
  );
}

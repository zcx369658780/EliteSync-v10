import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/status/domain/entities/status_post_entity.dart';
import 'package:flutter_elitesync_module/features/status/presentation/widgets/status_post_card.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

void main() {
  testWidgets(
    'status post card shows author, actions and media placeholder text',
    (tester) async {
      final post = StatusPostEntity.fromJson({
        'id': 2,
        'title': '周末状态',
        'body': '先发一条轻动态',
        'author': {
          'id': 12,
          'name': 'test1',
          'nickname': 'test1',
          'phone': '17094346566',
          'account_type': 'normal',
          'is_synthetic': false,
        },
        'visibility': 'square',
        'can_delete': true,
        'likes_count': 3,
        'liked_by_viewer': true,
        'cover_media': {'id': 99, 'public_url': ''},
        'created_at': '2026-04-19T08:00:00.000Z',
        'is_deleted': false,
      });

      var tappedAuthor = false;
      var toggledLike = false;
      var reported = false;
      var deleted = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appEnvProvider.overrideWithValue(
              const AppEnv(
                flavor: AppFlavor.prod,
                appName: 'EliteSync',
                apiBaseUrl: 'http://101.133.161.203/',
                useMockData: false,
              ),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: StatusPostCard(
                post: post,
                onTapAuthor: () => tappedAuthor = true,
                onLikeToggle: () => toggledLike = true,
                onReport: () => reported = true,
                onDelete: () => deleted = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('周末状态'), findsOneWidget);
      expect(find.text('test1'), findsOneWidget);
      expect(find.text('内测示例'), findsNothing);
      expect(find.text('3 喜欢'), findsOneWidget);
      expect(find.text('取消喜欢'), findsOneWidget);
      expect(find.text('举报'), findsOneWidget);
      expect(find.text('删除'), findsOneWidget);

      await tester.tap(find.text('test1'));
      await tester.pump();
      expect(tappedAuthor, isTrue);

      await tester.tap(find.text('取消喜欢'));
      await tester.pump();
      expect(toggledLike, isTrue);

      await tester.tap(find.text('举报'));
      await tester.pump();
      expect(reported, isTrue);

      await tester.tap(find.text('删除'));
      await tester.pump();
      expect(deleted, isTrue);
    },
  );

  testWidgets('status post card neutralizes numeric test-like content', (
    tester,
  ) async {
    final post = StatusPostEntity.fromJson({
      'id': 3,
      'title': '666',
      'body': '6666教师食堂 15',
      'location_name': '6666教师食堂 15',
      'author': {
        'id': 12,
        'name': 'test1',
        'nickname': 'test1',
        'phone': '17094346566',
        'account_type': 'normal',
        'is_synthetic': false,
      },
      'visibility': 'public',
      'can_delete': false,
      'likes_count': 0,
      'liked_by_viewer': false,
      'created_at': '2026-05-07T08:00:00.000Z',
      'is_deleted': false,
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvProvider.overrideWithValue(
            const AppEnv(
              flavor: AppFlavor.prod,
              appName: 'EliteSync',
              apiBaseUrl: 'http://101.133.161.203/',
              useMockData: false,
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(body: StatusPostCard(post: post)),
        ),
      ),
    );

    expect(find.text('示例内容'), findsWidgets);
    expect(find.text('666'), findsNothing);
    expect(find.text('6666教师食堂 15'), findsNothing);
    expect(find.textContaining('2026年5月7日'), findsOneWidget);
    expect(find.textContaining('May'), findsNothing);
  });
}

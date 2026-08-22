import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/home/domain/entities/home_feed_entity.dart';
import 'package:flutter_elitesync_module/features/home/presentation/pages/content_detail_page.dart';
import 'package:flutter_elitesync_module/features/home/presentation/providers/content_detail_provider.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _env = AppEnv(
  flavor: AppFlavor.dev,
  appName: 'EliteSync',
  apiBaseUrl: 'http://localhost',
  useMockData: false,
  useMockHome: false,
);

Widget _app(Future<HomeFeedEntity> Function(ContentDetailQuery query) load) {
  return ProviderScope(
    overrides: [
      appEnvProvider.overrideWithValue(_env),
      contentDetailProvider.overrideWith((ref, query) => load(query)),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      home: const ContentDetailPage(
        contentId: 'detail-1',
        content: HomeFeedEntity(
          id: 'detail-1',
          title: '路由种子标题',
          summary: '路由种子摘要',
          author: '种子作者',
          likes: 0,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('detail loading stays visually distinct from route seed', (
    tester,
  ) async {
    final pending = Completer<HomeFeedEntity>();
    await tester.pumpWidget(_app((_) => pending.future));
    await tester.pump();

    expect(find.byType(AppLoadingSkeleton), findsOneWidget);
    expect(find.text('路由种子标题'), findsNothing);
    expect(find.text('路由种子摘要'), findsNothing);
  });

  testWidgets('detail error is unavailable with bounded retry and no seed', (
    tester,
  ) async {
    var attempts = 0;
    await tester.pumpWidget(
      _app((_) async {
        attempts += 1;
        throw StateError('raw internal detail failure');
      }),
    );
    await tester.pumpAndSettle();

    expect(find.text('内容暂时无法打开'), findsOneWidget);
    expect(find.text('这条内容目前无法加载，你可以稍后重试或返回发现页。'), findsOneWidget);
    expect(find.text('重新加载'), findsOneWidget);
    expect(find.text('路由种子标题'), findsNothing);
    expect(find.textContaining('raw internal'), findsNothing);
    expect(attempts, 1);

    await tester.tap(find.text('重新加载'));
    await tester.pumpAndSettle();
    expect(attempts, 2);
  });

  testWidgets('detail success uses only supplied DTO fields', (tester) async {
    await tester.pumpWidget(
      _app(
        (_) async => const HomeFeedEntity(
          id: 'detail-1',
          title: '合成详情标题',
          summary: '合成详情摘要',
          author: '测试作者',
          likes: 1,
          body: null,
          tags: [],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('合成详情标题'), findsOneWidget);
    expect(find.text('合成详情摘要'), findsOneWidget);
    expect(find.text('来源：测试作者'), findsOneWidget);
    expect(find.textContaining('来源：测试作者 · 预计阅读'), findsOneWidget);
    expect(find.textContaining('后续这里将接入'), findsNothing);
    expect(find.textContaining('评论与互动入口'), findsNothing);
    expect(find.textContaining('导语：'), findsNothing);
    expect(find.textContaining('可执行建议'), findsNothing);
    expect(find.textContaining('建设中'), findsNothing);
  });

  testWidgets('detail uses a neutral fallback when author is empty', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        (_) async => const HomeFeedEntity(
          id: 'detail-1',
          title: '无署名内容',
          summary: '只展示当前已有内容。',
          author: '   ',
          likes: 0,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('无署名内容'), findsOneWidget);
    expect(find.text('只展示当前已有内容。'), findsOneWidget);
    expect(find.text('来源：未注明'), findsOneWidget);
    expect(find.textContaining('来源：未注明 · 预计阅读'), findsOneWidget);
  });

  testWidgets('detail keeps safe media error fallback', (tester) async {
    await tester.pumpWidget(
      _app(
        (_) async => const HomeFeedEntity(
          id: 'detail-1',
          title: '带图内容',
          summary: '图片不可用时仍保留正文。',
          author: '内容来源',
          likes: 0,
          media: ['http://127.0.0.1:1/unavailable.png'],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('带图内容'), findsOneWidget);
    expect(find.text('图片不可用时仍保留正文。'), findsOneWidget);
    expect(find.text('图片加载失败'), findsOneWidget);
  });
}

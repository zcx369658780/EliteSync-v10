import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/home/data/datasource/home_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/home/data/dto/home_feed_dto.dart';
import 'package:flutter_elitesync_module/features/discover/presentation/pages/discover_page.dart';
import 'package:flutter_elitesync_module/features/home/domain/entities/home_feed_entity.dart';
import 'package:flutter_elitesync_module/features/home/presentation/pages/content_detail_page.dart';
import 'package:flutter_elitesync_module/features/home/presentation/providers/content_detail_provider.dart';
import 'package:flutter_elitesync_module/features/home/presentation/providers/home_provider.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class FakeLocalStorageService extends LocalStorageService {
  final Map<String, Object?> _values = <String, Object?>{};

  @override
  Future<String?> getString(String key) async {
    final value = _values[key];
    return value is String ? value : null;
  }

  @override
  Future<bool> setString(String key, String value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool?> getBool(String key) async {
    final value = _values[key];
    return value is bool ? value : null;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<int?> getInt(String key) async {
    final value = _values[key];
    return value is int ? value : null;
  }

  @override
  Future<Map<String, dynamic>?> getJson(String key) async {
    final value = _values[key];
    return value is Map<String, dynamic> ? value : null;
  }

  @override
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    _values.remove(key);
    return true;
  }
}

class _ControlledHomeRemoteDataSource extends HomeRemoteDataSource {
  _ControlledHomeRemoteDataSource({
    required this.load,
    required FakeLocalStorageService localStorage,
  }) : super(
         apiClient: ApiClient(dio: Dio()),
         useMock: false,
         localStorage: localStorage,
       );

  final Future<FeedPageResult> Function() load;

  @override
  Future<FeedPageResult> fetchDiscoverFeedPage({
    String? tab,
    String? cursor,
    int limit = 12,
  }) {
    return load();
  }
}

Widget _discoverApp({
  required FakeLocalStorageService localStorage,
  required HomeRemoteDataSource remote,
}) {
  return ProviderScope(
    overrides: [
      appEnvProvider.overrideWithValue(
        const AppEnv(
          flavor: AppFlavor.dev,
          appName: 'EliteSync',
          apiBaseUrl: 'http://localhost',
          useMockData: false,
          useMockHome: false,
        ),
      ),
      localStorageProvider.overrideWithValue(localStorage),
      homeRemoteDataSourceProvider.overrideWithValue(remote),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      home: const DiscoverPage(),
    ),
  );
}

double _contrastRatio(Color a, Color b) {
  final light = a.computeLuminance();
  final dark = b.computeLuminance();
  final high = light > dark ? light : dark;
  final low = light > dark ? dark : light;
  return (high + 0.05) / (low + 0.05);
}

void main() {
  test('normalizeDiscoverVisibleCopy maps runtime feed wording', () {
    expect(normalizeDiscoverVisibleCopy('热点话题：异地恋最难的不是距离'), '关系话题：异地恋最难的不是距离');
    expect(
      normalizeDiscoverVisibleCopy('热门征集：你最想参加哪类第一次约会活动？'),
      '活动话题：你最想参加哪类第一次约会活动？',
    );
    expect(
      normalizeDiscoverVisibleCopy('从散步、展览、咖啡到桌游，看看同城选择趋势。'),
      '从散步、展览、咖啡到桌游，看看轻松活动想法。',
    );
    expect(
      normalizeDiscoverVisibleCopy('热门：同城活动后 24 小时内复盘最能提升二次见面率'),
      '小提示：活动之后 24 小时内复盘可以记下值得回想的细节',
    );
    expect(normalizeDiscoverVisibleCopy('参与讨论并查看不同城市用户的真实经验。'), '看看不同经历的人的分享。');
    expect(normalizeDiscoverVisibleCopy('热门低压力活动更容易开始'), '活动话题轻松活动可以开始');
    for (final unsafe in [
      ...[
        'no_round',
        'preparing',
        'waiting',
        'revealed',
        'no_candidate',
        'failed',
        'closed',
      ].map((state) => '内部状态=$state'),
      'raw_score=91 weight=0.8 threshold=60',
      'ranking=1 quality_grade=A',
      '保证匹配成功',
      '匹配率 100%',
      'HTTP 500 DioError status_code=500',
      '服务端 provider 返回结果',
      'https://internal.example/trace',
      '焦虑型依恋心理标签',
    ]) {
      expect(normalizeDiscoverVisibleCopy(unsafe), '内容正在整理中，可以稍后再看。');
    }
  });

  testWidgets('DiscoverPage renders optional unique content hierarchy', (
    tester,
  ) async {
    final localStorage = FakeLocalStorageService();
    final remote = HomeRemoteDataSource(
      apiClient: ApiClient(dio: Dio()),
      useMock: true,
      localStorage: localStorage,
    );
    final router = GoRouter(
      initialLocation: AppRouteNames.discover,
      routes: [
        GoRoute(
          path: AppRouteNames.discover,
          builder: (context, state) => const DiscoverPage(),
        ),
        GoRoute(
          path: '${AppRouteNames.contentDetail}/:id',
          builder: (context, state) => ContentDetailPage(
            contentId: state.pathParameters['id']!,
            content: state.extra as HomeFeedEntity?,
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvProvider.overrideWithValue(
            const AppEnv(
              flavor: AppFlavor.dev,
              appName: 'EliteSync',
              apiBaseUrl: 'http://localhost',
              useMockData: true,
              useMockHome: true,
            ),
          ),
          localStorageProvider.overrideWithValue(localStorage),
          homeRemoteDataSourceProvider.overrideWithValue(remote),
          contentDetailProvider.overrideWith((ref, query) async => query.seed!),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('发现'), findsOneWidget);
    expect(find.text('浏览少量关系与活动灵感，感兴趣时再看详情。'), findsOneWidget);
    expect(find.text('先看一个主题'), findsOneWidget);
    expect(find.text('表达提示'), findsNothing);
    expect(find.text('看看表达灵感'), findsNothing);
    expect(find.text('打开展示自己'), findsNothing);
    expect(find.text('查看关系参考'), findsNothing);
    expect(find.text('搜索话题、活动、兴趣圈'), findsNothing);
    expect(find.text('热点'), findsNothing);
    expect(find.text('热门'), findsNothing);
    expect(find.text('同城'), findsNothing);
    expect(find.text('广场'), findsNothing);
    expect(find.text('信息流'), findsNothing);
    expect(find.text('附近推荐'), findsNothing);
    expect(find.text('直播'), findsNothing);
    expect(find.text('语音房'), findsNothing);

    expect(find.text('看看搭子方向'), findsNothing);
    expect(find.text('从公共场景、清楚边界和共同兴趣开始'), findsNothing);

    expect(find.text('内容说明'), findsWidgets);
    await tester.tap(find.text('内容说明').first);
    await tester.pumpAndSettle();

    expect(find.text('内容说明'), findsWidgets);
    expect(
      find.descendant(
        of: find.byType(AppPrimaryButton),
        matching: find.text('查看详情'),
      ),
      findsOneWidget,
    );
    expect(find.text('稍后再看'), findsOneWidget);
    expect(
      tester.getSize(find.byType(AppPrimaryButton)).height,
      greaterThanOrEqualTo(48),
    );
    expect(
      tester
          .getSize(
            find.ancestor(
              of: find.text('稍后再看'),
              matching: find.byType(TextButton),
            ),
          )
          .height,
      greaterThanOrEqualTo(48),
    );
    expect(find.byType(AppPrimaryButton), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(AppPrimaryButton),
        matching: find.text('查看详情'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('内容详情'), findsOneWidget);
    expect(find.textContaining('热点'), findsNothing);
    expect(find.textContaining('热门'), findsNothing);
    expect(find.textContaining('热度'), findsNothing);

    router.go(AppRouteNames.discover);
    await tester.pumpAndSettle();
    final scrollableFinder = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('其他灵感'),
      240,
      scrollable: scrollableFinder,
    );
    await tester.pumpAndSettle();
    expect(find.text('其他灵感'), findsOneWidget);
    expect(find.text('星盘与性格提示'), findsNothing);
    expect(find.text('查看关系参考'), findsNothing);
    expect(find.textContaining('探索只是给你一些灵感'), findsNothing);
    expect(find.text('看看搭子方向'), findsNothing);
    expect(find.textContaining('演示'), findsNothing);
  });

  testWidgets('Discover action sheet stays above the persistent shell dock', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final localStorage = FakeLocalStorageService();
    final remote = HomeRemoteDataSource(
      apiClient: ApiClient(dio: Dio()),
      useMock: true,
      localStorage: localStorage,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvProvider.overrideWithValue(
            const AppEnv(
              flavor: AppFlavor.dev,
              appName: 'EliteSync',
              apiBaseUrl: 'http://localhost',
              useMockData: true,
              useMockHome: true,
            ),
          ),
          localStorageProvider.overrideWithValue(localStorage),
          homeRemoteDataSourceProvider.overrideWithValue(remote),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            extendBody: true,
            body: Navigator(
              onGenerateRoute: (_) =>
                  MaterialPageRoute<void>(builder: (_) => const DiscoverPage()),
            ),
            bottomNavigationBar: const SizedBox(
              height: 96,
              child: ColoredBox(
                color: Colors.black,
                child: Center(child: Text('SHELL NAV')),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('内容说明').first);
    await tester.pumpAndSettle();

    final later = find.text('稍后再看');
    expect(later, findsOneWidget);
    await tester.tap(later);
    await tester.pumpAndSettle();
    expect(find.text('可以先看看主题和分享，再决定是否继续了解。'), findsNothing);
    expect(find.text('SHELL NAV'), findsOneWidget);
  });

  testWidgets('Content detail normalizes raw Discover growth framing', (
    tester,
  ) async {
    const raw = HomeFeedEntity(
      id: 'raw-detail',
      title: '热点话题：异地恋最难的不是距离',
      summary: '参与讨论并查看不同城市用户的真实经验。',
      author: '社区运营',
      likes: 201,
      body: '热点话题可以先看看真实经验。',
      tags: ['热点', '热门征集'],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvProvider.overrideWithValue(
            const AppEnv(
              flavor: AppFlavor.dev,
              appName: 'EliteSync',
              apiBaseUrl: 'http://localhost',
              useMockData: false,
              useMockHome: false,
            ),
          ),
          contentDetailProvider.overrideWith((ref, query) async => raw),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ContentDetailPage(contentId: 'raw-detail', content: raw),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('关系话题'), findsWidgets);
    expect(find.textContaining('活动话题'), findsOneWidget);
    expect(find.textContaining('热点'), findsNothing);
    expect(find.textContaining('热门'), findsNothing);
    expect(find.textContaining('热度'), findsNothing);
    expect(find.textContaining('201'), findsNothing);
  });

  testWidgets('DiscoverPage normalizes remote runtime feed copy', (
    tester,
  ) async {
    final localStorage = FakeLocalStorageService();
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 200,
              data: const {
                'data': [
                  {
                    'id': 'runtime-001',
                    'title': '热点话题：异地恋最难的不是距离',
                    'summary': '参与讨论并查看不同城市用户的真实经验。',
                    'author': '活动灵感组',
                    'likes': 19,
                    'tags': ['同城活动后', '热点'],
                  },
                  {
                    'id': 'runtime-002',
                    'title': '热门征集：你最想参加哪类第一次约会活动？',
                    'summary': '从散步、展览、咖啡到桌游，看看同城选择趋势。',
                    'author': '活动灵感组',
                    'likes': 18,
                  },
                  {
                    'id': 'runtime-003',
                    'title': '热门：同城活动后 24 小时内复盘最能提升二次见面率',
                    'summary': '一句复盘比一串表情更有效。',
                    'author': '活动灵感组',
                    'likes': 17,
                  },
                ],
                'meta': {'has_more': false},
              },
            ),
          );
        },
      ),
    );
    final remote = HomeRemoteDataSource(
      apiClient: ApiClient(dio: dio),
      useMock: false,
      localStorage: localStorage,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvProvider.overrideWithValue(
            const AppEnv(
              flavor: AppFlavor.dev,
              appName: 'EliteSync',
              apiBaseUrl: 'http://localhost',
              useMockData: false,
              useMockHome: false,
            ),
          ),
          localStorageProvider.overrideWithValue(localStorage),
          homeRemoteDataSourceProvider.overrideWithValue(remote),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          home: const DiscoverPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('关系话题：异地恋最难的不是距离'), findsOneWidget);
    expect(find.text('看看不同经历的人的分享。'), findsOneWidget);
    expect(find.textContaining('热点'), findsNothing);
    expect(find.textContaining('热门'), findsNothing);
    expect(find.textContaining('同城'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('其他灵感'),
      260,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('活动话题：你最想参加哪类第一次约会活动？'), findsOneWidget);
    expect(find.text('从散步、展览、咖啡到桌游，看看轻松活动想法。'), findsOneWidget);
    expect(find.text('小提示：活动之后 24 小时内复盘可以记下值得回想的细节'), findsOneWidget);
    expect(find.text('关系话题：异地恋最难的不是距离'), findsOneWidget);
    expect(find.textContaining('热点'), findsNothing);
    expect(find.textContaining('热门'), findsNothing);
    expect(find.textContaining('同城'), findsNothing);

    await tester.tap(find.text('内容说明').first);
    await tester.pumpAndSettle();

    expect(find.text('内容说明'), findsWidgets);
    expect(find.textContaining('热点'), findsNothing);
    expect(find.textContaining('同城'), findsNothing);
  });

  testWidgets('DiscoverPage loading does not invent content or errors', (
    tester,
  ) async {
    final localStorage = FakeLocalStorageService();
    final pending = Completer<FeedPageResult>();
    final remote = _ControlledHomeRemoteDataSource(
      load: () => pending.future,
      localStorage: localStorage,
    );

    await tester.pumpWidget(
      _discoverApp(localStorage: localStorage, remote: remote),
    );
    await tester.pump();
    expect(find.text('发现'), findsOneWidget);
    expect(find.byType(AppLoadingSkeleton), findsOneWidget);
    expect(find.text('暂时没有新的内容'), findsNothing);
    expect(find.text('发现内容加载失败'), findsNothing);
  });

  testWidgets('DiscoverPage caps remote items and exposes two 48dp actions', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    tester.view.physicalSize = const Size(390, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final localStorage = FakeLocalStorageService();
    final items = List<HomeFeedDto>.generate(
      5,
      (index) => HomeFeedDto(
        id: 'bounded-$index',
        title: '关系灵感 ${index + 1}',
        summary: '一条有限的活动想法',
        author: '内容组',
        likes: 0,
      ),
    );
    final remote = _ControlledHomeRemoteDataSource(
      load: () async =>
          FeedPageResult(items: items, nextCursor: 'ignored', hasMore: true),
      localStorage: localStorage,
    );
    final router = GoRouter(
      initialLocation: AppRouteNames.discover,
      routes: [
        GoRoute(
          path: AppRouteNames.discover,
          builder: (_, _) => const DiscoverPage(),
        ),
        GoRoute(
          path: '${AppRouteNames.contentDetail}/:id',
          builder: (_, state) =>
              Scaffold(body: Text('DETAIL ${state.pathParameters['id']}')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageProvider.overrideWithValue(localStorage),
          homeRemoteDataSourceProvider.overrideWithValue(remote),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('关系灵感 1'), findsOneWidget);
    expect(find.text('关系灵感 4'), findsNothing);
    expect(find.text('关系灵感 5'), findsNothing);
    expect(find.text('查看详情'), findsNWidgets(3));
    expect(find.text('内容说明'), findsNWidgets(3));

    for (final label in ['查看详情', '内容说明']) {
      final buttons = find.ancestor(
        of: find.text(label),
        matching: find.byType(TextButton),
      );
      for (var index = 0; index < buttons.evaluate().length; index++) {
        expect(
          tester.getSize(buttons.at(index)).height,
          greaterThanOrEqualTo(48),
        );
      }
    }

    for (var item = 1; item <= 3; item++) {
      final id = 'bounded-${item - 1}';
      final title = '关系灵感 $item';
      await tester.scrollUntilVisible(
        find.text(title),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      final open = find.byKey(ValueKey('discover-open-$id'));
      final explain = find.byKey(ValueKey('discover-explain-$id'));
      expect(open, findsOneWidget);
      expect(explain, findsOneWidget);
      expect(find.bySemanticsLabel('查看详情：$title'), findsOneWidget);
      expect(find.bySemanticsLabel('内容说明：$title'), findsOneWidget);
      expect(tester.getSemantics(open).flagsCollection.isButton, isTrue);
      expect(tester.getSemantics(explain).flagsCollection.isButton, isTrue);

      await tester.tap(explain);
      await tester.pumpAndSettle();
      expect(find.text('可以先看看主题和分享，再决定是否继续了解。'), findsOneWidget);
      Navigator.of(tester.element(find.text('可以先看看主题和分享，再决定是否继续了解。'))).pop();
      await tester.pumpAndSettle();

      await tester.tap(open);
      await tester.pumpAndSettle();
      expect(find.text('DETAIL $id'), findsOneWidget);
      router.go(AppRouteNames.discover);
      await tester.pumpAndSettle();
    }
    expect(find.text('关系灵感 4'), findsNothing);

    const focusOrder = [
      ValueKey('discover-open-bounded-0'),
      ValueKey('discover-explain-bounded-0'),
      ValueKey('discover-open-bounded-1'),
      ValueKey('discover-explain-bounded-1'),
      ValueKey('discover-open-bounded-2'),
      ValueKey('discover-explain-bounded-2'),
    ];
    Key? focusedActionKey() {
      Key? result;
      final context = FocusManager.instance.primaryFocus?.context;
      if (context?.widget.key case final key? when focusOrder.contains(key)) {
        return key;
      }
      context?.visitAncestorElements((element) {
        final key = element.widget.key;
        if (key != null && focusOrder.contains(key)) {
          result = key;
          return false;
        }
        return true;
      });
      return result;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    for (final expectedKey in focusOrder) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(focusedActionKey(), expectedKey);
    }
    semantics.dispose();
  });

  testWidgets('DiscoverPage empty state stays truthful and content-only', (
    tester,
  ) async {
    final localStorage = FakeLocalStorageService();
    final remote = _ControlledHomeRemoteDataSource(
      load: () async =>
          const FeedPageResult(items: [], nextCursor: null, hasMore: false),
      localStorage: localStorage,
    );

    await tester.pumpWidget(
      _discoverApp(localStorage: localStorage, remote: remote),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('暂时没有新的内容'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('暂时没有新的内容'), findsOneWidget);
    expect(find.text('暂时没有可浏览的内容，可以稍后再回来看看。'), findsOneWidget);
    expect(find.text('看看表达灵感'), findsNothing);
    expect(find.text('打开展示自己'), findsNothing);
    expect(find.text('先看一个主题'), findsNothing);
    expect(find.text('今天可以先想一个轻松问题：对方最近真正投入的事情是什么？'), findsNothing);
    expect(find.text('星盘与性格提示'), findsNothing);
  });

  testWidgets(
    'Discover remains readable at 320px, large text, reduced motion',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );

      final localStorage = FakeLocalStorageService();
      final remote = _ControlledHomeRemoteDataSource(
        load: () async => const FeedPageResult(
          items: [
            HomeFeedDto(
              id: 'responsive-1',
              title: '关系灵感一',
              summary: '用普通语言描述的一条轻活动灵感',
              author: '内容组',
              likes: 0,
            ),
            HomeFeedDto(
              id: 'responsive-2',
              title: '关系灵感二',
              summary: '另一条有限灵感',
              author: '内容组',
              likes: 0,
            ),
          ],
          nextCursor: null,
          hasMore: false,
        ),
        localStorage: localStorage,
      );

      await tester.pumpWidget(
        _discoverApp(localStorage: localStorage, remote: remote),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('浏览少量关系与活动灵感，感兴趣时再看详情。'), findsOneWidget);
      final responsiveOpen = find.byKey(
        const ValueKey('discover-open-responsive-1'),
      );
      final responsiveExplain = find.byKey(
        const ValueKey('discover-explain-responsive-1'),
      );
      expect(responsiveOpen, findsOneWidget);
      expect(responsiveExplain, findsOneWidget);
      expect(tester.getSize(responsiveOpen).height, greaterThanOrEqualTo(48));
      expect(
        tester.getSize(responsiveExplain).height,
        greaterThanOrEqualTo(48),
      );
      expect(
        tester.getTopLeft(responsiveExplain).dy,
        greaterThan(tester.getTopLeft(responsiveOpen).dy),
      );
      await tester.tap(responsiveExplain);
      await tester.pumpAndSettle();
      expect(find.text('内容说明'), findsWidgets);
      Navigator.of(tester.element(find.text('可以先看看主题和分享，再决定是否继续了解。'))).pop();
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('其他灵感'),
        180,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final headingRect = tester.getRect(find.text('其他灵感'));
      final bodyRect = tester.getRect(find.byType(ListView));
      expect(headingRect.left, greaterThanOrEqualTo(0));
      expect(headingRect.right, lessThanOrEqualTo(320));
      expect(headingRect.left, bodyRect.left);
      expect(headingRect.top, greaterThanOrEqualTo(bodyRect.top));
    },
  );

  testWidgets(
    'Discover owned action contrast passes in light and dark themes',
    (tester) async {
      final localStorage = FakeLocalStorageService();
      final remote = _ControlledHomeRemoteDataSource(
        load: () async => const FeedPageResult(
          items: [
            HomeFeedDto(
              id: 'contrast',
              title: '关系灵感',
              summary: '有限内容',
              author: '内容组',
              likes: 0,
            ),
          ],
          nextCursor: null,
          hasMore: false,
        ),
        localStorage: localStorage,
      );

      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              localStorageProvider.overrideWithValue(localStorage),
              homeRemoteDataSourceProvider.overrideWithValue(remote),
            ],
            child: MaterialApp(
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: mode,
              home: const DiscoverPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final context = tester.element(
          find.byKey(const ValueKey('discover-open-contrast')),
        );
        final background = context.appTokens.browseSurface;
        for (final key in const [
          ValueKey('discover-open-contrast'),
          ValueKey('discover-explain-contrast'),
        ]) {
          final button = tester.widget<TextButton>(find.byKey(key));
          final foreground =
              button.style?.foregroundColor?.resolve({}) ??
              Theme.of(context).colorScheme.primary;
          expect(
            _contrastRatio(foreground, background),
            greaterThanOrEqualTo(4.5),
          );
        }
      }
    },
  );

  testWidgets('DiscoverPage error stays separate from empty content', (
    tester,
  ) async {
    final localStorage = FakeLocalStorageService();
    var attempts = 0;
    final remote = _ControlledHomeRemoteDataSource(
      load: () async {
        attempts += 1;
        if (attempts == 1) throw StateError('offline');
        return const FeedPageResult(
          items: [],
          nextCursor: null,
          hasMore: false,
        );
      },
      localStorage: localStorage,
    );

    await tester.pumpWidget(
      _discoverApp(localStorage: localStorage, remote: remote),
    );
    await tester.pumpAndSettle();
    expect(find.text('发现内容加载失败'), findsOneWidget);
    expect(find.text('暂时无法加载发现内容，请稍后重试。'), findsOneWidget);
    expect(find.text('重新加载'), findsOneWidget);
    expect(find.text('暂时没有新的内容'), findsNothing);
    expect(find.textContaining('Bad state'), findsNothing);
    expect(find.textContaining('offline'), findsNothing);
    expect(attempts, 1);

    await tester.tap(find.text('重新加载'));
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(find.text('暂时没有新的内容'), findsOneWidget);
    expect(find.text('发现内容加载失败'), findsNothing);
  });
}

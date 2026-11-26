import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/natal_restoration_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/natal_restoration_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_profile_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/natal_restoration_charts.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

class _Session extends SessionNotifier {
  @override
  SessionState build() => const SessionState(
    status: AuthStatus.authenticated,
    user: UserSummary(id: 101, phone: 'fictional-A'),
    accessToken: 'fictional-token-A',
  );
  void switchToB() => state = const AsyncData(
    SessionState(
      status: AuthStatus.authenticated,
      user: UserSummary(id: 202, phone: 'fictional-B'),
      accessToken: 'fictional-token-B',
    ),
  );
  void replaceTokenForA() => state = const AsyncData(
    SessionState(
      status: AuthStatus.authenticated,
      user: UserSummary(id: 101, phone: 'fictional-A'),
      accessToken: 'fictional-refreshed-token-A',
    ),
  );
}

Map<String, dynamic> _profile() => {
  'exists': true,
  'profile': {
    'input': {
      'civil_date': '1990-01-01',
      'civil_time': null,
      'time_precision': 'unknown',
      'timezone': 'Asia/Shanghai',
      'algorithm_sex': 'unknown',
    },
    'settings': {},
    'context': {},
    'results': {},
    'input_revision': 1,
    'result_revision': 1,
    'status': 'COMPUTED_UNVERIFIED',
  },
};

class _DelayedTokenApi {
  _DelayedTokenApi(this.delayedMethod) {
    dio.interceptors.add(
      AuthInterceptor(
        accessTokenProvider: () {
          if (activeMethod == delayedMethod) {
            if (!entered.isCompleted) entered.complete();
            return token.future;
          }
          return Future.value('fictional-token-A');
        },
      ),
    );
    // This request observer is downstream of the real AuthInterceptor. A stale
    // request reaching it would already be eligible for transport dispatch.
    dio.interceptors.insert(
      0,
      InterceptorsWrapper(
        onRequest: (request, handler) {
          activeMethod = request.method;
          request.extra['test-only-request-id'] = ++requestId;
          handler.next(request);
        },
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) {
          dispatched.add(request.method);
          dispatchedRequestIds.add(
            request.extra['test-only-request-id'] as int,
          );
          handler.resolve(
            Response(
              requestOptions: request,
              statusCode: 200,
              data: _profile(),
            ),
          );
        },
      ),
    );
  }
  final String delayedMethod;
  final dio = Dio();
  String? activeMethod;
  final entered = Completer<void>();
  final token = Completer<String?>();
  final dispatched = <String>[];
  int requestId = 0;
  final dispatchedRequestIds = <int>[];
}

class _ConcurrentApi extends ApiClient {
  _ConcurrentApi() : super(dio: Dio());
  int reads = 0;
  int writes = 0;
  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    reads++;
    final result = _profile();
    final profile = result['profile'] as Map<String, dynamic>;
    profile['input_revision'] = reads == 1 ? 1 : 3;
    profile['input_signature'] = reads == 1 ? 'signature-A' : 'signature-C';
    if (reads > 1) {
      (profile['input'] as Map<String, dynamic>)['civil_date'] = '1991-02-03';
    }
    return NetworkSuccess(result);
  }

  @override
  Future<NetworkResult<Map<String, dynamic>>> post(
    String path, {
    Object? body,
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    writes++;
    final result = _profile();
    final profile = result['profile'] as Map<String, dynamic>;
    profile['input_revision'] = 2;
    profile['input_signature'] = 'signature-B';
    return NetworkSuccess(result);
  }
}

class _SavedBirthApi extends ApiClient {
  _SavedBirthApi({this.savedNatal = false, this.delay}) : super(dio: Dio());

  final bool savedNatal;
  final Completer<void>? delay;
  final paths = <String>[];

  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    paths.add(path);
    if (path == '/api/v1/profile/natal') {
      return NetworkSuccess(savedNatal ? _profile() : {'exists': false});
    }
    expect(path, '/api/v1/profile/basic');
    final guard = options?.extra?[requestSessionGuardKey] as bool Function()?;
    expect(guard?.call(), isTrue);
    if (delay != null) await delay!.future;
    return const NetworkSuccess({
      'birthday': '1995-03-21',
      'birth_time': '08:15',
      'birth_place': '验收地点',
      'birth_lat': '0.0000000',
      'birth_lng': '112.5700000',
      'gender': 'female',
    });
  }
}

Finder _field(String label) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.labelText == label,
);

String _text(WidgetTester tester, String label) =>
    tester.widget<TextField>(_field(label)).controller!.text;

class _PlaceSearchApi extends _SavedBirthApi {
  final requests = <Object?>[];
  String coordinateSystem = 'WGS84';
  int? failureStatus;
  Map<String, dynamic>? payload;

  @override
  Future<NetworkResult<Map<String, dynamic>>> post(
    String path, {
    Object? body,
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    expect(path, '/api/v1/profile/natal/places');
    expect(options?.headers?['X-EliteSync-Natal-Places'], 'wgs84-v2');
    expect(options?.extra?[requestSessionGuardKey], isA<bool Function()>());
    requests.add(body);
    if (failureStatus != null) {
      return NetworkFailure(message: 'test failure', statusCode: failureStatus);
    }
    if (payload != null) return NetworkSuccess(payload!);
    return NetworkSuccess({
      'coordinate_system': coordinateSystem,
      'source': 'OpenStreetMap',
      'coverage': 'sample',
      'places': [
        {'label': '坐标越界', 'lat': 91.0, 'lng': 114.36},
        {
          'label': '测试地点甲',
          'address': '测试路1号',
          'point_kind': 'campus',
          'lat': 30.54,
          'lng': 114.36,
        },
      ],
    });
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('explicit search fills the draft only after selecting WGS84', (
    tester,
  ) async {
    final api = _PlaceSearchApi();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(api),
          sessionProvider.overrideWith(_Session.new),
        ],
        child: const MaterialApp(home: NatalRestorationPage()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('使用已保存的出生资料'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('跳过坐标'));
    await tester.pumpAndSettle();
    expect(_text(tester, '出生地点名称（可选）'), '验收地点');
    expect(
      tester.widget<TextField>(_field('出生地点名称（可选）')).enableSuggestions,
      isTrue,
    );
    expect(
      tester.widget<TextField>(_field('纬度 WGS84（可选）')).enableSuggestions,
      isFalse,
    );

    final button = find.widgetWithText(OutlinedButton, '搜索并带入坐标');
    Future<void> openSearch() async {
      await Scrollable.ensureVisible(tester.element(button), alignment: 0.5);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();
    }

    await openSearch();
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(api.requests, isEmpty);

    Future<void> search() async {
      await openSearch();
      final city = _field('搜索城市');
      expect(tester.widget<TextField>(city).enableSuggestions, isTrue);
      await tester.showKeyboard(city);
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'wuhan',
          selection: TextSelection.collapsed(offset: 5),
          composing: TextRange(start: 0, end: 5),
        ),
      );
      await tester.pump();
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '武汉市',
          selection: TextSelection.collapsed(offset: 3),
        ),
      );
      tester.testTextInput.hide();
      await tester.pumpAndSettle();
      await tester.tap(find.text('搜索'));
      await tester.pumpAndSettle();
    }

    api.failureStatus = 404;
    tester
        .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
        .clearSnackBars();
    await tester.pumpAndSettle();
    await search();
    expect(api.requests.single, {
      'query': '验收地点',
      'region': '武汉市',
      'allow_baidu': true,
    });
    expect(find.textContaining('当前服务器尚未开通地点搜索'), findsOneWidget);
    expect(_text(tester, '出生地点名称（可选）'), '验收地点');
    expect(_text(tester, '纬度 WGS84（可选）'), isEmpty);
    api.failureStatus = 503;
    tester
        .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
        .clearSnackBars();
    await search();
    expect(find.textContaining('地点搜索服务暂不可用'), findsOneWidget);
    expect(_text(tester, '出生地点名称（可选）'), '验收地点');
    expect(_text(tester, '纬度 WGS84（可选）'), isEmpty);
    expect(_text(tester, '经度 WGS84（可选）'), isEmpty);

    api.failureStatus = null;
    api.coordinateSystem = 'BD09';
    await search();
    expect(_text(tester, '纬度 WGS84（可选）'), isEmpty);
    expect(find.text('测试地点甲'), findsNothing);
    api.coordinateSystem = 'WGS84';
    await search();
    expect(find.text('坐标越界'), findsNothing);
    expect(find.textContaining('院区代表点'), findsOneWidget);
    expect(find.textContaining('© OpenStreetMap'), findsOneWidget);
    expect(find.textContaining('离线样本'), findsOneWidget);
    expect(_text(tester, '纬度 WGS84（可选）'), isEmpty);
    await tester.tap(find.text('测试地点甲'));
    await tester.pumpAndSettle();
    expect(api.requests, [
      {'query': '验收地点', 'region': '武汉市', 'allow_baidu': true},
      {'query': '验收地点', 'region': '武汉市', 'allow_baidu': true},
      {'query': '验收地点', 'region': '武汉市', 'allow_baidu': true},
      {'query': '验收地点', 'region': '武汉市', 'allow_baidu': true},
    ]);
    expect(_text(tester, '出生日期'), '1995-03-21');
    expect(_text(tester, '出生地点名称（可选）'), '测试地点甲（测试路1号）');
    expect(_text(tester, '纬度 WGS84（可选）'), '30.54');
    expect(_text(tester, '经度 WGS84（可选）'), '114.36');
  });

  testWidgets('new draft uses a representative point only after confirmation', (
    tester,
  ) async {
    final api = _PlaceSearchApi()
      ..payload = {
        'coordinate_system': 'WGS84',
        'lookup_provider': 'Baidu',
        'places': [
          {
            'label': '越秀区',
            'city': '广州市',
            'point_kind': 'district',
            'source': 'GeoNames',
            'approximate': true,
            'matched_name': '公开样例医院',
            'lat': 23.12528,
            'lng': 113.26528,
          },
        ],
      };
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(api),
          sessionProvider.overrideWith(_Session.new),
        ],
        child: const MaterialApp(home: NatalRestorationPage()),
      ),
    );
    await tester.pumpAndSettle();
    final place = _field('出生地点名称（可选）');
    await Scrollable.ensureVisible(tester.element(place), alignment: 0.5);
    await tester.pumpAndSettle();
    await tester.enterText(place, '公开样');
    await tester.pumpAndSettle();
    await tester.enterText(place, '公开样例医院');
    await tester.pumpAndSettle();
    final search = find.widgetWithText(OutlinedButton, '搜索并带入坐标');
    await Scrollable.ensureVisible(tester.element(search), alignment: 0.5);
    await tester.pumpAndSettle();
    expect(api.requests, isEmpty);

    await tester.tap(search);
    await tester.pumpAndSettle();
    expect(find.textContaining('百度地点检索'), findsOneWidget);
    await tester.enterText(_field('搜索城市'), '广');
    await tester.pumpAndSettle();
    await tester.enterText(_field('搜索城市'), '广州');
    await tester.pumpAndSettle();
    expect(api.requests, isEmpty);
    await tester.tap(find.text('搜索'));
    await tester.pumpAndSettle();
    expect(api.requests.single, {
      'query': '公开样例医院',
      'region': '广州',
      'allow_baidu': true,
    });

    expect(find.textContaining('约略位置'), findsOneWidget);
    expect(find.textContaining('GeoNames'), findsOneWidget);
    await tester.tap(find.text('越秀区'));
    await tester.pumpAndSettle();
    expect(_text(tester, '出生地点名称（可选）'), '公开样例医院');
    expect(_text(tester, '纬度 WGS84（可选）'), isEmpty);
    await tester.tap(find.text('确认使用代表点'));
    await tester.pumpAndSettle();
    expect(_text(tester, '出生地点名称（可选）'), '广州市越秀区（区县代表点）');
    expect(_text(tester, '纬度 WGS84（可选）'), '23.12528');
    expect(_text(tester, '经度 WGS84（可选）'), '113.26528');

    await tester.enterText(_field('出生日期'), '1995-03-21');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    final save = find.text('保存、计算并持久重读');
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.text('核对本命资料'), findsOneWidget);
    expect(find.textContaining('GeoNames 区县代表点'), findsOneWidget);
    expect(find.textContaining('WGS84 23.12528, 113.26528'), findsOneWidget);
    await tester.tap(find.text('返回修改'));
    await tester.pumpAndSettle();
    expect(api.requests, hasLength(1));

    await tester.ensureVisible(_field('纬度 WGS84（可选）'));
    await tester.enterText(_field('纬度 WGS84（可选）'), '23.125');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.textContaining('GeoNames 区县代表点'), findsNothing);
    expect(find.textContaining('WGS84 23.125, 113.26528'), findsOneWidget);
    await tester.tap(find.text('返回修改'));
    await tester.pumpAndSettle();
  });

  testWidgets(
    'Baidu receives only the confirmed place and leaves the draft intact',
    (tester) async {
      final launched = <Uri>[];
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(_SavedBirthApi()),
            sessionProvider.overrideWith(_Session.new),
          ],
          child: MaterialApp(
            home: NatalRestorationPage(
              launchMap: (uri) async {
                launched.add(uri);
                return false;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final search = find.widgetWithText(OutlinedButton, '打开百度地图查看');
      await tester.ensureVisible(search);
      expect(tester.widget<OutlinedButton>(search).onPressed, isNull);
      await tester.enterText(_field('出生地点名称（可选）'), '北京 公共地点 A&B');
      tester.testTextInput.hide();
      await tester.pumpAndSettle();
      await tester.ensureVisible(search);
      await tester.tap(search);
      await tester.pumpAndSettle();
      expect(find.textContaining('手机的返回键或返回手势'), findsOneWidget);
      expect(find.textContaining('最近任务'), findsOneWidget);
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();
      expect(launched, isEmpty);

      await tester.tap(search);
      await tester.pumpAndSettle();
      await tester.tap(find.text('打开百度地图'));
      await tester.pumpAndSettle();
      expect(launched.single.scheme, 'baidumap');
      expect(launched.single.host, 'map');
      expect(launched.single.path, '/place/search');
      expect(launched.single.queryParameters, {
        'query': '北京 公共地点 A&B',
        'region': '全国',
        'src': 'andr.elitesync.app',
      });
      expect(_text(tester, '出生地点名称（可选）'), '北京 公共地点 A&B');
      expect(find.textContaining('未能打开百度地图'), findsOneWidget);
    },
  );

  testWidgets(
    'explicit import fills saved fields and confirms WGS84 separately',
    (tester) async {
      final api = _SavedBirthApi();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(api),
            sessionProvider.overrideWith(_Session.new),
          ],
          child: const MaterialApp(home: NatalRestorationPage()),
        ),
      );
      await tester.pumpAndSettle();
      expect(api.paths, ['/api/v1/profile/natal']);
      expect(_text(tester, '出生日期'), isEmpty);
      final import = find.text('使用已保存的出生资料');
      await tester.tap(import);
      await tester.pumpAndSettle();
      await tester.tap(find.text('跳过坐标'));
      await tester.pumpAndSettle();
      expect(_text(tester, '出生日期'), '1995-03-21');
      expect(_text(tester, '出生当地时间'), '08:15');
      expect(_text(tester, '出生地点名称（可选）'), '验收地点');
      expect(_text(tester, '纬度 WGS84（可选）'), isEmpty);
      expect(find.text('未知（相关运限不计算）'), findsWidgets);

      await tester.tap(import);
      await tester.pumpAndSettle();
      await tester.tap(find.text('确认使用 WGS84 坐标'));
      await tester.pumpAndSettle();
      expect(_text(tester, '纬度 WGS84（可选）'), '0.0');
      expect(_text(tester, '经度 WGS84（可选）'), '112.57');
      expect(api.paths, [
        '/api/v1/profile/natal',
        '/api/v1/profile/basic',
        '/api/v1/profile/basic',
      ]);
    },
  );

  testWidgets(
    'import never replaces an existing date or pairs a different place',
    (tester) async {
      final api = _SavedBirthApi(savedNatal: true);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(api),
            sessionProvider.overrideWith(_Session.new),
          ],
          child: const MaterialApp(home: NatalRestorationPage()),
        ),
      );
      await tester.pumpAndSettle();
      final place = _field('出生地点名称（可选）');
      await tester.ensureVisible(place);
      await tester.enterText(place, '已手填的其他地点');
      tester.testTextInput.hide();
      final import = find.text('使用已保存的出生资料');
      await tester.ensureVisible(import);
      await tester.pumpAndSettle();
      await tester.tap(import);
      await tester.pumpAndSettle();
      expect(find.text('确认使用 WGS84 坐标'), findsNothing);
      expect(_text(tester, '出生日期'), '1990-01-01');
      expect(_text(tester, '出生地点名称（可选）'), '已手填的其他地点');
      expect(_text(tester, '经度 WGS84（可选）'), isEmpty);
    },
  );
  testWidgets('a delayed import cannot fill the next sign-in session', (
    tester,
  ) async {
    final completion = Completer<void>();
    final api = _SavedBirthApi(delay: completion);
    final container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(api),
        sessionProvider.overrideWith(_Session.new),
      ],
    );
    addTearDown(container.dispose);
    await container.read(sessionProvider.future);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: NatalRestorationPage()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('使用已保存的出生资料'));
    await tester.pump();
    expect(api.paths.last, '/api/v1/profile/basic');
    (container.read(sessionProvider.notifier) as _Session).switchToB();
    completion.complete();
    await tester.pumpAndSettle();
    expect(find.text('登录身份已变化，请重新读取。'), findsOneWidget);
    expect(find.text('确认使用 WGS84 坐标'), findsNothing);
    await tester.tap(find.text('重新读取已保存资料（替换当前输入）'));
    await tester.pumpAndSettle();
    expect(_text(tester, '出生日期'), isEmpty);
    expect(_text(tester, '出生地点名称（可选）'), isEmpty);
  });

  for (final provider in [astroSummaryProvider, astroNatalChartProvider]) {
    test(
      'legacy profile provider discards A request across delayed B token',
      () async {
        final network = _DelayedTokenApi('GET');
        final container = ProviderContainer(
          overrides: [
            apiClientProvider.overrideWithValue(ApiClient(dio: network.dio)),
            sessionProvider.overrideWith(_Session.new),
          ],
        );
        addTearDown(container.dispose);
        addTearDown(() => network.dio.close(force: true));
        await container.read(sessionProvider.future);
        unawaited(
          container
              .read(provider.future)
              .then<void>((_) {}, onError: (Object _) {}),
        );
        await network.entered.future;
        (container.read(sessionProvider.notifier) as _Session).switchToB();
        network.token.complete('fictional-token-B');
        await Future<void>.delayed(const Duration(milliseconds: 30));
        expect(network.dispatchedRequestIds, isNot(contains(1)));
        expect(container.read(sessionProvider).asData?.value.user?.id, 202);
      },
    );
  }
  testWidgets(
    'concurrent edit between POST and GET never rebinds old form to new revision',
    (tester) async {
      final api = _ConcurrentApi();
      final container = ProviderContainer(
        overrides: [
          apiClientProvider.overrideWithValue(api),
          sessionProvider.overrideWith(_Session.new),
        ],
      );
      addTearDown(container.dispose);
      await container.read(sessionProvider.future);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: NatalRestorationPage()),
        ),
      );
      await tester.pumpAndSettle();
      final save = find.text('保存、计算并持久重读');
      await tester.ensureVisible(save);
      await tester.pumpAndSettle();
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(api.writes, 0);
      await tester.tap(find.text('确认保存并计算'));
      await tester.pumpAndSettle();
      expect(api.writes, 1);
      expect(api.reads, 2);
      expect(
        tester
            .widget<FilledButton>(
              find.ancestor(of: save, matching: find.byType(FilledButton)),
            )
            .onPressed,
        isNull,
      );
      expect(find.textContaining('已保存并重新读取。'), findsNothing);
      await tester.drag(find.byType(ListView).first, const Offset(0, 4000));
      await tester.pumpAndSettle();
      expect(find.textContaining('保存后资料已被另一处更新'), findsOneWidget);
      // Only an explicit reload may populate C's inputs and revision.
      await tester.tap(find.text('重新读取已保存资料（替换当前输入）'));
      await tester.pumpAndSettle();
      expect(api.reads, 3);
      final date = tester.widget<TextFormField>(
        find.byType(TextFormField).first,
      );
      expect(date.controller!.text, '1991-02-03');
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('real ziwei schema renders natal transformation beside star', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: NatalRestorationCharts(
              results: {
                'ziwei': {
                  'calculation_status': 'CALCULATED',
                  'oracle_status': 'UNVERIFIED',
                  'palaces': [
                    {
                      'name': '命宫',
                      'heavenly_stem': '甲',
                      'earthly_branch': '子',
                      'major_stars': [
                        {
                          'name': '紫微',
                          'brightness': '庙',
                          'natal_transformation': '禄',
                        },
                      ],
                    },
                  ],
                },
              },
            ),
          ),
        ),
      ),
    );
    expect(find.text('紫微 庙 禄'), findsOneWidget);
    expect(find.textContaining('待核验 (UNVERIFIED)'), findsOneWidget);
  });

  test(
    'GET captured as A does not dispatch with B token after storage await',
    () async {
      final network = _DelayedTokenApi('GET');
      final container = ProviderContainer(
        overrides: [
          apiClientProvider.overrideWithValue(ApiClient(dio: network.dio)),
          sessionProvider.overrideWith(_Session.new),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(() => network.dio.close(force: true));
      await container.read(sessionProvider.future);
      final future = container.read(natalRestorationProvider.future);
      // Attach error handling before invalidating the request's session.
      unawaited(future.then<void>((_) {}, onError: (Object _) {}));
      await network.entered.future;
      (container.read(sessionProvider.notifier) as _Session).switchToB();
      network.token.complete('fictional-token-B');
      // Riverpod may discard the disposed A future when sessionProvider changes.
      // Wait for the real interceptor to process token completion, not that future.
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(network.dispatched, isEmpty);
    },
  );

  for (final sameUser in [false, true]) {
    testWidgets(
      'POST is blocked during token await: ${sameUser ? 'same user new session token' : 'A to B'}',
      (tester) async {
        final network = _DelayedTokenApi('POST');
        final container = ProviderContainer(
          overrides: [
            apiClientProvider.overrideWithValue(ApiClient(dio: network.dio)),
            sessionProvider.overrideWith(_Session.new),
          ],
        );
        addTearDown(container.dispose);
        addTearDown(() => network.dio.close(force: true));
        await container.read(sessionProvider.future);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(home: NatalRestorationPage()),
          ),
        );
        await tester.pumpAndSettle();
        final save = find.text('保存、计算并持久重读');
        await tester.ensureVisible(save);
        await tester.pumpAndSettle();
        await tester.tap(save);
        await tester.pumpAndSettle();
        await tester.tap(find.text('确认保存并计算'));
        for (var i = 0; i < 15 && !network.entered.isCompleted; i++) {
          await tester.pump(const Duration(milliseconds: 10));
        }
        expect(network.entered.isCompleted, isTrue);
        final session = container.read(sessionProvider.notifier) as _Session;
        if (sameUser) {
          session.replaceTokenForA();
        } else {
          session.switchToB();
        }
        await tester.pump();
        network.token.complete(
          sameUser ? 'fictional-refreshed-token-A' : 'fictional-token-B',
        );
        await tester.pumpAndSettle();
        expect(network.dispatched.where((method) => method == 'POST'), isEmpty);
        expect(find.textContaining('已保存并重新读取。'), findsNothing);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}

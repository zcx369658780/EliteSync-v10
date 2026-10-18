import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/astro_natal_chart_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/astro_chart_settings_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_chart_settings_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_profile_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_advanced_profile_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/natal_restoration_charts.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';

class _Session extends SessionNotifier {
  @override
  Future<SessionState> build() async => const SessionState(
    status: AuthStatus.authenticated,
    accessToken: 'fictional-A',
    user: UserSummary(id: 1, phone: 'fictional-A'),
  );
  void switchB() => state = const AsyncData(
    SessionState(
      status: AuthStatus.authenticated,
      accessToken: 'fictional-B',
      user: UserSummary(id: 2, phone: 'fictional-B'),
    ),
  );
}

class _Api extends ApiClient {
  _Api() : super(dio: Dio());
  int posts = 0;
  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async => const NetworkSuccess({'exists': false});
  @override
  Future<NetworkResult<Map<String, dynamic>>> post(
    String path, {
    Object? body,
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    posts++;
    return const NetworkSuccess({'ok': true, 'profile': {}});
  }
}

class _HiddenPrefs extends AstroChartSettingsNotifier {
  @override
  AstroChartDisplayPrefs build() =>
      AstroChartDisplayPrefs.forPreset(AstroChartDisplayPreset.minimal);
}

Map<String, dynamic> _native() => {
  'natal': {
    'status': 'COMPUTED_UNVERIFIED',
    'input': {},
    'settings': {},
    'results': {
      'western': {
        'oracle_status': 'UNVERIFIED',
        'calculation_status': 'CALCULATED',
        'axes': {'status': 'CALCULATED', 'effective_house_system': 'whole'},
        'planets': [
          {'name': 'sun', 'longitude': 20.0, 'latitude': 0.0, 'house': 1},
        ],
        'houses': [
          {'number': 1, 'cusp': 0.0},
        ],
        'aspects': [],
      },
    },
  },
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  testWidgets(
    'selected luck preserves childhood and real palace star mapping',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      // Literal adapter-shaped data; deliberately reordered natal palaces prove
      // arrays are joined by the palace index rather than UI list position.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: NatalRestorationCharts(
                section: 'ziwei',
                displayPrefs: AstroChartDisplayPrefs.forPreset(
                  AstroChartDisplayPreset.minimal,
                ),
                results: {
                  'ziwei': {
                    'calculation_status': 'CALCULATED',
                    'oracle_status': 'UNVERIFIED',
                    'palaces': [
                      {
                        'index': 1,
                        'name': '兄弟',
                        'earthly_branch': '卯',
                        'major_stars': [
                          {'name': '天机'},
                        ],
                        'minor_stars': [
                          {'name': '文曲'},
                        ],
                      },
                      {
                        'index': 0,
                        'name': '命宫',
                        'earthly_branch': '寅',
                        'major_stars': [
                          {'name': '太阳'},
                          {'name': '武曲'},
                        ],
                      },
                    ],
                    'selected_horoscope': {
                      'calculation_status': 'CALCULATED',
                      'oracle_status': 'UNVERIFIED',
                      'target_year': 2001,
                      'reference_date': '2001-07-01',
                      'reference_time': '12:00:00',
                      'decadal': {
                        'index': 1,
                        'name': '童限',
                        'heavenlyStem': '甲',
                        'earthlyBranch': '子',
                        'palaceNames': [
                          '兄弟',
                          '命宫',
                          '父母',
                          '福德',
                          '田宅',
                          '官禄',
                          '仆役',
                          '迁移',
                          '疾厄',
                          '财帛',
                          '子女',
                          '夫妻',
                        ],
                        'mutagen': ['太阳', '武曲', '天机', '文曲'],
                        'stars': [
                          [
                            {'name': '运魁', 'brightness': null},
                          ],
                          [
                            {'name': '运禄', 'brightness': '旺'},
                          ],
                          [],
                          [],
                          [],
                          [],
                          [],
                          [],
                          [],
                          [],
                          [],
                          [],
                        ],
                      },
                      'age': {
                        'index': 0,
                        'name': '小限',
                        'nominalAge': 2,
                        'heavenlyStem': '乙',
                        'earthlyBranch': '丑',
                        'palaceNames': [
                          '命宫',
                          '父母',
                          '福德',
                          '田宅',
                          '官禄',
                          '仆役',
                          '迁移',
                          '疾厄',
                          '财帛',
                          '子女',
                          '夫妻',
                          '兄弟',
                        ],
                        'mutagen': ['天机', '太阳', '武曲', '文曲'],
                      },
                      'yearly': {
                        'index': 0,
                        'name': '流年',
                        'heavenlyStem': '辛',
                        'earthlyBranch': '巳',
                        'palaceNames': [
                          '命宫',
                          '父母',
                          '福德',
                          '田宅',
                          '官禄',
                          '仆役',
                          '迁移',
                          '疾厄',
                          '财帛',
                          '子女',
                          '夫妻',
                          '兄弟',
                        ],
                        'mutagen': ['天机', '太阳', '武曲', '未提供星'],
                        'stars': [
                          [
                            {'name': '流魁'},
                          ],
                          [
                            {'name': '流禄'},
                            {'name': '流马'},
                          ],
                          [],
                          [],
                          [],
                          [],
                          [],
                          [],
                          [],
                          [],
                          [],
                          [],
                        ],
                        'yearlyDecStar': {
                          'suiqian12': [
                            '晦气',
                            '丧门',
                            '贯索',
                            '官符',
                            '小耗',
                            '大耗',
                            '龙德',
                            '白虎',
                            '天德',
                            '吊客',
                            '病符',
                            '岁建',
                          ],
                          'jiangqian12': [
                            '劫煞',
                            '灾煞',
                            '天煞',
                            '指背',
                            '咸池',
                            '月煞',
                            '亡神',
                            '将星',
                            '攀鞍',
                            '岁驿',
                            '息神',
                            '华盖',
                          ],
                        },
                      },
                    },
                  },
                },
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('选定运限'));
      await tester.pumpAndSettle();
      expect(find.text('童限'), findsOneWidget);
      expect(find.text('大限'), findsNothing);
      expect(find.text('小限'), findsOneWidget);
      expect(find.text('流年'), findsOneWidget);
      expect(find.textContaining('参考时刻 12:00:00'), findsOneWidget);
      expect(find.textContaining('目标年份 2001'), findsOneWidget);
      expect(find.textContaining('不代表目标年份全年恒定'), findsOneWidget);
      expect(find.textContaining('待核验 (UNVERIFIED)'), findsOneWidget);
      expect(find.text('独立核验：待核验'), findsOneWidget);
      await tester.tap(find.text('童限'));
      await tester.pumpAndSettle();
      expect(find.text('童限命宫对应 卯宫（本命兄弟）'), findsOneWidget);
      final mutagens = tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data)
          .where((text) => ['太阳化禄', '武曲化权', '天机化科', '文曲化忌'].contains(text))
          .toList();
      expect(mutagens, ['太阳化禄', '武曲化权', '天机化科', '文曲化忌']);
      expect(find.text('本命落宫 寅宫（本命命宫）'), findsNWidgets(2));
      await tester.tap(find.text('宫职与流曜详情'));
      await tester.pumpAndSettle();
      expect(find.text('命宫 → 卯宫（本命兄弟）'), findsOneWidget);
      expect(find.text('流曜：运禄（亮度 旺，待核验）'), findsOneWidget);
      expect(find.text('流曜：运魁'), findsOneWidget);
      await tester.tap(find.text('童限'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('小限'));
      await tester.pumpAndSettle();
      expect(find.text('干支 乙丑；名义年龄 2岁'), findsOneWidget);
      await tester.tap(find.text('小限'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('流年'));
      await tester.pumpAndSettle();
      expect(find.text('本命落宫未提供'), findsOneWidget);
      await tester.tap(find.text('宫职与流曜详情'));
      await tester.pumpAndSettle();
      expect(find.text('父母 → 卯宫（本命兄弟）'), findsOneWidget);
      expect(find.text('流曜：流禄 · 流马\n岁前：丧门\n将前：灾煞'), findsOneWidget);
      expect(find.text('流曜：流魁\n岁前：晦气\n将前：劫煞'), findsOneWidget);
    },
  );
  testWidgets(
    'birth-year luck preserves the returned non-noon reference instant',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: NatalRestorationCharts(
                section: 'ziwei',
                results: {
                  'ziwei': {
                    'calculation_status': 'CALCULATED',
                    'oracle_status': 'UNVERIFIED',
                    'selected_horoscope': {
                      'calculation_status': 'CALCULATED',
                      'oracle_status': 'UNVERIFIED',
                      'target_year': 2024,
                      'reference_date': '2024-12-31',
                      'reference_time': '15:37:42',
                      'reference_policy': 'MID_YEAR_OR_BIRTH_DATE_IF_LATER',
                      'decadal': {
                        'index': 0,
                        'name': '童限',
                        'heavenlyStem': '丙',
                        'earthlyBranch': '寅',
                        'palaceNames': [
                          '命宫',
                          '父母',
                          '福德',
                          '田宅',
                          '官禄',
                          '仆役',
                          '迁移',
                          '疾厄',
                          '财帛',
                          '子女',
                          '夫妻',
                          '兄弟',
                        ],
                        'mutagen': ['天同', '天机', '文昌', '廉贞'],
                        'stars': [
                          [],
                          [],
                          [],
                          [],
                          [],
                          [],
                          [],
                          [],
                          [],
                          [],
                          [],
                          [],
                        ],
                      },
                    },
                  },
                },
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('选定运限'));
      await tester.pumpAndSettle();
      expect(
        find.text('目标年份 2024；参考日 2024-12-31；参考时刻 15:37:42'),
        findsOneWidget,
      );
      expect(find.text('以下运限按参考时刻选取，不代表目标年份全年恒定。'), findsOneWidget);
      expect(find.text('童限'), findsOneWidget);
      expect(find.text('独立核验：待核验'), findsOneWidget);
      expect(find.textContaining('2024-07-01'), findsNothing);
      expect(find.textContaining('12:00:00'), findsNothing);
    },
  );
  testWidgets('unrequested and unknown luck do not invent empty layers', (
    tester,
  ) async {
    for (final status in ['NOT_REQUESTED', 'UNKNOWN']) {
      await tester.pumpWidget(
        MaterialApp(
          key: ValueKey(status),
          home: Scaffold(
            body: SingleChildScrollView(
              child: NatalRestorationCharts(
                section: 'ziwei',
                results: {
                  'ziwei': {
                    'oracle_status': 'UNVERIFIED',
                    'selected_horoscope': {'calculation_status': status},
                  },
                },
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('选定运限'));
      await tester.pumpAndSettle();
      expect(
        find.text(status == 'NOT_REQUESTED' ? '未请求运限计算' : '运限结果未知或尚未就绪'),
        findsOneWidget,
      );
      for (final label in ['童限', '大限', '小限', '流年', '宫职与流曜详情']) {
        expect(find.text(label), findsNothing);
      }
      expect(find.textContaining('待核验 (UNVERIFIED)'), findsOneWidget);
    }
  });
  testWidgets('historical and future time assumptions remain visible', (
    tester,
  ) async {
    for (final data in [
      [
        {'utc_interpretation': 'PRE_1960_CIVIL_LABEL_AS_UT1'},
        '1960年前的时间采用历史模型近似，不能当作精确UTC。',
      ],
      [
        {'accuracy_status': 'FUTURE_ASSUMPTION'},
        '未来时刻按当前闰秒表推算，实际未来闰秒未知。',
      ],
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: NatalRestorationCharts(
                section: 'bazi',
                results: {
                  'bazi': {
                    'time_basis': {'term_time_context': data[0]},
                  },
                },
              ),
            ),
          ),
        ),
      );
      expect(find.text(data[1] as String), findsOneWidget);
    }
  });
  testWidgets('qiyun timestamp keeps the returned local offset', (
    tester,
  ) async {
    // Display contract only; these timestamps are not an accuracy oracle.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: NatalRestorationCharts(
              section: 'bazi',
              results: {
                'bazi': {
                  'yun': {
                    'start_solar_datetime': '2008-05-22T01:05:06',
                    'timestamp_frame': 'UTC+08:00',
                    'start_user_datetime': '2008-05-21T13:05:06-04:00',
                    'forward': false,
                  },
                },
              },
            ),
          ),
        ),
      ),
    );
    expect(find.textContaining('2008-05-21T13:05:06-04:00'), findsOneWidget);
    expect(find.textContaining('2008-05-22T01:05:06'), findsNothing);
  });
  testWidgets(
    'native settings excludes dynamic preview and links persisted calculation editor',
    (tester) async {
      final c = ProviderContainer(
        overrides: [
          astroSummaryProvider.overrideWith((ref) async => _native()),
          astroNatalChartProvider.overrideWith((ref) async => _native()),
          apiClientProvider.overrideWithValue(_Api()),
          sessionProvider.overrideWith(_Session.new),
        ],
      );
      addTearDown(c.dispose);
      await c.read(sessionProvider.future);
      await c.read(astroNatalChartProvider.future);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const AstroChartSettingsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('打开高级时法'), findsNothing);
      await tester.tap(find.text('计算设置（重新计算并保存）'));
      await tester.pumpAndSettle();
      expect(find.text('三盘本命排盘'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '出生日期'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets(
    'calculated native house status omits absent reason and localizes body',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            astroNatalChartProvider.overrideWith((ref) async => _native()),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const AstroNatalChartPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('宫位状态 CALCULATED'), findsOneWidget);
      expect(find.text('太阳'), findsOneWidget);
    },
  );
  final displayVariants = <(String, AstroChartDisplayPrefs, int, int, int)>[
    (
      'sign grid',
      AstroChartDisplayPrefs.defaults().copyWith(showChartSignGridLines: false),
      12,
      0,
      0,
    ),
    (
      'house lines',
      AstroChartDisplayPrefs.defaults().copyWith(showChartHouseLines: false),
      1,
      0,
      0,
    ),
    (
      'aspect lines',
      AstroChartDisplayPrefs.defaults().copyWith(showChartAspectLines: false),
      1,
      0,
      0,
    ),
    (
      'planet connectors',
      AstroChartDisplayPrefs.defaults().copyWith(
        showChartPlanetConnectors: false,
      ),
      2,
      0,
      0,
    ),
    (
      'planet markers',
      AstroChartDisplayPrefs.defaults().copyWith(showChartPlanetMarkers: false),
      0,
      2,
      0,
    ),
    (
      'planet labels',
      AstroChartDisplayPrefs.defaults().copyWith(showChartPlanetLabels: false),
      0,
      0,
      2,
    ),
    (
      'sign labels',
      AstroChartDisplayPrefs.defaults().copyWith(showChartSignLabels: false),
      0,
      0,
      12,
    ),
    (
      'house numbers',
      AstroChartDisplayPrefs.defaults().copyWith(showChartHouseNumbers: false),
      0,
      0,
      1,
    ),
    (
      'center title',
      AstroChartDisplayPrefs.defaults().copyWith(showChartCenterTitle: false),
      0,
      0,
      1,
    ),
    (
      'center subtitle',
      AstroChartDisplayPrefs.defaults().copyWith(
        showChartCenterSubtitle: false,
      ),
      0,
      0,
      1,
    ),
    (
      'center place',
      AstroChartDisplayPrefs.defaults().copyWith(showChartCenterPlace: false),
      0,
      0,
      1,
    ),
  ];
  for (final variant in displayVariants) {
    test('native renderer truly changes canvas output for ${variant.$1}', () {
      TestRecordingCanvas render(AstroChartDisplayPrefs prefs) {
        final canvas = TestRecordingCanvas();
        NatalWheelPainter(
          [
            {'name': 'sun', 'longitude': 20.0},
            {'name': 'moon', 'longitude': 80.0},
          ],
          [
            {'number': 1, 'cusp': 0.0},
          ],
          [
            {'a': 'sun', 'b': 'moon', 'type': 'sextile'},
          ],
          prefs,
          subtitle: 'tropical / whole',
          place: '虚构地点',
        ).paint(canvas, const Size(300, 300));
        return canvas;
      }

      final baseline = render(AstroChartDisplayPrefs.defaults()),
          changed = render(variant.$2);
      int count(TestRecordingCanvas canvas, Symbol method) => canvas.invocations
          .where((i) => i.invocation.memberName == method)
          .length;
      expect(
        count(baseline, #drawLine) - count(changed, #drawLine),
        variant.$3,
      );
      expect(
        count(baseline, #drawCircle) - count(changed, #drawCircle),
        variant.$4,
      );
      expect(
        count(baseline, #drawParagraph) - count(changed, #drawParagraph),
        variant.$5,
      );
    });
  }
  test('native summary cannot dispatch excluded dynamic chart POSTs', () async {
    final api = _Api();
    final c = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(api),
        sessionProvider.overrideWith(_Session.new),
        astroSummaryProvider.overrideWith(
          (ref) async => {
            ..._native(),
            'birthday': '1990-01-01',
            'birth_time': '12:30',
            'birth_lat': 31.0,
            'birth_lng': 121.0,
          },
        ),
      ],
    );
    addTearDown(c.dispose);
    await c.read(sessionProvider.future);
    final value = await c.read(astroAdvancedPreviewProvider.future);
    expect(api.posts, 0);
    expect(value, isNull);
  });
  testWidgets(
    'new native western route obeys hidden summary display preferences',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            astroNatalChartProvider.overrideWith((ref) async => _native()),
            astroChartSettingsProvider.overrideWith(_HiddenPrefs.new),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const AstroNatalChartPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('太阳'), findsNothing);
      expect(find.text('四轴与十二宫'), findsNothing);
      expect(find.text('相位'), findsNothing);
    },
  );
  testWidgets('native western toolbar exposes real calculation settings', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          astroNatalChartProvider.overrideWith((ref) async => _native()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const AstroNatalChartPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byTooltip('计算设置'), findsOneWidget);
  });
  test(
    'legacy dynamic POST is blocked if account changes while reading secure token',
    () async {
      final gate = Completer<String?>(), entered = Completer<void>();
      var dispatches = 0;
      final dio = Dio()
        ..interceptors.add(
          AuthInterceptor(
            accessTokenProvider: () {
              if (!entered.isCompleted) entered.complete();
              return gate.future;
            },
          ),
        );
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (o, h) {
            dispatches++;
            h.resolve(
              Response(
                requestOptions: o,
                statusCode: 200,
                data: {'ok': true, 'profile': {}},
              ),
            );
          },
        ),
      );
      final c = ProviderContainer(
        overrides: [
          apiClientProvider.overrideWithValue(ApiClient(dio: dio)),
          sessionProvider.overrideWith(_Session.new),
          astroSummaryProvider.overrideWith(
            (ref) async => {
              'birthday': '1990-01-01',
              'birth_time': '12:30',
              'birth_lat': 31.0,
              'birth_lng': 121.0,
            },
          ),
        ],
      );
      addTearDown(c.dispose);
      addTearDown(() => dio.close(force: true));
      await c.read(sessionProvider.future);
      unawaited(
        c
            .read(astroAdvancedPreviewProvider.future)
            .then<void>((_) {}, onError: (Object _) {}),
      );
      await entered.future;
      (c.read(sessionProvider.notifier) as _Session).switchB();
      gate.complete('fictional-B');
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(dispatches, 0);
      expect(c.read(sessionProvider).asData?.value.user?.id, 2);
    },
  );
}

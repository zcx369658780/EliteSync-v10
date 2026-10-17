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

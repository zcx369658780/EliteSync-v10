import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/astro_bazi_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/astro_profile_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/astro_ziwei_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/astro_natal_chart_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_profile_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/natal_restoration_charts.dart';

Map<String, dynamic> _profile(String status) => {
  // These contradictory legacy values must never leak into a native projection.
  'bazi': '旧盘占位', 'sun_sign': '旧星座占位',
  'ziwei': {'summary': '旧紫微占位'},
  'natal': {
    'status': status,
    'input_revision': 3,
    'result_revision': 3,
    'input': {
      'civil_date': '1990-01-01',
      'civil_time': '12:30',
      'time_precision': 'minute',
      'timezone': 'Asia/Shanghai',
    },
    'settings': {'zodiac_mode': 'tropical', 'house_system': 'whole'},
    'results': {
      'bazi': {
        'status': 'COMPUTED_UNVERIFIED',
        'oracle_status': 'UNVERIFIED',
        'pillars': {
          'year': {
            'gan_zhi': '甲子',
            'hidden_stems': ['癸'],
          },
          'month': {'gan_zhi': '乙丑'},
          'day': {'gan_zhi': '丙寅'},
          'hour': {'gan_zhi': '丁卯'},
        },
      },
      'ziwei': {
        'calculation_status': 'CALCULATED',
        'oracle_status': 'UNVERIFIED',
        'palaces': [
          {
            'name': '命宫',
            'heavenly_stem': '甲',
            'earthly_branch': '子',
            'major_stars': [
              {'name': '紫微', 'brightness': '庙', 'natal_transformation': '禄'},
            ],
          },
        ],
      },
      'western': {
        'calculation_status': 'CALCULATED',
        'oracle_status': 'UNVERIFIED',
        'planets': [
          {'name': 'sun', 'longitude': 10.0, 'latitude': 0.0, 'house': 1},
        ],
        'houses': [],
      },
    },
  },
};

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  final pages = <String, Widget>{
    'summary': const AstroProfilePage(),
    'bazi': const AstroBaziPage(),
    'ziwei': const AstroZiweiPage(),
    'western': const AstroNatalChartPage(),
  };
  for (final entry in pages.entries) {
    for (final status in ['COMPUTED_UNVERIFIED', 'COMPUTING', 'FAILED']) {
      testWidgets('${entry.key} native $status owns existing detail route', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final profile = _profile(status);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              astroSummaryProvider.overrideWith((ref) async => profile),
              astroNatalChartProvider.overrideWith((ref) async => profile),
            ],
            child: MaterialApp(theme: AppTheme.light, home: entry.value),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('私有本命计算镜像'), findsOneWidget);
        expect(find.textContaining('旧盘占位'), findsNothing);
        expect(find.textContaining('旧紫微占位'), findsNothing);
        if (status == 'COMPUTED_UNVERIFIED') {
          final charts = tester.widget<NatalRestorationCharts>(
            find.byType(NatalRestorationCharts),
          );
          expect(charts.section, entry.key == 'summary' ? null : entry.key);
          expect(
            find.text('八字'),
            entry.key == 'bazi' || entry.key == 'summary'
                ? findsOneWidget
                : findsNothing,
          );
          expect(
            find.text('紫微斗数'),
            entry.key == 'ziwei' || entry.key == 'summary'
                ? findsOneWidget
                : findsNothing,
          );
          expect(
            find.text('西方本命盘'),
            entry.key == 'western' || entry.key == 'summary'
                ? findsOneWidget
                : findsNothing,
          );
        } else {
          expect(find.byType(NatalRestorationCharts), findsNothing);
          expect(find.textContaining('未展示旧盘替代结果'), findsOneWidget);
        }
      });
    }
  }
}

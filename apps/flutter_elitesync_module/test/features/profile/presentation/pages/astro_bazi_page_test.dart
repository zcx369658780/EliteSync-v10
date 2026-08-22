import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/astro_bazi_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_profile_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AstroBaziPage does not synthesize missing detail fields', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          astroSummaryProvider.overrideWith(
            (ref) async => <String, dynamic>{
              'bazi': '甲子 乙丑 丙寅 丁卯',
              'wu_xing': <String, dynamic>{'wood': 2, 'fire': 1},
              'da_yun': const <dynamic>[],
              'liu_nian': const <dynamic>[],
            },
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          home: const AstroBaziPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('甲子'), findsOneWidget);
    expect(find.text('乙丑'), findsOneWidget);
    expect(find.text('丙寅'), findsOneWidget);
    expect(find.text('丁卯'), findsOneWidget);
    expect(find.text('十神'), findsNothing);
    expect(find.text('藏干'), findsNothing);
    expect(find.text('地势'), findsNothing);
    expect(find.text('正印'), findsNothing);
    expect(find.text('比肩'), findsNothing);
    expect(find.text('日主'), findsNothing);
    expect(find.text('伤官'), findsNothing);
    expect(find.text('沐浴'), findsNothing);
    expect(find.text('冠带'), findsNothing);
    expect(find.text('长生'), findsNothing);
    expect(find.text('临官'), findsNothing);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/professional_bazi_grid.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ProfessionalBaziGrid keeps provider-supplied pillar details', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final details = <String, dynamic>{
      'pillars': [
        {
          'gan_zhi': '甲子',
          'shi_shen': '来源年柱',
          'cang_gan': ['来源藏干甲'],
          'di_shi': '来源地势甲',
        },
        {
          'gan_zhi': '乙丑',
          'shi_shen': '来源月柱',
          'cang_gan': ['来源藏干乙'],
          'di_shi': '来源地势乙',
        },
        {
          'gan_zhi': '丙寅',
          'shi_shen': '来源日柱',
          'cang_gan': ['来源藏干丙'],
          'di_shi': '来源地势丙',
        },
        {
          'gan_zhi': '丁卯',
          'shi_shen': '来源时柱',
          'cang_gan': ['来源藏干丁'],
          'di_shi': '来源地势丁',
        },
      ],
    };

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        home: Scaffold(
          body: SizedBox(
            width: 800,
            child: ProfessionalBaziGrid(
              bazi: '甲子 乙丑 丙寅 丁卯',
              baziDetails: details,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('来源年柱'), findsOneWidget);
    expect(find.text('来源藏干丙'), findsOneWidget);
    expect(find.text('来源地势丁'), findsOneWidget);
    expect(find.text('十神'), findsWidgets);
    expect(find.text('藏干'), findsWidgets);
    expect(find.text('地势'), findsWidgets);
  });
}

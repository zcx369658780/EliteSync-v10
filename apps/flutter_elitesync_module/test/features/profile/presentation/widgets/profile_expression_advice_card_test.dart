import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_summary_entity.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/professional_bazi_grid.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/profile_expression_advice_card.dart';

void main() {
  testWidgets('ProfileExpressionAdviceCard renders 5.8 display-only contract', (
    tester,
  ) async {
    const summary = ProfileSummaryEntity(
      nickname: 'test1',
      birthday: '1998-01-01',
      birthTime: '10:30',
      birthPlace: '北京动物园',
      birthLat: 39.947735,
      birthLng: 116.343376,
      city: '南阳',
      target: 'dating',
      verified: true,
      moderationStatus: 'normal',
      moderationNote: null,
      completion: 0.76,
      tags: ['生日已确认', '婚恋目标已确认', '本地草稿待确认'],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        home: const Scaffold(
          body: SingleChildScrollView(
            child: ProfileExpressionAdviceCard(summary: summary),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('我的慢约会表达建议'), findsOneWidget);
    expect(find.text('真实感'), findsOneWidget);
    expect(find.text('表达清晰度'), findsOneWidget);
    expect(find.text('慢约会适配度'), findsOneWidget);
    expect(find.text('开场友好度'), findsOneWidget);
    expect(find.text('资料展示建议'), findsOneWidget);
    expect(find.text('慢约会友好表达'), findsOneWidget);
    expect(find.text('可以补充什么'), findsOneWidget);
    expect(find.text('帮我整理一句表达 · 敬请期待'), findsOneWidget);
    expect(
      find.text('以上内容仅为自我表达参考，不会写入资料，不会改变星盘或匹配算法，也不会自动修改个人资料。'),
      findsOneWidget,
    );
  });

  testWidgets('ProfessionalBaziGrid displays backend hidden_stems list', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrapBaziGrid(
        baziDetails: {
          'pillars': [
            {
              'index': 0,
              'label': 'year',
              'gan_zhi': '己巳',
              'gan': '己',
              'zhi': '巳',
              'hidden_stems': ['丙', '庚', '戊'],
            },
            {'index': 1, 'label': 'month', 'gan_zhi': '壬申'},
            {'index': 2, 'label': 'day', 'gan_zhi': '戊辰'},
            {'index': 3, 'label': 'hour', 'gan_zhi': '己未'},
          ],
        },
      ),
    );

    expect(find.text('丙 / 庚 / 戊'), findsOneWidget);
  });

  testWidgets('ProfessionalBaziGrid converts legacy cang_gan string', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrapBaziGrid(
        baziDetails: {
          'pillars': [
            {'index': 0, 'label': 'year', 'gan_zhi': '己巳'},
            {
              'index': 1,
              'label': 'month',
              'gan_zhi': '壬申',
              'gan': '壬',
              'zhi': '申',
              'cang_gan': '庚壬戊',
            },
            {'index': 2, 'label': 'day', 'gan_zhi': '戊辰'},
            {'index': 3, 'label': 'hour', 'gan_zhi': '己未'},
          ],
        },
      ),
    );

    expect(find.text('庚 / 壬 / 戊'), findsOneWidget);
  });

  testWidgets(
    'ProfessionalBaziGrid omits hidden-stem row when all are missing',
    (tester) async {
      await tester.pumpWidget(
        _wrapBaziGrid(
          baziDetails: {
            'pillars': [
              {'index': 0, 'label': 'year', 'gan_zhi': '己巳'},
              {'index': 1, 'label': 'month', 'gan_zhi': '壬申'},
              {
                'index': 2,
                'label': 'day',
                'gan_zhi': '戊辰',
                'gan': '戊',
                'zhi': '辰',
              },
              {'index': 3, 'label': 'hour', 'gan_zhi': '己未'},
            ],
          },
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('藏干'), findsNothing);
    },
  );

  testWidgets('ProfessionalBaziGrid keeps dash fallback in a mixed row', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrapBaziGrid(
        baziDetails: {
          'pillars': [
            {
              'index': 0,
              'label': 'year',
              'gan_zhi': '己巳',
              'hidden_stems': ['丙', '庚', '戊'],
            },
            {'index': 1, 'label': 'month', 'gan_zhi': '壬申'},
            {'index': 2, 'label': 'day', 'gan_zhi': '戊辰'},
            {'index': 3, 'label': 'hour', 'gan_zhi': '己未'},
          ],
        },
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('藏干'), findsWidgets);
    expect(find.text('丙 / 庚 / 戊'), findsOneWidget);
    expect(find.text('-'), findsWidgets);
  });
}

Widget _wrapBaziGrid({required Map<String, dynamic> baziDetails}) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 360,
          child: ProfessionalBaziGrid(
            bazi: '己巳 壬申 戊辰 己未',
            baziDetails: baziDetails,
          ),
        ),
      ),
    ),
  );
}

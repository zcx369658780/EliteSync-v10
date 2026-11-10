import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/natal_restoration_charts.dart';

void main() {
  testWidgets('named sidereal and mean apogee definitions stay visible', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: NatalRestorationCharts(
              section: 'western',
              results: {
                'western': {
                  'effective_profile': {'zodiac_mode': 'sidereal'},
                  'sidereal_reference': {
                    'id': 'CRC1956-23.25-true-frame-anchor-IAU2000A-v1',
                    'display_name_zh': 'CRC1956 自定义恒星黄道（非官方 Lahiri）',
                  },
                  'planets': [
                    {'name': 'mean_lilith', 'longitude': 20.0, 'latitude': 0.0},
                  ],
                },
              },
            ),
          ),
        ),
      ),
    );
    expect(find.text('CRC1956 自定义恒星黄道（非官方 Lahiri）'), findsOneWidget);
    expect(find.textContaining('平均月球远地点；非瞬时真实远地点'), findsOneWidget);
  });

  testWidgets('qiyun retained seconds do not imply second accuracy', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: NatalRestorationCharts(
              section: 'bazi',
              results: {
                'bazi': {
                  'yun': {
                    'start_user_datetime': '2028-02-29T00:00:59+08:00',
                    'calendar_policy': {
                      'id':
                          'lunar-php-1.4.0-sequential-gregorian-clamp-utc8-v1',
                    },
                  },
                },
              },
            ),
          ),
        ),
      ),
    );
    expect(find.textContaining('兼容公历换算；保留分秒不代表秒级准确性'), findsOneWidget);
  });
}

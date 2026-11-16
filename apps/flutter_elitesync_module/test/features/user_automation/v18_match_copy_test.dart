import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/features/slow_dating_v1012/journey_components.dart';
import 'b3_journey_overview_test.dart' show mount, stateFor;
import '../slow_dating_v1012/journey_pages_test.dart' show FakeApi;
import 'package:flutter_elitesync_module/features/relationships_v1011/session_bound_page.dart';

void main() {
  test(
    'round and preparation labels use product language and keep unknown',
    () {
      expect(journeyStateLabel('NO_CANDIDATE'), '本轮暂无匹配');
      expect(preparationReasonLabel('eligible'), '准备已完成');
      expect(journeyStateLabel('future-code'), '状态暂未确认');
    },
  );

  test('known business failures retain a useful recovery action', () {
    expect(
      relationshipErrorLabel('enable Buddy requests first'),
      '请先开启搭子请求，再继续操作',
    );
    expect(relationshipErrorLabel('enable Buddy first'), '请先开启搭子请求，再继续操作');
    expect(relationshipErrorLabel('stale revision'), '内容已更新，请刷新后再试');
    expect(relationshipErrorLabel('opaque future error'), '暂时无法完成，请刷新重试');
  });

  testWidgets('restricted and unknown account projections remain distinct', (
    tester,
  ) async {
    for (final code in ['UNAVAILABLE', 'future-code']) {
      await mount(
        tester,
        FakeApi((method, path, body) async {
          final state = stateFor(1);
          (state['domains'] as Map)['account'] = {'code': code};
          return state;
        }),
      );
      expect(
        find.text(code == 'UNAVAILABLE' ? '当前账号受限，请查看账号状态' : '账号状态暂时无法确认'),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets(
    'Match has visible automation and history without API diagnostics',
    (tester) async {
      await mount(
        tester,
        FakeApi((method, path, body) async {
          if (path == '/user-state') return stateFor(1);
          if (path == '/journey') return {'proposal': <String, dynamic>{}};
          return <String, dynamic>{};
        }),
        detailed: true,
      );
      expect(find.text('匹配'), findsOneWidget);
      expect(find.text('持续参与与自动化'), findsWidgets);
      expect(find.text('匹配记录'), findsOneWidget);
      expect(find.textContaining('来源 /'), findsNothing);
      expect(find.textContaining('B2 /'), findsNothing);
      expect(find.text('我的关系旅程'), findsNothing);
    },
  );
}

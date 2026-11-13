import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/features/slow_dating_v1012/matching_input_page.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

SessionState inputSession(int id) => SessionState(
  status: AuthStatus.authenticated,
  accessToken: 'input-fixture-$id',
  user: UserSummary(id: id, phone: ''),
);

class TestSession extends SessionNotifier {
  @override
  SessionState build() => inputSession(1);

  void change(int id) => state = AsyncData(inputSession(id));
}

class FakeApi extends RelationshipApi {
  FakeApi(this.handler) : super(ApiClient(dio: Dio()));

  final Future<Map<String, dynamic>> Function(
    String,
    String,
    Map<String, dynamic>?,
  )
  handler;

  @override
  Future<Map<String, dynamic>> call(
    String method,
    String path, [
    Map<String, dynamic>? body,
  ]) => handler(method, path, body);
}

Future<void> mount(
  WidgetTester tester,
  Widget page,
  FakeApi api, {
  TestSession? notifier,
}) async {
  tester.view.physicalSize = const Size(900, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sessionProvider.overrideWith(() => notifier ?? TestSession()),
        relationshipApiProvider.overrideWithValue(api),
      ],
      child: MaterialApp(home: page),
    ),
  );
  await tester.pumpAndSettle();
}

Map<String, dynamic> matchingInput({
  String? ageMode = 'adult_any',
  String occupation = '原职业',
}) => {
  'revision': 3,
  'confirmed': true,
  'birthday': '1995-06-15',
  'gender': 'female',
  'city_key': '上海',
  'legacy_city': '上海市',
  'relationship_goal': 'marriage',
  'age_mode': ageMode,
  'age_min': null,
  'age_max': null,
  'region_mode': 'same_city',
  'height_cm': 168,
  'education': 'bachelor',
  'occupation': occupation,
  'marital_history': 'never_married',
  'children_status': 'none',
  'children_intention': 'unsure',
};

Future<void> saveInput(WidgetTester tester) async {
  final save = find.byKey(const Key('matching-input-save'));
  await tester.ensureVisible(save);
  await tester.tap(save);
  await tester.pumpAndSettle();
}

Future<void> selectChoice(
  WidgetTester tester,
  String key,
  String? currentValue,
  String label,
) async {
  final field = find.byKey(ValueKey('$key-${currentValue ?? ''}'));
  await tester.ensureVisible(field);
  await tester.tap(field);
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

String fieldText(WidgetTester tester, String key) =>
    tester.widget<TextFormField>(find.byKey(ValueKey(key))).controller!.text;

void main() {
  testWidgets('save failure retains input and permits retry on the same page', (
    tester,
  ) async {
    final writes = <Map<String, dynamic>>[];
    await mount(
      tester,
      const MatchingInputPage(),
      FakeApi((method, path, body) async {
        expect(path, '/matching-inputs');
        if (method == 'PUT') {
          writes.add(Map<String, dynamic>.from(body!));
          throw const RelationshipFailure('保存暂未完成，请重试');
        }
        return matchingInput();
      }),
    );
    await tester.enterText(find.byKey(const Key('matching-city')), '北京');
    await tester.ensureVisible(find.byKey(const Key('matching-occupation')));
    await tester.enterText(find.byKey(const Key('matching-occupation')), '新职业');
    await saveInput(tester);

    expect(find.text('我的匹配输入'), findsOneWidget);
    expect(find.byKey(const Key('server-error')), findsOneWidget);
    expect(fieldText(tester, 'matching-city'), '北京');
    expect(fieldText(tester, 'matching-occupation'), '新职业');
    expect(writes.single['city_key'], '北京');
    expect(writes.single['revision'], 3);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('matching-input-save')))
          .onPressed,
      isNotNull,
    );
    await saveInput(tester);
    expect(writes, hasLength(2));
    expect(writes.last, writes.first);
  });

  testWidgets(
    'unselected age is distinct from explicit adult range without limits',
    (tester) async {
      var current = matchingInput(ageMode: null)..['confirmed'] = false;
      final writes = <Map<String, dynamic>>[];
      await mount(
        tester,
        const MatchingInputPage(),
        FakeApi((method, path, body) async {
          expect(path, '/matching-inputs');
          if (method == 'PUT') {
            writes.add(Map<String, dynamic>.from(body!));
            current = {...body, 'revision': 4, 'confirmed': true};
          }
          return current;
        }),
      );
      await saveInput(tester);
      expect(writes, isEmpty);
      expect(find.text('请明确选择'), findsOneWidget);

      await selectChoice(tester, 'matching-age-mode', null, '成年范围不限（18周岁起）');
      await saveInput(tester);
      expect(writes, hasLength(1));
      expect(writes.single['age_mode'], 'adult_any');
      expect(writes.single['age_min'], isNull);
      expect(writes.single['age_max'], isNull);
      expect(writes.single['confirm'], isTrue);
      expect(find.text('当前输入已确认'), findsOneWidget);
    },
  );

  testWidgets(
    'optional values can be cleared and server readback stays blank',
    (tester) async {
      var current = matchingInput();
      Map<String, dynamic>? sent;
      await mount(
        tester,
        const MatchingInputPage(),
        FakeApi((method, path, body) async {
          expect(path, '/matching-inputs');
          if (method == 'PUT') {
            sent = Map<String, dynamic>.from(body!);
            current = {...body, 'revision': 4, 'confirmed': true};
          }
          return current;
        }),
      );
      await tester.ensureVisible(find.byKey(const Key('matching-height')));
      await tester.enterText(find.byKey(const Key('matching-height')), '');
      await tester.ensureVisible(find.byKey(const Key('matching-occupation')));
      await tester.enterText(
        find.byKey(const Key('matching-occupation')),
        '  ',
      );
      await selectChoice(tester, 'matching-education', 'bachelor', '未填写 / 清除');
      await saveInput(tester);

      expect(sent, isNotNull);
      expect(sent!['height_cm'], isNull);
      expect(sent!['occupation'], isNull);
      expect(sent!['education'], isNull);
      expect(fieldText(tester, 'matching-height'), isEmpty);
      expect(fieldText(tester, 'matching-occupation'), isEmpty);
      expect(find.byKey(const ValueKey('matching-education-')), findsOneWidget);
    },
  );

  testWidgets(
    'account change clears draft and ignores the previous late save',
    (tester) async {
      final notifier = TestSession();
      final pendingSave = Completer<Map<String, dynamic>>();
      var reads = 0;
      await mount(
        tester,
        const MatchingInputPage(),
        FakeApi((method, path, body) async {
          expect(path, '/matching-inputs');
          if (method == 'PUT') return pendingSave.future;
          reads++;
          return matchingInput(occupation: reads == 1 ? '账号一职业' : '账号二职业');
        }),
        notifier: notifier,
      );
      await tester.ensureVisible(find.byKey(const Key('matching-occupation')));
      await tester.enterText(
        find.byKey(const Key('matching-occupation')),
        '账号一未保存输入',
      );
      final save = find.byKey(const Key('matching-input-save'));
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pump();
      notifier.change(2);
      await tester.pumpAndSettle();
      expect(fieldText(tester, 'matching-occupation'), '账号二职业');

      pendingSave.complete(matchingInput(occupation: '账号一迟到保存结果'));
      await tester.pumpAndSettle();
      expect(reads, 2);
      expect(fieldText(tester, 'matching-occupation'), '账号二职业');
      expect(find.text('账号一未保存输入'), findsNothing);
      expect(find.text('账号一迟到保存结果'), findsNothing);
      expect(find.byKey(const Key('matching-input-saved')), findsNothing);
    },
  );
}

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/features/slow_dating_v1012/slow_dating_journey_page.dart';
import 'package:flutter_elitesync_module/features/slow_dating_v1012/formal_relationship_page.dart';
import 'package:flutter_elitesync_module/features/slow_dating_v1012/relationship_privacy_page.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

SessionState session(int id) => SessionState(
  status: AuthStatus.authenticated,
  accessToken: 'synthetic-$id',
  user: UserSummary(id: id, phone: ''),
);

class TestSession extends SessionNotifier {
  @override
  Future<SessionState> build() async => session(1);
  void change(int id) => state = AsyncData(session(id));
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

Map<String, dynamic> journey({
  bool eligible = true,
  String state = 'NOT_ENROLLED',
  Map<String, dynamic>? proposal,
}) => {
  'readiness': {
    'eligible': eligible,
    'reasons': eligible ? [] : ['问卷尚未完成'],
    'operational_review': 'approved',
    'showcase': 'ready',
  },
  'participation': {
    'state': state,
    'revision': 7,
    'generation': 2,
    'intent': '长期相处',
  },
  'round': {
    'data': {'state': 'no_candidate'},
  },
  'proposal': proposal,
  'identity': {'status': 'PROVIDER_NOT_CONFIGURED', 'test_only': false},
};
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

void main() {
  testWidgets(
    'resume saves own value and blank clears without changing audience',
    (tester) async {
      final sent = <Map<String, dynamic>>[];
      String? resume = '本人已有履历';
      await mount(
        tester,
        const RelationshipPrivacyPage(),
        FakeApi((method, path, body) async {
          if (method == 'PUT') {
            expect(path, '/privacy/resume');
            sent.add(Map<String, dynamic>.from(body!));
            resume = body['resume'] as String?;
          }
          return {
            'revision': 3,
            'fields': {'resume': 'SELF'},
            'self_profile': {'resume': resume},
          };
        }),
      );
      expect(find.text('本人已有履历'), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('privacy-resume')),
        '我填写的新履历',
      );
      await tester.tap(find.byKey(const Key('privacy-resume-save')));
      await tester.pumpAndSettle();
      expect(sent.single, {'resume': '我填写的新履历'});
      expect(find.text('我填写的新履历'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('privacy-resume')), '  ');
      await tester.tap(find.byKey(const Key('privacy-resume-save')));
      await tester.pumpAndSettle();
      expect(sent.last, {'resume': null});
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('privacy-resume')))
            .controller!
            .text,
        isEmpty,
      );
    },
  );

  testWidgets(
    'resume draft and late response clear on account switch even same revision',
    (tester) async {
      final notifier = TestSession();
      final pending = Completer<Map<String, dynamic>>();
      var reads = 0;
      await mount(
        tester,
        const RelationshipPrivacyPage(),
        FakeApi((method, path, body) async {
          reads++;
          if (reads == 2) return pending.future;
          return {
            'revision': 3,
            'self_profile': {'resume': reads == 1 ? '账号一履历' : '账号二履历'},
          };
        }),
        notifier: notifier,
      );
      await tester.enterText(
        find.byKey(const Key('privacy-resume')),
        '账号一未保存草稿',
      );
      await tester.tap(find.byTooltip('刷新'));
      await tester.pump();
      notifier.change(2);
      await tester.pumpAndSettle();
      pending.complete({
        'revision': 3,
        'self_profile': {'resume': '账号一晚响应'},
      });
      await tester.pumpAndSettle();
      expect(find.text('账号二履历'), findsOneWidget);
      expect(find.text('账号一未保存草稿'), findsNothing);
      expect(find.text('账号一晚响应'), findsNothing);
    },
  );

  testWidgets(
    'readiness fallback displays reason and missing answers without making showcase mandatory',
    (tester) async {
      await mount(
        tester,
        const SlowDatingJourneyPage(),
        FakeApi(
          (method, path, body) async => journey()
            ..['readiness'] = {
              'eligible': true,
              'reason_code': 'eligible',
              'missing_answer_count': 0,
              'showcase': 'not_provided',
            },
        ),
      );
      expect(find.text('准备提示：已完成当前必要准备，可自行决定是否参与'), findsOneWidget);
      expect(find.text('尚缺必要问卷答案：0'), findsOneWidget);
      expect(
        tester
            .widget<OutlinedButton>(
              find.byKey(const ValueKey('participation-opt_in')),
            )
            .onPressed,
        isNotNull,
      );
      expect(find.textContaining('Showcase仅作信息展示'), findsOneWidget);
    },
  );

  testWidgets(
    'intent draft uses server revision; ineligible opt-in remains disabled',
    (tester) async {
      Map<String, dynamic>? sent;
      await mount(
        tester,
        const SlowDatingJourneyPage(),
        FakeApi((method, path, body) async {
          if (method == 'PUT') sent = body;
          return journey(eligible: false);
        }),
      );
      expect(
        tester
            .widget<OutlinedButton>(
              find.byKey(const ValueKey('participation-opt_in')),
            )
            .onPressed,
        isNull,
      );
      await tester.enterText(find.byKey(const Key('journey-intent')), '先了解彼此');
      await tester.tap(find.text('保存草稿'));
      await tester.pumpAndSettle();
      expect(sent, {'action': 'draft', 'revision': 7, 'intent': '先了解彼此'});
      expect(find.textContaining('本轮暂无候选'), findsOneWidget);
      expect(find.textContaining('运营审核不等于实人核验'), findsOneWidget);
    },
  );

  testWidgets(
    'proposal independent decision posts identity revision and idempotency key',
    (tester) async {
      Map<String, dynamic>? sent;
      String? decisionPath;
      await mount(
        tester,
        const SlowDatingJourneyPage(),
        FakeApi((method, path, body) async {
          if (method == 'POST') {
            sent = body;
            decisionPath = path;
          }
          return journey(
            proposal: {
              'id': 22,
              'revision': 4,
              'state': 'PENDING',
              'peer_id': 2,
              'showcase': {'public_id': 'ES-2'},
              'explanation': {
                'categories': ['价值观'],
                'source': '本人问卷类别',
                'uncertainty': '有局限',
                'non_goals': '不判定爱情',
              },
            },
          );
        }),
      );
      await tester.ensureVisible(find.byKey(const ValueKey('proposal-accept')));
      await tester.tap(find.byKey(const ValueKey('proposal-accept')));
      await tester.pumpAndSettle();
      expect(decisionPath, '/journey/proposals/22/decision');
      expect(sent?['action'], 'accept');
      expect(sent?['revision'], 4);
      expect(sent?['idempotency_key'], isA<String>());
      expect(find.text('分别申请连接（CN）与消息同意（MC）'), findsNothing);
    },
  );

  testWidgets(
    'ended proposal cannot expose mutation controls or auto-open chat',
    (tester) async {
      await mount(
        tester,
        const SlowDatingJourneyPage(),
        FakeApi(
          (method, path, body) async => journey(
            proposal: {
              'id': 22,
              'revision': 9,
              'state': 'EXPIRED',
              'peer_id': 2,
            },
          ),
        ),
      );
      expect(find.byKey(const ValueKey('proposal-accept')), findsNothing);
      expect(find.text('分别申请连接（CN）与消息同意（MC）'), findsNothing);
    },
  );

  testWidgets('late old account journey response and intent are discarded', (
    tester,
  ) async {
    final notifier = TestSession();
    final pending = Completer<Map<String, dynamic>>();
    var reads = 0;
    await mount(
      tester,
      const SlowDatingJourneyPage(),
      FakeApi((method, path, body) async {
        reads++;
        if (reads == 2) return pending.future;
        return journey()
          ..['participation'] = {
            'state': 'NOT_ENROLLED',
            'revision': reads,
            'generation': 1,
            'intent': reads == 1 ? '账号一意图' : '账号二意图',
          };
      }),
      notifier: notifier,
    );
    await tester.tap(find.byTooltip('刷新'));
    await tester.pump();
    notifier.change(2);
    await tester.pumpAndSettle();
    pending.complete(
      journey()..['participation'] = {'revision': 99, 'intent': '旧账号晚响应'},
    );
    await tester.pumpAndSettle();
    expect(find.text('账号二意图'), findsOneWidget);
    expect(find.text('账号一意图'), findsNothing);
    expect(find.text('旧账号晚响应'), findsNothing);
  });

  testWidgets(
    'formal ending remains available without identity provider and terminal cannot resume',
    (tester) async {
      Map<String, dynamic>? sent;
      await mount(
        tester,
        const FormalRelationshipPage(),
        FakeApi((method, path, body) async {
          if (method == 'POST') sent = body;
          return {
            'identity': {'status': 'PROVIDER_NOT_CONFIGURED'},
            'relationships': [
              {
                'id': 9,
                'peer_id': 2,
                'state': 'SUSPENDED_REVERIFY',
                'revision': 6,
                'confirmed_me': false,
                'confirmed_peer': false,
                'test_only': true,
              },
              {
                'id': 10,
                'peer_id': 3,
                'state': 'ENDED',
                'revision': 2,
                'test_only': true,
              },
            ],
          };
        }),
      );
      expect(find.byKey(const ValueKey('formal-10-resume')), findsNothing);
      await tester.ensureVisible(find.byKey(const ValueKey('formal-9-end')));
      await tester.tap(find.byKey(const ValueKey('formal-9-end')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('确认'));
      await tester.pumpAndSettle();
      expect(sent?['action'], 'end');
      expect(sent?['revision'], 6);
      expect(sent?['idempotency_key'], isNotEmpty);
      expect(find.text('TEST_ONLY · 合成开发关系，非真实身份核验'), findsNWidgets(2));
    },
  );

  testWidgets(
    'failed peer reread clears previously authorized private fields',
    (tester) async {
      var reads = 0;
      await mount(
        tester,
        const RelationshipPrivacyPage(peerId: 2),
        FakeApi((method, path, body) async {
          if (path == '/privacy') {
            return {
              'revision': 3,
              'fields': {'birthday': 'SELF'},
            };
          }
          if (++reads > 1) throw const RelationshipFailure('分享授权已撤回');
          return {
            'projection': {'public_id': 'ES-2', 'resume': '曾授权的履历'},
          };
        }),
      );
      await tester.tap(find.text('读取对方当前授权资料'));
      await tester.pumpAndSettle();
      expect(find.textContaining('曾授权的履历'), findsOneWidget);
      await tester.tap(find.text('读取对方当前授权资料'));
      await tester.pumpAndSettle();
      expect(find.textContaining('曾授权的履历'), findsNothing);
      expect(find.textContaining('分享授权已撤回'), findsOneWidget);
    },
  );
}

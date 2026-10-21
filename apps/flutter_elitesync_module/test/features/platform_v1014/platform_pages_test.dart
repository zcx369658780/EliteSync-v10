import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/features/platform_v1014/platform_events_page.dart';
import 'package:flutter_elitesync_module/features/platform_v1014/safety_cases_page.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

SessionState _session(int id) => SessionState(
  status: AuthStatus.authenticated,
  accessToken: 'synthetic-widget-platform-$id',
  user: UserSummary(id: id, phone: ''),
);

class _Sessions extends SessionNotifier {
  @override
  Future<SessionState> build() async => _session(1);
  void change(int id) => state = AsyncData(_session(id));
}

class _Api extends RelationshipApi {
  _Api(this.handle) : super(ApiClient(dio: Dio()));
  final Future<Map<String, dynamic>> Function(
    String,
    String,
    Map<String, dynamic>?,
  )
  handle;

  @override
  Future<Map<String, dynamic>> call(
    String method,
    String path, [
    Map<String, dynamic>? body,
  ]) => handle(method, path, body);
}

Future<void> _mount(
  WidgetTester tester,
  Widget page,
  _Api api, {
  _Sessions? sessions,
  bool settle = true,
}) async {
  tester.view.physicalSize = const Size(900, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sessionProvider.overrideWith(() => sessions ?? _Sessions()),
        relationshipApiProvider.overrideWithValue(api),
      ],
      child: MaterialApp(home: page),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pump(const Duration(milliseconds: 20));
  }
}

Map<String, dynamic> _event({
  String title = '合成活动一',
  List<String> actions = const [],
  String registrationState = 'INVITED',
}) => {
  'id': 'event-one',
  'revision': 7,
  'title': title,
  'city': '测试城',
  'venue': '合成公共场所',
  'state': 'OPEN',
  'start_at': '2026-10-22T01:00:00Z',
  'end_at': '2026-10-22T03:00:00Z',
  'capacity': 2,
  'marker': 'DEV_SYNTHETIC_EVENT',
  'budget_internal': 'MUST_NOT_RENDER',
  'allowed_actions': actions,
  'registration': {
    'id': 'registration-a',
    'state': registrationState,
    'revision': 2,
    'wait_order': 3,
    'attendance': 'UNVERIFIED',
  },
  'participants': registrationState == 'INVITED'
      ? <Map<String, dynamic>>[]
      : [
          {'registration_id': 'registration-b', 'label': '受控参与者B'},
        ],
};

void main() {
  testWidgets(
    'current allowed actions are required and internal costs stay hidden',
    (tester) async {
      await _mount(
        tester,
        const PlatformEventsPage(),
        _Api(
          (method, path, body) async => {
            'items': [_event()],
          },
        ),
      );
      expect(find.text('合成活动一'), findsOneWidget);
      expect(
        find.text('DEV_SYNTHETIC_EVENT · NOT_REAL_BOOKING'),
        findsOneWidget,
      );
      expect(find.text('主动报名'), findsNothing);
      expect(find.text('取消本人参与'), findsNothing);
      expect(find.text('MUST_NOT_RENDER'), findsNothing);
    },
  );

  testWidgets(
    'voluntary apply sends current event revision and no actor authority',
    (tester) async {
      Map<String, dynamic>? sent;
      var applied = false;
      await _mount(
        tester,
        const PlatformEventsPage(),
        _Api((method, path, body) async {
          if (method == 'POST') {
            expect(path, '/platform-events/event-one/actions');
            sent = body;
            applied = true;
            return {'state': 'APPLIED'};
          }
          return {
            'items': [
              _event(
                actions: applied ? ['cancel'] : ['apply'],
                registrationState: applied ? 'APPLIED' : 'INVITED',
              ),
            ],
          };
        }),
      );
      await tester.tap(find.text('主动报名'));
      await tester.pumpAndSettle();
      expect(find.text('报名不等于已确认席位；名额和候补状态以服务器回读为准。'), findsOneWidget);
      await tester.tap(find.text('确认'));
      await tester.pumpAndSettle();
      expect(sent?['action'], 'apply');
      expect(sent?['revision'], 7);
      expect(sent?['idempotency_key'], isNotEmpty);
      expect(sent?.keys.toSet(), {'action', 'revision', 'idempotency_key'});
      expect(find.text('已主动报名，等待名额确认'), findsOneWidget);
      expect(find.text('主动报名'), findsNothing);
    },
  );

  testWidgets(
    'waitlist is not a confirmed seat and voluntary attendance stays unverified',
    (tester) async {
      final event = _event(
        registrationState: 'WAITLISTED',
        actions: ['cancel'],
      );
      event['registration']['attendance'] = 'SELF_REPORTED';
      await _mount(
        tester,
        const PlatformEventsPage(),
        _Api(
          (method, path, body) async => {
            'items': [event],
          },
        ),
      );
      expect(find.text('正在候补，尚未确认席位'), findsOneWidget);
      expect(find.text('服务端候补序号：3'), findsOneWidget);
      expect(find.text('本人到场声明：SELF_REPORTED / UNVERIFIED'), findsOneWidget);
      expect(find.text('主动报名'), findsNothing);
      expect(find.text('自愿测试到场声明'), findsNothing);
    },
  );

  testWidgets(
    'restricted owner can cancel a current minimal exit ticket without event details',
    (tester) async {
      Map<String, dynamic>? sent;
      var cancelled = false;
      await _mount(
        tester,
        const PlatformEventsPage(),
        _Api((method, path, body) async {
          if (method == 'POST') {
            expect(path, '/platform-events/event-one/actions');
            sent = body;
            cancelled = true;
            return {
              'id': 'event-one',
              'revision': 10,
              'state': 'CANCELLED_BY_USER',
            };
          }
          expect(path, '/platform-events');
          return {
            'items': <Map<String, dynamic>>[],
            'exit_tickets': cancelled
                ? <Map<String, dynamic>>[]
                : [
                    {
                      'id': 'event-one',
                      'revision': 9,
                      'registration_state': 'CONFIRMED',
                      'allowed_actions': ['cancel'],
                    },
                  ],
          };
        }),
      );
      expect(find.text('本人最小退出入口'), findsOneWidget);
      expect(find.text('当前受限仍可自主取消；此入口不展示活动详情或他人资料。'), findsOneWidget);
      expect(find.textContaining('虚构城市：'), findsNothing);
      expect(find.textContaining('合成公共场所：'), findsNothing);
      expect(find.text('活动相关举报'), findsNothing);
      expect(find.text('主动报名'), findsNothing);
      await tester.tap(
        find.byKey(const ValueKey('event-exit-cancel-event-one')),
      );
      await tester.pumpAndSettle();
      expect(find.text('取消本人活动参与'), findsOneWidget);
      await tester.tap(find.text('确认'));
      await tester.pumpAndSettle();
      expect(sent?['action'], 'cancel');
      expect(sent?['revision'], 9);
      expect(sent?['idempotency_key'], isNotEmpty);
      expect(sent?.keys.toSet(), {'action', 'revision', 'idempotency_key'});
      expect(find.text('本人最小退出入口'), findsNothing);
      expect(find.text('取消本人参与'), findsNothing);
    },
  );

  testWidgets(
    'an exit locator without current cancel authority cannot create an action',
    (tester) async {
      await _mount(
        tester,
        const PlatformEventsPage(),
        _Api(
          (method, path, body) async => {
            'items': <Map<String, dynamic>>[],
            'exit_tickets': [
              {
                'id': 'event-one',
                'revision': 9,
                'registration_state': 'CONFIRMED',
                'allowed_actions': <String>[],
              },
            ],
          },
        ),
      );
      expect(find.text('本人最小退出入口'), findsNothing);
      expect(find.text('取消本人参与'), findsNothing);
    },
  );

  testWidgets('failed current refresh removes the previous event card', (
    tester,
  ) async {
    var offline = false;
    await _mount(
      tester,
      const PlatformEventsPage(),
      _Api((method, path, body) async {
        if (offline) throw const RelationshipFailure('Connection error');
        return {
          'items': [_event(title: '前次活动正文')],
        };
      }),
    );
    expect(find.text('前次活动正文'), findsOneWidget);
    offline = true;
    await tester.tap(find.byTooltip('刷新'));
    await tester.pumpAndSettle();
    expect(find.text('前次活动正文'), findsNothing);
    expect(find.text('未完成：Connection error'), findsOneWidget);
  });

  testWidgets('late activity list cannot overwrite the next account', (
    tester,
  ) async {
    final old = Completer<Map<String, dynamic>>();
    final sessions = _Sessions();
    var reads = 0;
    await _mount(
      tester,
      const PlatformEventsPage(),
      _Api((method, path, body) async {
        reads++;
        return reads == 1
            ? old.future
            : {
                'items': [_event(title: '新账号有权活动')],
              };
      }),
      sessions: sessions,
      settle: false,
    );
    sessions.change(2);
    await tester.pumpAndSettle();
    old.complete({
      'items': [_event(title: '旧账号迟到活动')],
    });
    await tester.pumpAndSettle();
    expect(find.text('新账号有权活动'), findsOneWidget);
    expect(find.text('旧账号迟到活动'), findsNothing);
  });

  testWidgets(
    'sanction appeal uses the existing owner route without outcome flags',
    (tester) async {
      Map<String, dynamic>? sent;
      var submitted = false;
      await _mount(
        tester,
        const SafetyCasesPage(),
        _Api((method, path, body) async {
          if (method == 'POST') {
            expect(path, '/moderation/sanctions/15/appeals');
            sent = body;
            submitted = true;
            return {
              'appeal': {'id': 8, 'status': 'submitted'},
            };
          }
          expect(path, '/safety/own');
          return {
            'items': [
              {'id': 'case-one', 'state': 'ACTIONED', 'role': 'subject'},
            ],
            'sanctions': [
              {
                'id': 15,
                'kind': 'restrict',
                'created_at': '2026-10-21',
                'appeal': submitted ? {'id': 8, 'status': 'submitted'} : null,
              },
            ],
          };
        }),
      );
      await tester.tap(find.text('对此记录提出本人申诉'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('safety-appeal-note')),
        '本人请求人工复核',
      );
      await tester.pump();
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, '提交本人申诉'))
            .onPressed,
        isNotNull,
      );
      await tester.tap(find.text('提交本人申诉'));
      await tester.pumpAndSettle();
      expect(sent, {'note': '本人请求人工复核'});
      expect(find.text('本人申诉已提交，等待人工复核'), findsOneWidget);
      expect(find.text('对此记录提出本人申诉'), findsNothing);
    },
  );

  for (final outcome in {
    'UPHELD': '人工复核：维持本次处理',
    'OVERTURNED': '人工复核：推翻本次处理',
    'CORRECTED': '人工复核：已记录纠错结果',
  }.entries) {
    testWidgets(
      'reviewed appeal displays ${outcome.key} in both own projections',
      (tester) async {
        final appeal = {
          'id': 8,
          'status': 'reviewed',
          'outcome': outcome.key,
          'revision': 2,
        };
        await _mount(
          tester,
          const SafetyCasesPage(),
          _Api(
            (method, path, body) async => {
              'items': [
                {
                  'id': 'case-one',
                  'state': outcome.key == 'UPHELD' ? 'CLOSED' : 'CORRECTED',
                  'role': 'subject',
                  'appeal': appeal,
                },
              ],
              'sanctions': [
                {
                  'id': 15,
                  'kind': 'restrict',
                  'created_at': '2026-10-21',
                  'appeal': appeal,
                },
              ],
            },
          ),
        );
        expect(find.text(outcome.value), findsNWidgets(2));
        expect(find.text('申诉状态待刷新确认'), findsNothing);
        expect(find.text('本人申诉已提交，等待人工复核'), findsNothing);
        expect(find.text('对此记录提出本人申诉'), findsNothing);
      },
    );
  }

  testWidgets(
    'an unknown outcome cannot fall back to a successful review label',
    (tester) async {
      await _mount(
        tester,
        const SafetyCasesPage(),
        _Api(
          (method, path, body) async => {
            'items': [
              {
                'id': 'case-one',
                'state': 'ACTIONED',
                'role': 'subject',
                'appeal': {'status': 'UPHELD', 'outcome': 'UNKNOWN'},
              },
            ],
            'sanctions': <Map<String, dynamic>>[],
          },
        ),
      );
      expect(find.text('申诉状态待刷新确认'), findsOneWidget);
      expect(find.text('人工复核：维持本次处理'), findsNothing);
    },
  );

  testWidgets(
    'report-only target remains selectable beside a live card without old private fields',
    (tester) async {
      Map<String, dynamic>? submitted;
      await _mount(
        tester,
        const PlatformEventsPage(),
        _Api((method, path, body) async {
          if (method == 'POST') {
            expect(path, '/platform-events/history-event/reports');
            submitted = body;
            return {'id': 'case-receipt', 'state': 'OPEN'};
          }
          return {
            'items': submitted == null
                ? [
                    {
                      ..._event(registrationState: 'APPLIED'),
                      'id': 'history-event',
                      'participants': <Map<String, dynamic>>[],
                    },
                  ]
                : <Map<String, dynamic>>[],
            'report_contexts': submitted == null
                ? [
                    {
                      'id': 'history-event',
                      'scope': 'REPORT_ONLY',
                      'report_until': 'TEST_ONLY window',
                      'title': 'PRIVATE_TITLE_MUST_NOT_RENDER',
                      'venue': 'PRIVATE_VENUE_MUST_NOT_RENDER',
                      'participants': [
                        {
                          'registration_id': 'history-peer',
                          'label': '合成参与者 peer',
                        },
                      ],
                    },
                  ]
                : <Map<String, dynamic>>[],
          };
        }),
      );
      expect(find.text('本人历史参与安全报告'), findsOneWidget);
      expect(find.textContaining('PRIVATE_TITLE'), findsNothing);
      expect(find.textContaining('PRIVATE_VENUE'), findsNothing);
      await tester.tap(find.text('提交历史参与安全疑虑'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('合成参与者 peer').last);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('platform-report-statement')),
        'TEST_ONLY historical safety concern',
      );
      await tester.pump();
      await tester.ensureVisible(find.text('提交关联活动举报'));
      await tester.tap(find.text('提交关联活动举报'));
      await tester.pumpAndSettle();
      expect(submitted?['target_registration_id'], 'history-peer');
      expect(submitted?['category'], 'CONDUCT');
      expect(submitted?['statement'], 'TEST_ONLY historical safety concern');
      expect(submitted?.keys.toSet(), {
        'target_registration_id',
        'category',
        'statement',
        'idempotency_key',
      });
    },
  );

  testWidgets('late history context cannot cross a session change', (
    tester,
  ) async {
    final sessions = _Sessions();
    final old = Completer<Map<String, dynamic>>();
    var reads = 0;
    await _mount(
      tester,
      const PlatformEventsPage(),
      _Api((method, path, body) {
        reads++;
        return reads == 1
            ? old.future
            : Future.value({
                'items': <Map<String, dynamic>>[],
                'report_contexts': <Map<String, dynamic>>[],
              });
      }),
      sessions: sessions,
      settle: false,
    );
    sessions.change(2);
    await tester.pumpAndSettle();
    old.complete({
      'items': <Map<String, dynamic>>[],
      'report_contexts': [
        {
          'id': 'old-event',
          'scope': 'REPORT_ONLY',
          'participants': [
            {'registration_id': 'old-peer', 'label': 'OLD_HISTORY_PRIVATE'},
          ],
        },
      ],
    });
    await tester.pumpAndSettle();
    expect(find.text('本人历史参与安全报告'), findsNothing);
    expect(find.text('OLD_HISTORY_PRIVATE'), findsNothing);
  });

  testWidgets('switching account clears a partly written appeal form', (
    tester,
  ) async {
    final sessions = _Sessions();
    await _mount(
      tester,
      const SafetyCasesPage(),
      _Api(
        (method, path, body) async => {
          'items': <Map<String, dynamic>>[],
          'sanctions': [
            {
              'id': 15,
              'kind': 'restrict',
              'created_at': '2026-10-21',
              'appeal': null,
            },
          ],
        },
      ),
      sessions: sessions,
    );
    await tester.tap(find.text('对此记录提出本人申诉'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('safety-appeal-note')),
      '旧账号未提交说明',
    );
    sessions.change(2);
    await tester.pumpAndSettle();
    expect(find.text('旧账号未提交说明'), findsNothing);
    expect(find.byKey(const Key('safety-appeal-note')), findsNothing);
  });
}

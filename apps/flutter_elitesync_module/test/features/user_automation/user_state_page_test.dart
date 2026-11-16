import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/features/user_automation/user_state_page.dart';
import '../slow_dating_v1012/journey_pages_test.dart' show FakeApi, TestSession;
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

Map<String, dynamic> snapshot(String code, int revision, {bool ready = true}) =>
    {
      'domains': {
        'account': {'code': 'AVAILABLE'},
        'profile': {'code': 'CONFIRMED_INPUTS'},
        'lifestyle': {
          'code': ready ? 'completed' : 'not_started',
          'answered_count': ready ? 5 : 0,
          'scene_count': 5,
        },
        'readiness': {
          'eligible': ready,
          'code': ready ? 'eligible' : 'matching_inputs_unconfirmed',
        },
        'participation': {'code': 'NOT_ENROLLED'},
        'round': {'code': 'no_round'},
        'proposal': {'code': 'NONE'},
        'privacy': {'shared_field_count': 0, 'requests_enabled': false},
        'notifications': {'silent': false},
        'automation': {
          'code': code,
          'source_revision': revision,
          'policy_version': 'weekly_participation_v1',
          'consent_version': 'weekly_consent_v1',
          'scope_key': 'weekly_slow_dating_participation',
          'expires_at': null,
          'recent_task': {'code': 'SKIPPED', 'result_code': 'NO_OPEN_ROUND'},
        },
      },
    };

Future<void> mount(
  WidgetTester tester,
  FakeApi api, {
  TestSession? session,
  bool settle = true,
}) async {
  tester.view.physicalSize = const Size(500, 2200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        relationshipApiProvider.overrideWithValue(api),
        sessionProvider.overrideWith(() => session ?? TestSession()),
      ],
      child: const MaterialApp(home: UserStatePage()),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

void main() {
  testWidgets(
    'default off requires explicit consent and sends versioned UUID command',
    (tester) async {
      final commands = <Map<String, dynamic>>[];
      var code = 'OFF';
      await mount(
        tester,
        FakeApi((method, path, body) async {
          if (method == 'PUT') {
            commands.add(body!);
            code = 'ACTIVE';
          }
          return snapshot(code, commands.length);
        }),
      );
      expect(commands, isEmpty);
      await tester.ensureVisible(find.byKey(const Key('automation-grant')));
      await tester.tap(find.byKey(const Key('automation-grant')));
      await tester.pumpAndSettle();
      expect(commands, isEmpty);
      await tester.tap(find.text('确认'));
      await tester.pumpAndSettle();
      expect(commands.single['action'], 'grant');
      expect(commands.single['expected_revision'], 0);
      expect(
        commands.single['request_key'],
        matches(RegExp(r'^[0-9a-f-]{36}$')),
      );
      expect(find.text('持续参与已授权'), findsOneWidget);
    },
  );

  testWidgets(
    'incomplete preparation disables grant while keeping preparation entry',
    (tester) async {
      await mount(
        tester,
        FakeApi((method, path, body) async => snapshot('OFF', 0, ready: false)),
      );
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('automation-grant')))
            .onPressed,
        isNull,
      );
      expect(find.text('查看准备状态'), findsOneWidget);
    },
  );

  testWidgets(
    'pause resume revoke use current revision and refresh authoritative status',
    (tester) async {
      var code = 'ACTIVE';
      var revision = 1;
      final actions = <String>[];
      await mount(
        tester,
        FakeApi((method, path, body) async {
          if (method == 'PUT') {
            expect(body!['expected_revision'], revision);
            actions.add(body['action'] as String);
            code = switch (body['action']) {
              'pause' => 'PAUSED',
              'resume' => 'ACTIVE',
              _ => 'REVOKED',
            };
            revision++;
          }
          return snapshot(code, revision);
        }),
      );
      for (final action in ['pause', 'resume', 'revoke']) {
        final button = find.byKey(Key('automation-$action'));
        await tester.ensureVisible(button);
        await tester.tap(button);
        await tester.pumpAndSettle();
      }
      expect(actions, ['pause', 'resume', 'revoke']);
      expect(find.text('已撤销'), findsOneWidget);
      expect(find.text('等待下一开放轮次'), findsOneWidget);
    },
  );

  testWidgets('late previous-account status never appears after switch', (
    tester,
  ) async {
    final pending = Completer<Map<String, dynamic>>();
    final notifier = TestSession();
    var reads = 0;
    await mount(
      tester,
      FakeApi((method, path, body) {
        reads++;
        return reads == 1 ? pending.future : Future.value(snapshot('OFF', 0));
      }),
      session: notifier,
      settle: false,
    );
    notifier.change(2);
    await tester.pumpAndSettle();
    pending.complete(snapshot('ACTIVE', 99));
    await tester.pumpAndSettle();
    expect(find.text('持续参与已授权'), findsNothing);
    expect(find.text('尚未开启'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/features/slow_dating_v1012/slow_dating_journey_page.dart';

import 'journey_pages_test.dart' show FakeApi, journey, mount;

// Isolated widget regressions for server-projected flags, not real-chain E2E.
void main() {
  testWidgets('missing server decision flags fail closed', (tester) async {
    await mount(
      tester,
      const SlowDatingJourneyPage(),
      FakeApi(
        (method, path, body) async => journey(
          proposal: {
            'id': 'legacy-without-flags',
            'revision': 1,
            'state': 'PENDING',
            'peer_id': 2,
          },
        ),
      ),
    );
    expect(find.byKey(const ValueKey('proposal-accept')), findsNothing);
    expect(find.byKey(const ValueKey('proposal-decline')), findsNothing);
    expect(find.byKey(const ValueKey('proposal-withdraw')), findsNothing);
  });

  testWidgets(
    'paused pending proposal hides decisions, preserves explicit withdrawal and explains reenrollment',
    (tester) async {
      final writes = <Map<String, dynamic>>[];
      var withdrawn = false;
      await mount(
        tester,
        const SlowDatingJourneyPage(),
        FakeApi((method, path, body) async {
          if (method != 'GET') {
            expect(method, 'POST');
            expect(path, '/journey/proposals/r1-paused/decision');
            writes.add(Map<String, dynamic>.from(body!));
            withdrawn = true;
          }
          return journey(
            state: 'PAUSED',
            proposal: {
              'id': 'r1-paused',
              'revision': withdrawn ? 5 : 4,
              'state': withdrawn ? 'WITHDRAWN' : 'ACCEPTED_BY_ONE',
              'peer_id': 2,
              'decision_me': 'ACCEPTED',
              'decision_peer': 'PENDING',
              'decision_available': false,
              'withdraw_available': !withdrawn,
              'connection_eligible': false,
              'availability_reason': 'participation_paused_or_changed',
              'showcase': null,
            },
          );
        }),
      );

      expect(find.byKey(const ValueKey('proposal-accept')), findsNothing);
      expect(find.byKey(const ValueKey('proposal-decline')), findsNothing);
      expect(find.byKey(const ValueKey('proposal-withdraw')), findsOneWidget);
      expect(find.textContaining('请先撤回再明确重新报名'), findsOneWidget);
      expect(find.text('候选：暂不可见'), findsOneWidget);
      expect(find.text('分别申请连接（CN）与消息同意（MC）'), findsNothing);
      expect(writes, isEmpty);

      final withdraw = find.byKey(const ValueKey('proposal-withdraw'));
      expect(tester.widget<OutlinedButton>(withdraw).onPressed, isNotNull);
      await tester.ensureVisible(withdraw);
      await tester.tap(withdraw);
      await tester.pumpAndSettle();
      expect(writes, hasLength(1));
      expect(writes.single['action'], 'withdraw');
      expect(writes.single['revision'], 4);
      expect(writes.single['idempotency_key'], isA<String>());
      expect(writes.single['idempotency_key'], isNotEmpty);
      expect(find.byKey(const ValueKey('proposal-withdraw')), findsNothing);
    },
  );

  testWidgets(
    'withdrawn exit and legacy generation-invalid projections expose no new decisions',
    (tester) async {
      final snapshots = [
        {'participation': 'EXITED', 'proposal': 'WITHDRAWN'},
        // An old lifecycle label cannot override explicit server denial flags.
        {'participation': 'ACTIVE', 'proposal': 'PENDING'},
      ];
      for (final snapshot in snapshots) {
        await tester.pumpWidget(const SizedBox.shrink());
        await mount(
          tester,
          const SlowDatingJourneyPage(),
          FakeApi((method, path, body) async {
            expect(method, 'GET');
            expect(path, '/journey');
            return journey(
              state: snapshot['participation']!,
              proposal: {
                'id': 'r1-old-generation',
                'revision': 6,
                'state': snapshot['proposal'],
                'peer_id': 2,
                'decision_available': false,
                'withdraw_available': false,
                'connection_eligible': false,
                'availability_reason': 'participation_paused_or_changed',
                'showcase': null,
              },
            );
          }),
        );
        expect(find.byKey(const ValueKey('proposal-accept')), findsNothing);
        expect(find.byKey(const ValueKey('proposal-decline')), findsNothing);
        expect(find.byKey(const ValueKey('proposal-withdraw')), findsNothing);
        expect(find.text('分别申请连接（CN）与消息同意（MC）'), findsNothing);
        expect(find.text('候选：暂不可见'), findsOneWidget);
      }
    },
  );

  testWidgets(
    'mutual historical label without current connection eligibility cannot initiate CN or MC',
    (tester) async {
      await mount(
        tester,
        const SlowDatingJourneyPage(),
        FakeApi((method, path, body) async {
          expect(method, 'GET');
          expect(path, '/journey');
          return journey(
            state: 'ACTIVE',
            proposal: {
              'id': 'r1-mutual-history',
              'revision': 3,
              'state': 'MUTUALLY_ACCEPTED',
              'peer_id': 2,
              'decision_me': 'ACCEPTED',
              'decision_peer': 'ACCEPTED',
              'decision_available': false,
              'withdraw_available': false,
              'connection_eligible': false,
              'availability_reason': 'participation_paused_or_changed',
              'showcase': null,
            },
          );
        }),
      );
      expect(find.text('分别申请连接（CN）与消息同意（MC）'), findsNothing);
      expect(find.byKey(const ValueKey('proposal-accept')), findsNothing);
      expect(find.byKey(const ValueKey('proposal-decline')), findsNothing);
      expect(find.byKey(const ValueKey('proposal-withdraw')), findsNothing);
      expect(find.text('候选：暂不可见'), findsOneWidget);
    },
  );
}

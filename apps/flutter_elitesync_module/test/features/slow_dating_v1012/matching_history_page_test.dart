import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/features/slow_dating_v1012/matching_history_page.dart';

import 'matching_input_page_test.dart' show FakeApi, TestSession, mount;

Map<String, dynamic> historyPage(
  int page, {
  String? summary,
  String id = 'history-proposal',
  int lastPage = 2,
}) => {
  'current_page': page,
  'last_page': lastPage,
  'data': [
    {
      'id': id,
      'round_id': 17,
      'state': 'MUTUALLY_ACCEPTED',
      'decision_me': 'ACCEPTED',
      'decision_peer': 'ACCEPTED',
      'revealed_at': '2026-11-13T12:00:00Z',
      'expires_at': '2026-11-20T12:00:00Z',
      'showcase': summary == null ? null : {'summary': summary},
    },
  ],
};

void main() {
  testWidgets('pagination reads the requested server page and page size', (
    tester,
  ) async {
    final paths = <String>[];
    await mount(
      tester,
      const MatchingHistoryPage(),
      FakeApi((method, path, body) async {
        expect(method, 'GET');
        expect(body, isNull);
        paths.add(path);
        final uri = Uri.parse(path);
        expect(uri.path, '/journey/history');
        expect(uri.queryParameters['per_page'], '10');
        final page = int.parse(uri.queryParameters['page']!);
        return historyPage(page, summary: '第$page页允许读取的资料');
      }),
    );
    expect(find.text('第 1 / 2 页'), findsOneWidget);
    expect(find.text('第1页允许读取的资料'), findsOneWidget);
    await tester.tap(find.text('下一页'));
    await tester.pumpAndSettle();
    expect(find.text('第 2 / 2 页'), findsOneWidget);
    expect(find.text('第2页允许读取的资料'), findsOneWidget);
    expect(find.text('第1页允许读取的资料'), findsNothing);
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, '下一页'))
          .onPressed,
      isNull,
    );
    await tester.tap(find.text('上一页'));
    await tester.pumpAndSettle();
    expect(find.text('第 1 / 2 页'), findsOneWidget);
    expect(paths, [
      '/journey/history?page=1&per_page=10',
      '/journey/history?page=2&per_page=10',
      '/journey/history?page=1&per_page=10',
    ]);
  });

  testWidgets('hidden showcase preserves own facts without terminal actions', (
    tester,
  ) async {
    await mount(
      tester,
      const MatchingHistoryPage(),
      FakeApi((method, path, body) async {
        expect(method, 'GET');
        return historyPage(1, id: 'terminal-17', lastPage: 1);
      }),
    );
    expect(find.text('对方展示资料当前不可见'), findsOneWidget);
    expect(find.text('本人选择 已接受'), findsOneWidget);
    expect(find.text('轮次 17 · 提案 terminal-17'), findsOneWidget);
    expect(find.text('揭晓 2026-11-13T12:00:00Z'), findsOneWidget);
    expect(find.text('有效期 2026-11-20T12:00:00Z'), findsOneWidget);
    expect(find.textContaining('双方已选择'), findsOneWidget);
    expect(find.text('此处保留过程记录，当前提案操作请返回慢约旅程。'), findsOneWidget);
    expect(find.byKey(const ValueKey('proposal-accept')), findsNothing);
    expect(find.byKey(const ValueKey('proposal-decline')), findsNothing);
    expect(find.byKey(const ValueKey('proposal-withdraw')), findsNothing);
    expect(find.byType(FilledButton), findsNothing);
    expect(find.byType(OutlinedButton), findsNothing);
  });

  testWidgets(
    'account switch resets pagination and ignores late prior history',
    (tester) async {
      final notifier = TestSession();
      final lateHistory = Completer<Map<String, dynamic>>();
      final paths = <String>[];
      await mount(
        tester,
        const MatchingHistoryPage(),
        FakeApi((method, path, body) async {
          expect(method, 'GET');
          paths.add(path);
          if (paths.length == 2) return lateHistory.future;
          return historyPage(
            1,
            summary: paths.length == 1 ? '账号一历史资料' : '账号二历史资料',
          );
        }),
        notifier: notifier,
      );
      await tester.tap(find.text('下一页'));
      await tester.pump();
      notifier.change(2);
      await tester.pumpAndSettle();
      expect(find.text('账号二历史资料'), findsOneWidget);
      expect(find.text('账号一历史资料'), findsNothing);
      expect(find.text('第 1 / 2 页'), findsOneWidget);

      lateHistory.complete(historyPage(2, summary: '账号一迟到历史'));
      await tester.pumpAndSettle();
      expect(find.text('账号二历史资料'), findsOneWidget);
      expect(find.text('账号一迟到历史'), findsNothing);
      expect(find.text('第 1 / 2 页'), findsOneWidget);
      expect(paths, [
        '/journey/history?page=1&per_page=10',
        '/journey/history?page=2&per_page=10',
        '/journey/history?page=1&per_page=10',
      ]);
    },
  );

  testWidgets('resuming clears cached showcase before authorization refresh', (
    tester,
  ) async {
    final currentHistory = Completer<Map<String, dynamic>>();
    var reads = 0;
    await mount(
      tester,
      const MatchingHistoryPage(),
      FakeApi((method, path, body) async {
        expect(method, 'GET');
        expect(path, '/journey/history?page=1&per_page=10');
        reads++;
        if (reads == 2) return currentHistory.future;
        return historyPage(1, summary: '撤权前可见资料', lastPage: 1);
      }),
    );
    expect(find.text('撤权前可见资料'), findsOneWidget);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(reads, 2);
    expect(find.text('撤权前可见资料'), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    currentHistory.complete(historyPage(1, lastPage: 1));
    await tester.pumpAndSettle();
    expect(find.text('对方展示资料当前不可见'), findsOneWidget);
    expect(find.text('撤权前可见资料'), findsNothing);
    expect(find.text('本人选择 已接受'), findsOneWidget);
  });
}

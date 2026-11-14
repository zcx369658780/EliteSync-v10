import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/mbti_center_page.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';

class _Session extends SessionNotifier {
  void changeAccount() =>
      state = AsyncData(SessionState(status: AuthStatus.authenticated));
  @override
  SessionState build() => const SessionState(status: AuthStatus.authenticated);
}

class _Api extends ApiClient {
  _Api() : super(dio: Dio());
  bool disabled = false;
  bool submitted = false;
  bool failReadback = false;
  bool failSubmit = false;
  int? submitStatus;
  int? historyStatus;
  int? nextHistoryId;
  String resultLetters = 'INTJ';
  Completer<NetworkResult<Map<String, dynamic>>>? delayedResult;
  Object? submittedBody;
  final List<Map<String, dynamic>> submittedBodies = [];
  final List<Map<String, dynamic>?> historyQueries = [];
  int resultReads = 0;
  Map<String, dynamic> get attempt => {
    'id': 1,
    'result': resultLetters,
    'version_code': 'lite3_v1',
    'submitted_at': '2026-11-14T08:00:00Z',
    'scores': {'I': 2},
    'answers': [
      {'question_id': 1, 'option': 'A'},
    ],
  };
  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    if (disabled) {
      return const NetworkFailure(message: 'feature_disabled', statusCode: 410);
    }
    if (path.endsWith('/quiz')) {
      return const NetworkSuccess({
        'version_code': 'lite3_v1',
        'items': [
          {
            'question_id': 1,
            'content': '你如何恢复精力？',
            'option_a_text': '和朋友交流',
            'option_b_text': '独处休息',
          },
        ],
      });
    }
    if (path.endsWith('/history')) {
      historyQueries.add(query);
      if (historyStatus != null) {
        return NetworkFailure(
          message: 'history_denied',
          statusCode: historyStatus,
        );
      }
      return NetworkSuccess({
        'items': submitted ? [attempt] : [],
        'next_before_id': nextHistoryId,
      });
    }
    if (path.contains('/history/')) {
      if (failReadback) {
        return const NetworkFailure(
          message: 'readback_unavailable',
          statusCode: 503,
        );
      }
      return NetworkSuccess({'attempt': attempt});
    }
    resultReads++;
    final delayed = delayedResult;
    if (delayed != null) {
      delayedResult = null;
      return delayed.future;
    }
    return NetworkSuccess({
      'exists': submitted,
      'result': submitted ? resultLetters : null,
      'attempt_id': submitted ? 1 : null,
      'version_code': submitted ? 'lite3_v1' : null,
    });
  }

  @override
  Future<NetworkResult<Map<String, dynamic>>> post(
    String path, {
    CancelToken? cancelToken,
    Object? body,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    submittedBody = body;
    submittedBodies.add(
      Map<String, dynamic>.from(jsonDecode(jsonEncode(body)) as Map),
    );
    submitted = true;
    if (failSubmit) {
      return NetworkFailure(
        message: 'submit_failure',
        statusCode: submitStatus,
      );
    }
    return const NetworkSuccess({
      'ok': true,
      'result': 'INTJ',
      'attempt_id': 1,
    });
  }
}

Future<void> _show(WidgetTester tester, _Api api, {ThemeData? theme}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        apiClientProvider.overrideWithValue(api),
        sessionProvider.overrideWith(_Session.new),
      ],
      child: MaterialApp(
        theme: theme ?? AppTheme.light,
        home: const MbtiCenterPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final theme in [AppTheme.light, AppTheme.dark]) {
    testWidgets('selected options use paired colors in ${theme.brightness}', (
      tester,
    ) async {
      await _show(tester, _Api(), theme: theme);
      await tester.tap(find.text('开始测评'));
      await tester.pumpAndSettle();
      for (final option in ['A', 'B', 'A']) {
        final finder = find.byKey(ValueKey('mbti-1-$option'));
        await tester.ensureVisible(finder);
        await tester.tap(finder);
        await tester.pumpAndSettle();
        final button = tester.widget<OutlinedButton>(finder);
        expect(
          button.style?.foregroundColor?.resolve({}),
          theme.colorScheme.onPrimaryContainer,
        );
        expect(
          button.style?.backgroundColor?.resolve({}),
          theme.colorScheme.primaryContainer,
        );
        expect(find.text('题库版本：lite3_v1；已答 1/1'), findsOneWidget);
        final other = tester.widget<OutlinedButton>(
          find.byKey(ValueKey('mbti-1-${option == 'A' ? 'B' : 'A'}')),
        );
        expect(other.style, isNull);
      }
    });
  }
  testWidgets(
    'optional quiz submits answers and confirms persisted result by GET',
    (tester) async {
      final api = _Api();
      await _show(tester, api);
      expect(find.textContaining('不用于匹配排序'), findsOneWidget);
      await tester.tap(find.text('开始测评'));
      await tester.pumpAndSettle();
      expect(find.text('你如何恢复精力？'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, '提交测评'))
            .onPressed,
        isNull,
      );
      await tester.tap(find.text('A：和朋友交流'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('提交测评'));
      await tester.tap(find.text('提交测评'));
      await tester.pumpAndSettle();
      expect(api.submittedBody, containsPair('version_code', 'lite3_v1'));
      expect(
        api.submittedBody,
        containsPair('answers', [
          {'question_id': 1, 'option': 'A'},
        ]),
      );
      expect(
        (api.submittedBody as Map)['request_key'],
        matches(RegExp(r'^[0-9a-f-]{36}$')),
      );
      expect(api.resultReads, 1);
      expect(find.textContaining('服务端结果已确认：INTJ'), findsOneWidget);
    },
  );
  testWidgets('history supports bounded cursor and selected persisted detail', (
    tester,
  ) async {
    final api = _Api()
      ..submitted = true
      ..nextHistoryId = 1;
    await _show(tester, api);
    await tester.ensureVisible(find.text('读取测评历史'));
    await tester.tap(find.text('读取测评历史'));
    await tester.pumpAndSettle();
    final item = find.text('历史 #1 · INTJ · lite3_v1');
    await tester.ensureVisible(item);
    await tester.tap(item);
    await tester.pumpAndSettle();
    expect(find.textContaining('历史测评 #1'), findsOneWidget);
    await tester.scrollUntilVisible(find.textContaining('已保存作答'), 200);
    expect(find.textContaining('已保存作答'), findsOneWidget);
    final older = find.text('更早测评历史');
    await tester.ensureVisible(older);
    await tester.tap(older);
    await tester.pumpAndSettle();
    expect(api.historyQueries, [
      {},
      {'before_id': 1},
    ]);
    expect(item, findsOneWidget);
  });
  for (final code in <int?>[null, 503]) {
    testWidgets(
      'submit $code retains answers and retries immutable UUID payload',
      (tester) async {
        final api = _Api()
          ..failSubmit = true
          ..submitStatus = code;
        await _show(tester, api);
        await tester.tap(find.text('开始测评'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('A：和朋友交流'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('提交测评'));
        await tester.tap(find.text('提交测评'));
        await tester.pumpAndSettle();
        expect(find.text('题库版本：lite3_v1；已答 1/1'), findsOneWidget);
        expect(find.textContaining('结果未确认'), findsOneWidget);
        expect(
          tester
              .widget<OutlinedButton>(find.byKey(const ValueKey('mbti-1-B')))
              .onPressed,
          isNull,
        );
        api.failSubmit = false;
        final retry = find.text('重试原提交并确认结果');
        await tester.ensureVisible(retry);
        await tester.tap(retry);
        await tester.pumpAndSettle();
        expect(api.submittedBodies.length, 2);
        expect(api.submittedBodies[0], api.submittedBodies[1]);
        expect(find.textContaining('服务端结果已确认：INTJ'), findsOneWidget);
        expect(retry, findsNothing);
      },
    );
  }
  for (final code in [401, 403, 410]) {
    testWidgets(
      'history $code after display clears old result history and actions',
      (tester) async {
        final api = _Api()..submitted = true;
        await _show(tester, api);
        await tester.ensureVisible(find.text('读取测评历史'));
        await tester.tap(find.text('读取测评历史'));
        await tester.pumpAndSettle();
        expect(find.text('历史 #1 · INTJ · lite3_v1'), findsOneWidget);
        api.historyStatus = code;
        await tester.ensureVisible(find.text('读取测评历史'));
        await tester.tap(find.text('读取测评历史'));
        await tester.pumpAndSettle();
        expect(find.textContaining('INTJ'), findsNothing);
        expect(find.textContaining('当前测评不可用'), findsOneWidget);
        expect(find.textContaining('结果未确认'), findsNothing);
        expect(
          tester
              .widget<FilledButton>(find.widgetWithText(FilledButton, '开始测评'))
              .onPressed,
          isNull,
        );
      },
    );
  }
  testWidgets('history 503 retains displayed result and history for retry', (
    tester,
  ) async {
    final api = _Api()..submitted = true;
    await _show(tester, api);
    await tester.ensureVisible(find.text('读取测评历史'));
    await tester.tap(find.text('读取测评历史'));
    await tester.pumpAndSettle();
    api.historyStatus = 503;
    await tester.tap(find.text('读取测评历史'));
    await tester.pumpAndSettle();
    expect(find.textContaining('服务端结果已确认：INTJ'), findsOneWidget);
    expect(find.text('历史 #1 · INTJ · lite3_v1'), findsOneWidget);
    expect(find.textContaining('结果未确认'), findsOneWidget);
  });
  testWidgets(
    'submit 422 keeps answers editable and uses a new key after correction',
    (tester) async {
      final api = _Api()
        ..failSubmit = true
        ..submitStatus = 422;
      await _show(tester, api);
      await tester.tap(find.text('开始测评'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('A：和朋友交流'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('提交测评'));
      await tester.tap(find.text('提交测评'));
      await tester.pumpAndSettle();
      expect(find.textContaining('请求已被明确拒绝'), findsOneWidget);
      expect(find.text('重试原提交并确认结果'), findsNothing);
      final answer = find.byKey(const ValueKey('mbti-1-B'));
      await tester.ensureVisible(answer);
      await tester.tap(answer);
      await tester.pumpAndSettle();
      api.failSubmit = false;
      await tester.ensureVisible(find.text('提交测评'));
      await tester.tap(find.text('提交测评'));
      await tester.pumpAndSettle();
      expect(api.submittedBodies.length, 2);
      expect(
        api.submittedBodies[0]['request_key'],
        isNot(api.submittedBodies[1]['request_key']),
      );
      expect(api.submittedBodies[1]['answers'], [
        {'question_id': 1, 'option': 'B'},
      ]);
    },
  );
  for (final account in [true, false]) {
    testWidgets(
      'late denial from old ${account ? 'account' : 'authority'} cannot clear refreshed result',
      (tester) async {
        final api = _Api()..submitted = true;
        await _show(tester, api);
        final pending = Completer<NetworkResult<Map<String, dynamic>>>();
        api.delayedResult = pending;
        await tester.tap(find.text('刷新结果'));
        await tester.pump();
        final context = tester.element(find.byType(MbtiCenterPage));
        final c = ProviderScope.containerOf(context);
        if (account) {
          (c.read(sessionProvider.notifier) as _Session).changeAccount();
        } else {
          c.read(relationshipAuthorityEpochProvider.notifier).invalidate();
        }
        await tester.pump();
        api.resultLetters = 'ENFP';
        await tester.tap(find.text('刷新结果'));
        await tester.pumpAndSettle();
        expect(find.textContaining('服务端结果已确认：ENFP'), findsOneWidget);
        pending.complete(
          const NetworkFailure(message: 'old_denied', statusCode: 403),
        );
        await tester.pumpAndSettle();
        expect(find.textContaining('服务端结果已确认：ENFP'), findsOneWidget);
        expect(find.textContaining('old_denied'), findsNothing);
      },
    );
  }
  testWidgets('disabled API is visible and never reports success', (
    tester,
  ) async {
    await _show(tester, _Api()..disabled = true);
    expect(find.textContaining('feature_disabled'), findsOneWidget);
    expect(find.textContaining('结果已确认'), findsNothing);
  });
  testWidgets('successful POST alone does not confirm a persisted result', (
    tester,
  ) async {
    final api = _Api()..failReadback = true;
    await _show(tester, api);
    await tester.tap(find.text('开始测评'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A：和朋友交流'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('提交测评'));
    await tester.tap(find.text('提交测评'));
    await tester.pumpAndSettle();
    expect(find.textContaining('readback_unavailable'), findsOneWidget);
    expect(find.textContaining('结果已确认'), findsNothing);
    api.failReadback = false;
    final retry = find.text('重试原提交并确认结果');
    await tester.ensureVisible(retry);
    await tester.tap(retry);
    await tester.pumpAndSettle();
    expect(api.submittedBodies.length, 2);
    expect(api.submittedBodies[0], api.submittedBodies[1]);
    expect(find.textContaining('服务端结果已确认：INTJ'), findsOneWidget);
  });
  testWidgets('account changes hide the previous persisted result', (
    tester,
  ) async {
    await _show(tester, _Api()..submitted = true);
    expect(find.textContaining('INTJ'), findsOneWidget);
    final context = tester.element(find.byType(MbtiCenterPage));
    final container = ProviderScope.containerOf(context);
    (container.read(sessionProvider.notifier) as _Session).changeAccount();
    await tester.pumpAndSettle();
    expect(find.textContaining('INTJ'), findsNothing);
  });
}

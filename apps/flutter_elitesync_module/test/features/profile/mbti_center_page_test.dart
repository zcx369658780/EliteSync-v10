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

class _Session extends SessionNotifier {
  void changeAccount() =>
      state = AsyncData(SessionState(status: AuthStatus.authenticated));
  @override
  Future<SessionState> build() async =>
      const SessionState(status: AuthStatus.authenticated);
}

class _Api extends ApiClient {
  _Api() : super(dio: Dio());
  bool disabled = false;
  bool submitted = false;
  bool failReadback = false;
  Object? submittedBody;
  int resultReads = 0;
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
    resultReads++;
    if (submitted && failReadback) {
      return const NetworkFailure(
        message: 'readback_unavailable',
        statusCode: 503,
      );
    }
    return NetworkSuccess({
      'exists': submitted,
      'result': submitted ? 'INTJ' : null,
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
    submitted = true;
    return const NetworkSuccess({'ok': true, 'result': 'INTJ'});
  }
}

Future<void> _show(WidgetTester tester, _Api api) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        apiClientProvider.overrideWithValue(api),
        sessionProvider.overrideWith(_Session.new),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const MbtiCenterPage()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
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
      expect(api.submittedBody, {
        'version_code': 'lite3_v1',
        'answers': [
          {'question_id': 1, 'option': 'A'},
        ],
      });
      expect(api.resultReads, 2);
      expect(find.textContaining('INTJ'), findsOneWidget);
    },
  );
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

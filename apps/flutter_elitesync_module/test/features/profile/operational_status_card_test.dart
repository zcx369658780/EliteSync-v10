import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/operational_status_card.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _OperatingApiClient extends ApiClient {
  _OperatingApiClient(this.response) : super(dio: Dio());

  Future<NetworkResult<Map<String, dynamic>>> Function() response;
  final List<String> requestedPaths = [];

  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) {
    requestedPaths.add(path);
    return response();
  }
}

Map<String, dynamic> _payload({
  String status = 'pending',
  String reason = '等待运营审核',
  bool eligible = false,
  int missing = 0,
  String moderation = 'normal',
}) => {
  'status': status,
  'reason': reason,
  'revision': 3,
  'moderation_status': moderation,
  'matching_eligibility': {
    'eligible': eligible,
    'reason_code': missing > 0
        ? 'questionnaire_incomplete'
        : 'operating_review',
    'required_answer_count': 10,
    'answered_answer_count': 10 - missing,
    'missing_answer_count': missing,
    'next_action_code': missing > 0 ? 'complete_questionnaire' : 'none',
  },
};

Widget _wrap(_OperatingApiClient client) => ProviderScope(
  overrides: [apiClientProvider.overrideWithValue(client)],
  child: MaterialApp(
    theme: AppTheme.light,
    home: const Scaffold(
      body: SingleChildScrollView(child: OperationalStatusCard()),
    ),
  ),
);

void main() {
  for (final entry in {
    'pending': '运营审核待处理',
    'approved': '运营审核已通过',
    'rejected': '运营审核未通过',
  }.entries) {
    testWidgets('Shows ${entry.key} from the real API provider contract', (
      tester,
    ) async {
      final client = _OperatingApiClient(
        () async => NetworkSuccess(
          _payload(
            status: entry.key,
            reason: '具名审核理由',
            eligible: entry.key == 'approved',
          ),
        ),
      );
      await tester.pumpWidget(_wrap(client));
      await tester.pumpAndSettle();
      expect(client.requestedPaths, ['/api/v1/profile/operating-status']);
      expect(find.text('运营参与资格（非实名认证）'), findsOneWidget);
      expect(find.text(entry.value), findsOneWidget);
      expect(find.text('审核原因：具名审核理由'), findsOneWidget);
      expect(
        find.text('服务器确认可参与新一轮匹配'),
        entry.key == 'approved' ? findsOneWidget : findsNothing,
      );
    });
  }

  testWidgets('Approved review does not manufacture matching eligibility', (
    tester,
  ) async {
    final client = _OperatingApiClient(
      () async => NetworkSuccess(
        _payload(
          status: 'approved',
          eligible: false,
          missing: 2,
          moderation: 'restricted',
        ),
      ),
    );
    await tester.pumpWidget(_wrap(client));
    await tester.pumpAndSettle();
    expect(find.text('运营审核已通过'), findsOneWidget);
    expect(find.text('当前不能参与新一轮匹配'), findsOneWidget);
    expect(find.textContaining('新的私信收发暂停'), findsOneWidget);
    expect(find.textContaining('需补答 2 项'), findsOneWidget);
    expect(find.text('补答匹配问卷'), findsOneWidget);
    expect(find.text('服务器确认可参与新一轮匹配'), findsNothing);
  });

  testWidgets('Loading and failed refresh never display stale approval', (
    tester,
  ) async {
    final client = _OperatingApiClient(
      () async => NetworkSuccess(_payload(status: 'approved', eligible: true)),
    );
    await tester.pumpWidget(_wrap(client));
    await tester.pumpAndSettle();
    final pending = Completer<NetworkResult<Map<String, dynamic>>>();
    client.response = () => pending.future;
    await tester.tap(find.text('刷新运营资格'));
    await tester.pump();
    expect(find.text('正在读取服务器运营资格…'), findsOneWidget);
    expect(find.text('运营审核已通过'), findsNothing);
    pending.complete(
      const NetworkFailure(message: 'private raw error', statusCode: 503),
    );
    await tester.pumpAndSettle();
    expect(find.text('运营资格暂不可用，无法确认当前审核或匹配状态。'), findsOneWidget);
    expect(find.textContaining('private raw error'), findsNothing);
    expect(client.requestedPaths.length, 2);
    expect(find.text('运营审核已通过'), findsNothing);
    client.response = () async => NetworkSuccess(_payload(status: 'rejected'));
    await tester.tap(find.text('重试读取运营资格'));
    await tester.pumpAndSettle();
    expect(find.text('运营审核未通过'), findsOneWidget);
    expect(client.requestedPaths.length, 3);
  });

  testWidgets('Malformed server eligibility fails closed', (tester) async {
    final client = _OperatingApiClient(
      () async => const NetworkSuccess({'status': 'approved'}),
    );
    await tester.pumpWidget(_wrap(client));
    await tester.pumpAndSettle();
    expect(find.text('运营资格暂不可用，无法确认当前审核或匹配状态。'), findsOneWidget);
    expect(find.text('运营审核已通过'), findsNothing);
    expect(client.requestedPaths, ['/api/v1/profile/operating-status']);
  });

  testWidgets('Supplement answers uses the existing questionnaire route', (
    tester,
  ) async {
    final client = _OperatingApiClient(
      () async => NetworkSuccess(_payload(status: 'approved', missing: 1)),
    );
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(
            body: SingleChildScrollView(child: OperationalStatusCard()),
          ),
        ),
        GoRoute(
          path: AppRouteNames.questionnaire,
          builder: (_, _) =>
              const Scaffold(body: Text('Existing questionnaire')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [apiClientProvider.overrideWithValue(client)],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('补答匹配问卷'));
    await tester.tap(find.text('补答匹配问卷'));
    await tester.pumpAndSettle();
    expect(find.text('Existing questionnaire'), findsOneWidget);
  });
}


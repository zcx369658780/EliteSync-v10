import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/admin/presentation/pages/admin_matching_operations_page.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class _FakeApiClient extends ApiClient {
  _FakeApiClient({
    List<Future<NetworkResult<Map<String, dynamic>>>>? details,
    this.consumerConfigured = true,
    this.roundState = 'revealed',
    this.capabilities = const {'close': true},
    List<NetworkResult<Map<String, dynamic>>>? posts,
  }) : postResponses = List.of(posts ?? const []),
       detailResponses = details ?? [],
      super(dio: Dio());

  final List<Future<NetworkResult<Map<String, dynamic>>>> detailResponses;
  final List<NetworkResult<Map<String, dynamic>>> postResponses;
  final bool consumerConfigured;
  final String roundState;
  final Map<String, bool> capabilities;
  final List<String> getPaths = [];
  final List<String> postPaths = [];

  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    getPaths.add(path);
    if (path == '/api/v1/admin/matching/rounds') {
      return NetworkSuccess({
        'data': [
          {
            'round_key': 'round-1',
            'state': roundState,
            'state_version': 3,
            'user_states_count': 2,
            'operation_capabilities': capabilities,
            'active_run': {
              'state': 'succeeded',
              'outcome': 'matches_created',
              'pair_count': 1,
              'no_candidate_count': 0,
            },
          },
        ],
        'meta': {'consumer_configured': consumerConfigured},
      });
    }
    if (detailResponses.isEmpty) {
      return const NetworkFailure(message: 'unexpected detail request');
    }
    return detailResponses.removeAt(0);
  }

  @override
  Future<NetworkResult<Map<String, dynamic>>> post(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    postPaths.add(path);
    if (postResponses.isNotEmpty) return postResponses.removeAt(0);
    return const NetworkSuccess({'ok': true});
  }
}

const _validAuditResponse = NetworkSuccess<Map<String, dynamic>>({
  'audits': [
    {
      'action': 'reveal',
      'actor_type': 'admin',
      'actor_id': 7,
      'reason_code': 'c2_local_operator',
      'created_at': '2026-08-05T10:15:00',
      'after_state': {
        'before': {'state': 'waiting', 'state_version': 2},
        'after': {'state': 'revealed', 'state_version': 3},
        'private_profile': {'phone': 'must-not-render'},
        'idempotency_key': 'forbidden-key',
      },
      'correlation_id': 'forbidden-correlation',
      'role_snapshot': {'role': 'forbidden-role'},
      'aggregate_summary': {'pair_count': 99},
      'source_channel': 'forbidden-channel',
    },
  ],
});
AppEnv _env(bool enabled) => AppEnv(
  flavor: AppFlavor.dev,
  appName: 'test',
  apiBaseUrl: 'http://127.0.0.1/',
  useMockData: false,
  useAdminMatchingOperations: enabled,
);

Widget _wrap(bool enabled, {_FakeApiClient? apiClient}) => ProviderScope(
  overrides: [
    appEnvProvider.overrideWithValue(_env(enabled)),
    apiClientProvider.overrideWithValue(apiClient ?? _FakeApiClient()),
  ],
  child: MaterialApp(
    theme: AppTheme.light,
    home: const AdminMatchingOperationsPage(),
  ),
);

void main() {
  testWidgets('production/default exclusion is visible', (tester) async {
    await tester.pumpWidget(_wrap(false));
    await tester.pumpAndSettle();
    expect(find.text('匹配运营状态不可用'), findsOneWidget);
    expect(find.textContaining('仅在本地内部构建'), findsOneWidget);
  });

  testWidgets('shows job state aggregates and confirmation', (tester) async {
    await tester.pumpWidget(_wrap(true));
    await tester.pumpAndSettle();
    expect(find.text('结果已揭晓'), findsOneWidget);
    expect(find.text('最近运行：运行成功 · 匹配已生成'), findsOneWidget);
    expect(find.textContaining('succeeded'), findsNothing);
    expect(find.textContaining('matches_created'), findsNothing);
    expect(find.textContaining('本地保存的轮次'), findsOneWidget);
    expect(find.textContaining('耐久化'), findsNothing);
    expect(find.textContaining('配对 1 · 未匹配 0'), findsOneWidget);
    expect(find.text('补偿操作：未授权'), findsOneWidget);
    await tester.tap(find.text('关闭本轮'));
    await tester.pumpAndSettle();
    expect(find.text('确认关闭本轮？'), findsOneWidget);
    expect(find.text('取消'), findsOneWidget);
    expect(find.text('确认执行'), findsOneWidget);
  });

  testWidgets('initial load requests only round list', (tester) async {
    final api = _FakeApiClient();
    await tester.pumpWidget(_wrap(true, apiClient: api));
    await tester.pumpAndSettle();

    expect(api.getPaths, ['/api/v1/admin/matching/rounds']);
    expect(api.postPaths, isEmpty);
    expect(find.text('查看审计记录'), findsOneWidget);
  });

  testWidgets('explicit open renders only bounded audit fields with GET', (
    tester,
  ) async {
    final api = _FakeApiClient(details: [Future.value(_validAuditResponse)]);
    await tester.pumpWidget(_wrap(true, apiClient: api));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('查看审计记录'));
    await tester.tap(find.text('查看审计记录'));
    await tester.pumpAndSettle();

    expect(api.getPaths, [
      '/api/v1/admin/matching/rounds',
      '/api/v1/admin/matching/rounds/round-1',
    ]);
    expect(api.postPaths, isEmpty);
    expect(find.bySemanticsLabel('匹配操作审计记录'), findsOneWidget);
    expect(find.text('操作：揭晓轮次'), findsOneWidget);
    expect(find.text('执行方：管理员 #7'), findsOneWidget);
    expect(find.text('原因：内部运营操作'), findsOneWidget);
    expect(find.text('时间：2026-08-05 10:15'), findsOneWidget);
    expect(find.text('状态：等待揭晓 v2 → 结果已揭晓 v3'), findsOneWidget);
    for (final forbidden in [
      'must-not-render',
      'forbidden-key',
      'forbidden-correlation',
      'forbidden-role',
      'forbidden-channel',
      'pair_count',
      'idempotency_key',
      'correlation_id',
      'role_snapshot',
      'aggregate_summary',
      'source_channel',
    ]) {
      expect(find.textContaining(forbidden), findsNothing);
    }
  });

  testWidgets('empty audits renders truthful empty state and GET refresh', (
    tester,
  ) async {
    final api = _FakeApiClient(
      details: [
        Future.value(const NetworkSuccess({'audits': []})),
        Future.value(const NetworkSuccess({'audits': []})),
      ],
    );
    await tester.pumpWidget(_wrap(true, apiClient: api));
    await tester.pumpAndSettle();

    await tester.tap(find.text('查看审计记录'));
    await tester.pumpAndSettle();
    expect(find.text('当前没有审计记录。'), findsOneWidget);

    await tester.tap(find.text('刷新审计记录'));
    await tester.pumpAndSettle();
    expect(api.getPaths.where((path) => path.endsWith('/round-1')).length, 2);
    expect(api.postPaths, isEmpty);
  });

  testWidgets('delayed response keeps audit-local loading state', (
    tester,
  ) async {
    final detail = Completer<NetworkResult<Map<String, dynamic>>>();
    final api = _FakeApiClient(details: [detail.future]);
    await tester.pumpWidget(_wrap(true, apiClient: api));
    await tester.pumpAndSettle();

    await tester.tap(find.text('查看审计记录'));
    await tester.pump();
    expect(find.text('正在读取审计记录…'), findsOneWidget);

    detail.complete(_validAuditResponse);
    await tester.pumpAndSettle();
    expect(find.text('操作：揭晓轮次'), findsOneWidget);
  });

  testWidgets('network failure retries only the exact detail GET', (
    tester,
  ) async {
    final api = _FakeApiClient(
      details: [
        Future.value(
          const NetworkFailure<Map<String, dynamic>>(message: 'private raw'),
        ),
        Future.value(_validAuditResponse),
      ],
    );
    await tester.pumpWidget(_wrap(true, apiClient: api));
    await tester.pumpAndSettle();

    await tester.tap(find.text('查看审计记录'));
    await tester.pumpAndSettle();
    expect(find.text('审计记录暂时不可用，请重试。'), findsOneWidget);
    expect(find.textContaining('private raw'), findsNothing);

    await tester.tap(find.text('重试审计记录'));
    await tester.pumpAndSettle();
    expect(find.text('操作：揭晓轮次'), findsOneWidget);
    expect(api.getPaths.where((path) => path.endsWith('/round-1')).length, 2);
    expect(api.postPaths, isEmpty);
  });

  testWidgets('non-list and malformed audits fail closed without raw values', (
    tester,
  ) async {
    final api = _FakeApiClient(
      details: [
        Future.value(
          const NetworkSuccess({
            'audits': {'raw': 'forbidden-map'},
          }),
        ),
        Future.value(
          const NetworkSuccess({
            'audits': [
              {
                'action': 'reveal',
                'actor_type': 'admin',
                'created_at': 'not-a-date',
                'idempotency_key': 'forbidden-row',
              },
            ],
          }),
        ),
      ],
    );
    await tester.pumpWidget(_wrap(true, apiClient: api));
    await tester.pumpAndSettle();

    await tester.tap(find.text('查看审计记录'));
    await tester.pumpAndSettle();
    expect(find.text('审计记录格式不可用，请重试。'), findsOneWidget);
    expect(find.textContaining('forbidden-map'), findsNothing);

    await tester.tap(find.text('重试审计记录'));
    await tester.pumpAndSettle();
    expect(find.text('审计记录格式不可用，请重试。'), findsOneWidget);
    expect(find.textContaining('forbidden-row'), findsNothing);
    expect(api.postPaths, isEmpty);
  });

  testWidgets('newer explicit request supersedes a stale detail response', (
    tester,
  ) async {
    final first = Completer<NetworkResult<Map<String, dynamic>>>();
    final second = Completer<NetworkResult<Map<String, dynamic>>>();
    final api = _FakeApiClient(details: [first.future, second.future]);
    await tester.pumpWidget(_wrap(true, apiClient: api));
    await tester.pumpAndSettle();

    await tester.tap(find.text('查看审计记录'));
    await tester.pump();
    await tester.tap(find.text('收起审计记录'));
    await tester.pump();
    await tester.tap(find.text('查看审计记录'));
    await tester.pump();

    second.complete(_validAuditResponse);
    await tester.pumpAndSettle();
    expect(find.text('操作：揭晓轮次'), findsOneWidget);

    first.complete(const NetworkSuccess({'audits': []}));
    await tester.pumpAndSettle();
    expect(find.text('操作：揭晓轮次'), findsOneWidget);
    expect(find.text('当前没有审计记录。'), findsNothing);
    expect(api.postPaths, isEmpty);
  });

  testWidgets('direct schedule state and unknown codes stay bounded', (
    tester,
  ) async {
    final api = _FakeApiClient(
      details: [
        Future.value(
          const NetworkSuccess({
            'audits': [
              {
                'action': 'raw-action-code',
                'actor_type': 'raw-actor-code',
                'reason_code': 'raw-reason-code',
                'created_at': '2026-08-05T08:00:00',
                'before_state': null,
                'after_state': {
                  'state': 'scheduled',
                  'private_nested_value': 'raw-private-value',
                },
              },
            ],
          }),
        ),
      ],
    );
    await tester.pumpWidget(_wrap(true, apiClient: api));
    await tester.pumpAndSettle();

    await tester.tap(find.text('查看审计记录'));
    await tester.pumpAndSettle();
    expect(find.text('操作：未知操作'), findsOneWidget);
    expect(find.text('执行方：未知执行方'), findsOneWidget);
    expect(find.text('原因：未分类原因'), findsOneWidget);
    expect(find.text('状态：已安排'), findsOneWidget);
    for (final raw in [
      'raw-action-code',
      'raw-actor-code',
      'raw-reason-code',
      'raw-private-value',
      'private_nested_value',
    ]) {
      expect(find.textContaining(raw), findsNothing);
    }
    expect(api.postPaths, isEmpty);
  });

  testWidgets('separated before-state compatibility still renders both sides', (
    tester,
  ) async {
    final api = _FakeApiClient(
      details: [
        Future.value(
          const NetworkSuccess({
            'audits': [
              {
                'action': 'close',
                'actor_type': 'admin',
                'created_at': '2026-08-05T11:00:00',
                'before_state': {'state': 'revealed', 'state_version': 3},
                'after_state': {
                  'after': {'state': 'closed', 'state_version': 4},
                },
              },
            ],
          }),
        ),
      ],
    );
    await tester.pumpWidget(_wrap(true, apiClient: api));
    await tester.pumpAndSettle();

    await tester.tap(find.text('查看审计记录'));
    await tester.pumpAndSettle();
    expect(find.text('状态：结果已揭晓 v3 → 已关闭 v4'), findsOneWidget);
    expect(api.postPaths, isEmpty);
  });

  testWidgets('server capabilities gate actions and explain missing consumer', (
    tester,
  ) async {
    final api = _FakeApiClient(
      roundState: 'preparing',
      capabilities: const {'execute': true},
      consumerConfigured: false,
    );
    await tester.pumpWidget(_wrap(true, apiClient: api));
    await tester.pumpAndSettle();

    expect(find.text('创建执行请求'), findsNothing);
    expect(find.textContaining('不代表匹配失败'), findsOneWidget);
    expect(api.postPaths, isEmpty);
  });

  testWidgets('failed operation never reports success and reloads fresh truth', (
    tester,
  ) async {
    final api = _FakeApiClient(
      roundState: 'preparing',
      capabilities: const {'execute': true},
      posts: const [
        NetworkFailure<Map<String, dynamic>>(
          message: 'raw private failure',
          statusCode: 503,
        ),
      ],
    );
    await tester.pumpWidget(_wrap(true, apiClient: api));
    await tester.pumpAndSettle();

    await tester.tap(find.text('创建执行请求'));
    await tester.pumpAndSettle();

    expect(find.textContaining('本地手动执行器未配置'), findsOneWidget);
    expect(find.textContaining('操作已接受'), findsNothing);
    expect(find.textContaining('raw private failure'), findsNothing);
    expect(api.getPaths.where((path) => path.endsWith('/rounds')).length, 2);
  });
}

import 'package:dio/dio.dart';
import 'dart:async';
import 'package:flutter_elitesync_module/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/connection/presentation/pages/live_connection_page.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';

class _Session extends SessionNotifier {
  void switchAccount() => state = AsyncData(
    SessionState(
      status: AuthStatus.authenticated,
      user: const UserSummary(id: 3, phone: 'fictional-three'),
    ),
  );
  @override
  SessionState build() => const SessionState(
    status: AuthStatus.authenticated,
    user: UserSummary(id: 1, phone: 'fictional-one'),
  );
}

Map<String, dynamic> _proposalEnvelope({
  String state = 'MUTUALLY_ACCEPTED',
  bool eligible = true,
}) => {
  'proposal': {
    'id': 'fictional-proposal-1',
    'match_id': 101,
    'round_id': 201,
    'run_id': 301,
    'revision': 2,
    'state': state,
    'decision_me': state == 'PENDING' ? 'PENDING' : 'ACCEPTED',
    'decision_peer': state == 'MUTUALLY_ACCEPTED' ? 'ACCEPTED' : 'PENDING',
    'peer_id': 2,
    'revealed_at': '2026-11-13T00:00:00Z',
    'expires_at': '2026-11-20T00:00:00Z',
    'showcase': {
      'public_id': 'ES-2',
      'summary': 'fictional profile',
      'interest_tags': <String>[],
      'lifestyle_tags': <String>[],
    },
    'explanation': {
      'categories': ['questionnaire_preferences'],
      'source': 'existing_matching_run',
      'uncertainty': '候选来自有限自填输入，不保证相处效果',
      'non_goals': ['不构成实人认证或恋爱事实', '不授予连接、消息或通话同意'],
    },
    'connection_eligible': eligible,
    'decision_available': state == 'PENDING' || state == 'ACCEPTED_BY_ONE',
    'withdraw_available': state == 'PENDING' || state == 'ACCEPTED_BY_ONE',
    'availability_reason': null,
  },
  'message': 'Use /journey for the authoritative journey',
};

class _Api extends ApiClient {
  _Api() : super(dio: Dio());
  String connection = 'CN_NONE';
  String consent = 'MC_NONE';
  int revision = 0;
  int? connectionId;
  int? consentId;
  int requester = 1;
  bool reject = false;
  bool noMatch = false;
  bool failMatch = false;
  Map<String, dynamic> currentMatch = _proposalEnvelope();
  int matchReads = 0;
  final List<String> connectionPaths = [];
  int reads = 0;
  int posts = 0;
  Object? body;
  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    if (path.endsWith('/matches/current')) {
      matchReads++;
      if (failMatch) {
        return const NetworkFailure(
          message: 'upstream_unavailable',
          statusCode: 503,
        );
      }
      if (noMatch) {
        return const NetworkSuccess({
          'proposal': null,
          'message': 'Use /journey for the authoritative journey',
        });
      }
      return NetworkSuccess(currentMatch);
    }
    reads++;
    connectionPaths.add(path);
    return NetworkSuccess({
      'peer_id': 2,
      'connection': {
        'id': connectionId,
        'state': connection,
        'revision': revision,
        'requester_id': requester,
      },
      'consent': {
        'id': consentId,
        'state': consent,
        'revision': revision,
        'requester_id': requester,
      },
      'gates': {'live_read_allowed': false, 'live_send_allowed': false},
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
    posts++;
    this.body = body;
    if (reject) {
      return const NetworkFailure(message: 'stale revision', statusCode: 409);
    }
    if (path.endsWith('/consent')) {
      consent = 'MC_PENDING';
    } else {
      connection = 'CN_PENDING';
    }
    revision++;
    return const NetworkSuccess({});
  }
}

Future<void> _show(WidgetTester tester, ApiClient api, {int? peerId}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        apiClientProvider.overrideWithValue(api),
        sessionProvider.overrideWith(_Session.new),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: LiveConnectionPage(peerId: peerId),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'current proposal envelope reaches connection request and readback',
    (tester) async {
      final api = _Api();
      await _show(tester, api);
      expect(api.connectionPaths, ['/api/v1/connections/2']);
      expect(find.text('请求连接'), findsOneWidget);
      await tester.tap(find.text('请求连接'));
      await tester.pumpAndSettle();
      expect(api.posts, 1);
      expect(find.textContaining('CN_PENDING'), findsOneWidget);
      expect(api.reads, 2);
    },
  );

  for (final condition in [
    ('PENDING', false),
    ('ACCEPTED_BY_ONE', false),
    ('MUTUALLY_ACCEPTED', false),
    ('PENDING', true),
  ]) {
    testWidgets(
      'proposal ${condition.$1}/${condition.$2} cannot dispatch connection read',
      (tester) async {
        final api = _Api()
          ..currentMatch = {
            ..._proposalEnvelope(state: condition.$1, eligible: condition.$2),
            'partner_id': 99,
          };
        await _show(tester, api);
        expect(api.reads, 0);
        expect(find.text('请求连接'), findsNothing);
        expect(find.textContaining('尚未具备连接资格'), findsOneWidget);
        expect(find.textContaining('操作未确认'), findsNothing);
      },
    );
  }

  testWidgets('null proposal cannot fall back to a flat legacy partner', (
    tester,
  ) async {
    final api = _Api()
      ..currentMatch = {
        'proposal': null,
        'message': 'Use /journey for the authoritative journey',
        'partner_id': 99,
      };
    await _show(tester, api);
    expect(api.reads, 0);
    expect(find.textContaining('暂无已发布的匹配对象'), findsOneWidget);
    expect(find.text('请求连接'), findsNothing);
  });

  testWidgets('legacy partner remains compatible only without proposal key', (
    tester,
  ) async {
    final api = _Api()..currentMatch = {'partner_id': 2};
    await _show(tester, api);
    expect(api.connectionPaths, ['/api/v1/connections/2']);
    expect(find.text('请求连接'), findsOneWidget);
  });

  testWidgets('explicit friend peer bypasses current proposal discovery', (
    tester,
  ) async {
    final api = _Api()..noMatch = true;
    await _show(tester, api, peerId: 2);
    expect(api.matchReads, 0);
    expect(api.connectionPaths, ['/api/v1/connections/2']);
    expect(find.text('请求连接'), findsOneWidget);
  });
  for (final terminal in [
    'CN_CLOSED',
    'CN_DECLINED',
    'CN_WITHDRAWN',
    'CN_EXPIRED',
  ]) {
    testWidgets(
      '$terminal can explicitly request a new connection with observed IDs',
      (tester) async {
        final api = _Api()
          ..connection = terminal
          ..consent = 'MC_REVOKED'
          ..revision = 4
          ..connectionId = 10
          ..consentId = 20;
        await _show(tester, api);
        expect(api.posts, 0);
        expect(find.text('重新请求消息同意'), findsNothing);
        await tester.tap(find.text('重新请求连接'));
        await tester.pumpAndSettle();
        expect(api.body, {
          'action': 'request',
          'expected_revision': 4,
          'expected_connection_id': 10,
          'expected_consent_id': 20,
        });
        expect(api.posts, 1);
        expect(api.reads, 2);
        expect(find.textContaining('CN_PENDING'), findsOneWidget);
        expect(find.text('撤回连接请求'), findsOneWidget);
        expect(find.text('接受连接'), findsNothing);
        expect(
          tester
              .widget<FilledButton>(find.widgetWithText(FilledButton, '进入消息'))
              .onPressed,
          isNull,
        );
      },
    );
  }

  for (final terminal in ['MC_REVOKED', 'MC_DECLINED', 'MC_WITHDRAWN']) {
    testWidgets(
      '$terminal can explicitly request a new consent generation with observed IDs',
      (tester) async {
        final api = _Api()
          ..connection = 'CN_ACTIVE'
          ..consent = terminal
          ..revision = 4
          ..connectionId = 10
          ..consentId = 20;
        await _show(tester, api);
        expect(api.posts, 0);
        await tester.ensureVisible(find.text('重新请求消息同意'));
        await tester.tap(find.text('重新请求消息同意'));
        await tester.pumpAndSettle();
        expect(api.body, {
          'action': 'request',
          'expected_revision': 4,
          'expected_connection_id': 10,
          'expected_consent_id': 20,
        });
        expect(api.posts, 1);
        expect(api.reads, 2);
        expect(find.textContaining('CN_ACTIVE'), findsOneWidget);
        expect(find.textContaining('MC_PENDING'), findsOneWidget);
        expect(find.text('撤回消息同意请求'), findsOneWidget);
        expect(find.text('接受消息同意'), findsNothing);
        expect(
          tester
              .widget<FilledButton>(find.widgetWithText(FilledButton, '进入消息'))
              .onPressed,
          isNull,
        );
      },
    );
  }
  testWidgets('successful empty match shows neutral guidance and can refresh', (
    tester,
  ) async {
    final api = _Api()..noMatch = true;
    await _show(tester, api);
    expect(find.textContaining('暂无已发布的匹配对象'), findsOneWidget);
    expect(find.textContaining('Bad state'), findsNothing);
    expect(find.textContaining('操作未确认'), findsNothing);
    expect(api.reads, 0);
    api.noMatch = false;
    await tester.tap(find.text('刷新当前状态'));
    await tester.pumpAndSettle();
    expect(find.textContaining('CN_NONE'), findsOneWidget);
    expect(find.textContaining('暂无已发布的匹配对象'), findsNothing);
  });

  testWidgets(
    'match failure remains a retryable error instead of empty success',
    (tester) async {
      final api = _Api()..failMatch = true;
      await _show(tester, api);
      expect(find.textContaining('暂时无法读取或更新连接，请稍后刷新重试'), findsOneWidget);
      expect(find.textContaining('暂无已发布的匹配对象'), findsNothing);
      expect(find.textContaining('Bad state'), findsNothing);
      api.failMatch = false;
      api.noMatch = true;
      await tester.tap(find.text('刷新当前状态'));
      await tester.pumpAndSettle();
      expect(find.textContaining('操作未确认'), findsNothing);
      expect(find.textContaining('暂无已发布的匹配对象'), findsOneWidget);
    },
  );
  testWidgets('switch during token await dispatches no consent choice', (
    tester,
  ) async {
    final entered = Completer<void>();
    final token = Completer<String?>();
    int postDispatches = 0;
    int tokenReads = 0;
    final dio = Dio();
    dio.interceptors.add(
      AuthInterceptor(
        accessTokenProvider: () {
          tokenReads++;
          if (tokenReads <= 2) return Future.value('test-fixture-only');
          if (!entered.isCompleted) entered.complete();
          return token.future;
        },
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) {
          if (request.method == 'POST') postDispatches++;
          final data = request.path.endsWith('/matches/current')
              ? _proposalEnvelope()
              : <String, dynamic>{
                  'connection': {
                    'state': 'CN_ACTIVE',
                    'revision': 2,
                    'requester_id': 1,
                  },
                  'consent': {
                    'state': 'MC_NONE',
                    'revision': 0,
                    'requester_id': null,
                  },
                  'gates': {
                    'live_read_allowed': false,
                    'live_send_allowed': false,
                  },
                };
          handler.resolve(
            Response(requestOptions: request, statusCode: 200, data: data),
          );
        },
      ),
    );
    await _show(tester, ApiClient(dio: dio));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
    expect(tokenReads, 2);
    await tester.ensureVisible(find.text('请求消息同意'));
    await tester.tap(find.text('请求消息同意'));
    for (var i = 0; i < 10 && !entered.isCompleted; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
    expect(entered.isCompleted, isTrue);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(LiveConnectionPage)),
    );
    (container.read(sessionProvider.notifier) as _Session).switchAccount();
    await tester.pump();
    token.complete('test-new-fixture-only');
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
    expect(postDispatches, 0);
    expect(find.textContaining('CN_ACTIVE'), findsNothing);
  });
  testWidgets(
    'request sends observed revision and re-reads state; self cannot accept',
    (tester) async {
      final api = _Api();
      await _show(tester, api);
      await tester.tap(find.text('请求连接'));
      await tester.pumpAndSettle();
      expect(api.body, {'action': 'request', 'expected_revision': 0});
      expect(api.reads, 2);
      expect(find.textContaining('CN_PENDING'), findsOneWidget);
      expect(find.text('接受连接'), findsNothing);
      expect(find.text('撤回连接请求'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, '进入消息'))
            .onPressed,
        isNull,
      );
    },
  );
  testWidgets('server refusal is explicit and clears stale action projection', (
    tester,
  ) async {
    final api = _Api()..reject = true;
    await _show(tester, api);
    await tester.tap(find.text('请求连接'));
    await tester.pumpAndSettle();
    expect(find.textContaining('连接状态已变化，请刷新后重试'), findsOneWidget);
    expect(find.textContaining('CN_PENDING'), findsNothing);
  });
  testWidgets('terminal consent stays unavailable until connection is active', (
    tester,
  ) async {
    await _show(
      tester,
      _Api()
        ..connection = 'CN_CLOSED'
        ..consent = 'MC_REVOKED',
    );
    expect(find.text('请求连接'), findsNothing);
    expect(find.text('请求消息同意'), findsNothing);
  });
  testWidgets('account switch immediately hides old peer and permissions', (
    tester,
  ) async {
    await _show(tester, _Api()..connection = 'CN_ACTIVE');
    expect(find.textContaining('CN_ACTIVE'), findsOneWidget);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(LiveConnectionPage)),
    );
    (container.read(sessionProvider.notifier) as _Session).switchAccount();
    await tester.pumpAndSettle();
    expect(find.textContaining('CN_ACTIVE'), findsNothing);
    expect(find.textContaining('对象 ID：2'), findsNothing);
  });
}

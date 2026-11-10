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
  Future<SessionState> build() async => const SessionState(
    status: AuthStatus.authenticated,
    user: UserSummary(id: 1, phone: 'fictional-one'),
  );
}

class _Api extends ApiClient {
  _Api() : super(dio: Dio());
  String connection = 'CN_NONE';
  String consent = 'MC_NONE';
  int revision = 0;
  int requester = 1;
  bool reject = false;
  int reads = 0;
  Object? body;
  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    if (path.endsWith('/matches/current')) {
      return const NetworkSuccess({'partner_id': 2});
    }
    reads++;
    return NetworkSuccess({
      'peer_id': 2,
      'connection': {
        'state': connection,
        'revision': revision,
        'requester_id': requester,
      },
      'consent': {
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
    this.body = body;
    if (reject) {
      return const NetworkFailure(message: 'stale revision', statusCode: 409);
    }
    connection = 'CN_PENDING';
    revision++;
    return const NetworkSuccess({});
  }
}

Future<void> _show(WidgetTester tester, ApiClient api) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        apiClientProvider.overrideWithValue(api),
        sessionProvider.overrideWith(_Session.new),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const LiveConnectionPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
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
              ? <String, dynamic>{'partner_id': 2}
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
    expect(find.textContaining('stale revision'), findsOneWidget);
    expect(find.textContaining('CN_PENDING'), findsNothing);
  });
  testWidgets('terminal state never offers new requests', (tester) async {
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

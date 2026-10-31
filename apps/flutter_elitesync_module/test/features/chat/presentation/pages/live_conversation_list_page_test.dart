import '../../../../support/synthetic_private_login.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/pages/live_conversation_list_page.dart';

class _Session extends SessionNotifier {
  void change() =>
      state = AsyncData(SessionState(status: AuthStatus.authenticated));
  @override
  Future<SessionState> build() async =>
      const SessionState(status: AuthStatus.authenticated,accessToken:'synthetic-only',user:UserSummary(id:1,phone:'synthetic'));
}

class _Api extends ApiClient {
  _Api() : super(dio: Dio());
  bool fail = false;
  bool hidden = false;
  bool hiddenFilter = false;
  bool eligibleMatchOnly = false;
  @override
  Future<NetworkResult<Map<String, dynamic>>> post(
    String path, {
    Object? body,
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    expect(path, '/api/v1/conversations/9/visibility');
    hidden = (body as Map)['hidden'] == true;
    return const NetworkSuccess({'ok': true});
  }

  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    hiddenFilter = query?['hidden_only'] == 1;
    if (fail) {
      return const NetworkFailure(
        message: 'permission revoked',
        statusCode: 403,
      );
    }
    if (hidden != hiddenFilter) {
      return const NetworkSuccess({'ok': true, 'items': []});
    }
    return NetworkSuccess({
      'ok': true,
      'items': [
        {
          'id': '2',
          'conversation_id': eligibleMatchOnly ? null : 9,
          'peer_user_id': 2,
          'name': '虚构对象',
          'last_message': '服务器消息',
          'unread': 3,
        },
      ],
    });
  }
}

Future<void> _show(WidgetTester tester, _Api api) async {
  final secure=await syntheticPrivateLogin();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        secureStorageProvider.overrideWithValue(secure),
        apiClientProvider.overrideWithValue(api),
        sessionProvider.overrideWith(_Session.new),
      ],
      child: const MaterialApp(home: LiveConversationListPage()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('eligible match without conversation id has no hide action', (
    tester,
  ) async {
    final api = _Api()..eligibleMatchOnly = true;
    await _show(tester, api);
    expect(find.text('虚构对象'), findsOneWidget);
    expect(find.byType(PopupMenuButton<String>), findsNothing);
    final tile = tester.widget<ListTile>(
      find.ancestor(of: find.text('虚构对象'), matching: find.byType(ListTile)),
    );
    expect(tile.onLongPress, isNull);
  });
  testWidgets('hide persists server view then hidden list can restore entry', (
    tester,
  ) async {
    final api = _Api();
    await _show(tester, api);
    await tester.longPress(find.text('虚构对象'));
    await tester.pumpAndSettle();
    expect(api.hidden, true);
    expect(find.text('虚构对象'), findsNothing);
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(api.hiddenFilter, true);
    expect(find.text('虚构对象'), findsOneWidget);
    await tester.longPress(find.text('虚构对象'));
    await tester.pumpAndSettle();
    expect(api.hidden, false);
    expect(find.text('虚构对象'), findsNothing);
  });
  testWidgets('server fields render and rejected refresh removes old data', (
    tester,
  ) async {
    final api = _Api();
    await _show(tester, api);
    expect(find.text('虚构对象'), findsOneWidget);
    expect(find.text('服务器消息'), findsOneWidget);
    expect(find.text('未读 3'), findsOneWidget);
    api.fail = true;
    await tester.tap(find.byTooltip('刷新会话'));
    await tester.pumpAndSettle();
    expect(find.text('虚构对象'), findsNothing);
    expect(find.textContaining('permission revoked'), findsOneWidget);
  });
  testWidgets('principal change clears prior list', (tester) async {
    await _show(tester, _Api());
    final container = ProviderScope.containerOf(
      tester.element(find.byType(LiveConversationListPage)),
    );
    (container.read(sessionProvider.notifier) as _Session).change();
    await tester.pumpAndSettle();
    expect(find.text('虚构对象'), findsNothing);
  });
}

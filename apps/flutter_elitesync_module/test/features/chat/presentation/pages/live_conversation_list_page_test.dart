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
      const SessionState(status: AuthStatus.authenticated);
}

class _Api extends ApiClient {
  _Api() : super(dio: Dio());
  bool fail = false;
  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    if (fail) {
      return const NetworkFailure(
        message: 'permission revoked',
        statusCode: 403,
      );
    }
    return const NetworkSuccess({
      'ok': true,
      'items': [
        {
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
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        apiClientProvider.overrideWithValue(api),
        sessionProvider.overrideWith(_Session.new),
      ],
      child: const MaterialApp(home: LiveConversationListPage()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
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

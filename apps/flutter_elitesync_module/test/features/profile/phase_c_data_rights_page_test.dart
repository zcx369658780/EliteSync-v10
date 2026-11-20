import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/data_rights_page.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Session extends SessionNotifier {
  @override
  SessionState build() =>
      const SessionState(status: AuthStatus.authenticated, accessToken: 'qa');
}

class _Api extends RelationshipApi {
  _Api(this.testOnly) : super(ApiClient(dio: Dio()));
  final bool testOnly;
  final writes = <String>[];
  final lookups = <String>[];

  @override
  Future<Map<String, dynamic>> call(
    String method,
    String path, [
    Map<String, dynamic>? payload,
  ]) async {
    if (method == 'POST') {
      writes.add(payload!['request_key'] as String);
      if (writes.length == 1) throw const RelationshipFailure('lost response');
      return {'state': 'REQUESTED_TEST_ONLY', 'test_only': true};
    }
    if (path.contains('/result?')) {
      lookups.add(Uri.parse(path).queryParameters['request_key']!);
      return {'state': 'NOT_APPLIED', 'test_only': true};
    }
    return {
      'channel': testOnly ? 'TEST_ONLY' : 'REQUEST_CHANNEL_UNAVAILABLE',
      'test_only': testOnly,
      'object_version': '1',
      'state': 'NO_REQUEST',
    };
  }
}

Future<void> _open(WidgetTester tester, _Api api) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sessionProvider.overrideWith(_Session.new),
        relationshipApiProvider.overrideWithValue(api),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () =>
                  openObjectDataRights(context, 'comment', 'test-key'),
              child: const Text('打开对象权限'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('打开对象权限'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'unavailable legal channel offers no submission or fake receipt',
    (tester) async {
      final api = _Api(false);
      await _open(tester, api);
      expect(find.text('目前没有已核实可受理此对象的渠道。'), findsOneWidget);
      expect(find.text('提交测试请求'), findsNothing);
      expect(api.writes, isEmpty);
    },
  );

  testWidgets(
    'uncertain test request must be checked before explicit same-key retry',
    (tester) async {
      final api = _Api(true);
      await _open(tester, api);
      await tester.tap(find.text('提交测试请求'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('确认'));
      await tester.pumpAndSettle();
      expect(api.writes, hasLength(1));
      expect(find.text('用原请求重试'), findsNothing);
      await tester.tap(find.text('核对原请求'));
      await tester.pumpAndSettle();
      expect(api.lookups, [api.writes.single]);
      expect(api.writes, hasLength(1));
      await tester.tap(find.text('用原请求重试'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('确认'));
      await tester.pumpAndSettle();
      expect(api.writes, [api.lookups.single, api.lookups.single]);
    },
  );
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/me/presentation/pages/me_landing_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/sanction_appeal_card.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _appeal(String note) => {
  'id': 8,
  'status': 'submitted',
  'submitted_at': '2026-10-15T10:00:00Z',
  'note': note,
};
Map<String, dynamic> _item({Map<String, dynamic>? appeal}) => {
  'id': 12,
  'kind': 'restrict',
  'created_at': '2026-10-15T09:00:00Z',
  'appeal': appeal,
};
Map<String, dynamic> _list({Map<String, dynamic>? appeal}) => {
  'items': [_item(appeal: appeal)],
  'notice': 'PRIVATE RAW NOTICE',
};

class _Api extends ApiClient {
  _Api() : super(dio: Dio());
  Map<String, dynamic> list = _list();
  final gets = <String>[];
  final posts = <({String path, Object? body})>[];
  NetworkResult<Map<String, dynamic>>? getFailure;
  NetworkResult<Map<String, dynamic>> response = NetworkSuccess({
    'appeal': _appeal('请核对本人的处罚'),
    'sanction_id': 12,
  }, statusCode: 201);

  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    gets.add(path);
    if (path == '/api/v1/profile/operating-status') {
      return const NetworkSuccess({
        'status': 'approved',
        'reason': '',
        'revision': 1,
        'moderation_status': 'restricted',
        'matching_eligibility': {
          'eligible': false,
          'reason_code': 'restricted',
          'next_action_code': 'none',
          'required_answer_count': 20,
          'answered_answer_count': 20,
          'missing_answer_count': 0,
        },
      });
    }
    return getFailure ?? NetworkSuccess(list);
  }

  @override
  Future<NetworkResult<Map<String, dynamic>>> post(
    String path, {
    Object? body,
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    posts.add((path: path, body: body));
    return response;
  }
}

Future<void> _mount(
  WidgetTester tester,
  _Api api, {
  bool landing = false,
  double scale = 1,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [apiClientProvider.overrideWithValue(api)],
      child: MaterialApp(
        theme: AppTheme.light,
        builder: (_, child) => MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: landing
            ? const MeLandingPage(restorationLocalBuild: true)
            : const Scaffold(
                body: SingleChildScrollView(child: SanctionAppealCard()),
              ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _open(WidgetTester tester) async {
  await tester.ensureVisible(find.text('查看本人处罚与申诉'));
  await tester.tap(find.text('查看本人处罚与申诉'));
  await tester.pumpAndSettle();
}

Future<void> _send(WidgetTester tester, [String note = '  请核对本人的处罚  ']) async {
  await tester.ensureVisible(find.byType(TextField));
  await tester.enterText(find.byType(TextField), note);
  await tester.ensureVisible(find.text('提交本人处罚申诉'));
  await tester.tap(find.text('提交本人处罚申诉'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'Actual Me entry loads only owner endpoint and does not grant permissions',
    (tester) async {
      final api = _Api();
      await _mount(tester, api, landing: true);
      expect(find.byType(SanctionAppealCard), findsOneWidget);
      expect(api.gets, ['/api/v1/profile/operating-status']);
      expect(find.text('当前不能参与新一轮匹配'), findsOneWidget);
      await _open(tester);
      expect(api.gets, [
        '/api/v1/profile/operating-status',
        '/api/v1/moderation/sanctions',
      ]);
      expect(find.text('受限处罚 #12'), findsOneWidget);
      expect(find.textContaining('自动解除处罚或恢复匹配'), findsOneWidget);
      expect(find.textContaining('PRIVATE RAW'), findsNothing);
      expect(api.posts, isEmpty);
    },
  );

  for (final code in [200, 201]) {
    testWidgets(
      'Confirmed $code displays submitted note without resubmission or permission writes',
      (tester) async {
        final api = _Api()
          ..response = NetworkSuccess({
            'appeal': _appeal('请核对本人的处罚'),
            'sanction_id': 12,
          }, statusCode: code);
        await _mount(tester, api);
        await _open(tester);
        await _send(tester);
        expect(api.posts.length, 1);
        expect(
          api.posts.single.path,
          '/api/v1/moderation/sanctions/12/appeals',
        );
        expect(api.posts.single.body, {'note': '请核对本人的处罚'});
        expect(find.text('申诉已提交，等待管理员查看'), findsOneWidget);
        expect(find.text('本人申诉：请核对本人的处罚'), findsOneWidget);
        expect(find.byType(TextField), findsNothing);
        expect(find.text('提交本人处罚申诉'), findsNothing);
        expect(api.gets, ['/api/v1/moderation/sanctions']);
      },
    );
  }

  testWidgets(
    'Empty note never posts; unavailable request retains draft for retry',
    (tester) async {
      final api = _Api()
        ..response = const NetworkFailure(message: 'PRIVATE', statusCode: 503);
      await _mount(tester, api);
      await _open(tester);
      await _send(tester, '   ');
      expect(api.posts, isEmpty);
      expect(find.text('请填写1至1000字的申诉说明。'), findsOneWidget);
      await _send(tester);
      expect(find.text('未确认申诉提交成功，请核对服务器记录后重试。'), findsOneWidget);
      expect(find.text('申诉已提交，等待管理员查看'), findsNothing);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '  请核对本人的处罚  ',
      );
      expect(api.gets.length, 2);
      api.response = NetworkSuccess({
        'appeal': _appeal('请核对本人的处罚'),
        'sanction_id': 12,
      }, statusCode: 201);
      await _send(tester);
      expect(find.text('申诉已提交，等待管理员查看'), findsOneWidget);
      expect(api.posts.length, 2);
      expect(find.textContaining('PRIVATE'), findsNothing);
    },
  );

  for (final code in [401, 403, 404, 409]) {
    testWidgets(
      '$code refuses submission and refreshes current state without raw error',
      (tester) async {
        final api = _Api()
          ..response = NetworkFailure(
            message: 'PRIVATE raw identity',
            statusCode: code,
          );
        await _mount(tester, api);
        await _open(tester);
        await _send(tester);
        expect(api.posts.length, 1);
        expect(api.gets, [
          '/api/v1/moderation/sanctions',
          '/api/v1/moderation/sanctions',
        ]);
        expect(find.text('申诉已提交，等待管理员查看'), findsNothing);
        expect(find.textContaining('PRIVATE'), findsNothing);
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          '  请核对本人的处罚  ',
        );
      },
    );
  }

  testWidgets(
    '409 displays existing server appeal rather than overwriting it',
    (tester) async {
      final api = _Api();
      await _mount(tester, api);
      await _open(tester);
      api.list = _list(appeal: _appeal('服务器原申诉'));
      api.response = const NetworkFailure(message: 'conflict', statusCode: 409);
      await _send(tester);
      expect(find.text('未重复提交：该处罚已有申诉，请核对服务器记录。'), findsOneWidget);
      expect(find.text('本人申诉：服务器原申诉'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(api.posts.length, 1);
    },
  );

  testWidgets(
    'Inactive sanction disappears on failed-submit refresh without success claim',
    (tester) async {
      final api = _Api();
      await _mount(tester, api);
      await _open(tester);
      api.list = {'items': [], 'notice': 'private'};
      api.response = const NetworkFailure(
        message: 'not found',
        statusCode: 404,
      );
      await _send(tester);
      expect(find.text('当前没有可申诉的有效受限处罚。'), findsOneWidget);
      expect(find.text('申诉已提交，等待管理员查看'), findsNothing);
      expect(find.byType(TextField), findsNothing);
    },
  );

  testWidgets(
    'Empty, malformed and inaccessible list fail safely and can refresh',
    (tester) async {
      final api = _Api()..list = {'items': [], 'notice': 'PRIVATE'};
      await _mount(tester, api);
      await _open(tester);
      expect(find.text('当前没有可申诉的有效受限处罚。'), findsOneWidget);
      api.list = {
        'items': [
          {'id': 12, 'kind': 'banned'},
        ],
      };
      await tester.tap(find.text('刷新本人处罚'));
      await tester.pumpAndSettle();
      expect(find.text('无法确认当前本人处罚，请重试读取。'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      api.getFailure = const NetworkFailure(
        message: 'PRIVATE',
        statusCode: 403,
      );
      await _open(tester);
      expect(find.text('无法确认当前本人处罚，请重试读取。'), findsOneWidget);
      api.getFailure = null;
      api.list = _list();
      await _open(tester);
      expect(find.text('受限处罚 #12'), findsOneWidget);
      expect(api.posts, isEmpty);
      expect(find.textContaining('PRIVATE'), findsNothing);
    },
  );

  testWidgets('Mismatched response does not report submission success', (
    tester,
  ) async {
    final api = _Api()
      ..response = NetworkSuccess({
        'appeal': _appeal('请核对本人的处罚'),
        'sanction_id': 99,
      }, statusCode: 201);
    await _mount(tester, api);
    await _open(tester);
    await _send(tester);
    expect(find.text('申诉已提交，等待管理员查看'), findsNothing);
    expect(find.text('未确认申诉提交成功，请核对服务器记录后重试。'), findsOneWidget);
  });

  testWidgets('Large text and keyboard remain scrollable without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final api = _Api();
    await _mount(tester, api, scale: 2);
    await _open(tester);
    await tester.ensureVisible(find.byType(TextField));
    await tester.enterText(find.byType(TextField), '申诉说明');
    await tester.ensureVisible(find.text('提交本人处罚申诉'));
    expect(tester.takeException(), isNull);
  });
}

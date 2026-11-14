import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/dynamic_chart_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/natal_restoration_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/tool_revision_history.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

const _endpoint = '/api/v1/profile/dynamic/7/history';

class _Session extends SessionNotifier {
  @override
  SessionState build() => const SessionState(
    status: AuthStatus.authenticated,
    user: UserSummary(id: 101, phone: ''),
    accessToken: 'fictional-first',
  );

  void change() => state = const AsyncData(
    SessionState(
      status: AuthStatus.authenticated,
      user: UserSummary(id: 202, phone: ''),
      accessToken: 'fictional-second',
    ),
  );
}

Map<String, dynamic> _history(int id, {int? next}) => {
  'items': [
    {
      'id': id,
      'input_revision': id,
      'status': 'COMPUTED_UNVERIFIED',
      'archived_at': '2026-11-14T08:00:00Z',
    },
  ],
  'next_before_id': next,
};

Map<String, dynamic> _chart({int id = 7, int revision = 1}) => {
  'id': id,
  'chart_type': 'comparison',
  'input_revision': revision,
  'result_revision': revision,
  'status': 'COMPUTED_UNVERIFIED',
  'request': {
    'chart_type': 'comparison',
    'first': {'source': 'own_natal', 'revision': 1},
    'second': {'source': 'own_natal', 'revision': 1},
  },
  'settings': {},
  'results': {
    'status': 'CALCULATED',
    'first': {'planets': []},
    'second': {'planets': []},
  },
};

Map<String, dynamic> _natal({int revision = 1}) => {
  'exists': true,
  'profile': {
    'input_revision': revision,
    'result_revision': revision,
    'input_signature': 'signature-$revision',
    'status': 'COMPUTED_UNVERIFIED',
    'input': {
      'civil_date': '1990-01-01',
      'civil_time': null,
      'time_precision': 'unknown',
      'timezone': 'Asia/Shanghai',
      'algorithm_sex': 'unknown',
    },
    'settings': {},
    'context': {},
    'results': {},
  },
};

/// UI contract doubles. Ordinary API/database evidence is collected separately.
class _Api extends ApiClient {
  _Api() : super(dio: Dio());
  Future<NetworkResult<Map<String, dynamic>>> Function(
    String path,
    Map<String, dynamic>? query,
  )?
  reading;
  int? firstPostFailure;
  int? firstDeleteFailure;
  int deletes = 0;
  int natalRevision = 1;
  Map<String, dynamic> chart = _chart();
  final writes = <Map<String, dynamic>>[];
  final writePaths = <String>[];

  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    if (reading != null) return reading!(path, query);
    if (path.endsWith('/natal')) {
      return NetworkSuccess(_natal(revision: natalRevision));
    }
    if (path.endsWith('/dynamic')) {
      return NetworkSuccess({
        'charts': [chart],
      });
    }
    return NetworkSuccess({'chart': chart});
  }

  @override
  Future<NetworkResult<Map<String, dynamic>>> post(
    String path, {
    Object? body,
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    writes.add(Map<String, dynamic>.from(jsonDecode(jsonEncode(body)) as Map));
    writePaths.add(path);
    if (writes.length == 1 && firstPostFailure != null) {
      return NetworkFailure(message: 'temporary', statusCode: firstPostFailure);
    }
    if (path.endsWith('/natal')) {
      natalRevision = 2;
      return NetworkSuccess(_natal(revision: natalRevision));
    }
    chart = _chart(id: 8);
    return NetworkSuccess({'chart': chart});
  }

  @override
  Future<NetworkResult<Map<String, dynamic>>> delete(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    deletes++;
    if (deletes == 1 && firstDeleteFailure != null) {
      return NetworkFailure(
        message: 'temporary',
        statusCode: firstDeleteFailure,
      );
    }
    return const NetworkSuccess({'deleted': true});
  }
}

Future<ProviderContainer> _mount(
  WidgetTester tester,
  _Api api,
  Widget child,
) async {
  tester.view.physicalSize = const Size(1000, 2200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final container = ProviderContainer(
    overrides: [
      sessionProvider.overrideWith(_Session.new),
      apiClientProvider.overrideWithValue(api),
    ],
  );
  addTearDown(container.dispose);
  await container.read(sessionProvider.future);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: child),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

Widget _historyWidget() => const Scaffold(
  body: SingleChildScrollView(
    child: ToolRevisionHistory(endpoint: _endpoint, detailKey: 'chart'),
  ),
);

Future<void> _tap(WidgetTester tester, String text) async {
  final finder = find.text(text);
  await tester.scrollUntilVisible(
    finder,
    400,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _openChart(WidgetTester tester) async {
  final menu = find.byKey(const ValueKey('history:null:1'));
  await tester.tap(menu);
  await tester.pumpAndSettle();
  await tester.tap(find.textContaining('#7').last);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
    'displayed history pagination403 clears old versions and cursor',
    (tester) async {
      final api = _Api()
        ..reading = (path, query) async => query == null
            ? NetworkSuccess(_history(1, next: 10))
            : const NetworkFailure(message: 'denied', statusCode: 403);
      await _mount(tester, api, _historyWidget());
      await _tap(tester, '读取历史版本');
      expect(find.byKey(const ValueKey('tool-revision-1')), findsOneWidget);
      await _tap(tester, '读取更早版本');
      expect(find.byKey(const ValueKey('tool-revision-1')), findsNothing);
      expect(find.text('读取更早版本'), findsNothing);
      expect(find.textContaining('当前历史不可用'), findsOneWidget);
    },
  );

  testWidgets('history503 retains old list and retries the same cursor', (
    tester,
  ) async {
    final cursors = <dynamic>[];
    final api = _Api()
      ..reading = (path, query) async {
        if (query == null) return NetworkSuccess(_history(1, next: 10));
        cursors.add(query['before_id']);
        return const NetworkFailure(message: 'temporary', statusCode: 503);
      };
    await _mount(tester, api, _historyWidget());
    await _tap(tester, '读取历史版本');
    await _tap(tester, '读取更早版本');
    expect(find.byKey(const ValueKey('tool-revision-1')), findsOneWidget);
    await _tap(tester, '读取更早版本');
    expect(cursors, [10, 10]);
  });

  testWidgets('old account delayed403 cannot clear new account history', (
    tester,
  ) async {
    final delayed = Completer<NetworkResult<Map<String, dynamic>>>();
    var generation = 0;
    final api = _Api()
      ..reading = (path, query) async {
        if (query != null) return delayed.future;
        return NetworkSuccess(_history(generation == 0 ? 1 : 2, next: 10));
      };
    final container = await _mount(tester, api, _historyWidget());
    await _tap(tester, '读取历史版本');
    await tester.tap(find.text('读取更早版本'));
    await tester.pump();
    generation = 1;
    (container.read(sessionProvider.notifier) as _Session).change();
    await tester.pumpAndSettle();
    await _tap(tester, '读取历史版本');
    delayed.complete(const NetworkFailure(message: 'denied', statusCode: 403));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('tool-revision-2')), findsOneWidget);
    expect(find.textContaining('当前历史不可用'), findsNothing);
  });

  testWidgets('old authority delayed403 cannot clear new authority history', (
    tester,
  ) async {
    final delayed = Completer<NetworkResult<Map<String, dynamic>>>();
    var generation = 0;
    final api = _Api()
      ..reading = (path, query) async {
        if (query != null) return delayed.future;
        return NetworkSuccess(_history(generation == 0 ? 1 : 2, next: 10));
      };
    final container = await _mount(tester, api, _historyWidget());
    await _tap(tester, '读取历史版本');
    await tester.tap(find.text('读取更早版本'));
    await tester.pump();
    generation = 1;
    container.read(relationshipAuthorityEpochProvider.notifier).invalidate();
    await tester.pumpAndSettle();
    await _tap(tester, '读取历史版本');
    delayed.complete(const NetworkFailure(message: 'denied', statusCode: 403));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('tool-revision-2')), findsOneWidget);
    expect(find.textContaining('当前历史不可用'), findsNothing);
  });

  testWidgets('history detail stays read-only beside the current draft', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'CURRENT_LEGAL_DRAFT');
    addTearDown(controller.dispose);
    final api = _Api()
      ..reading = (path, query) async => path == _endpoint
          ? NetworkSuccess(_history(1))
          : NetworkSuccess({
              'historical': true,
              'archived_at': '2026-11-14T08:00:00Z',
              'chart': _chart(),
            });
    await _mount(
      tester,
      api,
      Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: controller),
              const ToolRevisionHistory(
                endpoint: _endpoint,
                detailKey: 'chart',
              ),
            ],
          ),
        ),
      ),
    );
    await _tap(tester, '读取历史版本');
    await tester.tap(find.byKey(const ValueKey('tool-revision-1')));
    await tester.pumpAndSettle();
    expect(controller.text, 'CURRENT_LEGAL_DRAFT');
    expect(find.textContaining('旧版本 1 · comparison'), findsOneWidget);
    expect(find.text('保存、计算并持久重读'), findsNothing);
    expect(find.text('删除当前盘及历史'), findsNothing);
  });

  testWidgets('new chart503 retry preserves original UUID payload and path', (
    tester,
  ) async {
    final api = _Api()..firstPostFailure = 503;
    await _mount(tester, api, const DynamicChartPage());
    await _openChart(tester);
    await _tap(tester, '另建私有盘（保留当前表单）');
    await _tap(tester, '保存、计算并持久重读');
    expect(api.writes, hasLength(1));
    expect(api.writes.single['request_key'], isA<String>());
    await _tap(tester, '按原操作重试');
    expect(api.writes, hasLength(2));
    expect(api.writes[1], api.writes[0]);
    expect(api.writePaths, [
      '/api/v1/profile/dynamic',
      '/api/v1/profile/dynamic',
    ]);
    expect(find.textContaining('输入版本 1'), findsWidgets);
  });

  testWidgets('delete503 keeps current id and confirmation retry deletes it', (
    tester,
  ) async {
    final api = _Api()..firstDeleteFailure = 503;
    await _mount(tester, api, const DynamicChartPage());
    await _openChart(tester);
    await _tap(tester, '删除当前盘及历史');
    await tester.tap(find.text('确认删除'));
    await tester.pumpAndSettle();
    expect(api.deletes, 1);
    await tester.scrollUntilVisible(
      find.textContaining('原盘编号与输入已保留'),
      -400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('原盘编号与输入已保留'), findsOneWidget);
    await _tap(tester, '删除当前盘及历史');
    await tester.tap(find.text('确认删除'));
    await tester.pumpAndSettle();
    expect(api.deletes, 2);
    expect(find.text('删除当前盘及历史'), findsNothing);
    await tester.scrollUntilVisible(
      find.textContaining('当前私有盘已删除'),
      -400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('当前私有盘已删除'), findsOneWidget);
  });

  testWidgets('natal422 preserves the legal draft and permits correction', (
    tester,
  ) async {
    final api = _Api()..firstPostFailure = 422;
    await _mount(tester, api, const NatalRestorationPage());
    final date = find.widgetWithText(TextFormField, '出生日期');
    await tester.enterText(date, '1991-02-03');
    await _tap(tester, '保存、计算并持久重读');
    expect(find.textContaining('输入未通过校验'), findsOneWidget);
    await tester.scrollUntilVisible(
      date,
      -400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.widget<TextFormField>(date).enabled, true);
    expect(tester.widget<TextFormField>(date).controller!.text, '1991-02-03');
  });

  testWidgets('natal503 retries immutable original input and revision', (
    tester,
  ) async {
    final api = _Api()..firstPostFailure = 503;
    await _mount(tester, api, const NatalRestorationPage());
    final date = find.widgetWithText(TextFormField, '出生日期');
    await tester.enterText(date, '1991-02-03');
    await _tap(tester, '保存、计算并持久重读');
    expect(api.writes.single['expected_revision'], 1);
    expect(api.writes.single['input']['civil_date'], '1991-02-03');
    await _tap(tester, '按原操作重试');
    expect(api.writes, hasLength(2));
    expect(api.writes[1], api.writes[0]);
  });

  testWidgets('displayed chart pagination403 clears old chart choices', (
    tester,
  ) async {
    final api = _Api()
      ..reading = (path, query) async => query == null
          ? NetworkSuccess({
              'charts': [_chart()],
              'next_before_id': 7,
            })
          : const NetworkFailure(message: 'denied', statusCode: 403);
    await _mount(tester, api, const DynamicChartPage());
    expect(find.byKey(const ValueKey('history:null:1')), findsOneWidget);
    await _tap(tester, '加载更早历史');
    expect(find.byKey(const ValueKey('history:null:1')), findsNothing);
    expect(find.textContaining('当前排盘不可用'), findsOneWidget);
    final save = find.widgetWithText(FilledButton, '保存、计算并持久重读');
    await tester.scrollUntilVisible(
      save,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.widget<FilledButton>(save).onPressed, isNull);
  });
}

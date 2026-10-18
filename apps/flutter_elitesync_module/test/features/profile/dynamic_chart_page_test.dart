import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/dynamic_chart_page.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

class _Session extends SessionNotifier {
  @override
  Future<SessionState> build() async => const SessionState(
    status: AuthStatus.authenticated,
    user: UserSummary(id: 101, phone: 'fictional-A'),
    accessToken: 'fictional-A',
  );
  void change() => state = const AsyncData(
    SessionState(
      status: AuthStatus.authenticated,
      user: UserSummary(id: 202, phone: 'fictional-B'),
      accessToken: 'fictional-B',
    ),
  );
}

Map<String, dynamic> _row({String type = 'solar_return'}) => {
  'id': 7,
  'chart_type': type,
  'input_revision': 1,
  'result_revision': 1,
  'status': 'COMPUTED_UNVERIFIED',
  'settings': {},
  'request': {
    'chart_type': type,
    'first': {'source': 'own_natal', 'revision': 4},
    'second': {'source': 'own_natal', 'revision': 4},
    'event': {
      'year': 2026,
      'civil_date': '2026-01-01',
      'civil_time': '00:00:00',
      'time_precision': 'second',
      'timezone': 'UTC',
      'latitude': 0,
      'longitude': 0,
      'location_label': 'Fictional',
    },
  },
  'results': {
    'status': 'COMPUTED_UNVERIFIED',
    'first': {'planets': []},
    'events': [
      for (var i = 0; i < 2; i++)
        {
          'utc': '2026-01-0${i + 1}T00:00:00Z',
          'bracket_seconds': 0.1,
          'residual_degrees': 0.000001,
          'chart': {'planets': []},
        },
    ],
  },
};

/// UI contract fixtures only. These do not claim real API/database acceptance.
class _Api extends ApiClient {
  _Api() : super(dio: Dio());
  Map<String, dynamic> row = _row();
  final writes = <Map<String, dynamic>>[];
  Completer<NetworkResult<Map<String, dynamic>>>? delayed;
  bool delayDetail = false;
  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    if (path.endsWith('/dynamic')) {
      return NetworkSuccess({
        'charts': [row],
      });
    }
    if (delayDetail) {
      delayed = Completer();
      return delayed!.future;
    }
    return NetworkSuccess({'chart': row});
  }

  @override
  Future<NetworkResult<Map<String, dynamic>>> post(
    String path, {
    Object? body,
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    final payload = Map<String, dynamic>.from(body! as Map);
    writes.add(payload);
    row = {
      ...row,
      'input_revision': 2,
      'result_revision': 2,
      'request': payload,
    };
    return NetworkSuccess({'chart': row});
  }
}

Future<ProviderContainer> _mount(WidgetTester tester, _Api api) async {
  final container = ProviderContainer(
    overrides: [
      apiClientProvider.overrideWithValue(api),
      sessionProvider.overrideWith(_Session.new),
    ],
  );
  await container.read(sessionProvider.future);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: DynamicChartPage()),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

Future<void> _history(WidgetTester tester, {bool settle = true}) async {
  final finder = find.byKey(const ValueKey('history:null:1'));
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
  await tester.tap(find.textContaining('#7').last);
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }
}

Finder _pageScrollable() => find
    .descendant(
      of: find.byKey(const ValueKey('dynamic-chart-scroll')),
      matching: find.byType(Scrollable),
    )
    .first;

void main() {
  testWidgets('manual inputs have no noon timezone or coordinate defaults', (
    tester,
  ) async {
    final api = _Api();
    final container = await _mount(tester, api);
    addTearDown(container.dispose);
    final date = find.byKey(const ValueKey('第一盘.civil_date'));
    await tester.ensureVisible(date);
    expect(tester.widget<TextFormField>(date).controller!.text, isEmpty);
    final tz = find.byKey(const ValueKey('第一盘.timezone'));
    await tester.scrollUntilVisible(tz, 200, scrollable: _pageScrollable());
    expect(tester.widget<TextFormField>(tz).controller!.text, isEmpty);
    expect(api.writes, isEmpty);
  });
  testWidgets(
    'chart type exposes explicit solar year and does not score relationships',
    (tester) async {
      final api = _Api();
      final container = await _mount(tester, api);
      addTearDown(container.dispose);
      final type = find.byKey(const ValueKey('盘型:synastry'));
      await tester.ensureVisible(type);
      await tester.tap(type);
      await tester.pumpAndSettle();
      await tester.tap(find.text('太阳回归').last);
      await tester.pumpAndSettle();
      final year = find.byKey(const ValueKey('事件输入.year'));
      await tester.scrollUntilVisible(year, 250, scrollable: _pageScrollable());
      expect(tester.widget<TextFormField>(year).controller!.text, isEmpty);
      expect(find.text('关系评分'), findsNothing);
      expect(api.writes, isEmpty);
    },
  );
  testWidgets(
    'event selection persists expected revision then rereads before display',
    (tester) async {
      final api = _Api(), container = await _mount(tester, api);
      addTearDown(container.dispose);
      await _history(tester);
      final event = find.byKey(const ValueKey('event.1'));
      await tester.scrollUntilVisible(
        event,
        400,
        scrollable: _pageScrollable(),
      );
      await Scrollable.ensureVisible(tester.element(event), alignment: 0.5);
      await tester.pumpAndSettle();
      await tester.tap(event);
      await tester.pumpAndSettle();
      expect(api.writes, hasLength(1));
      expect(api.writes.single['selected_event_index'], 1);
      expect(api.writes.single['expected_revision'], 1);
      expect(api.writes.single['chart_type'], 'solar_return');
      expect(find.textContaining('输入版本 2'), findsOneWidget);
    },
  );
  testWidgets('editing input hides persisted result immediately', (
    tester,
  ) async {
    final api = _Api(), container = await _mount(tester, api);
    addTearDown(container.dispose);
    await _history(tester);
    final year = find.byKey(const ValueKey('事件输入.year'));
    await tester.scrollUntilVisible(year, 200, scrollable: _pageScrollable());
    await tester.enterText(year, '2027');
    await tester.pump();
    expect(find.textContaining('输入版本 1'), findsNothing);
    await tester.scrollUntilVisible(
      find.textContaining('旧结果已隐藏'),
      250,
      scrollable: _pageScrollable(),
    );
    expect(find.textContaining('旧结果已隐藏'), findsOneWidget);
  });
  testWidgets('late detail response cannot populate another account', (
    tester,
  ) async {
    final api = _Api(), container = await _mount(tester, api);
    addTearDown(container.dispose);
    api.delayDetail = true;
    await _history(tester, settle: false);
    expect(api.delayed, isNotNull);
    (container.read(sessionProvider.notifier) as _Session).change();
    await tester.pumpAndSettle();
    api.delayed!.complete(NetworkSuccess({'chart': _row()}));
    await tester.pumpAndSettle();
    expect(find.textContaining('输入版本 1'), findsNothing);
    expect(find.byKey(const ValueKey('event.0')), findsNothing);
  });
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/about_update_page.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _UpdateApiClient extends ApiClient {
  _UpdateApiClient({this.response}) : super(dio: Dio());
  Map<String, dynamic>? response;
  final List<Map<String, dynamic>> queries = [];

  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    queries.add(Map<String, dynamic>.from(query ?? {}));
    return NetworkSuccess(
      response ??
          {
            'source': 'database',
            'channel': 'stable',
            'changelog': 'Stable fixture release notes',
            'latest_version_name': '0.09.01',
            'has_update': true,
            'force_update': false,
            'download_url': 'https://example.invalid/app.apk',
          },
    );
  }
}

Widget _wrap(
  ExternalUrlLauncher launcher, {
  _UpdateApiClient? api,
  bool localBuild = false,
}) {
  return ProviderScope(
    overrides: [apiClientProvider.overrideWithValue(api ?? _UpdateApiClient())],
    child: MaterialApp(
      theme: AppTheme.light,
      home: AboutUpdatePage(
        externalUrlLauncher: launcher,
        v1008LocalBuild: localBuild,
      ),
    ),
  );
}

Future<void> _requestDownload(WidgetTester tester) async {
  await tester.ensureVisible(find.text('手动检查更新'));
  await tester.tap(find.text('手动检查更新'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('下载'));
  await tester.pumpAndSettle();
}

Future<void> _prepareViewport(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1000, 1800);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('Version shows explicit unchecked initial state', (tester) async {
    await _prepareViewport(tester);
    await tester.pumpWidget(_wrap((url) async => true));
    await tester.pumpAndSettle();

    expect(find.text('尚未手动检查更新'), findsOneWidget);
  });

  testWidgets('Version reports false external launcher result', (tester) async {
    await _prepareViewport(tester);
    await tester.pumpWidget(_wrap((url) async => false));
    await tester.pumpAndSettle();
    await _requestDownload(tester);

    expect(find.text('暂时无法打开下载页面，请稍后重试。'), findsOneWidget);
  });

  testWidgets('Version sanitizes thrown external launcher failure', (
    tester,
  ) async {
    await _prepareViewport(tester);
    await tester.pumpWidget(
      _wrap((url) async => throw Exception('raw launcher failure')),
    );
    await tester.pumpAndSettle();
    await _requestDownload(tester);

    expect(find.text('暂时无法打开下载页面，请稍后重试。'), findsOneWidget);
    expect(find.textContaining('raw launcher failure'), findsNothing);
  });
  testWidgets(
    'Local build queries development and displays database metadata',
    (tester) async {
      final api = _UpdateApiClient(
        response: {
          'source': 'database',
          'channel': 'development',
          'latest_version_name': '0.10.08',
          'has_update': false,
          'changelog': 'Development DB fixture notes',
        },
      );
      await _prepareViewport(tester);
      await tester.pumpWidget(
        _wrap((_) async => true, api: api, localBuild: true),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('手动检查更新'));
      await tester.tap(find.text('手动检查更新'));
      await tester.pumpAndSettle();
      expect(api.queries.single['channel'], 'development');
      expect(api.queries.single['platform'], 'android');
      expect(api.queries.single['version_name'], isA<String>());
      expect(find.text('development'), findsOneWidget);
      expect(find.text('数据库（database）'), findsOneWidget);
      expect(find.text('0.10.08'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Development DB fixture notes'),
        150,
      );
      expect(find.text('Development DB fixture notes'), findsOneWidget);
      expect(find.text('下载'), findsNothing);
    },
  );

  testWidgets('Stable build retains explicit download confirmation', (
    tester,
  ) async {
    final api = _UpdateApiClient();
    var launched = 0;
    await _prepareViewport(tester);
    await tester.pumpWidget(
      _wrap((_) async {
        launched++;
        return true;
      }, api: api),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('手动检查更新'));
    await tester.tap(find.text('手动检查更新'));
    await tester.pumpAndSettle();
    expect(api.queries.single['channel'], 'stable');
    expect(launched, 0);
    expect(find.text('下载'), findsOneWidget);
    await tester.tap(find.text('稍后'));
    await tester.pumpAndSettle();
    expect(launched, 0);
  });

  testWidgets(
    'Deactivated development release shows config fallback without production download',
    (tester) async {
      final api = _UpdateApiClient(
        response: {
          'source': 'config',
          'channel': 'development',
          'latest_version_name': '0.07.04',
          'has_update': true,
          'force_update': true,
          'download_url': 'https://production.invalid/old.apk',
          'changelog': 'Config fallback notes',
        },
      );
      var launched = 0;
      await _prepareViewport(tester);
      await tester.pumpWidget(
        _wrap(
          (_) async {
            launched++;
            return true;
          },
          api: api,
          localBuild: true,
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('手动检查更新'));
      await tester.tap(find.text('手动检查更新'));
      await tester.pumpAndSettle();
      expect(find.text('配置回退（config fallback），非数据库有效发布'), findsOneWidget);
      expect(find.text('开发渠道当前为配置回退，未确认数据库有效发布；不提供下载。'), findsOneWidget);
      expect(find.text('数据库（database）'), findsNothing);
      expect(find.text('下载'), findsNothing);
      expect(launched, 0);
    },
  );

  for (final source in [null, 'untrusted', true]) {
    testWidgets('Unknown source $source cannot confirm an update', (
      tester,
    ) async {
      final api = _UpdateApiClient(
        response: {
          'source': source,
          'channel': 'development',
          'latest_version_name': '99.00.00',
          'has_update': true,
          'force_update': true,
          'download_url': 'https://production.invalid/a.apk',
        },
      );
      var launched = false;
      await _prepareViewport(tester);
      await tester.pumpWidget(
        _wrap(
          (_) async {
            launched = true;
            return true;
          },
          api: api,
          localBuild: true,
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('手动检查更新'));
      await tester.tap(find.text('手动检查更新'));
      await tester.pumpAndSettle();
      expect(find.text('未知来源（unknown），更新未确认'), findsOneWidget);
      expect(find.text('版本来源未确认，无法确认更新；请稍后重试。'), findsOneWidget);
      expect(find.text('下载'), findsNothing);
      expect(launched, false);
    });
  }

  testWidgets('Database metadata from the wrong channel is unconfirmed', (
    tester,
  ) async {
    final api = _UpdateApiClient(
      response: {
        'source': 'database',
        'channel': 'stable',
        'latest_version_name': '99.00.00',
        'has_update': true,
        'download_url': 'https://production.invalid/a.apk',
      },
    );
    await _prepareViewport(tester);
    await tester.pumpWidget(
      _wrap((_) async => true, api: api, localBuild: true),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('手动检查更新'));
    await tester.tap(find.text('手动检查更新'));
    await tester.pumpAndSettle();
    expect(find.text('未知来源（unknown），更新未确认'), findsOneWidget);
    expect(find.text('下载'), findsNothing);
  });
}

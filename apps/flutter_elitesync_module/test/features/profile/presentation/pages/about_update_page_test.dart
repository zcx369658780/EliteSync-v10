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
  _UpdateApiClient() : super(dio: Dio());

  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    return const NetworkSuccess({
      'latest_version_name': '0.09.01',
      'has_update': true,
      'force_update': false,
      'download_url': 'https://example.invalid/app.apk',
    });
  }
}

Widget _wrap(ExternalUrlLauncher launcher) {
  return ProviderScope(
    overrides: [apiClientProvider.overrideWithValue(_UpdateApiClient())],
    child: MaterialApp(
      theme: AppTheme.light,
      home: AboutUpdatePage(externalUrlLauncher: launcher),
    ),
  );
}

Future<void> _requestDownload(WidgetTester tester) async {
  await tester.tap(find.text('手动检查更新'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('下载'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Version shows explicit unchecked initial state', (tester) async {
    await tester.pumpWidget(_wrap((url) async => true));
    await tester.pumpAndSettle();

    expect(find.text('尚未手动检查更新'), findsOneWidget);
  });

  testWidgets('Version reports false external launcher result', (tester) async {
    await tester.pumpWidget(_wrap((url) async => false));
    await tester.pumpAndSettle();
    await _requestDownload(tester);

    expect(find.text('暂时无法打开下载页面，请稍后重试。'), findsOneWidget);
  });

  testWidgets('Version sanitizes thrown external launcher failure', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap((url) async => throw Exception('raw launcher failure')),
    );
    await tester.pumpAndSettle();
    await _requestDownload(tester);

    expect(find.text('暂时无法打开下载页面，请稍后重试。'), findsOneWidget);
    expect(find.textContaining('raw launcher failure'), findsNothing);
  });
}

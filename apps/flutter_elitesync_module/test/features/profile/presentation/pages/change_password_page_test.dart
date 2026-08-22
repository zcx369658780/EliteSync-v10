import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/change_password_page.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _PasswordFailureApiClient extends ApiClient {
  _PasswordFailureApiClient() : super(dio: Dio());

  @override
  Future<NetworkResult<Map<String, dynamic>>> post(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    return const NetworkFailure(message: 'raw remote password failure');
  }
}

void main() {
  testWidgets('Password failure is sanitized without changing submission', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(_PasswordFailureApiClient()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ChangePasswordPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Current123');
    await tester.enterText(fields.at(1), 'NextPass456');
    await tester.enterText(fields.at(2), 'NextPass456');
    await tester.tap(find.text('保存新密码'));
    await tester.pumpAndSettle();

    expect(find.text('密码修改未完成，请稍后重试。'), findsOneWidget);
    expect(find.textContaining('raw remote password failure'), findsNothing);
    expect(find.text('密码修改成功'), findsNothing);
  });
}

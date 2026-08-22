import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/admin/data/datasource/admin_moderation_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:flutter_elitesync_module/features/admin/presentation/providers/admin_moderation_provider.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

String _visibleText(WidgetTester tester) {
  return tester
      .widgetList<Text>(find.byType(Text))
      .map((text) => text.data ?? '')
      .where((text) => text.isNotEmpty)
      .join('\n');
}

void main() {
  testWidgets('AdminDashboardPage shows 8.2 read-only governance overview', (
    tester,
  ) async {
    final remote = AdminModerationRemoteDataSource(
      apiClient: ApiClient(dio: Dio(BaseOptions(baseUrl: 'http://127.0.0.1'))),
      useMock: true,
      useMockAdmin: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvProvider.overrideWithValue(
            const AppEnv(
              flavor: AppFlavor.dev,
              appName: 'test',
              apiBaseUrl: 'http://127.0.0.1/',
              useMockData: false,
            ),
          ),
          adminModerationRemoteDataSourceProvider.overrideWithValue(remote),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          home: const AdminDashboardPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('运营看板'), findsWidgets);
    expect(find.text('总用户'), findsOneWidget);
    expect(find.text('待处理举报'), findsOneWidget);

    expect(find.text('8.2 运营可视化准备'), findsOneWidget);
    expect(find.text('版本状态'), findsOneWidget);
    expect(find.text('云端数据库'), findsOneWidget);
    expect(find.text('观测入口'), findsOneWidget);
    expect(find.text('只读'), findsOneWidget);
    expect(find.text('待核验'), findsOneWidget);
    expect(find.text('索引化'), findsOneWidget);
    expect(find.text('以当前安装包、版本中心和检查更新结果为准；这里不声明新的发布验收。'), findsOneWidget);
    expect(_visibleText(tester), isNot(contains('5.4 只读运营准备')));
    expect(_visibleText(tester), isNot(contains('0.05.04 / 50400')));

    await tester.scrollUntilVisible(
      find.text('观测与回归核验入口'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('观测与回归核验入口'), findsOneWidget);
    expect(find.text('Health / Version'), findsOneWidget);
    expect(find.text('Notification'), findsOneWidget);
    expect(find.text('Media'), findsOneWidget);
    expect(find.text('RTC / LiveKit'), findsOneWidget);
    expect(find.text('边界保护'), findsOneWidget);

    await tester.tap(find.text('Health / Version'));
    await tester.pumpAndSettle();

    expect(find.text('Health / Version · 待采证'), findsOneWidget);
    expect(find.text('核验说明'), findsOneWidget);
    expect(find.text('采集当前安装包的版本中心截图与 XML。'), findsOneWidget);
    expect(find.text('禁止动作：不执行生产写库、不改接口协议、不把待核验写成已通过。'), findsOneWidget);

    await tester.tap(find.text('知道了'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Queue / Logs'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Queue / Logs'), findsOneWidget);
    expect(find.text('待接入'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('测试账号治理'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('测试账号治理'), findsOneWidget);
    expect(find.text('测试账号 3'), findsOneWidget);
    expect(find.text('合成用户 2'), findsOneWidget);
    expect(find.text('排除指标 3'), findsOneWidget);
    expect(find.text('广场可见合成 2', skipOffstage: false), findsOneWidget);
    expect(
      find.text('账号清理、可见性调整和指标排除仍需通过后续 runbook 或后台最小确认流执行。'),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.text('Smoke / Regression Matrix'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Smoke / Regression Matrix'), findsOneWidget);
    expect(find.text('Login / Profile Truth'), findsOneWidget);
    expect(find.text('Discover / Match / Status'), findsOneWidget);

    await tester.tap(find.text('Login / Profile Truth'));
    await tester.pumpAndSettle();

    expect(find.text('Login / Profile Truth · 待采证'), findsOneWidget);
    expect(find.text('不在仓库记录密码或 token。'), findsOneWidget);
    expect(
      find.text('Runbook：docs/runbooks/SYNTHETIC_ACCOUNT_GOVERNANCE.md'),
      findsOneWidget,
    );

    await tester.tap(find.text('知道了'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Media / RTC / Version Center'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Messages / Chat / Notification'), findsOneWidget);
    expect(find.text('Media / RTC / Version Center'), findsOneWidget);
    expect(find.text('保护面'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('备份 / 恢复 / 迁移 readiness'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('备份 / 恢复 / 迁移 readiness'), findsOneWidget);
    expect(find.text('备份存在性'), findsOneWidget);
    expect(find.text('恢复演练'), findsOneWidget);
    expect(find.text('待确认'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('迁移状态'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('迁移状态'), findsOneWidget);
    expect(find.textContaining('不从前端或 Codex 直接执行迁移'), findsOneWidget);

    await tester.tap(find.text('迁移状态'));
    await tester.pumpAndSettle();

    expect(find.text('迁移状态 · 只读'), findsOneWidget);
    expect(
      find.text('Runbook：docs/runbooks/BACKUP_RESTORE_AND_MIGRATION_CHECK.md'),
      findsOneWidget,
    );
    expect(
      find.text('pending migration 只能记录，不能由 Flutter 页面执行。'),
      findsOneWidget,
    );

    await tester.tap(find.text('知道了'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Runbook Library'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Runbook Library'), findsOneWidget);
    expect(find.text('Cloud Read-only DB Audit'), findsOneWidget);
    expect(find.text('Backup / Restore / Migration'), findsOneWidget);

    await tester.tap(find.text('Cloud Read-only DB Audit'));
    await tester.pumpAndSettle();

    expect(find.text('Cloud Read-only DB Audit · runbook'), findsOneWidget);
    expect(
      find.text('Runbook：docs/runbooks/CLOUD_READONLY_DB_ACCESS_AND_AUDIT.md'),
      findsOneWidget,
    );
    expect(find.text('任何写库需求必须升级为用户确认或 blocker。'), findsOneWidget);

    await tester.tap(find.text('知道了'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Synthetic Account Governance'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Synthetic Account Governance'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('治理入口'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('治理入口'), findsOneWidget);
    expect(find.text('运营后台'), findsOneWidget);
    expect(find.text('认证审核'), findsOneWidget);
    expect(find.text('用户列表'), findsOneWidget);
  });
}

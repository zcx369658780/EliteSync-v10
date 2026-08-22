import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/legal_document_card.dart';
import 'package:flutter_elitesync_module/design_system/components/feedback/app_confirm_dialog.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

typedef ExternalUrlLauncher = Future<bool> Function(Uri url);

Future<bool> _launchExternalUrl(Uri url) {
  return launchUrl(url, mode: LaunchMode.externalApplication);
}

class AboutUpdatePage extends ConsumerStatefulWidget {
  const AboutUpdatePage({
    super.key,
    this.externalUrlLauncher = _launchExternalUrl,
  });

  final ExternalUrlLauncher externalUrlLauncher;

  @override
  ConsumerState<AboutUpdatePage> createState() => _AboutUpdatePageState();
}

class _AboutUpdatePageState extends ConsumerState<AboutUpdatePage> {
  String _productVersion = '-';
  String _moduleVersionName = '-';
  String _status = '尚未手动检查更新';
  bool _checking = false;
  String _historyTitle = '更新历史';
  List<String> _historyItems = const ['更新记录加载中...'];
  String _qualificationTitle = '资质';
  List<String> _qualificationItems = const ['资质信息加载中...'];

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _loadLocalAboutConfig();
  }

  Future<void> _loadVersion() async {
    if (!mounted) return;
    String moduleVersionName = '-';
    String productVersion = '-';
    try {
      final info = await PackageInfo.fromPlatform();
      moduleVersionName = info.version;
    } catch (_) {
      // Keep fallback text when package info is unavailable.
    }

    try {
      const channel = MethodChannel('elitesync/bootstrap');
      final payload = await channel.invokeMapMethod<dynamic, dynamic>(
        'getBootstrap',
      );
      if (payload != null) {
        final map = payload.map(
          (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
        );
        productVersion = (map['appVersionName'] ?? '').trim();
      }
    } catch (_) {
      // Ignore missing bootstrap channel and fall back to module version.
    }

    if (productVersion.isEmpty) {
      productVersion = moduleVersionName;
    }
    if (!mounted) return;
    setState(() {
      _productVersion = productVersion;
      _moduleVersionName = moduleVersionName;
    });
  }

  Future<void> _loadLocalAboutConfig() async {
    try {
      final raw = await rootBundle.loadString(
        'assets/config/about_update_0_xx.json',
      );
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) return;
      if (!mounted) return;
      setState(() {
        _historyTitle = (json['history_title'] ?? _historyTitle).toString();
        _qualificationTitle =
            (json['qualification_title'] ?? _qualificationTitle).toString();
        _historyItems = (json['history_items'] is List)
            ? (json['history_items'] as List)
                  .map((e) => sanitizeVisibleUpdateHistoryCopy(e.toString()))
                  .toList()
            : _historyItems;
        _qualificationItems = (json['qualifications'] is List)
            ? (json['qualifications'] as List).map((e) => e.toString()).toList()
            : _qualificationItems;
      });
    } catch (_) {
      // Keep fallback text when local config is unavailable.
    }
  }

  Future<void> _checkUpdate() async {
    setState(() {
      _checking = true;
      _status = '';
    });
    final api = ref.read(apiClientProvider);
    final result = await api.get(
      '/api/v1/app/version/check',
      query: {
        'platform': 'android',
        'channel': 'stable',
        'version_name': _productVersion == _moduleVersionName
            ? _moduleVersionName
            : _productVersion,
      },
    );
    if (!mounted) return;
    setState(() => _checking = false);

    if (result is NetworkFailure<Map<String, dynamic>>) {
      setState(() => _status = '暂时无法检查更新，请稍后重试。');
      return;
    }

    final data = (result as NetworkSuccess<Map<String, dynamic>>).data;
    final latest = (data['latest_version_name'] ?? '').toString();
    final hasUpdate = data['has_update'] == true;
    final forceUpdate = data['force_update'] == true;
    final downloadUrl = (data['download_url'] ?? '').toString();
    setState(() {
      _status = hasUpdate ? '发现可用版本: $latest' : '当前已是可用版本（最新版本参考: $latest）';
    });

    if (!hasUpdate || downloadUrl.isEmpty) return;
    final confirmed = await AppConfirmDialog.show(
      context,
      title: forceUpdate ? '需要更新后继续使用' : '发现可用版本',
      message: forceUpdate
          ? '当前产品版本 $_productVersion，最新版本 $latest。请下载更新包后继续使用。'
          : '当前产品版本 $_productVersion，最新版本 $latest。是否下载更新包？',
      confirmLabel: '下载',
      cancelLabel: '稍后',
    );
    if (!confirmed) return;
    try {
      final launched = await widget.externalUrlLauncher(Uri.parse(downloadUrl));
      if (!launched && mounted) {
        setState(() => _status = '暂时无法打开下载页面，请稍后重试。');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _status = '暂时无法打开下载页面，请稍后重试。');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AppScaffold(
      appBar: const AppTopBar(title: '版本中心', mode: AppTopBarMode.backTitle),
      body: ListView(
        padding: EdgeInsets.fromLTRB(0, t.spacing.sm, 0, t.spacing.xl),
        children: [
          SectionReveal(
            child: PageTitleRail(
              title: '查看当前版本与更新说明',
              subtitle: '这里显示本机安装版本，更新检查需手动触发',
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 35),
            child: AppInfoSectionCard(
              title: '当前版本',
              subtitle: '本机安装版本与手动更新状态',
              leadingIcon: Icons.system_update_alt_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _KeyValueLine(label: '产品版本', value: _productVersion),
                  if (_status.isNotEmpty) ...[
                    SizedBox(height: t.spacing.xs),
                    Text(
                      _status,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: t.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 20),
            child: AppPrimaryButton(
              label: '手动检查更新',
              isLoading: _checking,
              onPressed: _checkUpdate,
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 40),
            child: AppInfoSectionCard(
              title: '更新说明',
              subtitle: '本机版本说明',
              leadingIcon: Icons.assignment_turned_in_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '这里展示当前安装包与本地更新说明；是否有可用更新，以手动检查结果为准。',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 60),
            child: AppInfoSectionCard(
              title: '遇到版本问题？把问题整理一下',
              subtitle: '在本机整理可复制反馈，由你选择发送方式',
              leadingIcon: Icons.rate_review_outlined,
              child: AppSecondaryButton(
                label: '反馈版本或更新问题',
                fullWidth: true,
                prefixIcon: const Icon(Icons.rate_review_outlined),
                onPressed: () => context.push(
                  Uri(
                    path: AppRouteNames.innerTestFeedback,
                    queryParameters: {
                      'category': 'bug_report',
                      'source': 'version_center',
                    },
                  ).toString(),
                ),
              ),
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 70),
            child: LegalDocumentCard(
              title: _qualificationTitle,
              lines: _qualificationItems,
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 100),
            child: LegalDocumentCard(
              title: _historyTitle,
              lines: _historyItems,
            ),
          ),
        ],
      ),
    );
  }
}

String sanitizeVisibleUpdateHistoryCopy(String text) {
  return text
      .replaceAll('Alpha', '内测体验')
      .replaceAll('mock', '示例')
      .replaceAll('SmokeUser', '示例用户')
      .replaceAll('smokeuser', '示例用户')
      .replaceAll('smoke', '回归检查')
      .replaceAll('oracle', '对照校验')
      .replaceAll('release-chain', '版本发布流程')
      .replaceAll('Flutter 模块版本', '页面模块版本')
      .replaceAll('Flutter module AAR', '页面模块包')
      .replaceAll('module sync', '模块同步')
      .replaceAll('route_mode', '显示路线')
      .replaceAll('advanced-context', '高级预览语境')
      .replaceAll('stage', '阶段')
      .replaceAll('staging', '预发布环境')
      .replaceAll('endpoint', '服务入口')
      .replaceAll('schema', '数据结构')
      .replaceAll('真值', '资料来源')
      .replaceAll('同城', '共同兴趣')
      .replaceAll('api / ws', '应用数据连接')
      .replaceAll('API / WS', '应用数据连接')
      .replaceAll('api', '数据连接')
      .replaceAll('API', '数据连接')
      .replaceAll('ws', '实时连接')
      .replaceAll('WS', '实时连接')
      .replaceAll('production ready', '生产整体就绪')
      .replaceAll('完整版本发布流程 ready', '完整版本发布流程就绪')
      .replaceAll('接口', '数据连接');
}

class _KeyValueLine extends StatelessWidget {
  const _KeyValueLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: t.textPrimary, height: 1.45),
          ),
        ),
      ],
    );
  }
}

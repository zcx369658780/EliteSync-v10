import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route_names.dart';
import '../../../../design_system/components/layout/ui_s3_canvas.dart';
import '../providers/astro_chart_settings_provider.dart';
import '../providers/natal_restoration_provider.dart';
import '../widgets/natal_restoration_charts.dart';
import '../widgets/tool_revision_history.dart';
import 'natal_restoration_page.dart';

enum _Chart {
  bazi('八字', UiS3Backdrop.bazi),
  ziwei('紫微', UiS3Backdrop.ziwei),
  western('西洋占星', UiS3Backdrop.western);

  const _Chart(this.label, this.backdrop);
  final String label;
  final UiS3Backdrop backdrop;
}

class MyChartsPage extends ConsumerStatefulWidget {
  const MyChartsPage({super.key});

  @override
  ConsumerState<MyChartsPage> createState() => _MyChartsPageState();
}

class _MyChartsPageState extends ConsumerState<MyChartsPage> {
  _Chart _chart = _Chart.bazi;

  Future<void> _edit({bool settings = false}) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) =>
            NatalRestorationPage(showEditorOnly: true, settingsOnly: settings),
      ),
    );
    if (mounted) ref.invalidate(natalRestorationProvider);
  }

  Future<void> _openTools() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheet) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final entry in const {
                'birth': '出生资料',
                'history': '历史命盘',
                'settings': '计算设置',
                'details': '来源、精度与高级工具',
              }.entries)
                ListTile(
                  title: Text(entry.value),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pop(sheet, entry.key),
                ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || selected == null) return;
    switch (selected) {
      case 'birth':
        await _edit();
      case 'settings':
        await _edit(settings: true);
      case 'history':
        await Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('历史命盘')),
              body: const UiS3Canvas(
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: ToolRevisionHistory(
                      endpoint: '/api/v1/profile/natal/history',
                      detailKey: 'profile',
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      case 'details':
        await Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (page) => Scaffold(
              appBar: AppBar(title: const Text('来源、精度与高级工具')),
              body: UiS3Canvas(
                child: SafeArea(
                  child: ListView(
                    children: [
                      const ListTile(
                        title: Text('计算说明'),
                        subtitle: Text(
                          '各盘列出计算来源和核验范围。三盘用于兴趣探索，不影响匹配资格，也不用于判断性格。',
                        ),
                      ),
                      ListTile(
                        title: const Text('原有盘面与高级工具'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => page.push(AppRouteNames.astroProfile),
                      ),
                      ListTile(
                        title: const Text('显示设置'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () =>
                            page.push(AppRouteNames.astroChartSettings),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(natalRestorationProvider);
    final prefs = ref.watch(astroChartSettingsProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的三盘'),
        actions: [
          IconButton(
            tooltip: '命盘管理',
            icon: const Icon(Icons.tune),
            onPressed: _openTools,
          ),
        ],
      ),
      body: UiS3Canvas(
        kind: _chart.backdrop,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  children: [
                    for (final chart in _Chart.values)
                      ChoiceChip(
                        label: Text(chart.label),
                        selected: chart == _chart,
                        selectedColor: theme.colorScheme.primary,
                        checkmarkColor: theme.colorScheme.onPrimary,
                        labelStyle: chart == _chart
                            ? TextStyle(color: theme.colorScheme.onPrimary)
                            : null,
                        onSelected: (_) => setState(() => _chart = chart),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  key: PageStorageKey('chart-${_chart.name}'),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    current.when(
                      skipLoadingOnReload: false,
                      skipLoadingOnRefresh: false,
                      loading: () => const LinearProgressIndicator(
                        semanticsLabel: '正在读取当前命盘',
                      ),
                      error: (_, _) => Column(
                        children: [
                          const Text('暂时无法读取命盘，请检查登录和网络。'),
                          OutlinedButton(
                            onPressed: () =>
                                ref.invalidate(natalRestorationProvider),
                            child: const Text('重新读取'),
                          ),
                        ],
                      ),
                      data: (profile) {
                        if (profile == null) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text('填写一次出生资料，即可计算三盘。资料仅自己可见。'),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: _edit,
                                child: const Text('填写出生资料'),
                              ),
                            ],
                          );
                        }
                        final status = profile['status'];
                        final ready =
                            status == 'COMPUTED_UNVERIFIED' ||
                            status == 'COMPUTED';
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              '当前命盘 · 版本 ${natalText(profile['result_revision'])}',
                              style: theme.textTheme.titleMedium,
                            ),
                            if (ready)
                              NatalRestorationCharts(
                                key: ValueKey(_chart),
                                results: natalMap(profile['results']),
                                section: _chart.name,
                                displayPrefs: prefs,
                                locationLabel: natalMap(
                                  profile['input'],
                                )['location_label']?.toString(),
                                backdrop: _chart.backdrop,
                              )
                            else
                              Text(
                                status == 'FAILED'
                                    ? '本次计算失败，请检查出生资料。'
                                    : '结果尚未就绪，请重新读取。',
                              ),
                            if (!ready)
                              OutlinedButton(
                                onPressed: () =>
                                    ref.invalidate(natalRestorationProvider),
                                child: const Text('重新读取'),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

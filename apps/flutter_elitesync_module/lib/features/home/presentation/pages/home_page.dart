import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/browse_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/home/presentation/state/calm_home_projection.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    const projection = CalmHomeProjection.current;
    return BrowseScaffold(
      header: const _CurrentStateArea(projection: projection),
      body: ListView(
        padding: EdgeInsets.fromLTRB(0, t.spacing.xs, 0, t.spacing.huge),
        children: [
          _NextDecisionArea(
            decision: projection.nextDecision,
            onOpen: () => context.go(projection.nextDecision.route),
          ),
          SizedBox(height: t.spacing.md),
          _OptionalSupportArea(
            onOpenPrivacy: () => context.go(AppRouteNames.mePrivacySettings),
          ),
        ],
      ),
    );
  }
}

class _CurrentStateArea extends StatelessWidget {
  const _CurrentStateArea({required this.projection});

  final CalmHomeProjection projection;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      key: const ValueKey('home-area-current-state'),
      width: double.infinity,
      padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
      decoration: BoxDecoration(
        color: t.browseSurface,
        borderRadius: BorderRadius.circular(t.radius.xl),
        border: Border.all(color: t.browseBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '当前状态 · Current state',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: t.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            '首页只做摘要；访问这里不会改变任何生命周期状态。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
          SizedBox(height: t.spacing.md),
          for (final summary in projection.summaries) ...[
            _StateSummaryRow(summary: summary),
            if (summary != projection.summaries.last)
              Divider(height: t.spacing.lg, color: t.browseBorder),
          ],
        ],
      ),
    );
  }
}

class _StateSummaryRow extends StatelessWidget {
  const _StateSummaryRow({required this.summary});

  final HomeStateSummary summary;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Row(
      children: [
        Expanded(
          child: Text(
            summary.domain.label,
            key: ValueKey(summary.domain.stateKey),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: t.textPrimary),
          ),
        ),
        Text(
          summary.statusLabel,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
        ),
      ],
    );
  }
}

class _NextDecisionArea extends StatelessWidget {
  const _NextDecisionArea({required this.decision, required this.onOpen});

  final HomeNextDecision decision;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      key: const ValueKey('home-area-next-decision'),
      width: double.infinity,
      padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
      decoration: BoxDecoration(
        color: t.browseSurface,
        borderRadius: BorderRadius.circular(t.radius.xl),
        border: Border.all(color: t.browseBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '下一步 · Next decision',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: t.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            '当前没有足够的权威状态来推荐后续生命周期动作。先查看准备状态。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
          SizedBox(height: t.spacing.md),
          FilledButton(
            key: const ValueKey('home-primary-next-decision'),
            onPressed: onOpen,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: t.textPrimary,
              foregroundColor: t.browseSurface,
            ),
            child: Text(decision.label),
          ),
        ],
      ),
    );
  }
}

class _OptionalSupportArea extends StatelessWidget {
  const _OptionalSupportArea({required this.onOpenPrivacy});

  final VoidCallback onOpenPrivacy;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      key: const ValueKey('home-area-optional-support'),
      width: double.infinity,
      padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
      decoration: BoxDecoration(
        color: t.browseSurface,
        borderRadius: BorderRadius.circular(t.radius.xl),
        border: Border.all(color: t.browseBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '可选支持 · Optional support',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: t.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            '状态尚未建立不代表失败或不符合条件。匹配不等于连接，连接不等于对话，对话也不等于关系。你可以稍后再回来，无需现在继续。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
          SizedBox(height: t.spacing.sm),
          TextButton.icon(
            key: const ValueKey('home-optional-privacy-support'),
            onPressed: onOpenPrivacy,
            icon: const Icon(Icons.privacy_tip_outlined),
            label: const Text('隐私与数据设置'),
          ),
        ],
      ),
    );
  }
}

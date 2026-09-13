import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/notification/presentation/state/notification_privacy_contract.dart';
import 'package:flutter_elitesync_module/features/privacy/presentation/state/privacy_control_projection.dart';
import 'package:flutter_elitesync_module/shared/explainability/explainability_contract.dart';
import 'package:flutter_elitesync_module/shared/explainability/explainability_panel.dart';

class PrivacySettingsPage extends StatelessWidget {
  const PrivacySettingsPage({super.key});

  static const _explanation = ExplainabilityContent(
    whatHappened: '这里按用途列出当前隐私边界、可用入口和仍未建立的控制。',
    why: '不同信息服务于不同目的，不能用一个总开关假装完成所有同意、撤回或数据权利。',
    informationClasses: ['产品用途与受众分类', '已接受的领域权限边界'],
    doesNotMean: '本页不代表存在全局公开 Profile，也不证明服务端导出、删除、撤回或可见性控制已经可用。',
    uncertaintyAndLimits: '地区法律实现、保留期限、导出、删除以及部分撤回机制仍未确定。',
    userControls: ['前往所属页面查看已有入口', '保留未建立能力的明确标记'],
  );

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AppScaffold(
      appBar: const AppTopBar(title: '隐私控制中心', mode: AppTopBarMode.backTitle),
      body: ListView(
        padding: EdgeInsets.fromLTRB(0, t.spacing.sm, 0, t.spacing.xl),
        children: [
          SectionReveal(
            delay: const Duration(milliseconds: 40),
            child: AppInfoSectionCard(
              title: '按用途理解和管理',
              subtitle: '只展示已存在的入口；UNKNOWN 不会被写成没有、失败或已关闭',
              leadingIcon: Icons.privacy_tip_outlined,
              child: Text(
                '本产品没有全局公开 MVP Profile。操作偏好不等于匹配、连接、消息或披露同意；状态词也不创造服务端权限。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                  height: 1.45,
                ),
              ),
            ),
          ),
          SizedBox(height: t.spacing.md),
          const SectionReveal(
            delay: Duration(milliseconds: 55),
            child: ExplainabilityPanel(title: '如何理解本页', content: _explanation),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 70),
            child: AppInfoSectionCard(
              title: '通知预览默认保护',
              subtitle: '外部与锁屏默认不显示身份、消息或领域结果',
              leadingIcon: Icons.notifications_none_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    NotificationPrivacyContract.externalDefault.title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  SizedBox(height: t.spacing.xxs),
                  Text(
                    NotificationPrivacyContract.externalDefault.body,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
                  ),
                  SizedBox(height: t.spacing.xs),
                  Text(
                    '这是一条 presentation 规则，不代表 OS 推送或送达能力已经建立。',
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
          for (final area in PrivacyControlProjection.areas) ...[
            SectionReveal(child: _PrivacyControlAreaCard(area: area)),
            SizedBox(height: t.spacing.sm),
          ],
        ],
      ),
    );
  }
}

class _PrivacyControlAreaCard extends StatelessWidget {
  const _PrivacyControlAreaCard({required this.area});

  final PrivacyControlArea area;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AppInfoSectionCard(
      key: ValueKey('privacy-purpose-${area.key}'),
      title: area.title,
      subtitle: area.audience,
      leadingIcon: Icons.shield_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            area.purpose,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: t.textPrimary,
              height: 1.45,
            ),
          ),
          SizedBox(height: t.spacing.sm),
          Text(
            area.hasAvailableNavigation
                ? '当前可用：前往所属页面查看已有说明或控制。'
                : '当前全局控制：${PrivacyControlProjection.notYetEstablished}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
          ),
          SizedBox(height: t.spacing.xs),
          Wrap(
            spacing: t.spacing.xs,
            runSpacing: t.spacing.xs,
            children: [
              for (final unresolved in area.unresolved)
                Chip(
                  label: Text(
                    '$unresolved · ${PrivacyControlProjection.notYetEstablished}',
                  ),
                ),
            ],
          ),
          if (area.hasAvailableNavigation) ...[
            SizedBox(height: t.spacing.sm),
            OutlinedButton(
              onPressed: () => context.push(area.availableActionRoute!),
              child: Text(area.availableActionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

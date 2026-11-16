import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/slow_dating_v1012/relationship_privacy_page.dart';

class PrivacySettingsPage extends StatelessWidget {
  const PrivacySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AppScaffold(
      appBar: const AppTopBar(title: '权限与说明', mode: AppTopBarMode.backTitle),
      body: ListView(
        padding: EdgeInsets.fromLTRB(0, t.spacing.sm, 0, t.spacing.xl),
        children: [
          ListTile(
            title: const Text('管理资料受众与本人预览'),
            subtitle: const Text('选择分享范围，查看或撤回分享。'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const RelationshipPrivacyPage(),
              ),
            ),
          ),
          const Divider(),
          _Explanation(
            title: '匹配与每周慢约',
            body:
                '完成资料、问卷与生活方式探索后，可自主报名每周慢约。匹配结果供双方分别决定；连接、消息许可、正式关系和资料分享各自确认。实际相处由你自己判断。暂停或退出报名时，请阅读当次操作提示。',
            links: [
              ('我的匹配输入', AppRouteNames.meMatchingInputs),
              ('匹配与报名', AppRouteNames.progressMatch),
            ],
          ),
          const _Explanation(
            title: '持续参与与自动化',
            body:
                '持续参与默认关闭。明确授权后，系统在已有开放轮次检查准备状态并协调报名。你可以暂停、恢复或撤销授权。暂停、撤销与到期只影响绑定该授权的报名，独立手动报名保持原状态。匹配选择、连接、消息和正式关系继续由本人决定。',
            links: [('管理持续参与与自动化', '/user-state')],
          ),
          _Explanation(
            title: '私密资料与展示',
            body:
                '私密资料用于账号维护与本人确认的匹配用途。展示资料由你编辑和发布，具体可见范围以当前受众授权为准。修改资料后，请重新确认需要用于匹配的内容。',
            links: [
              ('编辑私密资料', AppRouteNames.mePrivateIdentity),
              ('编辑展示资料', AppRouteNames.meShowcase),
            ],
          ),
          _Explanation(
            title: '连接与私密消息',
            body:
                '聊天需要有效连接和双方独立的消息许可。你可以在对应页面管理申请、回应和撤销。站内通知与会话各自记录已读状态。锁屏与外部提醒默认隐藏身份、消息正文和关系结果；本版尚未接入系统推送。',
            links: [
              ('管理连接', AppRouteNames.progressConnection),
              ('查看消息', AppRouteNames.messages),
            ],
          ),
          const _Explanation(
            title: '搭子与社区',
            body:
                '搭子用于吃饭、学习等独立活动，活动类型、城市和时间会影响发现结果。创建活动后可选择邀请或发布到发现。社区按你选择的受众展示有限动态，发布、联系和分享都由你主动操作。',
          ),
          const _Explanation(
            title: '自我了解工具',
            body:
                '自我了解工具自愿使用，结果供个人参考。MBTI和排盘结果具有各自的适用限制，不能用于心理诊断、身份判断或匹配硬筛选。本版未接入运行时AI；私聊保持原有私密用途。',
          ),
          const _Explanation(
            title: '举报与受限资料',
            body:
                '举报和申诉按相应流程处理。举报内容与处理结论分别记录，相关资料仅供获准的受限处理使用。正常拒绝、退出和拉黑由用户自主决定。',
          ),
          _Explanation(
            title: '账号与设备',
            body:
                '账号、设备和服务运行使用必要信息。完整数据导出、统一删除、保留期限及地区权利处理仍待完善。已提供的资料受众、撤回与消息权限可在对应页面管理。',
            links: [('设置与账号安全', AppRouteNames.settings)],
          ),
        ],
      ),
    );
  }
}

class _Explanation extends StatelessWidget {
  const _Explanation({
    required this.title,
    required this.body,
    this.links = const [],
  });

  final String title;
  final String body;
  final List<(String, String)> links;

  @override
  Widget build(BuildContext context) => ExpansionTile(
    title: Text(title),
    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    expandedCrossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(body),
      if (links.isNotEmpty) const SizedBox(height: 8),
      for (final link in links)
        TextButton(
          onPressed: () => context.push(link.$2),
          child: Text(link.$1),
        ),
    ],
  );
}

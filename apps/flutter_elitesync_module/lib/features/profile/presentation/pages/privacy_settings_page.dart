import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

class PrivacySettingsPage extends StatelessWidget {
  const PrivacySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AppScaffold(
      appBar: const AppTopBar(title: '隐私设置', mode: AppTopBarMode.backTitle),
      body: ListView(
        padding: EdgeInsets.fromLTRB(0, t.spacing.sm, 0, t.spacing.xl),
        children: [
          SectionReveal(
            delay: const Duration(milliseconds: 40),
            child: AppInfoSectionCard(
              title: '公开可见性设置暂未提供',
              subtitle: '当前本地或设备设置不会改变其他用户看到的内容',
              leadingIcon: Icons.privacy_tip_outlined,
              child: Text(
                '当前页面没有服务端公开可见性开关。本地或设备偏好不会改变其他用户能看到的资料或展示内容；需要了解某项信息的用途时，请在该信息所在页面查看说明。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

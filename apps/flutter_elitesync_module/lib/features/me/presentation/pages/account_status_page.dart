import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/platform_v1014/safety_cases_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/operational_status_card.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/operating_application_card.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/sanction_appeal_card.dart';

class AccountStatusPage extends StatelessWidget {
  const AccountStatusPage({super.key, required this.restorationLocalBuild});
  final bool restorationLocalBuild;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Scaffold(
      appBar: AppBar(title: const Text('资格、状态与申诉')),
      body: ListView(
        padding: EdgeInsets.all(t.spacing.pageHorizontal),
        children: [
          if (restorationLocalBuild) ...[
            const OperationalStatusCard(),
            const OperatingApplicationCard(),
            SizedBox(height: t.spacing.md),
          ],
          if (const bool.fromEnvironment('ELITESYNC_V1014_LOCAL_BUILD') ||
              const bool.fromEnvironment('ELITESYNC_V1015_R1_LOCAL_BUILD')) ...[
            ListTile(
              leading: const Icon(Icons.shield_outlined),
              title: const Text('本人处理状态与申诉'),
              subtitle: const Text('仅本人可见，查看处理进度或提交申诉。'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SafetyCasesPage(),
                ),
              ),
            ),
            SizedBox(height: t.spacing.md),
          ],
          if (restorationLocalBuild) const SanctionAppealCard(),
        ],
      ),
    );
  }
}

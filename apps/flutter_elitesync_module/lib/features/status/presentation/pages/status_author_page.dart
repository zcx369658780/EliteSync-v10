import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/shared/presentation_state/app_presentation_state.dart';
import 'package:flutter_elitesync_module/shared/presentation_state/app_presentation_state_view.dart';

class StatusAuthorPage extends StatelessWidget {
  const StatusAuthorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      appBar: AppTopBar(title: '作者内容', mode: AppTopBarMode.backTitle),
      body: AppPresentationStateView(
        state: AppPresentationState.authorityNotEstablished(
          safeTitle: '访问权限尚未建立',
          safeBody: '当前没有已建立的受众访问权限。为保护隐私，未加载任何作者或个人资料。',
        ),
      ),
    );
  }
}

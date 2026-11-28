import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/ui_s3_canvas.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('创建账号')),
      body: UiS3Canvas(
        kind: UiS3Backdrop.quiet,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(22),
            children: [
              Text('暂时无法注册', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 12),
              const Text('用户协议与隐私政策的正文、来源和版本尚待核实。'),
              const SizedBox(height: 8),
              const Text('密码至少 8 个字符，须包含字母和数字。'),
              const SizedBox(height: 24),
              const AppPrimaryButton(label: '完成注册', onPressed: null),
              const SizedBox(height: 12),
              AppSecondaryButton(
                label: '返回登录',
                fullWidth: true,
                onPressed: () => context.canPop()
                    ? context.pop()
                    : context.go(AppRouteNames.login),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

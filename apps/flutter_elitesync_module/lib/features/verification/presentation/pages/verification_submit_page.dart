import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/fields/app_text_field.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/verification/presentation/providers/verification_provider.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

class VerificationSubmitPage extends ConsumerStatefulWidget {
  const VerificationSubmitPage({super.key});

  @override
  ConsumerState<VerificationSubmitPage> createState() =>
      _VerificationSubmitPageState();
}

class _VerificationSubmitPageState
    extends ConsumerState<VerificationSubmitPage> {
  final _nameController = TextEditingController();
  final _idController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(verificationProvider);
    final state = async.asData?.value;
    final t = context.appTokens;
    final session = ref.watch(sessionProvider).asData?.value;
    final notifier = ref.read(verificationProvider.notifier);
    ref.listen(sessionProvider, (previous, next) {
      final before = previous?.asData?.value;
      final after = next.asData?.value;
      if (before?.isLoggedIn != after?.isLoggedIn ||
          before?.user?.id != after?.user?.id) {
        _nameController.clear();
        _idController.clear();
      }
    });

    return AppScaffold(
      appBar: const AppTopBar(title: '提交认证', mode: AppTopBarMode.backTitle),
      body: ListView(
        children: [
          SizedBox(height: t.spacing.md),
          const SectionReveal(
            child: PageTitleRail(title: '提交认证信息', subtitle: '仅用于实名认证，不会公开展示'),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 60),
            child: AppTextField(
              controller: _nameController,
              label: '真实姓名',
              hint: '请输入真实姓名',
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 110),
            child: AppTextField(
              controller: _idController,
              label: '身份证号',
              hint: '请输入身份证号',
            ),
          ),
          SizedBox(height: t.spacing.lg),
          if (state?.error != null)
            Text(
              state!.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          if (async.hasError)
            Text(
              notifier.requiresConfirmation
                  ? '已接收提交，但状态尚未确认，请刷新提交状态。'
                  : '认证状态加载失败，请刷新后重试。',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          SectionReveal(
            delay: const Duration(milliseconds: 160),
            child: AppPrimaryButton(
              label: notifier.requiresConfirmation
                  ? '刷新提交状态'
                  : async.hasError
                  ? '刷新认证状态'
                  : state?.error != null
                  ? '重试提交'
                  : '提交审核',
              isLoading:
                  async.isLoading ||
                  (state?.isSubmitting ?? false) ||
                  (state?.isLoading ?? false),
              onPressed: session?.isLoggedIn != true
                  ? null
                  : () async {
                      final router = GoRouter.of(context);
                      final route = ModalRoute.of(context);
                      final confirmingSubmission =
                          notifier.requiresConfirmation;
                      final result = confirmingSubmission || async.hasError
                          ? await notifier.refresh()
                          : await notifier.submit(
                              realName: _nameController.text.trim(),
                              idNumber: _idController.text.trim(),
                            );
                      if (!mounted) return;
                      // A stale operation can still record a receipt for this
                      // authentication, so refresh the confirmation action label.
                      setState(() {});
                      if (route?.isCurrent != true) return;
                      if (!identical(
                        ref.read(sessionProvider).asData?.value,
                        session,
                      )) {
                        return;
                      }
                      if (result == VerificationSubmissionResult.confirmed &&
                          (!async.hasError || confirmingSubmission)) {
                        router.pop();
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }
}

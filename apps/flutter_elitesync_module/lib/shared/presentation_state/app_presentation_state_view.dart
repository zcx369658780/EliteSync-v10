import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_empty_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_retry_block.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/shared/presentation_state/app_presentation_state.dart';

class AppPresentationStateView extends StatelessWidget {
  const AppPresentationStateView({
    super.key,
    required this.state,
    this.onRetryRead,
    this.lastKnownContent,
    this.loadingLines = 4,
  });

  final AppPresentationState state;

  /// This callback may repeat only the owning read/request. It must never
  /// perform consent, lifecycle, destructive, or other domain mutation.
  final VoidCallback? onRetryRead;

  /// Supply only after the owning privacy/consent gate has authorized display.
  final Widget? lastKnownContent;
  final int loadingLines;

  @override
  Widget build(BuildContext context) {
    final retry = state.retryAvailable ? onRetryRead : null;
    return switch (state.condition) {
      AppPresentationCondition.loading => _LoadingPresentation(
        state: state,
        lines: loadingLines,
      ),
      AppPresentationCondition.empty => AppEmptyState(
        title: state.safeTitle,
        description: state.safeBody,
      ),
      AppPresentationCondition.offline ||
      AppPresentationCondition.retryableError => AppErrorState(
        title: state.safeTitle,
        description: state.safeBody,
        retryLabel: state.safeActionLabel ?? '重新加载',
        onRetry: retry,
      ),
      AppPresentationCondition.stale => _StalePresentation(
        state: state,
        onRetryRead: retry,
        lastKnownContent: lastKnownContent,
      ),
      AppPresentationCondition.unavailable => AppEmptyState(
        title: state.safeTitle,
        description: state.safeBody,
        icon: Icons.cloud_off_outlined,
      ),
      AppPresentationCondition.authorityNotEstablished => AppEmptyState(
        title: state.safeTitle,
        description: state.safeBody,
        icon: Icons.lock_outline_rounded,
      ),
    };
  }
}

class _LoadingPresentation extends StatelessWidget {
  const _LoadingPresentation({required this.state, required this.lines});

  final AppPresentationState state;
  final int lines;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Semantics(
      label: '${state.safeTitle}。${state.safeBody}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(state.safeTitle, style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: t.spacing.xs),
          Text(
            state.safeBody,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
          ),
          SizedBox(height: t.spacing.md),
          AppLoadingSkeleton(lines: lines),
        ],
      ),
    );
  }
}

class _StalePresentation extends StatelessWidget {
  const _StalePresentation({
    required this.state,
    required this.onRetryRead,
    required this.lastKnownContent,
  });

  final AppPresentationState state;
  final VoidCallback? onRetryRead;
  final Widget? lastKnownContent;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final notice = onRetryRead == null
        ? AppEmptyState(
            title: state.safeTitle,
            description: state.safeBody,
            icon: Icons.history_rounded,
          )
        : AppRetryBlock(
            message: '${state.safeTitle}：${state.safeBody}',
            buttonLabel: state.safeActionLabel ?? '检查更新',
            onRetry: onRetryRead!,
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        notice,
        if (state.mayShowLastKnownContent && lastKnownContent != null) ...[
          SizedBox(height: t.spacing.md),
          lastKnownContent!,
        ],
      ],
    );
  }
}

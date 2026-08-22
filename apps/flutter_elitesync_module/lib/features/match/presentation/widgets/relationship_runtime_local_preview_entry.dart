import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/match/presentation/state/relationship_runtime_local_presentation_state.dart';
import 'package:flutter_elitesync_module/features/match/presentation/widgets/relationship_runtime_local_preview_panel.dart';

/// Developer-only local entry skeleton for relationship runtime previews.
class RelationshipRuntimeLocalPreviewEntry extends StatelessWidget {
  const RelationshipRuntimeLocalPreviewEntry({
    super.key,
    this.scenario = RelationshipRuntimeLocalPreviewScenario.waiting,
    this.state,
    this.maxEntries = 3,
    this.compact = false,
  }) : assert(maxEntries > 0);

  final RelationshipRuntimeLocalPreviewScenario scenario;
  final RelationshipRuntimeLocalPresentationState? state;
  final int maxEntries;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final previewState = state ?? scenario.state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          padding: EdgeInsets.all(t.spacing.cardPadding),
          border: Border.all(color: t.warning.withValues(alpha: 0.18)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: t.spacing.xs,
                runSpacing: t.spacing.xxs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '开发者本地入口',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const AppChoiceChip(label: '仅开发者', selected: true),
                  const AppChoiceChip(label: '本地样例'),
                ],
              ),
              SizedBox(height: t.spacing.xxs),
              Text(
                '仅用于本机构造关系运行态预览；不注册公开路由、不接 AppShell、不连接生产 Match 流程或线上运行时。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                  height: 1.45,
                ),
              ),
              SizedBox(height: t.spacing.xs),
              _LocalEntryAccessSummary(
                scenario: scenario,
                usesInjectedState: state != null,
              ),
            ],
          ),
        ),
        SizedBox(height: t.spacing.sm),
        RelationshipRuntimeLocalPreviewPanel(
          state: previewState,
          compact: compact,
          maxEntries: maxEntries,
        ),
      ],
    );
  }
}

enum RelationshipRuntimeLocalPreviewScenario {
  waiting,
  reveal,
  opener,
  noCandidate,
  paused,
}

class _LocalEntryAccessSummary extends StatelessWidget {
  const _LocalEntryAccessSummary({
    required this.scenario,
    required this.usesInjectedState,
  });

  final RelationshipRuntimeLocalPreviewScenario scenario;
  final bool usesInjectedState;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: t.spacing.sm,
        vertical: t.spacing.xs,
      ),
      decoration: BoxDecoration(
        color: t.warning.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(t.radius.md),
        border: Border.all(color: t.warning.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: t.spacing.xs,
            runSpacing: t.spacing.xxs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppChoiceChip(
                label: usesInjectedState ? '状态：外部注入' : '当前：${scenario.label}',
                selected: true,
              ),
              const AppChoiceChip(label: '入口：未挂载'),
              const AppChoiceChip(label: '待后续决策'),
            ],
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            usesInjectedState
                ? '外部注入仅用于本地测试或开发检查；入口仍保持未挂载。'
                : scenario.accessCopy,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: t.textTertiary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

extension RelationshipRuntimeLocalPreviewScenarioCopy
    on RelationshipRuntimeLocalPreviewScenario {
  String get label {
    switch (this) {
      case RelationshipRuntimeLocalPreviewScenario.waiting:
        return '等待揭晓';
      case RelationshipRuntimeLocalPreviewScenario.reveal:
        return '可查看线索';
      case RelationshipRuntimeLocalPreviewScenario.opener:
        return '开场草稿';
      case RelationshipRuntimeLocalPreviewScenario.noCandidate:
        return '暂无候选';
      case RelationshipRuntimeLocalPreviewScenario.paused:
        return '暂不可用';
    }
  }

  String get accessCopy {
    switch (this) {
      case RelationshipRuntimeLocalPreviewScenario.waiting:
        return '用于检查等待态本地入口，不触发刷新、请求或真实倒计时。';
      case RelationshipRuntimeLocalPreviewScenario.reveal:
        return '用于检查本地揭晓线索，不打开真实详情页或聊天入口。';
      case RelationshipRuntimeLocalPreviewScenario.opener:
        return '用于检查本地开场草稿入口；不打开真实聊天、不发送、不写远端。';
      case RelationshipRuntimeLocalPreviewScenario.noCandidate:
        return '用于检查暂无候选降级，不执行匹配、评分或拉取候选。';
      case RelationshipRuntimeLocalPreviewScenario.paused:
        return '用于检查暂停兜底，不写入状态、通知或远端反馈。';
    }
  }
}

extension RelationshipRuntimeLocalPreviewScenarioState
    on RelationshipRuntimeLocalPreviewScenario {
  RelationshipRuntimeLocalPresentationState get state {
    switch (this) {
      case RelationshipRuntimeLocalPreviewScenario.waiting:
        return _state(
          phase: RelationshipRuntimeLocalPresentationPhase.waiting,
          entries: [
            _entry(
              runtimeState: 'waiting',
              phase: RelationshipRuntimeLocalPresentationPhase.waiting,
            ),
          ],
        );
      case RelationshipRuntimeLocalPreviewScenario.reveal:
        return _state(
          phase: RelationshipRuntimeLocalPresentationPhase.revealAvailable,
          entries: [
            _entry(
              runtimeState: 'reveal_available',
              phase: RelationshipRuntimeLocalPresentationPhase.revealAvailable,
              candidateSummaryAvailable: true,
              explanationBlocksAvailable: true,
            ),
          ],
        );
      case RelationshipRuntimeLocalPreviewScenario.opener:
        return _state(
          phase: RelationshipRuntimeLocalPresentationPhase.openerPrepared,
          guards: _localOpenerPreviewGuards,
          entries: [
            _entry(
              runtimeState: 'opener_prepared',
              phase: RelationshipRuntimeLocalPresentationPhase.openerPrepared,
              candidateSummaryAvailable: true,
              explanationBlocksAvailable: true,
              guards: _localOpenerPreviewGuards,
              retryable: true,
            ),
          ],
        );
      case RelationshipRuntimeLocalPreviewScenario.noCandidate:
        return _state(
          phase: RelationshipRuntimeLocalPresentationPhase.noCandidate,
          guards: _fallbackPreviewGuards,
          entries: [
            _entry(
              runtimeState: 'no_candidate',
              phase: RelationshipRuntimeLocalPresentationPhase.noCandidate,
              guards: _fallbackPreviewGuards,
              reasonCode: 'no_candidate_local_fixture',
            ),
          ],
        );
      case RelationshipRuntimeLocalPreviewScenario.paused:
        return _state(
          phase: RelationshipRuntimeLocalPresentationPhase.pausedOrUnavailable,
          guards: _fallbackPreviewGuards,
          entries: [
            _entry(
              runtimeState: 'paused_or_unavailable',
              phase:
                  RelationshipRuntimeLocalPresentationPhase.pausedOrUnavailable,
              guards: _fallbackPreviewGuards,
              reasonCode: 'paused_local_fixture',
              retryable: false,
            ),
          ],
        );
    }
  }
}

RelationshipRuntimeLocalPresentationState _state({
  required RelationshipRuntimeLocalPresentationPhase phase,
  required List<RelationshipRuntimeLocalPresentationEntry> entries,
  RelationshipRuntimeLocalPresentationGuards guards = _localPreviewGuards,
}) {
  return RelationshipRuntimeLocalPresentationState(
    phase: phase,
    entries: entries,
    evidenceLevel: 'L2',
    guards: guards,
  );
}

RelationshipRuntimeLocalPresentationEntry _entry({
  required String runtimeState,
  required RelationshipRuntimeLocalPresentationPhase phase,
  bool candidateSummaryAvailable = false,
  bool candidateDetailAvailable = false,
  bool explanationBlocksAvailable = false,
  RelationshipRuntimeLocalPresentationGuards guards = _localPreviewGuards,
  String? reasonCode,
  bool? retryable,
}) {
  return RelationshipRuntimeLocalPresentationEntry(
    runtimeState: runtimeState,
    phase: phase,
    roundId: 'round-local-preview',
    fallbackCopyKey: 'relationship.runtime.preview.local_entry',
    evidenceLevel: 'L2',
    candidateSummaryAvailable: candidateSummaryAvailable,
    candidateDetailAvailable: candidateDetailAvailable,
    explanationBlocksAvailable: explanationBlocksAvailable,
    guards: guards,
    reasonCode: reasonCode,
    retryable: retryable,
  );
}

const _localPreviewGuards = RelationshipRuntimeLocalPresentationGuards(
  hasEndpointDependency: false,
  hasDatabaseDependency: false,
  hasProductionRuntimeImport: false,
  canRevealLocally: true,
  canOpenConversationLocally: false,
  manualSendOnly: true,
  automaticSendAllowed: false,
  localFeedbackOnly: true,
  remoteFeedbackInactive: true,
  notificationPushInactive: true,
  readModelOnly: true,
  canSend: false,
  scoringMutationAllowed: false,
  profileTruthMutationAllowed: false,
  astroTruthMutationAllowed: false,
);

const _localOpenerPreviewGuards = RelationshipRuntimeLocalPresentationGuards(
  hasEndpointDependency: false,
  hasDatabaseDependency: false,
  hasProductionRuntimeImport: false,
  canRevealLocally: true,
  canOpenConversationLocally: true,
  manualSendOnly: true,
  automaticSendAllowed: false,
  localFeedbackOnly: true,
  remoteFeedbackInactive: true,
  notificationPushInactive: true,
  readModelOnly: true,
  canSend: false,
  scoringMutationAllowed: false,
  profileTruthMutationAllowed: false,
  astroTruthMutationAllowed: false,
);

const _fallbackPreviewGuards = RelationshipRuntimeLocalPresentationGuards(
  hasEndpointDependency: false,
  hasDatabaseDependency: false,
  hasProductionRuntimeImport: false,
  canRevealLocally: false,
  canOpenConversationLocally: false,
  manualSendOnly: false,
  automaticSendAllowed: false,
  localFeedbackOnly: false,
  remoteFeedbackInactive: true,
  notificationPushInactive: true,
  readModelOnly: true,
  canSend: false,
  scoringMutationAllowed: false,
  profileTruthMutationAllowed: false,
  astroTruthMutationAllowed: false,
);

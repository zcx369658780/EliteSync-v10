import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/features/chat/domain/product_conversation_contract.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/state/conversation_access_state.dart';
import 'package:flutter_elitesync_module/features/connection/domain/product_connection_contract.dart';
import 'package:flutter_elitesync_module/features/connection/presentation/providers/connection_presentation_provider.dart';
import 'package:flutter_elitesync_module/features/home/presentation/state/calm_home_projection.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/canonical_match_lifecycle.dart';
import 'package:flutter_elitesync_module/features/match/presentation/providers/match_providers.dart';
import 'package:flutter_elitesync_module/shared/models/navigation_snapshot.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/navigation_guard_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final calmHomeProjectionProvider = Provider<CalmHomeProjection>((ref) {
  final env = ref.watch(appEnvProvider);
  if (!env.isDev || !env.useSyntheticHomeProjection) {
    return CalmHomeProjection.current;
  }

  final navigation = ref.watch(navigationGuardProvider);
  final match = ref.watch(matchRoundProjectionProvider);
  final connection = ref.watch(connectionPresentationProvider);
  final conversation = ref.watch(conversationAccessProvider);

  final readinessUnknown =
      navigation.readinessState == ReadinessGuardState.unknown;
  final readinessReady = navigation.readinessState == ReadinessGuardState.ready;
  final matchProjection = switch (match) {
    AsyncData(:final value) => value,
    _ => null,
  };
  final matchSnapshot = matchProjection == null
      ? null
      : CanonicalMatchLifecycleAdapter.fromRound(matchProjection);
  final matchConditionUnknown =
      matchSnapshot?.condition ==
          CanonicalMatchPresentationCondition.transportUnavailable ||
      matchSnapshot?.condition ==
          CanonicalMatchPresentationCondition.closedWithoutCompletionEvidence;
  final matchAvailable =
      matchSnapshot?.condition ==
          CanonicalMatchPresentationCondition.roundAvailable &&
      matchSnapshot?.targetState != null;
  final connectionActive = connection.state == ProductConnectionState.active;
  final conversationActive =
      conversation.state == ProductConversationState.active;
  final downstreamStateMissing =
      readinessReady &&
      matchAvailable &&
      (!connection.hasSyntheticDevelopmentState ||
          (connectionActive && !conversation.hasSyntheticDevelopmentState));

  final decision = switch ((
    readinessReady,
    matchAvailable,
    connectionActive,
    conversationActive,
  )) {
    (false, _, _, _) => const HomeNextDecision(
      label: '前往准备状态',
      route: AppRouteNames.meReadiness,
      description: '准备状态尚未就绪；前往查看当前准备状态。首页不会改变该状态。',
    ),
    (true, false, _, _) => const HomeNextDecision(
      label: '查看匹配',
      route: AppRouteNames.progressMatch,
      description: '当前没有可用的匹配提案；前往匹配页查看只读状态。',
    ),
    (true, true, false, _) => const HomeNextDecision(
      label: '查看连接',
      route: AppRouteNames.progressConnection,
      description: '连接尚未激活；前往连接页查看当前可用动作。',
    ),
    (true, true, true, false) => const HomeNextDecision(
      label: '前往消息同意',
      route: AppRouteNames.messages,
      description: '连接已激活，但消息同意尚未完成；前往消息页继续。',
    ),
    (true, true, true, true) => const HomeNextDecision(
      label: '查看消息',
      route: AppRouteNames.messages,
      description: '本地 synthetic 对话已激活；前往消息页查看。',
    ),
  };

  return CalmHomeProjection(
    summaries: [
      HomeStateSummary(
        domain: HomeProjectedDomain.readiness,
        authority: readinessUnknown
            ? HomeProjectionAuthority.unknown
            : HomeProjectionAuthority.syntheticDevelopment,
        stateCode: readinessUnknown
            ? null
            : navigation.readinessState.name.toUpperCase(),
      ),
      HomeStateSummary(
        domain: HomeProjectedDomain.match,
        authority: matchProjection != null && !matchConditionUnknown
            ? HomeProjectionAuthority.syntheticDevelopment
            : HomeProjectionAuthority.unknown,
        stateCode: matchSnapshot?.targetState?.code,
      ),
      HomeStateSummary(
        domain: HomeProjectedDomain.connection,
        authority: connection.hasSyntheticDevelopmentState
            ? HomeProjectionAuthority.syntheticDevelopment
            : HomeProjectionAuthority.notYetEstablished,
        stateCode: connection.state?.code,
      ),
      HomeStateSummary(
        domain: HomeProjectedDomain.conversation,
        authority: conversation.hasSyntheticDevelopmentState
            ? HomeProjectionAuthority.syntheticDevelopment
            : HomeProjectionAuthority.notYetEstablished,
        stateCode: conversation.hasSyntheticDevelopmentState
            ? conversation.state.code
            : null,
      ),
    ],
    readinessAuthority: readinessUnknown
        ? HomeProjectionAuthority.unknown
        : HomeProjectionAuthority.syntheticDevelopment,
    authoritativeNextDecision:
        readinessUnknown ||
            (readinessReady && matchProjection == null) ||
            (readinessReady && matchConditionUnknown) ||
            downstreamStateMissing
        ? null
        : decision,
  );
});

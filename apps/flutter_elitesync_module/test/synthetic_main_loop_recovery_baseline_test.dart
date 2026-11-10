import 'dart:async';

import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/features/chat/domain/product_conversation_contract.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/state/conversation_access_state.dart';
import 'package:flutter_elitesync_module/features/connection/domain/product_connection_contract.dart';
import 'package:flutter_elitesync_module/features/connection/presentation/providers/connection_presentation_provider.dart';
import 'package:flutter_elitesync_module/features/home/presentation/providers/calm_home_projection_provider.dart';
import 'package:flutter_elitesync_module/features/home/presentation/state/calm_home_projection.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_round_projection.dart';
import 'package:flutter_elitesync_module/features/match/presentation/providers/match_providers.dart';
import 'package:flutter_elitesync_module/main_demo.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/enums/match_status.dart';
import 'package:flutter_elitesync_module/shared/enums/questionnaire_status.dart';
import 'package:flutter_elitesync_module/shared/enums/verification_status.dart';
import 'package:flutter_elitesync_module/shared/models/navigation_snapshot.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/navigation_guard_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final fixtureMatch = MatchRoundProjection(
  state: MatchRoundBusinessState.revealed,
  serverTime: DateTime.utc(2026, 9, 21),
  receivedAt: DateTime.utc(2026, 9, 21),
  contractVersion: 'synthetic-demo-v1',
  retryEligible: false,
  userAction: 'view',
  projectionVersion: 1,
  updatedAt: DateTime.utc(2026, 9, 21),
  result: const MatchRoundResult(
    matchId: 990000101,
    partnerId: 990000201,
    headline: 'Synthetic candidate proposal',
  ),
);

const readyNavigation = NavigationSnapshot(
  authStatus: AuthStatus.authenticated,
  verificationStatus: VerificationStatus.unknown,
  questionnaireStatus: QuestionnaireStatus.unknown,
  matchStatus: MatchStatus.unknown,
  canChat: false,
  readinessState: ReadinessGuardState.ready,
  isBootstrapLoading: false,
);

ProviderContainer fixtureContainer({Future<MatchRoundProjection>? match}) => ProviderContainer(
  overrides: [
    appEnvProvider.overrideWithValue(createDemoAppEnv()),
    navigationGuardProvider.overrideWithValue(readyNavigation),
    matchRoundProjectionProvider.overrideWith(
      (ref) => match ?? Future.value(fixtureMatch),
    ),
  ],
);

HomeStateSummary homeSummary(ProviderContainer container, HomeProjectedDomain domain) =>
    container
        .read(calmHomeProjectionProvider)
        .summaries
        .singleWhere((value) => value.domain == domain);

void main() {
  test('fresh container re-seeds demo state; it is not a process restart', () async {
    final first = fixtureContainer();
    addTearDown(first.dispose);
    await first.read(matchRoundProjectionProvider.future);

    final connection = first.read(connectionPresentationProvider.notifier);
    connection.apply(ConnectionLifecycleAction.request);
    connection.apply(ConnectionLifecycleAction.accept);
    expect(homeSummary(first, HomeProjectedDomain.connection).stateCode, 'CN_ACTIVE');

    final conversation = first.read(conversationAccessProvider.notifier);
    expect(first.read(conversationAccessProvider).canRevealPrivateContent, isFalse);
    conversation.apply(ConversationLifecycleAction.requestMessagingConsent);
    conversation.apply(ConversationLifecycleAction.acceptMessagingConsent);
    expect(homeSummary(first, HomeProjectedDomain.conversation).stateCode, 'CV_ACTIVE');
    expect(first.read(conversationAccessProvider).canRevealPrivateContent, isTrue);

    final fresh = fixtureContainer();
    addTearDown(fresh.dispose);
    await fresh.read(matchRoundProjectionProvider.future);
    expect(homeSummary(fresh, HomeProjectedDomain.connection).stateCode, 'CN_NONE');
    expect(homeSummary(fresh, HomeProjectedDomain.conversation).stateCode, 'CV_LOCKED');
    expect(fresh.read(conversationAccessProvider).canRevealPrivateContent, isFalse);
    expect(fresh.read(calmHomeProjectionProvider).nextDecision.route,
        AppRouteNames.progressConnection);

    connection.apply(ConnectionLifecycleAction.close);
    expect(homeSummary(first, HomeProjectedDomain.connection).stateCode, 'CN_CLOSED');
    expect(homeSummary(first, HomeProjectedDomain.conversation).stateCode, 'CV_LOCKED');
    expect(first.read(conversationAccessProvider).canRevealPrivateContent, isFalse);
    expect(first.read(calmHomeProjectionProvider).nextDecision.route,
        AppRouteNames.progressConnection);
  });

  test('Match loading and error stay UNKNOWN and route to Match', () async {
    final pending = Completer<MatchRoundProjection>();
    final loading = fixtureContainer(match: pending.future);
    addTearDown(loading.dispose);
    final loadingProjection = loading.read(calmHomeProjectionProvider);
    expect(homeSummary(loading, HomeProjectedDomain.match).statusLabel, 'UNKNOWN');
    expect(loadingProjection.nextDecision.route, AppRouteNames.progressMatch);
    pending.complete(fixtureMatch);
    await loading.read(matchRoundProjectionProvider.future);

    final failed = fixtureContainer(match: Future.error(StateError('fixture failure')));
    addTearDown(failed.dispose);
    await expectLater(failed.read(matchRoundProjectionProvider.future), throwsStateError);
    expect(homeSummary(failed, HomeProjectedDomain.match).statusLabel, 'UNKNOWN');
    expect(failed.read(calmHomeProjectionProvider).nextDecision.route,
        AppRouteNames.progressMatch);
  });
}

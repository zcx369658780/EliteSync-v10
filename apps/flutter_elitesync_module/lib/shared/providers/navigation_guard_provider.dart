import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/enums/match_status.dart';
import 'package:flutter_elitesync_module/shared/enums/questionnaire_status.dart';
import 'package:flutter_elitesync_module/shared/enums/verification_status.dart';
import 'package:flutter_elitesync_module/shared/models/navigation_snapshot.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

final navigationGuardProvider = Provider<NavigationSnapshot>((ref) {
  final auth = ref.watch(authStatusProvider);

  // Authentication is the only authoritative fact available in this bounded
  // source. It must not manufacture verification, questionnaire, readiness,
  // Match, or Conversation authority.
  final verificationStatus = auth == AuthStatus.unauthenticated
      ? VerificationStatus.unverified
      : VerificationStatus.unknown;
  final questionnaireStatus = auth == AuthStatus.unauthenticated
      ? QuestionnaireStatus.notStarted
      : QuestionnaireStatus.unknown;
  final readinessState = switch (auth) {
    AuthStatus.unauthenticated => ReadinessGuardState.unauthenticated,
    AuthStatus.authenticated => ReadinessGuardState.unknown,
    AuthStatus.unknown => ReadinessGuardState.unknown,
  };

  return NavigationSnapshot(
    authStatus: auth,
    verificationStatus: verificationStatus,
    questionnaireStatus: questionnaireStatus,
    matchStatus: MatchStatus.unknown,
    canChat: false,
    readinessState: readinessState,
    isBootstrapLoading: auth == AuthStatus.unknown,
  );
});

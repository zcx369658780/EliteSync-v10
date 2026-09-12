import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/enums/match_status.dart';
import 'package:flutter_elitesync_module/shared/enums/questionnaire_status.dart';
import 'package:flutter_elitesync_module/shared/enums/verification_status.dart';

enum ReadinessGuardState { unknown, unauthenticated, setupRequired, ready }

class NavigationSnapshot {
  const NavigationSnapshot({
    required this.authStatus,
    required this.verificationStatus,
    required this.questionnaireStatus,
    required this.matchStatus,
    required this.canChat,
    required this.readinessState,
    required this.isBootstrapLoading,
  });

  final AuthStatus authStatus;
  final VerificationStatus verificationStatus;
  final QuestionnaireStatus questionnaireStatus;
  final MatchStatus matchStatus;
  final bool canChat;
  final ReadinessGuardState readinessState;
  final bool isBootstrapLoading;

  bool get isLoggedIn => authStatus == AuthStatus.authenticated;

  bool get isReadinessEstablished =>
      readinessState == ReadinessGuardState.ready;
}

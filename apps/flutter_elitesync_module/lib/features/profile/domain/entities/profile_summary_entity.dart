class ProfileSummaryEntity {
  const ProfileSummaryEntity({
    required this.nickname,
    required this.birthday,
    required this.birthTime,
    required this.birthPlace,
    this.birthLat,
    this.birthLng,
    required this.city,
    required this.target,
    required this.verified,
    required this.moderationStatus,
    required this.moderationNote,
    required this.completion,
    required this.tags,
    this.readiness = const ProfileReadinessEntity(),
  });

  final String nickname;
  final String birthday;
  final String birthTime;
  final String? birthPlace;
  final double? birthLat;
  final double? birthLng;
  final String city;
  final String target;
  final bool verified;
  final String moderationStatus;
  final String? moderationNote;
  final double completion;
  final List<String> tags;
  final ProfileReadinessEntity readiness;
}

class ProfileReadinessEntity {
  const ProfileReadinessEntity({
    this.contractVersion = '',
    this.matchingEligibility = const MatchingEligibilityEntity(),
    this.showcase = const ShowcaseReadinessEntity(),
  });

  final String contractVersion;
  final MatchingEligibilityEntity matchingEligibility;
  final ShowcaseReadinessEntity showcase;

  bool get hasServerTruth => contractVersion == 'profile_readiness_v1';
}

class MatchingEligibilityEntity {
  const MatchingEligibilityEntity({
    this.eligible = false,
    this.reasonCode = 'unavailable',
    this.requiredAnswerCount = 0,
    this.answeredAnswerCount = 0,
    this.missingAnswerCount = 0,
    this.nextActionCode = 'refresh',
  });

  final bool eligible;
  final String reasonCode;
  final int requiredAnswerCount;
  final int answeredAnswerCount;
  final int missingAnswerCount;
  final String nextActionCode;
}

class ShowcaseReadinessEntity {
  const ShowcaseReadinessEntity({
    this.draftState = 'none',
    this.reviewStatus = 'not_submitted',
    this.publicationStatus = 'not_published',
    this.publishedVersionCurrent = false,
    this.affectsMatchingEligibility = false,
  });

  final String draftState;
  final String reviewStatus;
  final String publicationStatus;
  final bool publishedVersionCurrent;
  final bool affectsMatchingEligibility;
}

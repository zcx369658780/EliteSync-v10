/// All inputs are caller claims. This pure policy cannot authenticate a login,
/// a clock, an offline credential, content provenance, or an actual deletion.
enum RetentionTimeClaim { trusted, missing, untrusted, anomalous }

enum OfflineRetentionRefusal {
  missingTime,
  untrustedTime,
  anomalousTime,
  negativeElapsedTime,
  missingLoginAnchorBinding,
  loginAnchorBindingMismatch,
  thirtyDayLimitReached,
  deviceOnline,
  loggedOut,
  accountChanged,
  knownInvalidation,
  missingBinding,
  bindingMismatch,
  offlineReadClaimInvalid,
  contentNotSaved,
  ciphertextIntegrityFailed,
}

class OfflinePrivateRetentionClaims {
  const OfflinePrivateRetentionClaims({
    required this.elapsedSinceSuccessfulOnlineLogin,
    required this.timeClaim,
    required this.loginAccountId,
    required this.loginDeviceId,
    required this.isOffline,
    required this.loggedOut,
    required this.accountChanged,
    required this.knownInvalidation,
    required this.currentAccountId,
    required this.currentDeviceId,
    required this.requestedObjectId,
    required this.savedAccountId,
    required this.savedDeviceId,
    required this.savedObjectId,
    required this.offlineReadClaimValid,
    required this.contentSaved,
    required this.ciphertextIntegrityVerified,
  });

  /// Supplied by the caller; never calculated from a device clock or token.
  final Duration? elapsedSinceSuccessfulOnlineLogin;
  final RetentionTimeClaim timeClaim;

  /// Claimed binding of the successful online login used as the time anchor.
  final String? loginAccountId;
  final String? loginDeviceId;
  final bool isOffline;
  final bool loggedOut;
  final bool accountChanged;
  final bool knownInvalidation;
  final String? currentAccountId;
  final String? currentDeviceId;
  final String? requestedObjectId;
  final String? savedAccountId;
  final String? savedDeviceId;
  final String? savedObjectId;
  final bool offlineReadClaimValid;
  final bool contentSaved;
  final bool ciphertextIntegrityVerified;
}

class OfflinePrivateRetentionDecision {
  const OfflinePrivateRetentionDecision({
    required this.onlineLoginTimeWindowCandidate,
    required this.offlineReadOnlyCandidate,
    required this.thirtyDayPurgeDueCandidate,
    required this.offlineReadRefusals,
  });

  /// A time-window result only; never a live read or send grant.
  final bool onlineLoginTimeWindowCandidate;

  /// Viewing saved content and drafts only; never edit, write-back, or send.
  final bool offlineReadOnlyCandidate;

  /// A due signal only. This policy neither deletes nor confirms deletion.
  final bool thirtyDayPurgeDueCandidate;
  final List<OfflineRetentionRefusal> offlineReadRefusals;
}

abstract final class OfflinePrivateRetentionPolicy {
  static const _onlineWindow = Duration(days: 15);
  static const _purgeBoundary = Duration(days: 30);

  static OfflinePrivateRetentionDecision evaluate(
    OfflinePrivateRetentionClaims claims,
  ) {
    final refusals = <OfflineRetentionRefusal>[];
    final elapsed = claims.elapsedSinceSuccessfulOnlineLogin;
    if (claims.timeClaim == RetentionTimeClaim.missing || elapsed == null) {
      refusals.add(OfflineRetentionRefusal.missingTime);
    } else if (claims.timeClaim == RetentionTimeClaim.untrusted) {
      refusals.add(OfflineRetentionRefusal.untrustedTime);
    } else if (claims.timeClaim == RetentionTimeClaim.anomalous) {
      refusals.add(OfflineRetentionRefusal.anomalousTime);
    } else if (elapsed.isNegative) {
      refusals.add(OfflineRetentionRefusal.negativeElapsedTime);
    }

    final loginBindings = <String?>[
      claims.loginAccountId,
      claims.loginDeviceId,
      claims.currentAccountId,
      claims.currentDeviceId,
      claims.savedAccountId,
      claims.savedDeviceId,
    ];
    if (loginBindings.any((value) => value == null || value.trim().isEmpty)) {
      refusals.add(OfflineRetentionRefusal.missingLoginAnchorBinding);
    } else if (claims.loginAccountId != claims.currentAccountId ||
        claims.loginAccountId != claims.savedAccountId ||
        claims.loginDeviceId != claims.currentDeviceId ||
        claims.loginDeviceId != claims.savedDeviceId) {
      refusals.add(OfflineRetentionRefusal.loginAnchorBindingMismatch);
    }

    final usableTime = refusals.isEmpty;
    final purgeDue = usableTime && elapsed! >= _purgeBoundary;
    if (purgeDue) {
      refusals.add(OfflineRetentionRefusal.thirtyDayLimitReached);
    }
    if (!claims.isOffline) {
      refusals.add(OfflineRetentionRefusal.deviceOnline);
    }
    if (claims.loggedOut) {
      refusals.add(OfflineRetentionRefusal.loggedOut);
    }
    if (claims.accountChanged) {
      refusals.add(OfflineRetentionRefusal.accountChanged);
    }
    if (claims.knownInvalidation) {
      refusals.add(OfflineRetentionRefusal.knownInvalidation);
    }

    final bindings = <String?>[
      claims.currentAccountId,
      claims.currentDeviceId,
      claims.requestedObjectId,
      claims.savedAccountId,
      claims.savedDeviceId,
      claims.savedObjectId,
    ];
    if (bindings.any((value) => value == null || value.trim().isEmpty)) {
      refusals.add(OfflineRetentionRefusal.missingBinding);
    } else if (claims.currentAccountId != claims.savedAccountId ||
        claims.currentDeviceId != claims.savedDeviceId ||
        claims.requestedObjectId != claims.savedObjectId) {
      refusals.add(OfflineRetentionRefusal.bindingMismatch);
    }
    if (!claims.offlineReadClaimValid) {
      refusals.add(OfflineRetentionRefusal.offlineReadClaimInvalid);
    }
    if (!claims.contentSaved) {
      refusals.add(OfflineRetentionRefusal.contentNotSaved);
    }
    if (!claims.ciphertextIntegrityVerified) {
      refusals.add(OfflineRetentionRefusal.ciphertextIntegrityFailed);
    }

    return OfflinePrivateRetentionDecision(
      onlineLoginTimeWindowCandidate: usableTime && elapsed! < _onlineWindow,
      offlineReadOnlyCandidate: refusals.isEmpty,
      thirtyDayPurgeDueCandidate: purgeDue,
      offlineReadRefusals: List.unmodifiable(refusals),
    );
  }
}

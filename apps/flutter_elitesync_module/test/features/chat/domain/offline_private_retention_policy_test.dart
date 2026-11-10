import 'package:flutter_elitesync_module/features/chat/domain/offline_private_retention_policy.dart';
import 'package:flutter_test/flutter_test.dart';

// Fictional caller claims only. Passing tests establish no trusted source,
// private-content grant, device purge, or production behavior.
OfflinePrivateRetentionClaims claims({
  Duration? elapsed = const Duration(days: 10),
  RetentionTimeClaim timeClaim = RetentionTimeClaim.trusted,
  String? loginAccountId = 'fictional-account',
  String? loginDeviceId = 'fictional-device',
  bool isOffline = true,
  bool loggedOut = false,
  bool accountChanged = false,
  bool knownInvalidation = false,
  String? currentAccountId = 'fictional-account',
  String? currentDeviceId = 'fictional-device',
  String? requestedObjectId = 'fictional-conversation',
  String? savedAccountId = 'fictional-account',
  String? savedDeviceId = 'fictional-device',
  String? savedObjectId = 'fictional-conversation',
  bool offlineReadClaimValid = true,
  bool contentSaved = true,
  bool ciphertextIntegrityVerified = true,
}) => OfflinePrivateRetentionClaims(
  elapsedSinceSuccessfulOnlineLogin: elapsed,
  timeClaim: timeClaim,
  loginAccountId: loginAccountId,
  loginDeviceId: loginDeviceId,
  isOffline: isOffline,
  loggedOut: loggedOut,
  accountChanged: accountChanged,
  knownInvalidation: knownInvalidation,
  currentAccountId: currentAccountId,
  currentDeviceId: currentDeviceId,
  requestedObjectId: requestedObjectId,
  savedAccountId: savedAccountId,
  savedDeviceId: savedDeviceId,
  savedObjectId: savedObjectId,
  offlineReadClaimValid: offlineReadClaimValid,
  contentSaved: contentSaved,
  ciphertextIntegrityVerified: ciphertextIntegrityVerified,
);

void main() {
  test('15-day boundary changes only the login time-window candidate', () {
    final before = OfflinePrivateRetentionPolicy.evaluate(
      claims(
        elapsed: const Duration(days: 15) - const Duration(microseconds: 1),
      ),
    );
    final at = OfflinePrivateRetentionPolicy.evaluate(
      claims(elapsed: const Duration(days: 15)),
    );
    expect(before.onlineLoginTimeWindowCandidate, isTrue);
    expect(at.onlineLoginTimeWindowCandidate, isFalse);
    expect(before.offlineReadOnlyCandidate, isTrue);
    expect(at.offlineReadOnlyCandidate, isTrue);
    expect(at.thirtyDayPurgeDueCandidate, isFalse);
    expect(at.offlineReadRefusals, isEmpty);
  });

  test('29-day end remains read-only; 30-day boundary is purge due', () {
    final before = OfflinePrivateRetentionPolicy.evaluate(
      claims(
        elapsed: const Duration(days: 30) - const Duration(microseconds: 1),
      ),
    );
    final at = OfflinePrivateRetentionPolicy.evaluate(
      claims(elapsed: const Duration(days: 30)),
    );
    expect(before.offlineReadOnlyCandidate, isTrue);
    expect(before.thirtyDayPurgeDueCandidate, isFalse);
    expect(at.offlineReadOnlyCandidate, isFalse);
    expect(at.thirtyDayPurgeDueCandidate, isTrue);
    expect(
      at.offlineReadRefusals,
      contains(OfflineRetentionRefusal.thirtyDayLimitReached),
    );
    // Due is not a completion receipt. The API exposes no deletion operation.
  });

  test(
    'token renewal, restart, and profile change cannot reset elapsed time',
    () {
      // These events are intentionally absent from the input contract. The
      // caller must retain elapsed time since the last successful online login.
      for (final ignoredEvent in [
        'token renewal',
        'restart',
        'profile change',
      ]) {
        final result = OfflinePrivateRetentionPolicy.evaluate(
          claims(elapsed: const Duration(days: 30)),
        );
        expect(result.thirtyDayPurgeDueCandidate, isTrue, reason: ignoredEvent);
        expect(result.offlineReadOnlyCandidate, isFalse, reason: ignoredEvent);
      }
    },
  );

  test('missing, untrusted, anomalous, and negative time fail closed', () {
    final cases = <OfflinePrivateRetentionClaims, OfflineRetentionRefusal>{
      claims(elapsed: null): OfflineRetentionRefusal.missingTime,
      claims(timeClaim: RetentionTimeClaim.missing):
          OfflineRetentionRefusal.missingTime,
      claims(timeClaim: RetentionTimeClaim.untrusted):
          OfflineRetentionRefusal.untrustedTime,
      claims(timeClaim: RetentionTimeClaim.anomalous):
          OfflineRetentionRefusal.anomalousTime,
      claims(elapsed: const Duration(microseconds: -1)):
          OfflineRetentionRefusal.negativeElapsedTime,
    };
    for (final entry in cases.entries) {
      final result = OfflinePrivateRetentionPolicy.evaluate(entry.key);
      expect(result.onlineLoginTimeWindowCandidate, isFalse);
      expect(result.offlineReadOnlyCandidate, isFalse);
      expect(result.thirtyDayPurgeDueCandidate, isFalse);
      expect(result.offlineReadRefusals, contains(entry.value));
    }
  });

  test('account, device, and object bindings must match', () {
    for (final input in [
      claims(savedAccountId: 'other-account'),
      claims(savedDeviceId: 'other-device'),
      claims(savedObjectId: 'other-conversation'),
    ]) {
      final result = OfflinePrivateRetentionPolicy.evaluate(input);
      expect(result.offlineReadOnlyCandidate, isFalse);
      expect(
        result.offlineReadRefusals,
        contains(OfflineRetentionRefusal.bindingMismatch),
      );
    }
    final missing = OfflinePrivateRetentionPolicy.evaluate(
      claims(savedObjectId: null),
    );
    expect(missing.offlineReadOnlyCandidate, isFalse);
    expect(
      missing.offlineReadRefusals,
      contains(OfflineRetentionRefusal.missingBinding),
    );
  });

  test('a different account or device cannot lend its login time anchor', () {
    for (final input in [
      claims(loginAccountId: 'other-account'),
      claims(loginDeviceId: 'other-device'),
    ]) {
      final result = OfflinePrivateRetentionPolicy.evaluate(input);
      expect(result.onlineLoginTimeWindowCandidate, isFalse);
      expect(result.offlineReadOnlyCandidate, isFalse);
      expect(
        result.offlineReadRefusals,
        contains(OfflineRetentionRefusal.loginAnchorBindingMismatch),
      );
    }
    final missing = OfflinePrivateRetentionPolicy.evaluate(
      claims(loginAccountId: null),
    );
    expect(missing.offlineReadOnlyCandidate, isFalse);
    expect(
      missing.offlineReadRefusals,
      contains(OfflineRetentionRefusal.missingLoginAnchorBinding),
    );

    final wrongAccountAtThirtyDays = OfflinePrivateRetentionPolicy.evaluate(
      claims(
        elapsed: const Duration(days: 30),
        loginAccountId: 'other-account',
      ),
    );
    expect(wrongAccountAtThirtyDays.offlineReadOnlyCandidate, isFalse);
    expect(wrongAccountAtThirtyDays.thirtyDayPurgeDueCandidate, isFalse);
  });

  test('known invalidation, logout, and account switch deny offline view', () {
    final cases = <OfflinePrivateRetentionClaims, OfflineRetentionRefusal>{
      claims(loggedOut: true): OfflineRetentionRefusal.loggedOut,
      claims(accountChanged: true): OfflineRetentionRefusal.accountChanged,
      claims(knownInvalidation: true):
          OfflineRetentionRefusal.knownInvalidation,
    };
    for (final entry in cases.entries) {
      final result = OfflinePrivateRetentionPolicy.evaluate(entry.key);
      expect(result.offlineReadOnlyCandidate, isFalse);
      expect(result.offlineReadRefusals, contains(entry.value));
    }
  });

  test('online state and missing offline prerequisites deny offline view', () {
    final cases = <OfflinePrivateRetentionClaims, OfflineRetentionRefusal>{
      claims(isOffline: false): OfflineRetentionRefusal.deviceOnline,
      claims(offlineReadClaimValid: false):
          OfflineRetentionRefusal.offlineReadClaimInvalid,
      claims(contentSaved: false): OfflineRetentionRefusal.contentNotSaved,
      claims(ciphertextIntegrityVerified: false):
          OfflineRetentionRefusal.ciphertextIntegrityFailed,
    };
    for (final entry in cases.entries) {
      final result = OfflinePrivateRetentionPolicy.evaluate(entry.key);
      expect(result.offlineReadOnlyCandidate, isFalse);
      expect(result.offlineReadRefusals, contains(entry.value));
    }
  });
}

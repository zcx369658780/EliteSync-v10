import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/features/connection/domain/product_connection_contract.dart';

void main() {
  test('declares the complete target Connection vocabulary', () {
    expect(
      ProductConnectionState.values.map((state) => state.code),
      orderedEquals(const [
        'CN_NONE',
        'CN_PENDING',
        'CN_ACTIVE',
        'CN_PAUSED',
        'CN_CLOSED',
        'CN_DECLINED',
        'CN_WITHDRAWN',
        'CN_EXPIRED',
      ]),
    );
  });

  test('requires recipient acceptance before Connection becomes active', () {
    final transition = ProductConnectionContract.transition(
      from: ProductConnectionState.pending,
      to: ProductConnectionState.active,
    );

    expect(transition, isNotNull);
    expect(transition!.action, ConnectionLifecycleAction.accept);
    expect(transition.actor, ConnectionActorRequirement.recipient);
    expect(transition.establishesMutualConsent, isTrue);
    expect(
      ProductConnectionContract.transition(
        from: ProductConnectionState.none,
        to: ProductConnectionState.active,
      ),
      isNull,
    );
  });

  test('keeps every mutation unavailable without accepted authority', () {
    expect(ProductConnectionAuthority.authoritativeActions, isEmpty);
    for (final action in ConnectionLifecycleAction.values) {
      expect(
        ProductConnectionAuthority.statusFor(action),
        ConnectionActionAuthority.notYetEstablished,
      );
    }
  });

  test('terminal request outcomes carry no adverse inference', () {
    for (final state in const [
      ProductConnectionState.declined,
      ProductConnectionState.withdrawn,
      ProductConnectionState.expired,
    ]) {
      expect(state.isTerminalRequestOutcome, isTrue);
      expect(state.impliesSafetyFinding, isFalse);
      expect(state.impliesObjectiveIncompatibility, isFalse);
    }
  });
}

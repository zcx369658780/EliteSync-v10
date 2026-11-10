import 'package:flutter_elitesync_module/shared/presentation_state/app_presentation_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all common conditions are explicit and domain-neutral by default', () {
    const states = <AppPresentationState>[
      AppPresentationState.loading(),
      AppPresentationState.empty(),
      AppPresentationState.offline(),
      AppPresentationState.stale(),
      AppPresentationState.retryableError(),
      AppPresentationState.unavailable(),
      AppPresentationState.authorityNotEstablished(),
    ];

    expect(
      states.map((state) => state.condition.code),
      orderedEquals(const [
        'loading',
        'empty',
        'offline',
        'stale',
        'retryableError',
        'unavailable',
        'unknown / authorityNotEstablished',
      ]),
    );
    expect(states.every((state) => !state.hasOwningDomainMeaning), isTrue);
  });

  test(
    'only stale permits last-known content and marks it non-authoritative',
    () {
      const states = <AppPresentationState>[
        AppPresentationState.loading(),
        AppPresentationState.empty(),
        AppPresentationState.offline(),
        AppPresentationState.stale(),
        AppPresentationState.retryableError(),
        AppPresentationState.unavailable(),
        AppPresentationState.authorityNotEstablished(),
      ];

      expect(
        states.where((state) => state.mayShowLastKnownContent).single.condition,
        AppPresentationCondition.stale,
      );
      expect(states[3].safeBody, contains('可能已过期'));
      expect(states[3].safeBody, contains('不是当前权威生命周期事实'));
      expect(states[3].safeBody, contains('隐私与同意门'));
    },
  );

  test('retry is limited to transport/read conditions', () {
    expect(const AppPresentationState.offline().retryAvailable, isTrue);
    expect(const AppPresentationState.stale().retryAvailable, isTrue);
    expect(const AppPresentationState.retryableError().retryAvailable, isTrue);
    expect(const AppPresentationState.loading().retryAvailable, isFalse);
    expect(const AppPresentationState.empty().retryAvailable, isFalse);
    expect(const AppPresentationState.unavailable().retryAvailable, isFalse);
    expect(
      const AppPresentationState.authorityNotEstablished().retryAvailable,
      isFalse,
    );
  });

  test(
    'empty offline and unavailable preserve their required non-meanings',
    () {
      expect(const AppPresentationState.empty().safeBody, contains('不代表拒绝'));
      expect(const AppPresentationState.empty().safeBody, contains('Safety'));
      expect(const AppPresentationState.offline().safeBody, contains('传输条件'));
      expect(const AppPresentationState.offline().safeBody, contains('不会改写'));
      expect(
        const AppPresentationState.unavailable().safeBody,
        contains('不等于内容不存在'),
      );
    },
  );
}

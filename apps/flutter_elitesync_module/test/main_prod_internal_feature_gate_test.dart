import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/main_prod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  InternalFeatureGateResolution resolve({
    bool c2LocalBuild = false,
    bool internalDevPreview = false,
    bool matchRoundContract = false,
    bool adminMatchingOperations = false,
  }) => resolveInternalFeatureGates(
    c2LocalBuild: c2LocalBuild,
    internalDevPreview: internalDevPreview,
    matchRoundContract: matchRoundContract,
    adminMatchingOperations: adminMatchingOperations,
  );

  test('defaults to prod with both internal surfaces off', () {
    final result = resolve();

    expect(result.flavor, AppFlavor.prod);
    expect(result.useMatchRoundContract, isFalse);
    expect(result.useAdminMatchingOperations, isFalse);
  });

  test('individual feature flags cannot authorize their own parent', () {
    final result = resolve(
      matchRoundContract: true,
      adminMatchingOperations: true,
    );

    expect(result.flavor, AppFlavor.prod);
    expect(result.useMatchRoundContract, isFalse);
    expect(result.useAdminMatchingOperations, isFalse);
  });

  test('C2-local parent remains compatible with both feature flags', () {
    final result = resolve(
      c2LocalBuild: true,
      matchRoundContract: true,
      adminMatchingOperations: true,
    );

    expect(result.flavor, AppFlavor.dev);
    expect(result.useMatchRoundContract, isTrue);
    expect(result.useAdminMatchingOperations, isTrue);
  });

  test('internal preview authorizes both explicitly enabled features', () {
    final result = resolve(
      internalDevPreview: true,
      matchRoundContract: true,
      adminMatchingOperations: true,
    );

    expect(result.flavor, AppFlavor.dev);
    expect(result.useMatchRoundContract, isTrue);
    expect(result.useAdminMatchingOperations, isTrue);
  });

  test('internal preview alone keeps individual features off', () {
    final result = resolve(internalDevPreview: true);

    expect(result.flavor, AppFlavor.dev);
    expect(result.useMatchRoundContract, isFalse);
    expect(result.useAdminMatchingOperations, isFalse);
  });

  test('internal preview keeps Match independently off', () {
    final result = resolve(
      internalDevPreview: true,
      adminMatchingOperations: true,
    );

    expect(result.useMatchRoundContract, isFalse);
    expect(result.useAdminMatchingOperations, isTrue);
  });

  test('internal preview keeps Admin independently off', () {
    final result = resolve(internalDevPreview: true, matchRoundContract: true);

    expect(result.useMatchRoundContract, isTrue);
    expect(result.useAdminMatchingOperations, isFalse);
  });

  test('explicit preview resolution has no debug-mode dependency', () {
    final result = resolve(
      internalDevPreview: true,
      matchRoundContract: true,
      adminMatchingOperations: true,
    );

    expect(result.flavor, AppFlavor.dev);
    expect(result.useMatchRoundContract, isTrue);
    expect(result.useAdminMatchingOperations, isTrue);
  });

  test(
    'internal feature resolution does not broaden API bootstrap behavior',
    () {
      expect(
        resolveApiBaseUrl(
          hostBootstrap: const {'apiBaseUrl': 'https://isolated.invalid'},
        ),
        'https://isolated.invalid/',
      );
      expect(
        resolveApiBaseUrl(
          hostBootstrap: const {'apiBaseUrl': 'https://isolated.invalid/'},
        ),
        'https://isolated.invalid/',
      );
    },
  );
}

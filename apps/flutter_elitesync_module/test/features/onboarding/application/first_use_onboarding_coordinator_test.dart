import 'dart:async';

import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/features/onboarding/application/first_use_onboarding_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLocalStorageService extends LocalStorageService {
  String? value;
  bool throwOnRead = false;
  bool throwOnWrite = false;
  bool neverCompleteWrite = false;
  int readCount = 0;
  int writeCount = 0;

  @override
  Future<String?> getString(String key) async {
    expect(key, CacheKeys.firstUseOnboardingV1Status);
    readCount += 1;
    if (throwOnRead) throw StateError('read failed');
    return value;
  }

  @override
  Future<bool> setString(String key, String value) async {
    expect(key, CacheKeys.firstUseOnboardingV1Status);
    writeCount += 1;
    if (throwOnWrite) throw StateError('write failed');
    if (neverCompleteWrite) return Completer<bool>().future;
    this.value = value;
    return true;
  }
}

void main() {
  test(
    'missing revision state is eligible for automatic presentation',
    () async {
      final storage = _FakeLocalStorageService();
      final coordinator = FirstUseOnboardingCoordinator(storage);

      expect(await coordinator.shouldPresentAutomatically(), isTrue);
    },
  );

  test(
    'handled and unknown non-empty states suppress automatic presentation',
    () async {
      final storage = _FakeLocalStorageService();
      final coordinator = FirstUseOnboardingCoordinator(storage);

      for (final status in [
        FirstUseOnboardingStatus.skipped,
        FirstUseOnboardingStatus.completed,
        'future_revision_handled',
      ]) {
        storage.value = status;
        expect(await coordinator.shouldPresentAutomatically(), isFalse);
      }
    },
  );

  test('read failure fails open to the ordinary app', () async {
    final storage = _FakeLocalStorageService()..throwOnRead = true;

    expect(
      await FirstUseOnboardingCoordinator(storage).shouldPresentAutomatically(),
      isFalse,
    );
  });

  test(
    'session gate attempts automatic presentation check at most once',
    () async {
      final storage = _FakeLocalStorageService();
      final coordinator = FirstUseOnboardingCoordinator(storage);
      final gate = FirstUseOnboardingSessionGate();

      expect(await gate.shouldPresent(coordinator), isTrue);
      expect(await gate.shouldPresent(coordinator), isFalse);
      expect(gate.attempted, isTrue);
      expect(storage.readCount, 1);
    },
  );

  test('skip and completion write versioned states', () async {
    final storage = _FakeLocalStorageService();
    final coordinator = FirstUseOnboardingCoordinator(storage);

    await coordinator.markSkipped();
    expect(storage.value, FirstUseOnboardingStatus.skipped);
    await coordinator.markCompleted();
    expect(storage.value, FirstUseOnboardingStatus.completed);
  });

  test('write failure is swallowed so dismissal cannot be trapped', () async {
    final storage = _FakeLocalStorageService()..throwOnWrite = true;
    final coordinator = FirstUseOnboardingCoordinator(storage);

    await expectLater(coordinator.markSkipped(), completes);
    await expectLater(coordinator.markCompleted(), completes);
    expect(storage.writeCount, 2);
  });

  test('never-completing write is bounded by the configured timeout', () async {
    final storage = _FakeLocalStorageService()..neverCompleteWrite = true;
    final coordinator = FirstUseOnboardingCoordinator(
      storage,
      writeTimeout: const Duration(milliseconds: 10),
    );

    await expectLater(coordinator.markSkipped(), completes);
    expect(storage.writeCount, 1);
  });
}

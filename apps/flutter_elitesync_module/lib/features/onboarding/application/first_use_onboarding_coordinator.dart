import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';

abstract final class FirstUseOnboardingStatus {
  static const skipped = 'skipped';
  static const completed = 'completed';
}

class FirstUseOnboardingCoordinator {
  const FirstUseOnboardingCoordinator(
    this._storage, {
    this.writeTimeout = const Duration(milliseconds: 750),
  });

  final LocalStorageService _storage;
  final Duration writeTimeout;

  Future<bool> shouldPresentAutomatically() async {
    try {
      final status = await _storage.getString(
        CacheKeys.firstUseOnboardingV1Status,
      );
      return status == null || status.trim().isEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> markSkipped() =>
      _writeHandledStatus(FirstUseOnboardingStatus.skipped);

  Future<void> markCompleted() =>
      _writeHandledStatus(FirstUseOnboardingStatus.completed);

  Future<void> _writeHandledStatus(String status) async {
    try {
      await _storage
          .setString(CacheKeys.firstUseOnboardingV1Status, status)
          .timeout(writeTimeout);
    } catch (_) {
      // Persistence must never trap the user in the guidance flow.
    }
  }
}

class FirstUseOnboardingSessionGate {
  bool _attempted = false;

  bool get attempted => _attempted;

  Future<bool> shouldPresent(FirstUseOnboardingCoordinator coordinator) async {
    if (_attempted) return false;
    _attempted = true;
    return coordinator.shouldPresentAutomatically();
  }
}

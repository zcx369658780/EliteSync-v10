import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_elitesync_module/core/storage/secure_storage_service.dart';
import 'package:flutter_elitesync_module/features/chat/domain/offline_private_retention_policy.dart';

enum PrivateCachePurgeStatus { notDue, untrustedTime, completed, failed }

class PrivateCachePurgeReceipt {
  const PrivateCachePurgeReceipt(this.status, {this.deletedObjects = 0});
  final PrivateCachePurgeStatus status;
  final int deletedObjects;
}

/// Account/device-scoped platform-encrypted storage. Credentials and cached
/// records cannot unlock this service: only a fresh successful online login can
/// establish its process-local monotonic clock. Restart deliberately locks it.
/// Callers must save only after the corresponding current server read succeeds.
class PrivateCacheService {
  PrivateCacheService._(this._secure, this._wallNow, this._elapsed);

  static final _instances = Expando<PrivateCacheService>();
  static const _ownerLocatorKey = 'v1015_private:cleanup-owner';
  factory PrivateCacheService.forStorage(SecureStorageService secure) {
    return _instances[secure] ??= PrivateCacheService._(
      secure,
      DateTime.now,
      null,
    );
  }

  @visibleForTesting
  factory PrivateCacheService.forTesting(
    SecureStorageService secure, {
    required DateTime Function() wallNow,
    Duration Function()? elapsed,
  }) {
    final service = PrivateCacheService._(secure, wallNow, elapsed);
    _instances[secure] = service;
    return service;
  }

  final SecureStorageService _secure;
  final DateTime Function() _wallNow;
  final Duration Function()? _elapsed;
  Stopwatch? _stopwatch;
  DateTime? _wallAnchor;
  DateTime? _serverAnchor;
  DateTime? _loginAt;
  String? _namespace;
  String? _sessionId;
  String? _deviceId;
  int? _userId;
  bool _offline = false;
  bool _unlocked = false;
  int _generation = 0;
  final _readGrants = <String>{};
  Future<void> _mutation = Future.value();

  bool get isUnlocked => _unlocked && _trustedNow() != null;
  bool get isOffline => _offline;
  int? get accountId => _unlocked ? _userId : null;

  Future<T> _serialize<T>(Future<T> Function() action) {
    final next = _mutation.then((_) => action());
    _mutation = next.then<void>((_) {}, onError: (Object _) {});
    return next;
  }

  void lock() {
    _generation++;
    _unlocked = false;
    _offline = false;
    _readGrants.clear();
  }

  void revokeObject(String objectKey) {
    _generation++;
    _readGrants.remove(objectKey);
  }

  void enterOffline() {
    if (_unlocked && _trustedNow() != null) _offline = true;
  }

  /// Network recovery must be followed by a fresh current-read before any data
  /// becomes visible; it cannot inherit an offline object's old authorization.
  void beginOnlineRevalidation() {
    _generation++;
    _offline = false;
    _readGrants.clear();
  }

  String _namespaceFor(int accountId, String deviceId) =>
      'v1015_private:a$accountId:d${Uri.encodeComponent(deviceId)}';

  // This locator is only a deletion target. It never restores a session,
  // a server clock, read grants, or offline access after process restart.
  Future<String?> _readOwnerNamespace() async {
    final raw = await _secure.read(_ownerLocatorKey);
    if (raw == null) return null;
    final value = jsonDecode(raw);
    if (value is! Map ||
        value.length != 3 ||
        value['version'] is! int ||
        value['version'] != 1 ||
        value['account_id'] is! int ||
        (value['account_id'] as int) <= 0 ||
        value['device_id'] is! String ||
        (value['device_id'] as String).isEmpty) {
      throw const FormatException('Invalid private cache cleanup owner.');
    }
    return _namespaceFor(
      value['account_id'] as int,
      value['device_id'] as String,
    );
  }

  Future<bool> establishLogin({
    required int userId,
    required Map<String, dynamic>? retention,
  }) {
    lock();
    final generation = _generation;
    return _serialize(() async {
      if (generation != _generation) return false;
      try {
        if (retention == null ||
            retention['user_id'].toString() != '$userId' ||
            userId <= 0) {
          return false;
        }
        final device = retention['device_id']?.toString() ?? '';
        final session = retention['session_id']?.toString() ?? '';
        if (device.isEmpty || session.isEmpty) return false;
        final login = DateTime.parse(retention['login_at'] as String).toUtc();
        final server = DateTime.parse(
          retention['server_now'] as String,
        ).toUtc();
        final onlineExpiry = DateTime.parse(
          retention['online_expires_at'] as String,
        ).toUtc();
        final purge = DateTime.parse(retention['purge_at'] as String).toUtc();
        if (onlineExpiry.difference(login) != const Duration(days: 15) ||
            purge.difference(login) != const Duration(days: 30) ||
            server.isBefore(login) ||
            !server.isBefore(onlineExpiry)) {
          return false;
        }
        final storedOwner = await _readOwnerNamespace();
        if (storedOwner != null &&
            _namespace != null &&
            storedOwner != _namespace) {
          return false;
        }
        final oldNamespace = storedOwner ?? _namespace;
        if (oldNamespace != null) {
          final oldCleanup = await _purgeNamespace(oldNamespace);
          if (generation != _generation ||
              oldCleanup.status != PrivateCachePurgeStatus.completed) {
            return false;
          }
        }
        final nextNamespace = _namespaceFor(userId, device);
        _userId = userId;
        _sessionId = session;
        _deviceId = device;
        _namespace = nextNamespace;
        // A fresh login also clears any old copy at its exact target. Neither
        // the locator nor an old encrypted copy renews the login clock.
        if (nextNamespace != oldNamespace) {
          final cleanup = await _purgeOwnedNamespace(invalidate: false);
          if (generation != _generation ||
              cleanup.status != PrivateCachePurgeStatus.completed) {
            return false;
          }
        }
        _loginAt = login;
        _serverAnchor = server;
        _wallAnchor = _wallNow();
        _stopwatch = Stopwatch()..start();
        _unlocked = true;
        return true;
      } catch (_) {
        if (generation == _generation) lock();
        return false;
      }
    });
  }

  DateTime? _trustedNow() {
    if (!_unlocked ||
        _serverAnchor == null ||
        _wallAnchor == null ||
        _stopwatch == null) {
      return null;
    }
    final elapsed = _elapsed?.call() ?? _stopwatch!.elapsed;
    final wallElapsed = _wallNow().difference(_wallAnchor!);
    // Wall time is only an anomaly detector, never the retention authority.
    if (elapsed.isNegative ||
        (wallElapsed - elapsed).abs() > const Duration(minutes: 1)) {
      lock();
      return null;
    }
    return _serverAnchor!.add(elapsed);
  }

  bool _canUse({required bool offline}) {
    final now = _trustedNow();
    if (now == null || _loginAt == null || offline != _offline) return false;
    final age = now.difference(_loginAt!);
    return !age.isNegative && age < Duration(days: offline ? 30 : 15);
  }

  String _key(String objectKey) =>
      '$_namespace:${Uri.encodeComponent(objectKey)}';
  String get _manifestKey => '$_namespace:manifest';
  String get _recoveryManifestKey => '$_namespace:manifest-recovery';

  bool _validObjectKey(String key) =>
      key.isNotEmpty &&
      key.length <= 256 &&
      key != 'manifest' &&
      key != 'manifest-recovery';

  Future<Set<String>> _manifest({String? namespace}) async {
    final target = namespace ?? _namespace;
    if (target == null) return {};
    final objects = <String>{};
    var found = false;
    var parsed = false;
    for (final key in ['$target:manifest', '$target:manifest-recovery']) {
      final raw = await _secure.read(key);
      if (raw == null) continue;
      found = true;
      try {
        final values = jsonDecode(raw);
        if (values is! List ||
            values.length > 128 ||
            values.any((e) => e is! String || !_validObjectKey(e))) {
          continue;
        }
        objects.addAll(values.cast<String>());
        parsed = true;
      } on FormatException {
        // One intact index can recover this known namespace; never enumerate
        // other accounts, credentials or unindexed storage entries.
      }
    }
    if (found && !parsed) {
      throw const FormatException('No valid private cache index remains.');
    }
    return objects;
  }

  /// Successful online current-read grants this exact object for this process.
  Future<bool> saveAuthorized(
    String objectKey,
    Map<String, dynamic> value, {
    int? expectedAccountId,
    bool Function()? isCurrent,
  }) {
    // Capture at invocation, not when this work eventually reaches the queue.
    // Otherwise an old account's waiting write could borrow a new login's key.
    final generation = _generation;
    final account = _userId;
    final device = _deviceId;
    final session = _sessionId;
    final namespace = _namespace;
    final login = _loginAt;
    final wasUnlocked = _unlocked;
    final objectKeyOnDisk = _key(objectKey);
    final manifestKey = _manifestKey;
    final recoveryManifestKey = _recoveryManifestKey;
    final envelope = jsonEncode({
      'account_id': account,
      'session_id': session,
      'device_id': _deviceId,
      'object_id': objectKey,
      'login_at': login?.toIso8601String(),
      'value': value,
    });
    bool current() {
      try {
        return wasUnlocked &&
            generation == _generation &&
            account == _userId &&
            session == _sessionId &&
            namespace == _namespace &&
            login == _loginAt &&
            (expectedAccountId == null || account == expectedAccountId) &&
            (isCurrent?.call() ?? true);
      } catch (_) {
        return false;
      }
    }

    return _serialize(() async {
      if (namespace == null ||
          account == null ||
          device == null ||
          !current() ||
          !_canUse(offline: false) ||
          !_validObjectKey(objectKey) ||
          utf8.encode(envelope).length > 512 * 1024) {
        return false;
      }
      try {
        final storedOwner = await _readOwnerNamespace();
        if (storedOwner != null && storedOwner != namespace) {
          throw const FormatException('Private cache cleanup owner changed.');
        }
        final manifest = await _manifest();
        if (!current()) return false;
        if (manifest.length > 128) {
          throw const FormatException(
            'Recovered cache exceeds write capacity.',
          );
        }
        // Recovery first, then primary, then object. Saving also consumes the
        // union so a missing primary cannot erase older recovery-owned objects.
        if (!manifest.contains(objectKey) && manifest.length >= 128) {
          return false;
        }
        manifest.add(objectKey);
        await _secure.write(recoveryManifestKey, jsonEncode(manifest.toList()));
        if (!current()) return false;
        await _secure.write(manifestKey, jsonEncode(manifest.toList()));
        if (!current()) return false;
        // Establish cleanup reachability before writing any private content.
        // Empty logins and failures before the indexes do not create a locator.
        await _secure.write(
          _ownerLocatorKey,
          jsonEncode({
            'version': 1,
            'account_id': account,
            'device_id': device,
          }),
        );
        if (!current()) return false;
        if (await _readOwnerNamespace() != namespace) {
          throw const FormatException(
            'Private cache cleanup owner was not persisted.',
          );
        }
        if (!current()) return false;
        await _secure.write(objectKeyOnDisk, envelope);
        if (!current() || !_canUse(offline: false)) {
          await _secure.delete(objectKeyOnDisk);
          return false;
        }
        _readGrants.add(objectKey);
        return true;
      } catch (_) {
        if (generation == _generation) lock();
        return false;
      }
    });
  }

  Future<Map<String, dynamic>?> readOnlineAuthorized(String objectKey) =>
      _read(objectKey, offline: false);
  Future<Map<String, dynamic>?> readOffline(String objectKey) =>
      _read(objectKey, offline: true);

  Future<Map<String, dynamic>?> _read(
    String objectKey, {
    required bool offline,
  }) async {
    if (!_canUse(offline: offline) || !_readGrants.contains(objectKey)) {
      return null;
    }
    final generation = _generation;
    try {
      final raw = await _secure.read(_key(objectKey));
      if (raw == null ||
          generation != _generation ||
          !_canUse(offline: offline)) {
        return null;
      }
      final envelope = jsonDecode(raw) as Map<String, dynamic>;
      if (envelope['account_id'] != _userId ||
          envelope['session_id'] != _sessionId ||
          envelope['device_id'] != _deviceId ||
          envelope['object_id'] != objectKey ||
          envelope['login_at'] != _loginAt!.toIso8601String()) {
        lock();
        return null;
      }
      if (offline) {
        // The pure policy consumes the concrete login anchor, namespace and
        // decrypted-record bindings; its candidate alone never unlocked IO.
        final decision = OfflinePrivateRetentionPolicy.evaluate(
          OfflinePrivateRetentionClaims(
            elapsedSinceSuccessfulOnlineLogin: _trustedNow()?.difference(
              _loginAt!,
            ),
            timeClaim: RetentionTimeClaim.trusted,
            loginAccountId: '$_userId',
            loginDeviceId: _deviceId,
            isOffline: _offline,
            loggedOut: !_unlocked,
            accountChanged: false,
            knownInvalidation: !_readGrants.contains(objectKey),
            currentAccountId: '$_userId',
            currentDeviceId: _deviceId,
            requestedObjectId: objectKey,
            savedAccountId: '${envelope['account_id']}',
            savedDeviceId: envelope['device_id'] as String?,
            savedObjectId: envelope['object_id'] as String?,
            offlineReadClaimValid: _readGrants.contains(objectKey),
            contentSaved: true,
            ciphertextIntegrityVerified: true,
          ),
        );
        if (!decision.offlineReadOnlyCandidate) return null;
      }
      return Map<String, dynamic>.from(envelope['value'] as Map);
    } catch (_) {
      lock();
      return null;
    }
  }

  Future<void> removeObject(String objectKey) {
    if (!_validObjectKey(objectKey)) return Future<void>.value();
    final generation = _generation;
    final namespace = _namespace;
    final key = _key(objectKey);
    return _serialize(() async {
      if (generation != _generation || namespace != _namespace) return;
      _readGrants.remove(objectKey);
      if (_namespace == null) return;
      await _secure.delete(key);
    });
  }

  Future<PrivateCachePurgeReceipt> purgeExpired() => _serialize(() async {
    final now = _trustedNow();
    if (now == null || _loginAt == null || _namespace == null) {
      return const PrivateCachePurgeReceipt(
        PrivateCachePurgeStatus.untrustedTime,
      );
    }
    if (now.difference(_loginAt!) < const Duration(days: 30)) {
      return const PrivateCachePurgeReceipt(PrivateCachePurgeStatus.notDue);
    }
    return _purgeOwnedNamespace();
  });

  /// Explicit logout/account switch clears only the opened namespace or its
  /// validated restart locator. It never enumerates storage or restores reads.
  Future<PrivateCachePurgeReceipt> clearCurrentAccount() => _serialize(
    () async {
      lock();
      try {
        final storedOwner = await _readOwnerNamespace();
        if (storedOwner != null &&
            _namespace != null &&
            storedOwner != _namespace) {
          return const PrivateCachePurgeReceipt(PrivateCachePurgeStatus.failed);
        }
        final target = storedOwner ?? _namespace;
        if (target == null) {
          return const PrivateCachePurgeReceipt(
            PrivateCachePurgeStatus.completed,
          );
        }
        return _purgeNamespace(target);
      } catch (_) {
        return const PrivateCachePurgeReceipt(PrivateCachePurgeStatus.failed);
      }
    },
  );

  Future<PrivateCachePurgeReceipt> _purgeOwnedNamespace({
    bool invalidate = true,
  }) async {
    if (invalidate) lock();
    final target = _namespace;
    if (target == null) {
      return const PrivateCachePurgeReceipt(PrivateCachePurgeStatus.completed);
    }
    return _purgeNamespace(target);
  }

  Future<PrivateCachePurgeReceipt> _purgeNamespace(String namespace) async {
    var deleted = 0;
    try {
      final storedOwner = await _readOwnerNamespace();
      if (storedOwner != null && storedOwner != namespace) {
        return const PrivateCachePurgeReceipt(PrivateCachePurgeStatus.failed);
      }
      final manifest = await _manifest(namespace: namespace);
      for (final object in manifest) {
        final key = '$namespace:${Uri.encodeComponent(object)}';
        await _secure.delete(key);
        if (await _secure.read(key) != null) {
          return PrivateCachePurgeReceipt(
            PrivateCachePurgeStatus.failed,
            deletedObjects: deleted,
          );
        }
        deleted++;
      }
      for (final index in [
        '$namespace:manifest',
        '$namespace:manifest-recovery',
      ]) {
        await _secure.delete(index);
        if (await _secure.read(index) != null) {
          return PrivateCachePurgeReceipt(
            PrivateCachePurgeStatus.failed,
            deletedObjects: deleted,
          );
        }
      }
      if (storedOwner != null) {
        // Delete the locator last; any earlier failure retains its retry target.
        if (await _readOwnerNamespace() != namespace) {
          return PrivateCachePurgeReceipt(
            PrivateCachePurgeStatus.failed,
            deletedObjects: deleted,
          );
        }
        await _secure.delete(_ownerLocatorKey);
        if (await _secure.read(_ownerLocatorKey) != null) {
          return PrivateCachePurgeReceipt(
            PrivateCachePurgeStatus.failed,
            deletedObjects: deleted,
          );
        }
      }
      return PrivateCachePurgeReceipt(
        PrivateCachePurgeStatus.completed,
        deletedObjects: deleted,
      );
    } catch (_) {
      return PrivateCachePurgeReceipt(
        PrivateCachePurgeStatus.failed,
        deletedObjects: deleted,
      );
    }
  }
}

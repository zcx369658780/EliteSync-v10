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
        _userId = userId;
        _sessionId = session;
        _deviceId = device;
        _namespace = 'v1015_private:a$userId:d${Uri.encodeComponent(device)}';
        // A new successful login does not silently renew a prior process's
        // unverified cached copy. Clear only this exact account/device namespace.
        final cleanup = await _purgeOwnedNamespace(invalidate: false);
        if (generation != _generation ||
            cleanup.status != PrivateCachePurgeStatus.completed) {
          return false;
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

  Future<Set<String>> _manifest() async {
    final raw = await _secure.read(_manifestKey);
    if (raw == null) return <String>{};
    final values = jsonDecode(raw) as List<dynamic>;
    return values.map((e) => e as String).toSet();
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
    final session = _sessionId;
    final namespace = _namespace;
    final login = _loginAt;
    final wasUnlocked = _unlocked;
    final objectKeyOnDisk = _key(objectKey);
    final manifestKey = _manifestKey;
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
      if (!current() || !_canUse(offline: false) || objectKey.isEmpty) {
        return false;
      }
      try {
        final manifest = await _manifest();
        if (!current()) return false;
        // Index first, so interrupted object writes remain discoverable for purge.
        manifest.add(objectKey);
        await _secure.write(manifestKey, jsonEncode(manifest.toList()));
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

  /// Explicit logout/account switch only deletes the namespace opened by this
  /// login. Unknown old accounts and historical evidence are never enumerated.
  Future<PrivateCachePurgeReceipt> clearCurrentAccount() =>
      _serialize(() async {
        lock();
        if (_namespace == null) {
          return const PrivateCachePurgeReceipt(
            PrivateCachePurgeStatus.completed,
          );
        }
        return _purgeOwnedNamespace();
      });

  Future<PrivateCachePurgeReceipt> _purgeOwnedNamespace({
    bool invalidate = true,
  }) async {
    if (invalidate) lock();
    var deleted = 0;
    try {
      final manifest = await _manifest();
      for (final object in manifest) {
        final key = _key(object);
        await _secure.delete(key);
        if (await _secure.read(key) != null) {
          return PrivateCachePurgeReceipt(
            PrivateCachePurgeStatus.failed,
            deletedObjects: deleted,
          );
        }
        deleted++;
      }
      await _secure.delete(_manifestKey);
      if (await _secure.read(_manifestKey) != null) {
        return PrivateCachePurgeReceipt(
          PrivateCachePurgeStatus.failed,
          deletedObjects: deleted,
        );
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

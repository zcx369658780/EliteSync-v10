import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_elitesync_module/core/storage/secure_storage_service.dart';
import 'package:flutter_elitesync_module/features/chat/domain/offline_chat_text.dart';
import 'package:flutter_elitesync_module/features/chat/domain/offline_private_retention_policy.dart';

enum PrivateCachePurgeStatus { notDue, untrustedTime, completed, failed }

typedef RetainedListAuthority = ({bool recovered, Map<int, String> rooms});

class PrivateCachePurgeReceipt {
  const PrivateCachePurgeReceipt(this.status, {this.deletedObjects = 0});
  final PrivateCachePurgeStatus status;
  final int deletedObjects;
}

/// Account/device-scoped platform-encrypted storage. Credentials and cached
/// records cannot unlock this service: only a fresh successful online login can
/// establish its process-local monotonic clock. Restart deliberately locks it.
/// Save after the corresponding current server read, or for the owner's
/// explicit online submission receipt. Neither creates offline send authority.
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
  bool _awaitingForegroundResponse = false;
  int _generation = 0;
  int _onlineRevalidationEpoch = 0;
  final _readGrants = <String>{};
  final _offlineChatTextGrants = <String>{};
  final _savedChatRooms = <String, String>{};
  final _retainedListAuthority = ValueNotifier<RetainedListAuthority?>(null);
  Future<void> _mutation = Future.value();

  bool get isUnlocked => _unlocked && _trustedNow() != null;
  bool get isOffline => _offline;
  int get onlineRevalidationEpoch => _onlineRevalidationEpoch;
  ValueListenable<RetainedListAuthority?> get retainedListAuthority =>
      _retainedListAuthority;
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
    _awaitingForegroundResponse = false;
    _readGrants.clear();
    _offlineChatTextGrants.clear();
    _savedChatRooms.clear();
    _retainedListAuthority.value = null;
  }

  void revokeObject(String objectKey) {
    _generation++;
    _readGrants.remove(objectKey);
    _offlineChatTextGrants.remove(objectKey);
    _savedChatRooms.remove(objectKey);
  }

  void revokeOfflineChatText(int peerId) {
    _offlineChatTextGrants.remove('live-chat:$peerId');
  }

  void enterOffline({String? cachedObject}) {
    if (cachedObject != null && !_readGrants.contains(cachedObject)) return;
    if (_unlocked && _trustedNow() != null) _offline = true;
  }

  bool enterOfflineForChatText(int peerId) {
    if (!_offlineChatTextGrants.contains('live-chat:$peerId')) return false;
    enterOffline();
    return _offline;
  }

  /// Network recovery must be followed by a fresh current-read before any data
  /// becomes visible; it cannot inherit an offline object's old authorization.
  void beginOnlineRevalidation({bool recoveredFromRetainedList = false}) {
    _invalidateCurrentReads();
    _awaitingForegroundResponse = false;
    _offlineChatTextGrants.clear();
    _savedChatRooms.clear();
    if (recoveredFromRetainedList) {
      _retainedListAuthority.value = null;
      _retainedListAuthority.value = (recovered: true, rooms: const {});
    }
  }

  bool get hasOfflineChatTextGrants => _offlineChatTextGrants.isNotEmpty;

  bool observeRetainedListRooms(Map<int, String> rooms) {
    if (rooms.isEmpty) return false;
    var changedSavedRoom = false;
    for (final entry in rooms.entries) {
      final key = 'live-chat:${entry.key}';
      final savedRoom = _savedChatRooms[key];
      if (savedRoom != null && savedRoom != entry.value) {
        changedSavedRoom = true;
        _readGrants.remove(key);
        _offlineChatTextGrants.remove(key);
        _savedChatRooms.remove(key);
      }
    }
    // A mounted chat also cancels reads for any generation the list changed.
    _retainedListAuthority.value = (recovered: false, rooms: rooms);
    return changedSavedRoom;
  }

  /// Retire current reads immediately. A subsequent transport failure can
  /// still use a bound text receipt in this same trusted login process.
  void beginForegroundRevalidation() {
    _invalidateCurrentReads();
    _awaitingForegroundResponse = true;
  }

  void _invalidateCurrentReads() {
    _onlineRevalidationEpoch++;
    _generation++;
    _offline = false;
    _readGrants.clear();
  }

  /// Once a current request reaches the server, pre-background receipts may
  /// no longer provide a fallback. This leaves other online saves in flight.
  bool observeForegroundServerResponse() {
    if (!_awaitingForegroundResponse) return false;
    _awaitingForegroundResponse = false;
    _offlineChatTextGrants.clear();
    return true;
  }

  String _namespaceFor(int accountId, String deviceId) =>
      'v1015_private:a$accountId:d${Uri.encodeComponent(deviceId)}';

  // This locator is only a deletion target. It never restores a session,
  // a server clock, read grants, or offline access after process restart.
  Future<Map<String, dynamic>?> _readOwnerLocator() async {
    final raw = await _secure.read(_ownerLocatorKey);
    if (raw == null) return null;
    final value = jsonDecode(raw);
    if (value is! Map ||
        value['version'] is! int ||
        (value['version'] != 1 && value['version'] != 2) ||
        value.length != (value['version'] == 1 ? 3 : 4) ||
        (value['version'] == 2 && value['objects_cleared'] != true) ||
        value['account_id'] is! int ||
        (value['account_id'] as int) <= 0 ||
        value['device_id'] is! String ||
        (value['device_id'] as String).isEmpty) {
      throw const FormatException('Invalid private cache cleanup owner.');
    }
    return Map<String, dynamic>.from(value);
  }

  Future<String?> _readOwnerNamespace() async {
    final value = await _readOwnerLocator();
    if (value == null) return null;
    return _namespaceFor(
      value['account_id'] as int,
      value['device_id'] as String,
    );
  }

  ({DateTime wall, Stopwatch elapsed}) markLoginReceiptTime() =>
      (wall: _wallNow(), elapsed: Stopwatch()..start());

  Future<bool> establishLogin({
    required int userId,
    required Map<String, dynamic>? retention,
    ({String sessionId, DateTime loginAt})? verifiedResume,
    bool Function()? isCurrent,
    ({DateTime wall, Stopwatch elapsed})? receiptTime,
  }) {
    final timing = receiptTime ?? markLoginReceiptTime();
    lock();
    final generation = _generation;
    bool current() {
      try {
        return generation == _generation && (isCurrent?.call() ?? true);
      } catch (_) {
        return false;
      }
    }

    return _serialize(() async {
      if (!current()) return false;
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
        // Only the caller's successful online verification of the identical
        // session/T0 may carry explicit text drafts across a process restart.
        if (verifiedResume != null &&
            (isCurrent == null ||
                verifiedResume.sessionId != session ||
                verifiedResume.loginAt.toUtc() != login)) {
          return false;
        }
        final storedOwner = await _readOwnerNamespace();
        if (storedOwner != null &&
            _namespace != null &&
            storedOwner != _namespace) {
          return false;
        }
        final oldNamespace = storedOwner ?? _namespace;
        final nextNamespace = _namespaceFor(userId, device);
        final retainedDrafts = <String, String>{};
        var objects = <String>{};
        final resumeOwner = verifiedResume == null
            ? null
            : await _readOwnerLocator();
        if (verifiedResume != null &&
            oldNamespace == nextNamespace &&
            resumeOwner?['version'] == 1) {
          objects = await _manifest(namespace: oldNamespace);
          if (!current()) return false;
          for (final object in objects) {
            if (object != 'lifestyle-discovery-draft:v1' &&
                !RegExp(r'^live-chat-draft:[1-9][0-9]*$').hasMatch(object)) {
              continue;
            }
            final raw = await _secure.read(
              '$oldNamespace:${Uri.encodeComponent(object)}',
            );
            if (!current()) return false;
            if (raw == null || utf8.encode(raw).length > 512 * 1024) continue;
            try {
              final envelope = jsonDecode(raw);
              if (envelope is Map &&
                  envelope['account_id'] == userId &&
                  envelope['session_id'] == session &&
                  envelope['device_id'] == device &&
                  envelope['object_id'] == object &&
                  envelope['login_at'] == login.toIso8601String() &&
                  envelope['value'] is Map) {
                retainedDrafts[object] = raw;
              }
            } on FormatException {
              // Malformed or differently bound drafts follow normal cleanup.
            }
          }
        }
        if (retainedDrafts.length > 128) {
          throw const FormatException('Verified drafts exceed index capacity.');
        }
        if (retainedDrafts.isNotEmpty) {
          // Keep the original envelopes in place. A failed write or cancelled
          // verification must not destroy the only saved submission identity.
          for (final object in objects.difference(
            retainedDrafts.keys.toSet(),
          )) {
            if (!current()) return false;
            final key = '$nextNamespace:${Uri.encodeComponent(object)}';
            await _secure.delete(key);
            if (!current()) return false;
            if (await _secure.read(key) != null) {
              throw StateError('Old private object cleanup was not confirmed.');
            }
            if (!current()) return false;
          }
          final index = jsonEncode(retainedDrafts.keys.toList());
          for (final key in [
            '$nextNamespace:manifest-recovery',
            '$nextNamespace:manifest',
          ]) {
            if (!current()) return false;
            await _secure.write(key, index);
            if (!current()) return false;
            if (await _secure.read(key) != index) {
              throw StateError('Verified draft index was not confirmed.');
            }
            if (!current()) return false;
          }
          if (await _readOwnerNamespace() != nextNamespace ||
              (await _readOwnerLocator())?['version'] != 1) {
            throw StateError('Verified draft cleanup owner changed.');
          }
          for (final entry in retainedDrafts.entries) {
            if (await _secure.read(
                  '$nextNamespace:${Uri.encodeComponent(entry.key)}',
                ) !=
                entry.value) {
              throw StateError('Verified draft envelope changed.');
            }
            if (!current()) return false;
          }
          // No completion marker or read grant: content remains private until
          // its own current peer authorization succeeds after session recovery.
        } else if (oldNamespace != null) {
          final oldCleanup = await _purgeNamespace(oldNamespace);
          if (!current() ||
              oldCleanup.status != PrivateCachePurgeStatus.completed) {
            return false;
          }
        }
        _userId = userId;
        _sessionId = session;
        _deviceId = device;
        _namespace = nextNamespace;
        // A fresh login also clears any old copy at its exact target. Neither
        // the locator nor an old encrypted copy renews the login clock.
        if (nextNamespace != oldNamespace) {
          final cleanup = await _purgeOwnedNamespace(invalidate: false);
          if (!current() ||
              cleanup.status != PrivateCachePurgeStatus.completed) {
            return false;
          }
        }
        if (!current()) return false;
        _loginAt = login;
        _serverAnchor = server;
        _wallAnchor = timing.wall;
        _stopwatch = timing.elapsed;
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
    if (!parsed) {
      final owner = await _readOwnerLocator();
      final owned =
          owner != null &&
          _namespaceFor(
                owner['account_id'] as int,
                owner['device_id'] as String,
              ) ==
              target;
      // Only a verified post-deletion phase can distinguish a retry after
      // index removal from unexplained loss of both indexes.
      if (found || (owned && owner['objects_cleared'] != true)) {
        throw const FormatException('No valid private cache index remains.');
      }
    }
    return objects;
  }

  /// Successful online current-read grants this exact object for this process.
  Future<bool> saveAuthorized(
    String objectKey,
    Map<String, dynamic> value, {
    int? expectedAccountId,
    bool Function()? isCurrent,
  }) => _saveAuthorized(
    objectKey,
    value,
    expectedAccountId: expectedAccountId,
    isCurrent: isCurrent,
  );

  Future<bool> saveAuthorizedChatText(
    int peerId,
    Map<String, dynamic> value, {
    required int? expectedAccountId,
    required bool Function() isCurrent,
  }) => _saveAuthorized(
    'live-chat:$peerId',
    value,
    expectedAccountId: expectedAccountId,
    isCurrent: isCurrent,
    chatText: true,
  );

  Future<bool> _saveAuthorized(
    String objectKey,
    Map<String, dynamic> value, {
    int? expectedAccountId,
    bool Function()? isCurrent,
    bool chatText = false,
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
        final ownerRecord = jsonEncode({
          'version': 1,
          'account_id': account,
          'device_id': device,
        });
        await _secure.write(_ownerLocatorKey, ownerRecord);
        if (!current()) return false;
        if (await _secure.read(_ownerLocatorKey) != ownerRecord) {
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
        final room = value['room_key'];
        if (chatText && room is String && room.isNotEmpty) {
          _savedChatRooms[objectKey] = room;
        } else {
          _savedChatRooms.remove(objectKey);
        }
        if (chatText && value['offline_text_grant'] is Map) {
          _offlineChatTextGrants.add(objectKey);
        } else {
          _offlineChatTextGrants.remove(objectKey);
        }
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
      objectKey.startsWith('live-chat:')
      ? Future.value()
      : _read(objectKey, offline: true);

  Future<
    ({String roomKey, Duration remaining, List<Map<String, dynamic>> messages})?
  >
  readOfflineChatText(int peerId) async {
    final generation = _generation;
    final key = 'live-chat:$peerId';
    final saved = await _read(
      key,
      offline: true,
      grants: _offlineChatTextGrants,
    );
    final now = _trustedNow();
    final roomKey = saved?['room_key'];
    final rows = saved?['messages'];
    if (generation != _generation ||
        !_offlineChatTextGrants.contains(key) ||
        !_offline ||
        now == null ||
        _loginAt == null ||
        _userId == null ||
        _deviceId == null ||
        _sessionId == null ||
        roomKey is! String ||
        roomKey.isEmpty ||
        rows is! List) {
      return null;
    }
    final duration = OfflineChatText.remaining(
      receipt: saved?['offline_text_grant'],
      now: now,
      loginAt: _loginAt!,
      accountId: _userId!,
      peerId: peerId,
      deviceId: _deviceId!,
      sessionId: _sessionId!,
      roomKey: roomKey,
    );
    if (duration == null) return null;
    return (
      roomKey: roomKey,
      remaining: duration,
      messages: rows
          .map((row) => OfflineChatText.project(row, roomKey))
          .whereType<Map<String, dynamic>>()
          .toList(),
    );
  }

  /// Index-only overwrite guard. This neither reads content nor grants access;
  /// an entry may remain after deletion. Unknown is never proof of absence.
  Future<bool?> hasIndexedObject(
    String objectKey, {
    required int expectedAccountId,
  }) {
    final generation = _generation;
    return _serialize(() async {
      try {
        if (generation != _generation ||
            expectedAccountId != _userId ||
            !_validObjectKey(objectKey) ||
            !_canUse(offline: false)) {
          return null;
        }
        final objects = await _manifest();
        if (generation != _generation) return null;
        return objects.contains(objectKey);
      } catch (_) {
        if (generation == _generation) lock();
        return null;
      }
    });
  }

  /// The caller must first obtain a successful current server read for this
  /// exact context. This restores only a record of the already-open login;
  /// it cannot bootstrap a clock, unlock a cold start or renew a deadline.
  Future<Map<String, dynamic>?> readAfterCurrentAuthorization(
    String objectKey, {
    required int expectedAccountId,
    required bool Function() isCurrent,
  }) {
    final generation = _generation;
    bool current() {
      try {
        return generation == _generation &&
            expectedAccountId == _userId &&
            _validObjectKey(objectKey) &&
            _canUse(offline: false) &&
            isCurrent();
      } catch (_) {
        return false;
      }
    }

    return _serialize(() async {
      if (!current()) return null;
      _readGrants.add(objectKey);
      final value = await _read(objectKey, offline: false);
      if (!current() || value == null) {
        if (generation == _generation) _readGrants.remove(objectKey);
        return null;
      }
      return value;
    });
  }

  Future<Map<String, dynamic>?> _read(
    String objectKey, {
    required bool offline,
    Set<String>? grants,
  }) async {
    final readGrants = grants ?? _readGrants;
    if (!_canUse(offline: offline) || !readGrants.contains(objectKey)) {
      return null;
    }
    final generation = _generation;
    try {
      final raw = await _secure.read(_key(objectKey));
      if (raw == null ||
          generation != _generation ||
          !readGrants.contains(objectKey) ||
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
            knownInvalidation: !readGrants.contains(objectKey),
            currentAccountId: '$_userId',
            currentDeviceId: _deviceId,
            requestedObjectId: objectKey,
            savedAccountId: '${envelope['account_id']}',
            savedDeviceId: envelope['device_id'] as String?,
            savedObjectId: envelope['object_id'] as String?,
            offlineReadClaimValid: readGrants.contains(objectKey),
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

  Future<bool> removeObject(String objectKey) {
    if (!_validObjectKey(objectKey)) return Future<bool>.value(false);
    final generation = _generation;
    final namespace = _namespace;
    final key = _key(objectKey);
    return _serialize(() async {
      if (generation != _generation || namespace != _namespace) return false;
      _readGrants.remove(objectKey);
      _offlineChatTextGrants.remove(objectKey);
      _savedChatRooms.remove(objectKey);
      if (_namespace == null) return false;
      await _secure.delete(key);
      if (await _secure.read(key) != null) {
        throw StateError('Private object removal was not confirmed.');
      }
      return true;
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
      if (storedOwner != null) {
        final owner = await _readOwnerLocator();
        if (owner == null || await _readOwnerNamespace() != namespace) {
          return PrivateCachePurgeReceipt(
            PrivateCachePurgeStatus.failed,
            deletedObjects: deleted,
          );
        }
        // Persist completion only after every indexed object was deleted and
        // read back absent. It is a cleanup receipt, never read/login authority.
        final completed = jsonEncode({
          ...owner,
          'version': 2,
          'objects_cleared': true,
        });
        await _secure.write(_ownerLocatorKey, completed);
        if (await _secure.read(_ownerLocatorKey) != completed) {
          return PrivateCachePurgeReceipt(
            PrivateCachePurgeStatus.failed,
            deletedObjects: deleted,
          );
        }
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

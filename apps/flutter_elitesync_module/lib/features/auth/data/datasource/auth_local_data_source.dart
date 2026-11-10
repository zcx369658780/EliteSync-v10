import 'dart:convert';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/core/storage/secure_storage_service.dart';
import 'package:flutter_elitesync_module/core/storage/private_cache_service.dart';
import 'package:flutter_elitesync_module/features/auth/domain/entities/auth_session.dart';
import 'package:uuid/uuid.dart';

class _AuthStorageMutation {
  int epoch = 0;
  Future<void> queue = Future.value();
  Future<String>? deviceId;
}

class AuthLocalDataSource {
  const AuthLocalDataSource({
    required SecureStorageService secureStorage,
    required LocalStorageService localStorage,
  }) : _secureStorage = secureStorage,
       _localStorage = localStorage;

  final SecureStorageService _secureStorage;
  final LocalStorageService _localStorage;
  static final _mutations = Expando<_AuthStorageMutation>();
  _AuthStorageMutation get _mutation =>
      _mutations[_secureStorage] ??= _AuthStorageMutation();

  int beginLoginAttempt() => ++_mutation.epoch;
  bool isCurrentAttempt(int epoch) => epoch == _mutation.epoch;
  void cancelPendingLogin() => _mutation.epoch++;

  /// An explicit login attempt must not leave an older account resumable.
  Future<void> prepareLoginAttempt(int epoch) => _serialize(() async {
    if (!isCurrentAttempt(epoch)) throw StateError('Login changed.');
    await _secureStorage.delete(CacheKeys.privateResumeAllowed);
    if (!isCurrentAttempt(epoch) ||
        await _secureStorage.read(CacheKeys.privateResumeAllowed) != null) {
      throw StateError('Previous session recovery could not be disabled.');
    }
  });

  Future<
    ({
      String accessToken,
      String refreshToken,
      String deviceId,
      int userId,
      String sessionId,
      DateTime loginAt,
    })?
  >
  readResumeCandidate(int epoch) => _serialize(() async {
    if (!isCurrentAttempt(epoch)) return null;
    final raw = await _secureStorage.read(CacheKeys.privateResumeAllowed);
    if (raw == null) return null;
    final binding = jsonDecode(raw) as Map<String, dynamic>;
    final access = await _secureStorage.read(CacheKeys.accessToken);
    final refresh = await _secureStorage.read(CacheKeys.refreshToken);
    final device = await _secureStorage.read(CacheKeys.privateDeviceBinding);
    if (!isCurrentAttempt(epoch) ||
        access == null ||
        access.isEmpty ||
        refresh == null ||
        refresh.isEmpty ||
        device == null ||
        device.isEmpty)
      return null;
    if (binding['access_token'] != access ||
        binding['refresh_token'] != refresh ||
        binding['device_id'] != device ||
        binding['user_id'] is! int ||
        (binding['user_id'] as int) <= 0 ||
        binding['session_id'] is! String ||
        (binding['session_id'] as String).isEmpty)
      return null;
    return (
      accessToken: access,
      refreshToken: refresh,
      deviceId: device,
      userId: binding['user_id'] as int,
      sessionId: binding['session_id'] as String,
      loginAt: DateTime.parse(binding['login_at'] as String).toUtc(),
    );
  });
  Future<String> getOrCreateDeviceId() => _mutation.deviceId ??= () async {
    final saved = await _secureStorage.read(CacheKeys.privateDeviceBinding);
    if (saved != null && saved.isNotEmpty) return saved;
    final created = const Uuid().v4();
    await _secureStorage.write(CacheKeys.privateDeviceBinding, created);
    return created;
  }();

  Future<T> _serialize<T>(Future<T> Function() action) {
    final next = _mutation.queue.then((_) => action());
    _mutation.queue = next.then<void>((_) {}, onError: (Object _) {});
    return next;
  }

  Future<void> persistSession(
    AuthSession session, {
    Map<String, dynamic>? retention,
    int? expectedEpoch,
    String? expectedDeviceId,
    bool Function()? isCurrent,
  }) => _serialize(() async {
    void checkEpoch() {
      if ((expectedEpoch != null && !isCurrentAttempt(expectedEpoch)) ||
          (isCurrent != null && !isCurrent())) {
        throw StateError('Login changed; obsolete response was discarded.');
      }
    }

    checkEpoch();
    await _secureStorage.delete(CacheKeys.privateResumeAllowed);
    checkEpoch();
    if (await _secureStorage.read(CacheKeys.privateResumeAllowed) != null) {
      throw StateError('Previous session recovery could not be disabled.');
    }
    if (retention != null &&
        expectedDeviceId != null &&
        retention['device_id'] != expectedDeviceId) {
      throw StateError('Login device binding did not match.');
    }
    final cache = PrivateCacheService.forStorage(_secureStorage);
    final cleanup = await cache.clearCurrentAccount();
    checkEpoch();
    if (cleanup.status == PrivateCachePurgeStatus.failed ||
        !await _localStorage.purgeLegacyPrivateCache()) {
      cache.lock();
      throw StateError('Private cache cleanup failed; login remains locked.');
    }
    checkEpoch();
    final trusted = await cache.establishLogin(
      userId: session.user.id,
      retention: retention,
    );
    if (retention != null && !trusted) {
      throw StateError('Login retention receipt could not be verified.');
    }
    checkEpoch();
    await _secureStorage.write(CacheKeys.accessToken, session.accessToken);
    await _secureStorage.write(CacheKeys.refreshToken, session.refreshToken);
    checkEpoch();
    await _clearAccountScopedCaches();
    checkEpoch();
    await _localStorage.setJson(CacheKeys.lastKnownProfile, {
      'id': session.user.id,
      'phone': session.user.phone,
      'role': session.user.role,
      'nickname': session.user.nickname,
      'name': session.user.nickname,
      'birthday': session.user.birthday,
      'birth_time': session.user.birthTime,
      'gender': session.user.gender,
      'city': session.user.city,
      'relationship_goal': session.user.relationshipGoal,
      'target': session.user.relationshipGoal,
      'birth_place': session.user.birthPlace,
      'birth_lat': session.user.birthLat,
      'birth_lng': session.user.birthLng,
      'avatar_url': session.user.avatarUrl,
      'verified': session.user.verified,
      'realname_verified': session.user.verified,
    });
    checkEpoch();
    if (retention != null && trusted && session.refreshToken.isNotEmpty) {
      final binding = jsonEncode({
        'access_token': session.accessToken,
        'refresh_token': session.refreshToken,
        'user_id': session.user.id,
        'device_id': retention['device_id'],
        'session_id': retention['session_id'].toString(),
        'login_at': retention['login_at'],
      });
      await _secureStorage.write(CacheKeys.privateResumeAllowed, binding);
      checkEpoch();
      if (await _secureStorage.read(CacheKeys.privateResumeAllowed) !=
          binding) {
        throw StateError('Session recovery marker was not saved.');
      }
      checkEpoch();
    }
  });

  /// Publish visible credentials through the same queue as login and logout.
  /// This does not establish or renew a trusted-login retention receipt.
  Future<void> persistVisibleCredentials({
    required String accessToken,
    String? refreshToken,
    required bool Function() isCurrent,
  }) => _serialize(() async {
    void checkCurrent() {
      if (!isCurrent() || accessToken.isEmpty)
        throw StateError('Obsolete credentials discarded.');
    }

    checkCurrent();
    final savedAccess = await _secureStorage.read(CacheKeys.accessToken);
    final savedRefresh = await _secureStorage.read(CacheKeys.refreshToken);
    checkCurrent();
    if (savedAccess != accessToken || savedRefresh != refreshToken) {
      await _secureStorage.delete(CacheKeys.privateResumeAllowed);
      checkCurrent();
      if (await _secureStorage.read(CacheKeys.privateResumeAllowed) != null) {
        throw StateError('Previous session recovery could not be disabled.');
      }
      checkCurrent();
    }
    await _secureStorage.write(CacheKeys.accessToken, accessToken);
    checkCurrent();
    if (refreshToken == null) {
      await _secureStorage.delete(CacheKeys.refreshToken);
    } else {
      await _secureStorage.write(CacheKeys.refreshToken, refreshToken);
    }
    checkCurrent();
  });

  Future<void> clearSession() async {
    await clearSessionWithReceipt();
  }

  /// Enqueue at logout invocation, behind old writes and before a later login.
  /// A failed deletion never restores a visible session or unlocks private data.
  Future<bool> clearSessionWithReceipt() {
    cancelPendingLogin();
    final cache = PrivateCacheService.forStorage(_secureStorage);
    cache.lock();
    var completed = false;
    return _serialize(() async {
      final privateCleanup = await cache.clearCurrentAccount();
      final legacyCleaned = await _localStorage.purgeLegacyPrivateCache();
      var credentialsCleaned = true;
      for (final key in [
        CacheKeys.privateResumeAllowed,
        CacheKeys.accessToken,
        CacheKeys.refreshToken,
      ]) {
        try {
          await _secureStorage.delete(key);
          if (await _secureStorage.read(key) != null)
            credentialsCleaned = false;
        } catch (_) {
          credentialsCleaned = false;
        }
      }
      var snapshotsCleaned = true;
      try {
        await _clearAccountScopedCaches();
      } catch (_) {
        snapshotsCleaned = false;
      }
      completed =
          privateCleanup.status == PrivateCachePurgeStatus.completed &&
          legacyCleaned &&
          credentialsCleaned &&
          snapshotsCleaned;
    }).then((_) => completed);
  }

  Future<void> _clearAccountScopedCaches() async {
    await _localStorage.remove(CacheKeys.lastKnownProfile);
    await _localStorage.remove(CacheKeys.profileSummarySnapshot);
    await _localStorage.remove(CacheKeys.profileDetailSnapshot);
    await _localStorage.remove(CacheKeys.matchResultSnapshot);
    await _localStorage.remove(CacheKeys.matchDetailSnapshot);
    await _localStorage.remove(CacheKeys.questionnaireProfileSnapshot);
    await _localStorage.remove(CacheKeys.questionnaireDraft);
    await _localStorage.remove(CacheKeys.messagesConversationSnapshot);
    await _localStorage.remove(CacheKeys.messagesSearchHistory);
    await _localStorage.remove(CacheKeys.messagesQuickUnreadOnly);
    await _localStorage.remove(CacheKeys.homeFeedSnapshot);
    await _localStorage.remove(CacheKeys.discoverFeedSnapshot);
    await _localStorage.remove(CacheKeys.homeSearchHistory);
    await _localStorage.remove(CacheKeys.discoverSearchHistory);
    await _localStorage.remove(CacheKeys.homeSelectedTab);
    await _localStorage.remove(CacheKeys.discoverSelectedTab);
    await _localStorage.remove(CacheKeys.homeSearchQuery);
    await _localStorage.remove(CacheKeys.discoverSearchQuery);
    await _localStorage.remove(CacheKeys.chatDraftPrefix);
  }
}

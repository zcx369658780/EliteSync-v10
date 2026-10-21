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
  Future<String> getOrCreateDeviceId() => _mutation.deviceId ??= () async {
    final saved = await _secureStorage.read(CacheKeys.privateDeviceBinding);
    if (saved != null && saved.isNotEmpty) return saved;
    final created = const Uuid().v4();
    await _secureStorage.write(CacheKeys.privateDeviceBinding, created);
    return created;
  }();

  Future<void> _serialize(Future<void> Function() action) {
    final next = _mutation.queue.then((_) => action());
    _mutation.queue = next.catchError((Object _) {});
    return next;
  }

  Future<void> persistSession(
    AuthSession session, {
    Map<String, dynamic>? retention,
    int? expectedEpoch,
    String? expectedDeviceId,
  }) => _serialize(() async {
    void checkEpoch() {
      if (expectedEpoch != null && !isCurrentAttempt(expectedEpoch)) {
        throw StateError('Login changed; obsolete response was discarded.');
      }
    }

    checkEpoch();
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
  });

  Future<void> clearSession() {
    cancelPendingLogin();
    return _serialize(() async {
      await PrivateCacheService.forStorage(
        _secureStorage,
      ).clearCurrentAccount();
      await _localStorage.purgeLegacyPrivateCache();
      await _secureStorage.delete(CacheKeys.accessToken);
      await _secureStorage.delete(CacheKeys.refreshToken);
      await _clearAccountScopedCaches();
    });
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
    await _localStorage.remove(CacheKeys.messagesSelectedTab);
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

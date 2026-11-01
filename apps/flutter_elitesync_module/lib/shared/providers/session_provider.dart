import 'package:flutter_elitesync_module/features/auth/data/datasource/auth_local_data_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/storage/private_cache_service.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class SessionState {
  const SessionState({
    required this.status,
    this.user,
    this.accessToken,
    this.refreshToken,
    this.notice,
  });

  final AuthStatus status;
  final UserSummary? user;
  final String? accessToken;
  final String? refreshToken;
  final String? notice;

  bool get isLoggedIn => status == AuthStatus.authenticated;

  SessionState copyWith({
    AuthStatus? status,
    UserSummary? user,
    String? accessToken,
    String? refreshToken,
  }) {
    return SessionState(
      status: status ?? this.status,
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  static const unknown = SessionState(status: AuthStatus.unknown);
}

// Transient UI notice; reading the login page must not start credential IO.
class SessionRejectionNotice extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? value) => state = value;
}

final sessionRejectionNoticeProvider =
    NotifierProvider<SessionRejectionNotice, String?>(
      SessionRejectionNotice.new,
    );

class SessionNotifier extends AsyncNotifier<SessionState> {
  Future<void> _mutation = Future.value();
  int _authenticationIntent = 0;
  int beginAuthentication() {
    _authenticationIntent++;
    PrivateCacheService.forStorage(ref.read(secureStorageProvider)).lock();
    state = const AsyncData(SessionState(status: AuthStatus.unauthenticated));
    return _authenticationIntent;
  }
  bool isCurrentAuthentication(int intent) => intent == _authenticationIntent;
  Future<void> _serialize(Future<void> Function() action) {
    final next = _mutation.then((_) => action());
    _mutation = next.catchError((Object _) {});
    return next;
  }

  Future<void> _clearAccountSnapshots() async {
    final local = ref.read(localStorageProvider);
    for (final key in [
      CacheKeys.lastKnownProfile,
      CacheKeys.profileSummarySnapshot,
      CacheKeys.profileDetailSnapshot,
      CacheKeys.questionnaireProfileSnapshot,
      CacheKeys.questionnaireDraft,
      CacheKeys.matchResultSnapshot,
      CacheKeys.matchDetailSnapshot,
      CacheKeys.matchFeedbackHistory,
      CacheKeys.homeFeedSnapshot,
      CacheKeys.discoverFeedSnapshot,
      CacheKeys.messagesConversationSnapshot,
      CacheKeys.rtcAutoInviteHandledCallId,
      CacheKeys.rtcAutoInviteHandledNotificationId,
    ]) {
      await local.remove(key);
    }
  }

  @override
  Future<SessionState> build() async {
    final secure = ref.read(secureStorageProvider);
    final local = ref.read(localStorageProvider);
    PrivateCacheService.forStorage(secure).lock();
    // Persisted credentials/profile cannot prove a current online session or a
    // trustworthy cross-restart clock. Require a successful online login.
    await local.purgeLegacyPrivateCache();
    return const SessionState(status: AuthStatus.unauthenticated);
  }

  Future<void> setAuthenticated({
    required String accessToken,
    String? refreshToken,
    UserSummary? user,
    int? expectedIntent,
  }) {
    final intent = expectedIntent ?? _authenticationIntent;
    return _serialize(() async {
    void checkIntent() {
      if (!isCurrentAuthentication(intent)) throw StateError('Obsolete login response discarded.');
    }
    checkIntent();
    final secure = ref.read(secureStorageProvider);
    final local = ref.read(localStorageProvider);

    final cache = PrivateCacheService.forStorage(secure);
    if (cache.accountId != null && cache.accountId != user?.id) cache.lock();
    final expectedCacheAccount = cache.accountId;
    if (!await local.purgeLegacyPrivateCache()) {
      cache.lock();
      throw StateError('Private cache cleanup failed; login remains locked.');
    }
    await _clearAccountSnapshots();

    checkIntent();
    await AuthLocalDataSource(secureStorage: secure, localStorage: local)
        .persistVisibleCredentials(
          accessToken: accessToken, refreshToken: refreshToken,
          isCurrent: () => isCurrentAuthentication(intent),
        );
    checkIntent();
    if (user != null) {
      await local.setJson(CacheKeys.lastKnownProfile, user.toJson());
    }

    if (expectedCacheAccount != null &&
        cache.accountId != expectedCacheAccount) {
      throw StateError(
        'Login changed while private storage was being checked.',
      );
    }

    checkIntent();
    ref.read(sessionRejectionNoticeProvider.notifier).set(null);
    state = AsyncData(
      SessionState(
        status: AuthStatus.authenticated,
        user: user,
        accessToken: accessToken,
        refreshToken: refreshToken,
      ),
    );
    });
  }

  Future<void> updateProfile(
    UserSummary user, {
    String? expectedAccessToken,
  }) => _serialize(() async {
    final local = ref.read(localStorageProvider);
    final current = state.maybeWhen(data: (s) => s, orElse: () => null);
    if (current == null || !current.isLoggedIn) return;
    if (expectedAccessToken != null &&
        current.accessToken != expectedAccessToken) {
      return;
    }
    if (current.user != null && user.id != 0 && current.user!.id != user.id) {
      return;
    }
    final intent = _authenticationIntent;
    final merged = UserSummary(
      id: user.id != 0 ? user.id : (current.user?.id ?? 0),
      phone: user.phone.isNotEmpty ? user.phone : (current.user?.phone ?? ''),
      role: user.role.isNotEmpty ? user.role : (current.user?.role ?? 'user'),
      nickname: user.nickname ?? current.user?.nickname,
      birthday: user.birthday ?? current.user?.birthday,
      birthTime: user.birthTime ?? current.user?.birthTime,
      gender: user.gender ?? current.user?.gender,
      city: user.city ?? current.user?.city,
      relationshipGoal: user.relationshipGoal ?? current.user?.relationshipGoal,
      birthPlace: user.birthPlace ?? current.user?.birthPlace,
      birthLat: user.birthLat ?? current.user?.birthLat,
      birthLng: user.birthLng ?? current.user?.birthLng,
      avatarUrl: user.avatarUrl ?? current.user?.avatarUrl,
      verified: user.verified,
      moderationStatus: user.moderationStatus.isNotEmpty
          ? user.moderationStatus
          : (current.user?.moderationStatus ?? 'normal'),
      moderationNote: user.moderationNote ?? current.user?.moderationNote,
    );

    await local.setJson(CacheKeys.lastKnownProfile, merged.toJson());
    if (intent != _authenticationIntent ||
        state.asData?.value.accessToken != current.accessToken ||
        state.asData?.value.isLoggedIn != true) {
      return;
    }
    state = AsyncData(current.copyWith(user: merged));
  });

  Future<void> cacheProfileSnapshot(
    String key,
    Map<String, dynamic> value, {
    required SessionState? expectedSession,
  }) => _serialize(() async {
    final current = state.asData?.value;
    if (current?.status != expectedSession?.status ||
        current?.accessToken != expectedSession?.accessToken ||
        current?.user?.id != expectedSession?.user?.id) {
      throw StateError('登录会话已变化，旧资料缓存未写入。');
    }
    await ref.read(localStorageProvider).setJson(key, value);
  });

  Future<void> setUnauthenticated({String? notice, String? rejectedToken}) {
    final visibleToken = state.asData?.value.accessToken;
    if (rejectedToken != null && rejectedToken != visibleToken) return Future.value();
    final logoutIntent = ++_authenticationIntent;
    state = AsyncData(SessionState(status: AuthStatus.unauthenticated, notice: notice));
    ref.read(sessionRejectionNoticeProvider.notifier).set(notice);
    final storage = ref.read(secureStorageProvider);
    final local = AuthLocalDataSource(
      secureStorage: storage, localStorage: ref.read(localStorageProvider),
    );
    // Invoke now: waiting old persistSession writes must finish before deletion,
    // while a later login's writes must be enqueued after this cleanup.
    final cleanup = local.clearSessionWithReceipt();
    return _serialize(() async {
      final completed = await cleanup;
      if (logoutIntent != _authenticationIntent) return;
      final effectiveNotice = completed ? notice :
          '已退出，私密数据仍锁定；部分本地清理未完成，请重新登录后重试。';
      state = AsyncData(SessionState(status: AuthStatus.unauthenticated, notice: effectiveNotice));
      ref.read(sessionRejectionNoticeProvider.notifier).set(effectiveNotice);
    });
  }

}

final sessionProvider = AsyncNotifierProvider<SessionNotifier, SessionState>(
  SessionNotifier.new,
);

final authStatusProvider = Provider<AuthStatus>((ref) {
  final session = ref.watch(sessionProvider);
  return session.maybeWhen(
    data: (state) => state.status,
    orElse: () => AuthStatus.unknown,
  );
});

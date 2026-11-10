import 'package:flutter_elitesync_module/features/auth/data/datasource/auth_local_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/features/auth/data/dto/login_response_dto.dart';
import 'package:flutter_elitesync_module/features/auth/data/mapper/auth_mapper.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/pending_logout_store.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
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
  SessionState build() {
    final secure = ref.read(secureStorageProvider);
    final local = ref.read(localStorageProvider);
    final cache = PrivateCacheService.forStorage(secure)..lock();
    final auth = AuthLocalDataSource(
      secureStorage: secure,
      localStorage: local,
    );
    final intent = _authenticationIntent;
    final epoch = auth.beginLoginAttempt();
    var active = true;
    ref.onDispose(() {
      active = false;
      auth.cancelPendingLogin();
      cache.lock();
    });
    bool current() =>
        active &&
        intent == _authenticationIntent &&
        auth.isCurrentAttempt(epoch);
    // Finish build synchronously. Startup IO can never publish a late build
    // result over a newer explicit login/logout.
    Future<void>(() async {
      try {
        final cleaned = await local.purgeLegacyPrivateCache();
        if (!current()) return;
        if (!cleaned) throw StateError('Private cache cleanup failed.');
        final candidate = await auth.readResumeCandidate(epoch);
        if (!current()) return;
        if (candidate == null) {
          state = const AsyncData(
            SessionState(status: AuthStatus.unauthenticated),
          );
          return;
        }
        final pending = await PendingLogoutStore.read(secure);
        if (!current()) return;
        if (pending.contains(candidate.accessToken) ||
            pending.contains(candidate.refreshToken)) {
          state = const AsyncData(
            SessionState(status: AuthStatus.unauthenticated),
          );
          return;
        }
        // This client has no session dependency, retries, logging or token
        // rotation. Both credentials must belong to one current server family.
        final result = await ref
            .read(restrictedAccountClientProvider)
            .post(
              '/api/v1/auth/session/verify',
              body: {'refresh_token': candidate.refreshToken},
              options: Options(
                headers: {'Authorization': 'Bearer ${candidate.accessToken}'},
              ),
            );
        if (!current()) return;
        if (result is! NetworkSuccess<Map<String, dynamic>>)
          throw StateError('Session not verified.');
        final data = result.data;
        final user = Map<String, dynamic>.from(data['user'] as Map);
        final retention = Map<String, dynamic>.from(
          data['session_retention'] as Map,
        );
        if (data['verified'] != true ||
            user['id'] != candidate.userId ||
            retention['user_id'].toString() != user['id'].toString() ||
            retention['device_id'] != candidate.deviceId ||
            data['session_id'] != candidate.sessionId ||
            data['session_id'] != retention['session_id']) {
          throw StateError('Online session binding mismatch.');
        }
        final login = DateTime.parse(retention['login_at'] as String).toUtc();
        final server = DateTime.parse(
          retention['server_now'] as String,
        ).toUtc();
        final expires = DateTime.parse(
          retention['online_expires_at'] as String,
        ).toUtc();
        final purge = DateTime.parse(retention['purge_at'] as String).toUtc();
        if (login != candidate.loginAt ||
            expires.difference(login) != const Duration(days: 15) ||
            purge.difference(login) != const Duration(days: 30) ||
            server.isBefore(login) ||
            !server.isBefore(expires)) {
          throw StateError('Online session time is not trusted.');
        }
        final restored = const AuthMapper().toSession(
          LoginResponseDto(
            ok: true,
            accessToken: candidate.accessToken,
            refreshToken: candidate.refreshToken,
            user: user,
            sessionRetention: retention,
          ),
        );
        await _serialize(() async {
          if (!current()) return;
          await auth.persistSession(
            restored,
            retention: retention,
            expectedEpoch: epoch,
            expectedDeviceId: candidate.deviceId,
            isCurrent: current,
          );
          if (!current()) return;
          state = AsyncData(
            SessionState(
              status: AuthStatus.authenticated,
              accessToken: candidate.accessToken,
              refreshToken: candidate.refreshToken,
              user: UserSummary.fromJson(user),
            ),
          );
        });
      } catch (_) {
        if (!current()) return;
        cache.lock();
        state = const AsyncData(
          SessionState(status: AuthStatus.unauthenticated),
        );
      }
    });
    return SessionState.unknown;
  }

  Future<void> setAuthenticated({
    required String accessToken,
    String? refreshToken,
    UserSummary? user,
    int? expectedIntent,
  }) {
    final intent = expectedIntent ?? ++_authenticationIntent;
    return _serialize(() async {
      void checkIntent() {
        if (!isCurrentAuthentication(intent))
          throw StateError('Obsolete login response discarded.');
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
      await AuthLocalDataSource(
        secureStorage: secure,
        localStorage: local,
      ).persistVisibleCredentials(
        accessToken: accessToken,
        refreshToken: refreshToken,
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
    if (rejectedToken != null && rejectedToken != visibleToken)
      return Future.value();
    final logoutIntent = ++_authenticationIntent;
    state = AsyncData(
      SessionState(status: AuthStatus.unauthenticated, notice: notice),
    );
    ref.read(sessionRejectionNoticeProvider.notifier).set(notice);
    final storage = ref.read(secureStorageProvider);
    final local = AuthLocalDataSource(
      secureStorage: storage,
      localStorage: ref.read(localStorageProvider),
    );
    // Invoke now: waiting old persistSession writes must finish before deletion,
    // while a later login's writes must be enqueued after this cleanup.
    final cleanup = local.clearSessionWithReceipt();
    return _serialize(() async {
      final completed = await cleanup;
      if (logoutIntent != _authenticationIntent) return;
      final effectiveNotice = completed
          ? notice
          : '已退出，私密数据仍锁定；部分本地清理未完成，请重新登录后重试。';
      state = AsyncData(
        SessionState(
          status: AuthStatus.unauthenticated,
          notice: effectiveNotice,
        ),
      );
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

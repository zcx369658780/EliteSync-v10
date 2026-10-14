import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
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
  Future<void> _serialize(Future<void> Function() action) {
    final next = _mutation.then((_) => action());
    _mutation = next.catchError((Object _) {});
    return next;
  }

  @override
  Future<SessionState> build() async {
    final secure = ref.read(secureStorageProvider);
    final local = ref.read(localStorageProvider);

    final accessToken = await secure.read(CacheKeys.accessToken);
    final refreshToken = await secure.read(CacheKeys.refreshToken);
    final profileJson = await local.getJson(CacheKeys.lastKnownProfile);

    if (accessToken == null || accessToken.isEmpty) {
      return const SessionState(status: AuthStatus.unauthenticated);
    }

    final user = profileJson == null ? null : UserSummary.fromJson(profileJson);
    return SessionState(
      status: AuthStatus.authenticated,
      user: user,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  Future<void> setAuthenticated({
    required String accessToken,
    String? refreshToken,
    UserSummary? user,
  }) => _serialize(() async {
    final secure = ref.read(secureStorageProvider);
    final local = ref.read(localStorageProvider);

    await local.tryPurgeLegacyPrivateChatCache();

    await secure.write(CacheKeys.accessToken, accessToken);
    if (refreshToken != null) {
      await secure.write(CacheKeys.refreshToken, refreshToken);
    }
    if (user != null) {
      await local.setJson(CacheKeys.lastKnownProfile, user.toJson());
    }

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
      verified: user.verified || (current.user?.verified ?? false),
      moderationStatus: user.moderationStatus.isNotEmpty
          ? user.moderationStatus
          : (current.user?.moderationStatus ?? 'normal'),
      moderationNote: user.moderationNote ?? current.user?.moderationNote,
    );

    await local.setJson(CacheKeys.lastKnownProfile, merged.toJson());
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

  Future<void> setUnauthenticated({String? notice, String? rejectedToken}) =>
      _serialize(() async {
        String? currentToken;
        try {
          currentToken = await ref
              .read(secureStorageProvider)
              .read(CacheKeys.accessToken);
        } catch (_) {
          final current = state.asData?.value;
          if (rejectedToken == null || current?.accessToken == rejectedToken) {
            ref.read(sessionRejectionNoticeProvider.notifier).set(notice);
            state = AsyncData(
              SessionState(status: AuthStatus.unauthenticated, notice: notice),
            );
          }
          rethrow;
        }
        if (rejectedToken != null && currentToken != rejectedToken) return;
        ref.read(sessionRejectionNoticeProvider.notifier).set(notice);
        state = AsyncData(
          SessionState(status: AuthStatus.unauthenticated, notice: notice),
        );
        await ref.read(localStorageProvider).tryPurgeLegacyPrivateChatCache();
        final secure = ref.read(secureStorageProvider);
        await secure.delete(CacheKeys.accessToken);
        await secure.delete(CacheKeys.refreshToken);

        final local = ref.read(localStorageProvider);
        await local.remove(CacheKeys.lastKnownProfile);
        await local.remove(CacheKeys.profileSummarySnapshot);
        await local.remove(CacheKeys.profileDetailSnapshot);
        state = AsyncData(
          SessionState(status: AuthStatus.unauthenticated, notice: notice),
        );
      });
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

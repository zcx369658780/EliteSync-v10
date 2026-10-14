import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/features/profile/data/datasource/profile_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/profile/data/mapper/profile_mapper.dart';
import 'package:flutter_elitesync_module/features/profile/data/repository/profile_repository_impl.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_detail_entity.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_summary_entity.dart';
import 'package:flutter_elitesync_module/features/profile/domain/repository/profile_repository.dart';
import 'package:flutter_elitesync_module/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:flutter_elitesync_module/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/state/edit_profile_ui_state.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/state/personal_showcase_model.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/state/profile_ui_state.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_profile_provider.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((
  ref,
) {
  final env = ref.watch(appEnvProvider);
  return ProfileRemoteDataSource(
    apiClient: ref.watch(apiClientProvider),
    useMock: env.useMockProfile,
  );
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    remote: ref.watch(profileRemoteDataSourceProvider),
    mapper: const ProfileMapper(),
  );
});

final getProfileUseCaseProvider = Provider<GetProfileUseCase>(
  (ref) => GetProfileUseCase(ref.watch(profileRepositoryProvider)),
);
final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>(
  (ref) => UpdateProfileUseCase(ref.watch(profileRepositoryProvider)),
);

Map<String, dynamic> _summaryToJson(ProfileSummaryEntity summary) => {
  'nickname': summary.nickname,
  'name': summary.nickname,
  'birthday': summary.birthday,
  'birth_time': summary.birthTime,
  'birth_place': summary.birthPlace,
  'birth_lat': summary.birthLat,
  'birth_lng': summary.birthLng,
  'city': summary.city,
  'target': summary.target,
  'relationship_goal': summary.target,
  'verified': summary.verified,
  'realname_verified': summary.verified,
  'moderation_status': summary.moderationStatus,
  'moderation_note': summary.moderationNote,
  'completion': summary.completion,
  'tags': summary.tags,
};

Map<String, dynamic> _detailToJson(ProfileDetailEntity detail) => {
  'nickname': detail.nickname,
  'name': detail.nickname,
  'gender': detail.gender,
  'birthday': detail.birthday,
  'birth_time': detail.birthTime,
  'city': detail.city,
  'target': detail.target,
  'relationship_goal': detail.target,
  'birth_place': detail.birthPlace,
  'birth_lat': detail.birthLat,
  'birth_lng': detail.birthLng,
};

ProfileSummaryEntity _summaryFromDetail(
  ProfileDetailEntity detail,
  ProfileSummaryEntity? currentSummary,
) {
  final tags = <String>[
    if (detail.birthday.isNotEmpty) '生日已确认',
    if (detail.birthTime.isNotEmpty) '出生时间已确认',
    if (detail.gender.isNotEmpty) '性别已确认',
    if (detail.target.isNotEmpty) '婚恋目标已确认',
    if (detail.city.isNotEmpty) '城市已确认',
    if ((detail.birthPlace ?? '').isNotEmpty) '出生地已确认',
    '本地草稿待确认',
  ];
  return ProfileSummaryEntity(
    nickname: detail.nickname.isNotEmpty
        ? detail.nickname
        : (currentSummary?.nickname ?? ''),
    birthday: detail.birthday.isNotEmpty
        ? detail.birthday
        : (currentSummary?.birthday ?? ''),
    birthTime: detail.birthTime.isNotEmpty
        ? detail.birthTime
        : (currentSummary?.birthTime ?? ''),
    birthPlace: detail.birthPlace ?? currentSummary?.birthPlace,
    birthLat: detail.birthLat ?? currentSummary?.birthLat,
    birthLng: detail.birthLng ?? currentSummary?.birthLng,
    city: detail.city.isNotEmpty ? detail.city : (currentSummary?.city ?? ''),
    target: detail.target.isNotEmpty
        ? detail.target
        : (currentSummary?.target ?? ''),
    verified: currentSummary?.verified ?? false,
    moderationStatus: currentSummary?.moderationStatus ?? 'normal',
    moderationNote: currentSummary?.moderationNote,
    completion: 0.8,
    tags: tags,
  );
}

ProfileSummaryEntity? _summaryFromJson(Map<String, dynamic>? json) {
  if (json == null || json.isEmpty) return null;
  return ProfileSummaryEntity(
    nickname: (json['nickname'] ?? json['name'] ?? '').toString(),
    birthday: (json['birthday'] ?? '').toString(),
    birthTime: (json['birth_time'] ?? json['birthTime'] ?? '').toString(),
    birthPlace:
        (json['birth_place'] ?? json['private_birth_place'] ?? '')
            .toString()
            .isEmpty
        ? null
        : (json['birth_place'] ?? json['private_birth_place'] ?? '').toString(),
    birthLat:
        (json['birth_lat'] as num?)?.toDouble() ??
        (json['private_birth_lat'] as num?)?.toDouble(),
    birthLng:
        (json['birth_lng'] as num?)?.toDouble() ??
        (json['private_birth_lng'] as num?)?.toDouble(),
    city: (json['city'] ?? '').toString(),
    target: (json['target'] ?? json['relationship_goal'] ?? '').toString(),
    verified:
        (json['verified'] as bool?) ??
        (json['realname_verified'] as bool?) ??
        false,
    moderationStatus: (json['moderation_status'] ?? 'normal').toString(),
    moderationNote: (json['moderation_note'] ?? '').toString().isEmpty
        ? null
        : (json['moderation_note'] ?? '').toString(),
    completion: (json['completion'] as num?)?.toDouble() ?? 0,
    tags: (json['tags'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList(),
  );
}

ProfileDetailEntity? _detailFromJson(Map<String, dynamic>? json) {
  if (json == null || json.isEmpty) return null;
  return ProfileDetailEntity(
    nickname: (json['nickname'] ?? json['name'] ?? '').toString(),
    gender: (json['gender'] ?? '').toString(),
    birthday: (json['birthday'] ?? '').toString(),
    birthTime: (json['birth_time'] ?? json['birthTime'] ?? '').toString(),
    city: (json['city'] ?? '').toString(),
    target: (json['target'] ?? json['relationship_goal'] ?? '').toString(),
    birthPlace:
        (json['birth_place'] ?? json['private_birth_place'] ?? '')
            .toString()
            .isEmpty
        ? null
        : (json['birth_place'] ?? json['private_birth_place'] ?? '').toString(),
    birthLat:
        (json['birth_lat'] as num?)?.toDouble() ??
        (json['private_birth_lat'] as num?)?.toDouble(),
    birthLng:
        (json['birth_lng'] as num?)?.toDouble() ??
        (json['private_birth_lng'] as num?)?.toDouble(),
  );
}

ProfileSummaryEntity? _summaryFromSessionJson(Map<String, dynamic>? json) {
  if (json == null || json.isEmpty) return null;
  return ProfileSummaryEntity(
    nickname: (json['nickname'] ?? json['name'] ?? '').toString(),
    birthday: (json['birthday'] ?? '').toString(),
    birthTime: (json['birth_time'] ?? json['birthTime'] ?? '').toString(),
    birthPlace:
        (json['birth_place'] ?? json['private_birth_place'] ?? '')
            .toString()
            .isEmpty
        ? null
        : (json['birth_place'] ?? json['private_birth_place'] ?? '').toString(),
    birthLat:
        (json['birth_lat'] as num?)?.toDouble() ??
        (json['private_birth_lat'] as num?)?.toDouble(),
    birthLng:
        (json['birth_lng'] as num?)?.toDouble() ??
        (json['private_birth_lng'] as num?)?.toDouble(),
    city: (json['city'] ?? '').toString(),
    target: (json['relationship_goal'] ?? json['target'] ?? '').toString(),
    verified:
        (json['verified'] as bool?) ??
        (json['realname_verified'] as bool?) ??
        false,
    moderationStatus: (json['moderation_status'] ?? 'normal').toString(),
    moderationNote: (json['moderation_note'] ?? '').toString().isEmpty
        ? null
        : (json['moderation_note'] ?? '').toString(),
    completion: 0.5,
    tags: [
      if ((json['birthday'] ?? '').toString().isNotEmpty) '生日已确认',
      if ((json['birth_time'] ?? json['birthTime'] ?? '').toString().isNotEmpty)
        '出生时间已确认',
      if ((json['gender'] ?? '').toString().isNotEmpty) '性别已确认',
      if ((json['relationship_goal'] ?? json['target'] ?? '')
          .toString()
          .isNotEmpty)
        '婚恋目标已确认',
      '本地草稿待确认',
    ],
  );
}

ProfileDetailEntity? _detailFromSessionJson(Map<String, dynamic>? json) {
  if (json == null || json.isEmpty) return null;
  return ProfileDetailEntity(
    nickname: (json['nickname'] ?? json['name'] ?? '').toString(),
    gender: (json['gender'] ?? '').toString(),
    birthday: (json['birthday'] ?? '').toString(),
    birthTime: (json['birth_time'] ?? json['birthTime'] ?? '').toString(),
    city: (json['city'] ?? '').toString(),
    target: (json['relationship_goal'] ?? json['target'] ?? '').toString(),
    birthPlace:
        (json['birth_place'] ?? json['private_birth_place'] ?? '')
            .toString()
            .isEmpty
        ? null
        : (json['birth_place'] ?? json['private_birth_place'] ?? '').toString(),
    birthLat:
        (json['birth_lat'] as num?)?.toDouble() ??
        (json['private_birth_lat'] as num?)?.toDouble(),
    birthLng:
        (json['birth_lng'] as num?)?.toDouble() ??
        (json['private_birth_lng'] as num?)?.toDouble(),
  );
}

ProfileDetailEntity? _detailFromSessionUser(Map<String, dynamic>? map) {
  if (map == null || map.isEmpty) return null;
  return ProfileDetailEntity(
    nickname: (map['nickname'] ?? map['name'] ?? '').toString(),
    gender: (map['gender'] ?? '').toString(),
    birthday: (map['birthday'] ?? '').toString(),
    birthTime: (map['birth_time'] ?? map['birthTime'] ?? '').toString(),
    city: (map['city'] ?? '').toString(),
    target: (map['relationship_goal'] ?? map['target'] ?? '').toString(),
    birthPlace:
        (map['birth_place'] ?? map['private_birth_place'] ?? '')
            .toString()
            .isEmpty
        ? null
        : (map['birth_place'] ?? map['private_birth_place'] ?? '').toString(),
    birthLat:
        (map['birth_lat'] as num?)?.toDouble() ??
        (map['private_birth_lat'] as num?)?.toDouble(),
    birthLng:
        (map['birth_lng'] as num?)?.toDouble() ??
        (map['private_birth_lng'] as num?)?.toDouble(),
  );
}

ProfileSummaryEntity? _summaryFromSessionUser(UserSummary? user) {
  if (user == null) return null;
  final nickname = (user.nickname ?? '').trim();
  return ProfileSummaryEntity(
    nickname: nickname,
    birthday: (user.birthday ?? '').trim(),
    birthTime: (user.birthTime ?? '').trim(),
    birthPlace: (user.birthPlace ?? '').trim().isEmpty ? null : user.birthPlace,
    birthLat: user.birthLat,
    birthLng: user.birthLng,
    city: (user.city ?? '').trim(),
    target: (user.relationshipGoal ?? '').trim(),
    verified: user.verified,
    moderationStatus: user.moderationStatus,
    moderationNote: user.moderationNote,
    completion: 0.5,
    tags: [
      if ((user.birthday ?? '').trim().isNotEmpty) '生日已确认',
      if ((user.birthTime ?? '').trim().isNotEmpty) '出生时间已确认',
      if ((user.gender ?? '').trim().isNotEmpty) '性别已确认',
      if ((user.relationshipGoal ?? '').trim().isNotEmpty) '婚恋目标已确认',
      '本地草稿待确认',
    ],
  );
}

bool _sameAccount(Map<String, dynamic>? json, UserSummary? user) {
  if (json == null || user == null) return false;
  final cachedId =
      (json['id'] as num?)?.toInt() ??
      int.tryParse((json['id'] ?? '').toString()) ??
      0;
  final cachedPhone = (json['phone'] ?? '').toString().trim();
  return (cachedId != 0 && cachedId == user.id) ||
      (cachedPhone.isNotEmpty && cachedPhone == user.phone.trim());
}

bool _sessionUnchanged(Ref ref, SessionState? started) {
  if (!ref.mounted) return false;
  final now = ref.read(sessionProvider).asData?.value;
  return now?.status == started?.status &&
      now?.accessToken == started?.accessToken &&
      now?.user?.id == started?.user?.id &&
      now?.user?.phone == started?.user?.phone;
}

void _requireSameSession(Ref ref, SessionState? started) {
  if (!_sessionUnchanged(ref, started)) {
    throw StateError('登录会话已变化，旧资料结果未确认。');
  }
}

final profileProvider = FutureProvider<ProfileUiState>((ref) async {
  final started = await ref.watch(sessionProvider.future);
  if (!started.isLoggedIn) {
    return const ProfileUiState(error: '请登录后读取资料。');
  }
  final sessionUser = started.user;
  final local = ref.read(localStorageProvider);
  try {
    final summary = await ref.read(getProfileUseCaseProvider).call();
    _requireSameSession(ref, started);
    await ref
        .read(sessionProvider.notifier)
        .cacheProfileSnapshot(
          CacheKeys.profileSummarySnapshot,
          _summaryToJson(summary),
          expectedSession: started,
        );
    _requireSameSession(ref, started);
    return ProfileUiState(summary: summary);
  } catch (e) {
    _requireSameSession(ref, started);
    final cached = await local.getJson(CacheKeys.profileSummarySnapshot);
    final lastKnown = await local.getJson(CacheKeys.lastKnownProfile);
    _requireSameSession(ref, started);
    final summary =
        (_sameAccount(cached, sessionUser) ? _summaryFromJson(cached) : null) ??
        (_sameAccount(lastKnown, sessionUser)
            ? _summaryFromSessionJson(lastKnown)
            : null) ??
        _summaryFromSessionUser(sessionUser);
    return ProfileUiState(summary: summary, error: e.toString());
  }
});

final personalShowcaseProvider = FutureProvider<PersonalShowcaseSnapshot>((
  ref,
) async {
  final profileState = await ref.watch(profileProvider.future);
  final summary = profileState.summary;
  if (summary == null) {
    throw Exception('资料暂不可用');
  }
  try {
    final detailState = await ref.watch(editProfileProvider.future);
    return PersonalShowcaseSnapshot.fromProfile(
      summary: summary,
      detail: detailState.detail,
    );
  } catch (_) {
    return PersonalShowcaseSnapshot.fromProfile(summary: summary);
  }
});

class EditProfileNotifier extends AsyncNotifier<EditProfileUiState> {
  @override
  Future<EditProfileUiState> build() async {
    final started = await ref.watch(sessionProvider.future);
    if (!started.isLoggedIn) {
      return const EditProfileUiState(error: '请登录后读取资料。');
    }
    final sessionUser = started.user;
    final local = ref.read(localStorageProvider);
    try {
      final detail = await ref.read(profileRepositoryProvider).getDetail();
      _requireSameSession(ref, started);
      await ref
          .read(sessionProvider.notifier)
          .cacheProfileSnapshot(
            CacheKeys.profileDetailSnapshot,
            _detailToJson(detail),
            expectedSession: started,
          );
      _requireSameSession(ref, started);
      return EditProfileUiState(detail: detail);
    } catch (e) {
      _requireSameSession(ref, started);
      final message = e.toString();
      if (message.contains('Unauthorized') ||
          message.contains('禁用') ||
          message.contains('Unauthenticated')) {
        return EditProfileUiState(error: '账号不可用或登录已失效：$message');
      }
      final cached = await local.getJson(CacheKeys.profileDetailSnapshot);
      final lastKnown = await local.getJson(CacheKeys.lastKnownProfile);
      _requireSameSession(ref, started);
      return EditProfileUiState(
        error: '资料读取未确认；以下如有历史资料，仅供参考：$message',
        detail:
            (_sameAccount(cached, sessionUser)
                ? _detailFromJson(cached)
                : null) ??
            (_sameAccount(lastKnown, sessionUser)
                ? _detailFromSessionJson(lastKnown)
                : null) ??
            (sessionUser == null
                ? null
                : _detailFromSessionUser({
                    'nickname': sessionUser.nickname,
                    'name': sessionUser.nickname,
                    'gender': sessionUser.gender,
                    'birthday': sessionUser.birthday,
                    'birth_time': sessionUser.birthTime,
                    'city': sessionUser.city,
                    'relationship_goal': sessionUser.relationshipGoal,
                    'target': sessionUser.relationshipGoal,
                    'birth_place': sessionUser.birthPlace,
                    'birth_lat': sessionUser.birthLat,
                    'birth_lng': sessionUser.birthLng,
                  })),
      );
    }
  }

  Future<ProfileDetailEntity> saveCity(String city) async {
    final started = ref.read(sessionProvider).asData?.value;
    if (started?.isLoggedIn != true) throw StateError('请登录后保存资料。');
    final current = state.asData?.value ?? const EditProfileUiState();
    try {
      final confirmed = const ProfileMapper().toDetail(
        await ref.read(profileRemoteDataSourceProvider).saveCity(city),
      );
      _requireSameSession(ref, started);
      // Publish only the fresh server response, never the submitted draft.
      state = AsyncData(EditProfileUiState(detail: confirmed));
      ref.invalidate(profileProvider);
      ref.invalidate(personalShowcaseProvider);
      return confirmed;
    } catch (e) {
      if (_sessionUnchanged(ref, started)) {
        state = AsyncData(current.copyWith(error: e.toString()));
      }
      rethrow;
    }
  }

  Future<ProfileDetailEntity> save(ProfileDetailEntity detail) async {
    final started = ref.read(sessionProvider).asData?.value;
    if (started?.isLoggedIn != true) throw StateError('请登录后保存资料。');
    final current = state.asData?.value ?? const EditProfileUiState();
    state = AsyncData(EditProfileUiState(detail: detail, saving: true));
    try {
      final saveResult = await ref
          .read(updateProfileUseCaseProvider)
          .call(detail);
      _requireSameSession(ref, started);
      final savedUser = saveResult['user'];
      final persistedDetail = savedUser is Map<String, dynamic>
          ? _detailFromJson(savedUser) ?? detail
          : await ref
                .read(profileRepositoryProvider)
                .getDetail()
                .catchError((_) => detail);
      _requireSameSession(ref, started);
      await ref
          .read(sessionProvider.notifier)
          .cacheProfileSnapshot(
            CacheKeys.profileDetailSnapshot,
            _detailToJson(persistedDetail),
            expectedSession: started,
          );
      _requireSameSession(ref, started);
      final currentSummary = ref.read(profileProvider).asData?.value.summary;
      final summary = _summaryFromDetail(persistedDetail, currentSummary);
      await ref
          .read(sessionProvider.notifier)
          .cacheProfileSnapshot(
            CacheKeys.profileSummarySnapshot,
            _summaryToJson(summary),
            expectedSession: started,
          );
      _requireSameSession(ref, started);
      final sessionState = started;
      if (sessionState?.user != null) {
        final user = sessionState!.user!;
        await ref
            .read(sessionProvider.notifier)
            .updateProfile(
              UserSummary(
                id: user.id,
                phone: user.phone,
                role: user.role,
                nickname: persistedDetail.nickname,
                birthday: persistedDetail.birthday,
                birthTime: persistedDetail.birthTime,
                gender: persistedDetail.gender,
                city: persistedDetail.city,
                relationshipGoal: persistedDetail.target,
                birthPlace: persistedDetail.birthPlace,
                birthLat: persistedDetail.birthLat,
                birthLng: persistedDetail.birthLng,
                avatarUrl: user.avatarUrl,
                verified: user.verified,
              ),
              expectedAccessToken: started?.accessToken,
            );
      }
      _requireSameSession(ref, started);
      ref.invalidate(editProfileProvider);
      ref.invalidate(profileProvider);
      ref.invalidate(personalShowcaseProvider);
      ref.invalidate(astroNatalChartProvider);
      ref.invalidate(astroSummaryProvider);
      state = AsyncData(
        EditProfileUiState(detail: persistedDetail, saving: false),
      );
      return persistedDetail;
    } catch (e) {
      if (_sessionUnchanged(ref, started)) {
        state = AsyncData(current.copyWith(error: e.toString()));
      }
      rethrow;
    }
  }
}

extension on EditProfileUiState {
  EditProfileUiState copyWith({
    ProfileDetailEntity? detail,
    bool? saving,
    String? error,
  }) {
    return EditProfileUiState(
      detail: detail ?? this.detail,
      saving: saving ?? this.saving,
      error: error ?? this.error,
    );
  }
}

final editProfileProvider =
    AsyncNotifierProvider.autoDispose<EditProfileNotifier, EditProfileUiState>(
      EditProfileNotifier.new,
    );

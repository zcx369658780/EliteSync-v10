import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/features/profile/data/datasource/profile_showcase_draft_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/profile/data/datasource/profile_showcase_publication_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/profile/data/repository/profile_showcase_draft_repository_impl.dart';
import 'package:flutter_elitesync_module/features/profile/data/repository/profile_showcase_publication_repository_impl.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_showcase_draft_entity.dart';
import 'package:flutter_elitesync_module/features/profile/domain/repository/profile_showcase_draft_repository.dart';
import 'package:flutter_elitesync_module/features/profile/domain/repository/profile_showcase_publication_repository.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/state/profile_showcase_draft_ui_state.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/state/profile_showcase_publication_ui_state.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

final profileShowcaseDraftRemoteDataSourceProvider =
    Provider<ProfileShowcaseDraftRemoteDataSource>((ref) {
      return ProfileShowcaseDraftRemoteDataSource(
        apiClient: ref.watch(apiClientProvider),
      );
    });

final profileShowcaseDraftRepositoryProvider =
    Provider<ProfileShowcaseDraftRepository>((ref) {
      return ProfileShowcaseDraftRepositoryImpl(
        remote: ref.watch(profileShowcaseDraftRemoteDataSourceProvider),
      );
    });

final profileShowcaseDraftControllerProvider =
    AsyncNotifierProvider.autoDispose<
      ProfileShowcaseDraftController,
      ProfileShowcaseDraftUiState
    >(ProfileShowcaseDraftController.new);

final profileShowcasePublicationRemoteDataSourceProvider =
    Provider<ProfileShowcasePublicationRemoteDataSource>((ref) {
      return ProfileShowcasePublicationRemoteDataSource(
        apiClient: ref.watch(apiClientProvider),
      );
    });

final profileShowcasePublicationRepositoryProvider =
    Provider<ProfileShowcasePublicationRepository>((ref) {
      return ProfileShowcasePublicationRepositoryImpl(
        remote: ref.watch(profileShowcasePublicationRemoteDataSourceProvider),
      );
    });

final profileShowcasePublicationControllerProvider =
    AsyncNotifierProvider.autoDispose<
      ProfileShowcasePublicationController,
      ProfileShowcasePublicationUiState
    >(ProfileShowcasePublicationController.new);

class ProfileShowcaseDraftController
    extends AsyncNotifier<ProfileShowcaseDraftUiState> {
  @override
  Future<ProfileShowcaseDraftUiState> build() async {
    try {
      final draft = await ref
          .read(profileShowcaseDraftRepositoryProvider)
          .getDraft();
      return ProfileShowcaseDraftUiState(
        serverDraft: draft,
        editor: draft?.toInput() ?? ProfileShowcaseDraftInput.empty,
        loaded: true,
      );
    } catch (error) {
      return ProfileShowcaseDraftUiState(
        loaded: true,
        loadError: _mapError(error),
      );
    }
  }

  Future<void> refreshDraft() async {
    state = const AsyncLoading<ProfileShowcaseDraftUiState>();
    state = await AsyncValue.guard(() async => build());
  }

  void edit(ProfileShowcaseDraftInput input) {
    final current = state.asData?.value ?? const ProfileShowcaseDraftUiState();
    state = AsyncData(
      current.copyWith(
        editor: input,
        dirty: true,
        clearSaveError: true,
        clearSubmitError: true,
        clearSubmitMessage: true,
        clearClearMessage: true,
        validationErrors: const {},
      ),
    );
  }

  Future<void> save(ProfileShowcaseDraftInput input) async {
    final validationErrors = validateProfileShowcaseDraftInput(input);
    final current = state.asData?.value ?? const ProfileShowcaseDraftUiState();
    if (validationErrors.isNotEmpty) {
      state = AsyncData(
        current.copyWith(
          editor: input,
          dirty: true,
          saveError: '有些内容暂时不能保存，请检查长度和标签数量。',
          validationErrors: validationErrors,
          clearSubmitError: true,
          clearSubmitMessage: true,
          clearClearMessage: true,
        ),
      );
      return;
    }

    state = AsyncData(
      current.copyWith(
        editor: input,
        saving: true,
        clearSaveError: true,
        clearSubmitError: true,
        clearSubmitMessage: true,
        clearClearMessage: true,
        validationErrors: const {},
      ),
    );
    try {
      final saved = await ref
          .read(profileShowcaseDraftRepositoryProvider)
          .saveDraft(input);
      state = AsyncData(
        current.copyWith(
          serverDraft: saved,
          editor: saved?.toInput() ?? input,
          dirty: false,
          saving: false,
          loaded: true,
          clearSaveError: true,
          clearSubmitError: true,
          clearSubmitMessage: true,
          clearClearMessage: true,
          validationErrors: const {},
        ),
      );
    } catch (error) {
      state = AsyncData(
        current.copyWith(
          editor: input,
          dirty: true,
          saving: false,
          saveError: _mapError(error),
          clearSubmitError: true,
          clearSubmitMessage: true,
          validationErrors: const {},
          clearClearMessage: true,
        ),
      );
    }
  }

  Future<void> submitForReview() async {
    final current = state.asData?.value ?? const ProfileShowcaseDraftUiState();
    if (current.dirty) {
      state = AsyncData(
        current.copyWith(
          submitError: '请先保存私有草稿，再提交安全审核。',
          clearSubmitMessage: true,
          clearClearMessage: true,
        ),
      );
      return;
    }
    if (!current.hasSavedPrivateDraft) {
      state = AsyncData(
        current.copyWith(
          submitError: '还没有可提交的私有草稿。',
          clearSubmitMessage: true,
          clearClearMessage: true,
        ),
      );
      return;
    }

    state = AsyncData(
      current.copyWith(
        submitting: true,
        clearSaveError: true,
        clearSubmitError: true,
        clearSubmitMessage: true,
        clearClearMessage: true,
      ),
    );
    try {
      final submitted = await ref
          .read(profileShowcaseDraftRepositoryProvider)
          .submitForReview();
      state = AsyncData(
        current.copyWith(
          serverDraft: submitted ?? current.serverDraft,
          editor:
              (submitted ?? current.serverDraft)?.toInput() ?? current.editor,
          dirty: false,
          submitting: false,
          loaded: true,
          submitMessage: '已提交审核，等待处理；仍是私有草稿，审核完成前不会发布，也不会用于推荐评分。',
          clearSaveError: true,
          clearSubmitError: true,
          clearClearMessage: true,
          validationErrors: const {},
        ),
      );
    } catch (error) {
      state = AsyncData(
        current.copyWith(
          submitting: false,
          submitError: _mapSubmitError(error),
          clearSubmitMessage: true,
          clearClearMessage: true,
        ),
      );
    }
  }

  Future<void> clearDraft() async {
    final current = state.asData?.value ?? const ProfileShowcaseDraftUiState();
    state = AsyncData(
      current.copyWith(
        clearing: true,
        clearSaveError: true,
        clearSubmitError: true,
        clearSubmitMessage: true,
        clearClearMessage: true,
      ),
    );
    try {
      await ref.read(profileShowcaseDraftRepositoryProvider).clearDraft();
      state = AsyncData(
        current.copyWith(
          clearServerDraft: true,
          editor: ProfileShowcaseDraftInput.empty,
          dirty: false,
          clearing: false,
          loaded: true,
          clearMessage: '私有草稿已清除。',
          clearSubmitError: true,
          clearSubmitMessage: true,
          validationErrors: const {},
        ),
      );
    } catch (error) {
      state = AsyncData(
        current.copyWith(
          clearing: false,
          saveError: _mapError(error),
          clearSubmitError: true,
          clearSubmitMessage: true,
          clearClearMessage: true,
        ),
      );
    }
  }
}

class ProfileShowcasePublicationController
    extends AsyncNotifier<ProfileShowcasePublicationUiState> {
  @override
  Future<ProfileShowcasePublicationUiState> build() async {
    try {
      final publication = await ref
          .read(profileShowcasePublicationRepositoryProvider)
          .getPublication();
      return ProfileShowcasePublicationUiState(
        publication: publication,
        loaded: true,
      );
    } catch (error) {
      return ProfileShowcasePublicationUiState(
        loaded: true,
        error: _mapPublicationError(error),
      );
    }
  }

  Future<void> refreshPublication() async {
    state = const AsyncLoading<ProfileShowcasePublicationUiState>();
    state = await AsyncValue.guard(() async => build());
  }

  Future<void> publishApprovedDraft() async {
    final current =
        state.asData?.value ?? const ProfileShowcasePublicationUiState();
    state = AsyncData(
      current.copyWith(publishing: true, clearError: true, clearMessage: true),
    );
    try {
      final publication = await ref
          .read(profileShowcasePublicationRepositoryProvider)
          .publishApprovedDraft();
      state = AsyncData(
        current.copyWith(
          publication: publication,
          loaded: true,
          publishing: false,
          message: '已生成新的发布版本；推荐评分仍未开启。',
          clearError: true,
        ),
      );
    } catch (error) {
      state = AsyncData(
        current.copyWith(
          publishing: false,
          error: _mapPublicationError(error),
          clearMessage: true,
        ),
      );
    }
  }
}

Map<String, String> validateProfileShowcaseDraftInput(
  ProfileShowcaseDraftInput input,
) {
  final errors = <String, String>{};
  if (input.selfIntro.trim().length > 500) {
    errors['self_intro'] = '自我介绍最多 500 字。';
  }
  if (input.openerNote.trim().length > 280) {
    errors['opener_note'] = '开场线索最多 280 字。';
  }
  _validateTags(errors, 'interest_tags', input.interestTags, '兴趣标签');
  _validateTags(errors, 'lifestyle_tags', input.lifestyleTags, '生活线索');
  return errors;
}

void _validateTags(
  Map<String, String> errors,
  String key,
  List<String> tags,
  String label,
) {
  final normalized = tags
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty);
  if (normalized.length > 10) {
    errors[key] = '$label最多 10 个。';
    return;
  }
  if (normalized.any((tag) => tag.length > 24)) {
    errors[key] = '$label每个最多 24 字。';
  }
}

String _mapError(Object error) {
  if (error is ProfileShowcaseDraftRequestException) {
    return switch (error.statusCode) {
      401 => '登录状态已失效，请重新登录后再保存私有草稿。',
      403 => '当前账号不能修改这份私有草稿。',
      422 => '有些内容暂时不能保存，请检查长度和标签数量。',
      429 => '保存太频繁了，请稍后再试。',
      int code when code >= 500 => '服务暂时不可用，请稍后再保存私有草稿。',
      _ => _networkFallback(error.message),
    };
  }
  return _networkFallback(error.toString());
}

String _mapSubmitError(Object error) {
  if (error is ProfileShowcaseDraftRequestException) {
    return switch (error.statusCode) {
      401 => '登录状态已失效，请重新登录后再提交安全审核。',
      403 => '当前账号不能提交这份私有草稿。',
      404 => '还没有可提交的私有草稿。',
      409 => '请先保存私有草稿，再提交安全审核。',
      422 => '这份私有草稿暂时不能提交，请检查内容后重试。',
      429 => '提交太频繁了，请稍后再试。',
      int code when code >= 500 => '服务暂时不可用，当前草稿还没有提交安全审核。',
      _ => _submitFallback(error.message),
    };
  }
  return _submitFallback(error.toString());
}

String _networkFallback(String raw) {
  final lower = raw.toLowerCase();
  if (lower.contains('timeout') ||
      lower.contains('connection') ||
      lower.contains('network')) {
    return '网络暂时不可用，当前内容还没有保存为私有草稿。';
  }
  return '服务暂时不可用，请稍后再保存私有草稿。';
}

String _submitFallback(String raw) {
  final lower = raw.toLowerCase();
  if (lower.contains('timeout') ||
      lower.contains('connection') ||
      lower.contains('network')) {
    return '网络暂时不可用，当前草稿还没有提交安全审核。';
  }
  return '服务暂时不可用，当前草稿还没有提交安全审核。';
}

String _mapPublicationError(Object error) {
  if (error is ProfileShowcasePublicationRequestException) {
    return switch (error.statusCode) {
      401 => '登录状态已失效，请重新登录后再确认公开展示。',
      403 => '当前账号不能公开展示这份草稿。',
      404 => '还没有可以确认发布的审核通过草稿。',
      422 => '这份草稿暂时不能公开展示，请确认已通过审核并主动确认。',
      429 => '操作太频繁了，请稍后再试。',
      int code when code >= 500 => '服务暂时不可用，当前草稿尚未发布。',
      _ => _publicationFallback(error.message),
    };
  }
  return _publicationFallback(error.toString());
}

String _publicationFallback(String raw) {
  final lower = raw.toLowerCase();
  if (lower.contains('timeout') ||
      lower.contains('connection') ||
      lower.contains('network')) {
    return '网络暂时不可用，当前草稿尚未发布。';
  }
  return '服务暂时不可用，当前草稿尚未发布。';
}

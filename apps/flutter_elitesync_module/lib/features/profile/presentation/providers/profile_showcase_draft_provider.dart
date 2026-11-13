import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
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
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

bool Function() _sessionGuard(Ref ref) {
  final session = ref.watch(sessionProvider).asData?.value;
  return () =>
      ref.mounted &&
      identical(session, ref.read(sessionProvider).asData?.value);
}

final profileShowcaseDraftRemoteDataSourceProvider =
    Provider<ProfileShowcaseDraftRemoteDataSource>((ref) {
      final current = _sessionGuard(ref);
      return ProfileShowcaseDraftRemoteDataSource(
        apiClient: ref.watch(apiClientProvider),
        isCurrent: current,
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
      final current = _sessionGuard(ref);
      return ProfileShowcasePublicationRemoteDataSource(
        apiClient: ref.watch(apiClientProvider),
        isCurrent: current,
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
final showcasePhotoPickerProvider = Provider<Future<XFile?> Function()>(
  (ref) =>
      () => ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 88,
      ),
);

class ProfileShowcaseDraftController
    extends AsyncNotifier<ProfileShowcaseDraftUiState> {
  SessionState? _session;
  int _operation = 0;
  XFile? _pendingPhoto;
  String? _pendingUploadId;
  int? _pendingUploadRevision;

  bool get hasPendingUpload => _pendingPhoto != null;
  bool _current(int operation) =>
      ref.mounted &&
      operation == _operation &&
      identical(_session, ref.read(sessionProvider).asData?.value);

  @override
  Future<ProfileShowcaseDraftUiState> build() async {
    final session = ref.watch(sessionProvider).asData?.value;
    if (!identical(_session, session)) {
      _pendingPhoto = null;
      _pendingUploadId = null;
      _pendingUploadRevision = null;
    }
    _session = session;
    _operation++;
    ref.onDispose(() => _operation++);
    final repository = ref.watch(profileShowcaseDraftRepositoryProvider);
    if (session?.isLoggedIn != true) {
      return const ProfileShowcaseDraftUiState(
        loaded: true,
        loadError: '请登录后编辑展示资料。',
      );
    }
    try {
      final draft = await repository.getDraft();
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
    final current = state.asData?.value ?? const ProfileShowcaseDraftUiState();
    if (current.isBusy || _session?.isLoggedIn != true) return;
    final operation = ++_operation;
    state = AsyncData(current.copyWith(saving: true, clearLoadError: true));
    try {
      final draft = await ref
          .read(profileShowcaseDraftRepositoryProvider)
          .getDraft();
      if (!_current(operation)) return;
      state = AsyncData(
        ProfileShowcaseDraftUiState(
          serverDraft: draft,
          editor: current.dirty
              ? current.editor
              : draft?.toInput() ?? ProfileShowcaseDraftInput.empty,
          dirty: current.dirty,
          loaded: true,
        ),
      );
    } catch (error) {
      if (!_current(operation)) return;
      state = AsyncData(
        current.copyWith(saving: false, loadError: _mapError(error)),
      );
    }
  }

  void edit(ProfileShowcaseDraftInput input) {
    final current = state.asData?.value ?? const ProfileShowcaseDraftUiState();
    if (current.isBusy || _session?.isLoggedIn != true) return;
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
    final current = state.asData?.value ?? const ProfileShowcaseDraftUiState();
    if (current.isBusy || _session?.isLoggedIn != true) return;
    final validation = validateProfileShowcaseDraftInput(input);
    if (validation.isNotEmpty) {
      state = AsyncData(
        current.copyWith(
          editor: input,
          dirty: true,
          saveError: '有些内容暂时不能保存，请检查字段长度、照片和展示范围。',
          validationErrors: validation,
        ),
      );
      return;
    }
    final operation = ++_operation;
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
          .saveDraft(
            input,
            expectedRevision: current.serverDraft?.revision ?? 0,
          );
      if (!_current(operation)) return;
      if (saved == null) throw StateError('保存响应缺少草稿，结果未确认');
      state = AsyncData(
        ProfileShowcaseDraftUiState(
          serverDraft: saved,
          editor: saved.toInput(),
          loaded: true,
        ),
      );
    } catch (error) {
      if (!_current(operation)) return;
      state = AsyncData(
        current.copyWith(
          editor: input,
          dirty: true,
          saving: false,
          saveError: _mapError(error),
          clearSubmitMessage: true,
        ),
      );
    }
  }

  Future<void> submitForReview() async {
    final current = state.asData?.value ?? const ProfileShowcaseDraftUiState();
    if (current.isBusy || _session?.isLoggedIn != true) return;
    if (current.dirty || !current.hasSavedPrivateDraft) {
      state = AsyncData(
        current.copyWith(
          submitError: '请先保存私有草稿，再提交安全审核。',
          clearSubmitMessage: true,
        ),
      );
      return;
    }
    if (!current.canSubmitForReview) {
      state = AsyncData(
        current.copyWith(
          submitError: '此版本已有审核状态，或展示范围尚未选择。请先核对并保存需要的新修改。',
          clearSubmitMessage: true,
        ),
      );
      return;
    }
    final operation = ++_operation;
    state = AsyncData(
      current.copyWith(
        submitting: true,
        clearSubmitError: true,
        clearSubmitMessage: true,
      ),
    );
    try {
      final submitted = await ref
          .read(profileShowcaseDraftRepositoryProvider)
          .submitForReview(
            expectedRevision: current.serverDraft?.revision ?? 0,
          );
      if (!_current(operation)) return;
      if (submitted == null) throw StateError('提交响应缺少草稿，结果未确认');
      final submission = submitted.submission;
      if (submitted.revision > 0 &&
          (submission == null || submission.revision != submitted.revision)) {
        throw StateError('提交内容版本未确认');
      }
      final reviewState = submission?.state ?? submitted.moderationStatus;
      final message = switch (reviewState) {
        'pending' => '已提交审核，等待处理；仍是私有草稿，审核完成前不会发布，也不会用于推荐评分。',
        'approved' => '该版本已通过审核，可以单独确认发布。',
        'needs_revision' || 'rejected' => '该版本已有处理结果，请修改并保存新版本后再提交。',
        _ => '提交处理状态尚未确认，请刷新核对。',
      };
      state = AsyncData(
        current.copyWith(
          serverDraft: submitted,
          editor: submitted.toInput(),
          submitting: false,
          dirty: false,
          loaded: true,
          clearSubmitError: true,
          submitMessage: message,
        ),
      );
    } catch (error) {
      if (!_current(operation)) return;
      state = AsyncData(
        current.copyWith(
          submitting: false,
          submitError: _mapSubmitError(error),
          clearSubmitMessage: true,
        ),
      );
    }
  }

  Future<void> clearDraft({int? expectedRevision}) async {
    final current = state.asData?.value ?? const ProfileShowcaseDraftUiState();
    if (current.isBusy || _session?.isLoggedIn != true) return;
    if (expectedRevision != null &&
        (current.serverDraft?.revision ?? 0) != expectedRevision) {
      return;
    }
    final operation = ++_operation;
    state = AsyncData(
      current.copyWith(
        clearing: true,
        clearSaveError: true,
        clearClearMessage: true,
      ),
    );
    final repository = ref.read(profileShowcaseDraftRepositoryProvider);
    try {
      await repository.clearDraft(
        expectedRevision: current.serverDraft?.revision ?? 0,
      );
      if (!_current(operation)) return;
      final draft = await repository.getDraft();
      if (!_current(operation)) return;
      if (draft?.hasContent == true) throw StateError('清除后的读回尚未确认');
      state = AsyncData(
        ProfileShowcaseDraftUiState(
          serverDraft: draft,
          loaded: true,
          clearMessage: '私有草稿已清除。',
        ),
      );
      _discardUpload();
    } catch (error) {
      if (!_current(operation)) return;
      state = AsyncData(
        current.copyWith(clearing: false, saveError: '清除结果未确认，请刷新核对。'),
      );
    }
  }

  void _discardUpload() {
    _pendingPhoto = null;
    _pendingUploadId = null;
    _pendingUploadRevision = null;
  }

  void discardPendingUpload() {
    final current = state.asData?.value;
    if (current == null || current.isBusy) return;
    _discardUpload();
    state = AsyncData(current.copyWith(clearSaveError: true));
  }

  Future<void> uploadPhoto() async {
    final current = state.asData?.value ?? const ProfileShowcaseDraftUiState();
    if (current.isBusy || _session?.isLoggedIn != true) return;
    if (current.dirty) {
      state = AsyncData(current.copyWith(saveError: '请先保存当前修改，再添加照片。'));
      return;
    }
    if (current.editor.photoIds.length >= 6 && _pendingPhoto == null) return;
    final operation = ++_operation;
    state = AsyncData(current.copyWith(saving: true, clearSaveError: true));
    try {
      final photo =
          _pendingPhoto ?? await ref.read(showcasePhotoPickerProvider)();
      if (!_current(operation)) return;
      if (photo == null) {
        state = AsyncData(current);
        return;
      }
      final size = await photo.length();
      if (!_current(operation)) return;
      if (size > 5 * 1024 * 1024) throw StateError('请选择不超过 5 MiB 的照片。');
      _pendingPhoto = photo;
      _pendingUploadId ??= const Uuid().v4();
      _pendingUploadRevision ??= current.serverDraft?.revision ?? 0;
      final saved = await ref
          .read(profileShowcaseDraftRepositoryProvider)
          .uploadPhoto(
            path: photo.path,
            name: photo.name,
            expectedRevision: _pendingUploadRevision!,
            clientUploadId: _pendingUploadId!,
          );
      if (!_current(operation)) return;
      if (saved == null) throw StateError('照片上传响应未确认');
      _discardUpload();
      state = AsyncData(
        ProfileShowcaseDraftUiState(
          serverDraft: saved,
          editor: saved.toInput(),
          loaded: true,
        ),
      );
    } catch (error) {
      if (!_current(operation)) return;
      state = AsyncData(
        current.copyWith(
          saving: false,
          saveError: '照片上传结果未确认，选择已保留。请重试添加照片或刷新核对。',
        ),
      );
    }
  }
}

class ProfileShowcasePublicationController
    extends AsyncNotifier<ProfileShowcasePublicationUiState> {
  SessionState? _session;
  int _operation = 0;
  bool _current(int operation) =>
      ref.mounted &&
      operation == _operation &&
      identical(_session, ref.read(sessionProvider).asData?.value);

  @override
  Future<ProfileShowcasePublicationUiState> build() async {
    _session = ref.watch(sessionProvider).asData?.value;
    _operation++;
    ref.onDispose(() => _operation++);
    final repository = ref.watch(profileShowcasePublicationRepositoryProvider);
    if (_session?.isLoggedIn != true) {
      return const ProfileShowcasePublicationUiState(loaded: true);
    }
    try {
      return ProfileShowcasePublicationUiState(
        publication: await repository.getPublication(),
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
    final current =
        state.asData?.value ?? const ProfileShowcasePublicationUiState();
    if (current.publishing || _session?.isLoggedIn != true) return;
    final operation = ++_operation;
    state = AsyncData(current.copyWith(publishing: true, clearError: true));
    try {
      final publication = await ref
          .read(profileShowcasePublicationRepositoryProvider)
          .getPublication();
      if (!_current(operation)) return;
      state = AsyncData(
        ProfileShowcasePublicationUiState(
          publication: publication,
          loaded: true,
        ),
      );
    } catch (error) {
      if (!_current(operation)) return;
      state = AsyncData(
        current.copyWith(publishing: false, error: _mapPublicationError(error)),
      );
    }
  }

  Future<void> publishApprovedDraft({
    int? expectedDraftRevision,
    int? expectedPublicationRevision,
  }) async {
    final current =
        state.asData?.value ?? const ProfileShowcasePublicationUiState();
    final draft = ref
        .read(profileShowcaseDraftControllerProvider)
        .asData
        ?.value;
    if (current.publishing || _session?.isLoggedIn != true || draft == null) {
      return;
    }
    final revision = draft.serverDraft?.revision ?? 0;
    if ((expectedDraftRevision != null && expectedDraftRevision != revision) ||
        (expectedPublicationRevision != null &&
            expectedPublicationRevision != current.publication.revision)) {
      state = AsyncData(
        current.copyWith(error: '内容或发布版本已变化，请重新确认。', clearMessage: true),
      );
      return;
    }
    if (!current.canPublish(draft)) return;
    final operation = ++_operation;
    state = AsyncData(
      current.copyWith(publishing: true, clearError: true, clearMessage: true),
    );
    try {
      final publication = await ref
          .read(profileShowcasePublicationRepositoryProvider)
          .publishApprovedDraft(
            expectedRevision: revision,
            publicationRevision: current.publication.revision,
          );
      if (!_current(operation)) return;
      if (!publication.isPublished ||
          (publication.sourceRevision != revision && revision > 0)) {
        throw StateError('发布版本未确认');
      }
      state = AsyncData(
        ProfileShowcasePublicationUiState(
          publication: publication,
          loaded: true,
          message: '已发布确认版本；仅对当前符合所选范围的对象展示。',
        ),
      );
    } catch (error) {
      if (!_current(operation)) return;
      state = AsyncData(
        current.copyWith(
          publishing: false,
          error: _mapPublicationError(error),
          clearMessage: true,
        ),
      );
    }
  }

  Future<void> withdraw({int? expectedPublicationRevision}) async {
    final current =
        state.asData?.value ?? const ProfileShowcasePublicationUiState();
    if (current.publishing ||
        !current.isPublished ||
        _session?.isLoggedIn != true) {
      return;
    }
    if (expectedPublicationRevision != null &&
        current.publication.revision != expectedPublicationRevision) {
      return;
    }
    final operation = ++_operation;
    state = AsyncData(
      current.copyWith(publishing: true, clearError: true, clearMessage: true),
    );
    try {
      final publication = await ref
          .read(profileShowcasePublicationRepositoryProvider)
          .withdraw(expectedRevision: current.publication.revision);
      if (!_current(operation)) return;
      if (publication.publicationStatus != 'withdrawn') {
        throw StateError('撤回状态未确认');
      }
      state = AsyncData(
        ProfileShowcasePublicationUiState(
          publication: publication,
          loaded: true,
          message: '展示已撤回。',
        ),
      );
    } catch (error) {
      if (!_current(operation)) return;
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
  for (final entry in {
    'display_name': input.displayName,
    'city': input.city,
    'relationship_goal': input.relationshipGoal,
  }.entries) {
    if (entry.value.trim().length > 80) errors[entry.key] = '最多 80 字。';
  }
  if (input.photoIds.length > 6 ||
      input.photoIds.toSet().length != input.photoIds.length) {
    errors['photo_ids'] = '最多选择 6 张不同的照片。';
  }
  if (input.audiences.any(
    (value) => !const ['friends', 'contacts', 'relationship'].contains(value),
  )) {
    errors['audiences'] = '请选择页面提供的展示范围。';
  }
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
      409 => '资料版本已变化。当前输入已保留，请刷新核对后再保存。',
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
    return '保存结果未确认，输入已保留。请重试保存或刷新核对。';
  }
  return '保存结果未确认，输入已保留。请重试保存或刷新核对。';
}

String _submitFallback(String raw) {
  final lower = raw.toLowerCase();
  if (lower.contains('timeout') ||
      lower.contains('connection') ||
      lower.contains('network')) {
    return '提交结果未确认，请刷新审核状态或重试当前版本。';
  }
  return '提交结果未确认，请刷新审核状态或重试当前版本。';
}

String _mapPublicationError(Object error) {
  if (error is ProfileShowcasePublicationRequestException) {
    return switch (error.statusCode) {
      401 => '登录状态已失效，请重新登录后再确认公开展示。',
      403 => '当前账号不能公开展示这份草稿。',
      404 => '还没有可以确认发布的审核通过草稿。',
      409 => '内容或发布版本已变化，请刷新后重新确认。',
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
    return '发布操作结果未确认，请刷新发布状态核对。';
  }
  return '发布操作结果未确认，请刷新发布状态核对。';
}

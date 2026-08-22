import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_showcase_publication_entity.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/state/profile_showcase_draft_ui_state.dart';

class ProfileShowcasePublicationUiState {
  const ProfileShowcasePublicationUiState({
    this.publication = ProfileShowcasePublicationEntity.notPublished,
    this.loaded = false,
    this.publishing = false,
    this.error,
    this.message,
  });

  final ProfileShowcasePublicationEntity publication;
  final bool loaded;
  final bool publishing;
  final String? error;
  final String? message;

  bool get isPublished => publication.isPublished;

  String get statusLabel {
    if (publishing) return '正在确认发布';
    if (publication.isPublished) return '已发布版本';
    return switch (publication.publicationStatus) {
      'unavailable' => '暂不可确认发布',
      _ => '尚未发布',
    };
  }

  String guidanceText(ProfileShowcaseDraftUiState? draftState) {
    if (publication.isPublished) {
      if (draftState?.dirty == true) {
        return '有未公开的新修改；当前已发布版本保持不变。';
      }
      if (_hasSupportedDraftDivergence(draftState)) {
        return '有未公开的新草稿；当前已发布版本保持不变。';
      }
      return '已发布版本与私有草稿分别管理；这里不代表对其他用户的可见范围。';
    }
    if (error != null) {
      return '发布状态暂不可用；私有草稿仍可继续编辑。';
    }
    if (draftState == null || !draftState.hasSavedPrivateDraft) {
      return '先保存为私有草稿；保存不会自动提交审核或发布。';
    }
    if (draftState.dirty) {
      return '请先保存这次私有修改，再决定是否提交审核或确认发布。';
    }
    return switch (draftState.reviewStatus) {
      'approved' =>
        draftState.isPublicDisplayEligible
            ? '审核通过，可确认发布；发布仍需要你单独确认，也不会改变匹配结果。'
            : '审核已通过，但当前状态尚未提供发布确认；请稍后刷新状态。',
      'pending' => '审核中不会发布；等待结果后再决定。',
      'rejected' || 'needs_revision' => '请先修改并重新通过审核，再决定是否确认发布。',
      'manual_review_required' => '人工复核完成前不要确认发布或重复操作。',
      'error' => '审核状态暂不可用；确认前不要发布。',
      _ => '提交并通过安全审核后，才可以单独确认发布。',
    };
  }

  bool canPublish(ProfileShowcaseDraftUiState? draftState) {
    if (publishing ||
        publication.isPublished ||
        publication.isUnavailable ||
        error != null ||
        draftState == null) {
      return false;
    }
    if (draftState.isBusy ||
        draftState.dirty ||
        !draftState.hasSavedPrivateDraft) {
      return false;
    }
    return draftState.reviewStatus == 'approved' &&
        draftState.isPublicDisplayEligible;
  }

  String get publishCtaLabel {
    if (publishing) return '正在确认发布';
    if (publication.isPublished) return '已发布版本';
    return '手动打开这份可展示草稿';
  }

  bool _hasSupportedDraftDivergence(ProfileShowcaseDraftUiState? draftState) {
    final draft = draftState?.serverDraft;
    if (draft == null || !draft.hasContent) return false;
    if (publication.sourceDraftId != null &&
        draft.id != null &&
        publication.sourceDraftId != draft.id) {
      return true;
    }
    final published = publication.publicFields;
    return (draft.selfIntro ?? '').trim() != published.selfIntro.trim() ||
        !_sameStrings(draft.interestTags, published.interestTags) ||
        !_sameStrings(draft.lifestyleTags, published.lifestyleTags) ||
        (draft.openerNote ?? '').trim() != published.openerNote.trim();
  }

  ProfileShowcasePublicationUiState copyWith({
    ProfileShowcasePublicationEntity? publication,
    bool? loaded,
    bool? publishing,
    String? error,
    bool clearError = false,
    String? message,
    bool clearMessage = false,
  }) {
    return ProfileShowcasePublicationUiState(
      publication: publication ?? this.publication,
      loaded: loaded ?? this.loaded,
      publishing: publishing ?? this.publishing,
      error: clearError ? null : error ?? this.error,
      message: clearMessage ? null : message ?? this.message,
    );
  }
}

bool _sameStrings(List<String> left, List<String> right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index += 1) {
    if (left[index] != right[index]) return false;
  }
  return true;
}

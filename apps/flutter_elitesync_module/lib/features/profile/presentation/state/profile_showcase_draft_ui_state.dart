import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_showcase_draft_entity.dart';

class ProfileShowcaseDraftUiState {
  const ProfileShowcaseDraftUiState({
    this.serverDraft,
    this.editor = ProfileShowcaseDraftInput.empty,
    this.dirty = false,
    this.saving = false,
    this.submitting = false,
    this.clearing = false,
    this.loaded = false,
    this.loadError,
    this.saveError,
    this.submitError,
    this.submitMessage,
    this.clearMessage,
    this.validationErrors = const {},
  });

  final ProfileShowcaseDraftEntity? serverDraft;
  final ProfileShowcaseDraftInput editor;
  final bool dirty;
  final bool saving;
  final bool submitting;
  final bool clearing;
  final bool loaded;
  final String? loadError;
  final String? saveError;
  final String? submitError;
  final String? submitMessage;
  final String? clearMessage;
  final Map<String, String> validationErrors;

  bool get hasSavedPrivateDraft => serverDraft?.hasContent ?? false;

  bool get isPublicDisplayEligible =>
      serverDraft?.publicDisplayEligible == true;

  String get reviewStatus => serverDraft?.moderationStatus ?? 'not_submitted';

  bool get isPendingReview => reviewStatus == 'pending';

  bool get hasReviewResult => const {
    'approved',
    'rejected',
    'needs_revision',
    'manual_review_required',
    'error',
  }.contains(reviewStatus);

  bool get isBusy => saving || submitting || clearing;

  bool get canSubmitForReview {
    if (isBusy || dirty || !hasSavedPrivateDraft) return false;
    return switch (reviewStatus) {
      'pending' || 'approved' || 'manual_review_required' || 'error' => false,
      _ => true,
    };
  }

  String get submitCtaLabel {
    if (submitting) return '正在提交';
    if ((loadError ?? '').isNotEmpty || (saveError ?? '').isNotEmpty) {
      return '状态恢复后再提交审核';
    }
    if (!hasSavedPrivateDraft) return '保存后再提交审核';
    return switch (reviewStatus) {
      'rejected' || 'needs_revision' => '重新提交审核',
      'pending' => '审核中，等待处理',
      'approved' => isPublicDisplayEligible ? '审核通过，可确认发布' : '审核通过，仍是私有草稿',
      'manual_review_required' => '人工复核中',
      'error' => '状态待确认',
      _ => '提交安全审核',
    };
  }

  String get ctaGuidanceText {
    if ((loadError ?? '').isNotEmpty) {
      return '暂时无法读取私有草稿；请先重新读取或稍后再试，确认保存成功前不要提交安全审核。';
    }
    if ((saveError ?? '').isNotEmpty) {
      return '私有草稿保存失败时不会提交安全审核；请稍后重试保存，保存成功后再继续。';
    }
    if (dirty) return dirtyInteractionGuidanceText;
    if (!hasSavedPrivateDraft) {
      return '先保存为私有草稿；保存成功前不能提交安全审核，也不会公开展示或改变匹配结果。';
    }
    return switch (reviewStatus) {
      'pending' => '这份草稿正在等待审核，可以刷新状态；审核中不会发布，也不会改变匹配结果。',
      'approved' =>
        isPublicDisplayEligible
            ? '审核已通过，可以进入单独的发布确认；确认前仍是私有草稿。'
            : '审核已通过，但当前状态尚未提供发布确认；仍是私有草稿。',
      'rejected' => '可以修改后重新提交审核；这不是公开资料评价，也不会改变匹配结果。',
      'needs_revision' => '请按自己的节奏补充或调整，再重新提交审核；当前仍是私有草稿。',
      'manual_review_required' => '这份草稿需要更多时间确认，可以稍后刷新；不要重复提交或假设结果。',
      'error' => '暂时无法确认审核状态，请先重新读取；确认前不要重复提交审核。',
      _ => '保存后的私有草稿可以提交安全审核；提交不会自动发布，也不会改变匹配结果。',
    };
  }

  String get dirtyInteractionGuidanceText {
    return switch (reviewStatus) {
      'pending' => '这次修改还只是私有编辑；请先保存，审核状态仍以重新读取结果为准。',
      'approved' =>
        isPublicDisplayEligible
            ? '这次修改会先保存为私有草稿；上一版审核通过不代表新内容已经发布。'
            : '这次修改会先保存为私有草稿；上一版审核通过不代表新内容可以发布。',
      'rejected' => '先保存修改，再重新提交审核；这份草稿仍不会公开展示，也不会改变匹配结果。',
      'needs_revision' => '先保存补充内容，再重新提交审核；当前修改仍是私有草稿。',
      'manual_review_required' => '这次修改只会作为私有编辑保存；不会改变人工复核状态或承诺处理结果。',
      'error' => '先保存修改或重新读取状态；状态确认前不要重复提交审核。',
      _ => '请先保存这次修改，再决定是否提交安全审核。',
    };
  }

  String get clearDraftConfirmationText {
    return switch (reviewStatus) {
      'pending' => '只清除这份私有草稿。清除后这里不再显示它的审核状态；这不会改变审核处理状态，也不会改变正式资料、推荐或聊天。',
      'approved' =>
        isPublicDisplayEligible
            ? '只清除这份审核通过但仍私有的草稿。清除不会移除已有发布版本，也不会改变匹配结果。'
            : '只清除这份审核通过但仍私有的草稿。清除不会打开或发布任何内容，也不会改变匹配结果。',
      'rejected' ||
      'needs_revision' => '只清除这份私有草稿和当前可见的审核结果。之后可以重新整理草稿；不会公开展示，也不会改变匹配结果。',
      'manual_review_required' => '只清除这份私有草稿。清除不会改变人工复核状态，也不会改变正式资料。',
      'error' => '当前审核状态暂不可用；清除只影响这份私有草稿，不代表审核状态已处理。',
      _ => '清除后，这份私有草稿将不再保留。你的正式资料、星盘、推荐和聊天不会因此改变。',
    };
  }

  String get statusLabel {
    if (saving) return '正在保存私有草稿';
    if (submitting) return '正在提交安全审核';
    if (clearing) return '正在清除私有草稿';
    if (dirty) return '当前修改还没有保存为私有草稿';
    if (isPendingReview) return '已提交审核，等待处理';
    if (hasSavedPrivateDraft) {
      return switch (reviewStatus) {
        'approved' => isPublicDisplayEligible ? '审核通过，可确认发布' : '审核通过，仍是私有草稿',
        'rejected' => '审核未通过，可修改后再提交',
        'needs_revision' => '需要修改后再提交审核',
        'manual_review_required' => '需要人工复核，仍是私有草稿',
        'error' => '审核状态暂不可用',
        _ => '私有草稿已保存',
      };
    }
    if (hasSavedPrivateDraft) return '私有草稿已保存';
    return '还没有保存过私有草稿';
  }

  String get boundaryText {
    if (isPendingReview) {
      return '这份草稿已提交安全审核，等待处理；审核完成前不会发布，也不会改变匹配结果。';
    }
    if (!hasSavedPrivateDraft) {
      return '这份草稿不会公开展示，尚未提交安全审核，也不会改变匹配结果。';
    }
    return switch (reviewStatus) {
      'approved' =>
        isPublicDisplayEligible
            ? '这份草稿审核已通过，可以单独确认发布；确认前仍是私有草稿，也不会改变匹配结果。'
            : '这份草稿审核已通过，但当前状态尚未提供发布确认；仍是私有草稿，也不会改变匹配结果。',
      'rejected' => '这份草稿未通过审核，可以修改后重新提交；它不会公开展示，也不会改变匹配结果。',
      'needs_revision' => '这份草稿需要补充或调整后再提交审核；当前仍不会公开展示，也不会改变匹配结果。',
      'manual_review_required' => '这份草稿需要人工复核；处理完成前仍不会公开展示，也不会改变匹配结果。',
      'error' => '审核状态暂不可用；请稍后重新读取，当前草稿仍不会公开展示，也不会改变匹配结果。',
      _ => '这份草稿不会公开展示，尚未提交安全审核，也不会改变匹配结果。',
    };
  }

  String get compactReviewLabel {
    if (!hasSavedPrivateDraft) return '本地草稿';
    return switch (reviewStatus) {
      'pending' => '审核中',
      'approved' => isPublicDisplayEligible ? '可确认发布' : '审核通过',
      'rejected' => '需修改',
      'needs_revision' => '需完善',
      'manual_review_required' => '人工复核',
      'error' => '状态待确认',
      _ => '私有草稿已保存',
    };
  }

  ProfileShowcaseDraftUiState copyWith({
    ProfileShowcaseDraftEntity? serverDraft,
    bool clearServerDraft = false,
    ProfileShowcaseDraftInput? editor,
    bool? dirty,
    bool? saving,
    bool? submitting,
    bool? clearing,
    bool? loaded,
    String? loadError,
    bool clearLoadError = false,
    String? saveError,
    bool clearSaveError = false,
    String? submitError,
    bool clearSubmitError = false,
    String? submitMessage,
    bool clearSubmitMessage = false,
    String? clearMessage,
    bool clearClearMessage = false,
    Map<String, String>? validationErrors,
  }) {
    return ProfileShowcaseDraftUiState(
      serverDraft: clearServerDraft ? null : serverDraft ?? this.serverDraft,
      editor: editor ?? this.editor,
      dirty: dirty ?? this.dirty,
      saving: saving ?? this.saving,
      submitting: submitting ?? this.submitting,
      clearing: clearing ?? this.clearing,
      loaded: loaded ?? this.loaded,
      loadError: clearLoadError ? null : loadError ?? this.loadError,
      saveError: clearSaveError ? null : saveError ?? this.saveError,
      submitError: clearSubmitError ? null : submitError ?? this.submitError,
      submitMessage: clearSubmitMessage
          ? null
          : submitMessage ?? this.submitMessage,
      clearMessage: clearClearMessage
          ? null
          : clearMessage ?? this.clearMessage,
      validationErrors: validationErrors ?? this.validationErrors,
    );
  }
}

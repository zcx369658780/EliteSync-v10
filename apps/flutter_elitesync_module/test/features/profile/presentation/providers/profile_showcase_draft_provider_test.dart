import 'package:flutter_elitesync_module/features/profile/data/datasource/profile_showcase_draft_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/profile/data/datasource/profile_showcase_publication_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_showcase_draft_entity.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_showcase_publication_entity.dart';
import 'package:flutter_elitesync_module/features/profile/domain/repository/profile_showcase_draft_repository.dart';
import 'package:flutter_elitesync_module/features/profile/domain/repository/profile_showcase_publication_repository.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/profile_showcase_draft_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/state/profile_showcase_draft_ui_state.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/state/profile_showcase_publication_ui_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeDraftRepository implements ProfileShowcaseDraftRepository {
  _FakeDraftRepository({
    this.draft,
    this.throwOnSave = false,
    this.throwOnSubmit = false,
  });

  ProfileShowcaseDraftEntity? draft;
  bool throwOnSave;
  bool throwOnSubmit;
  ProfileShowcaseDraftInput? savedInput;
  bool clearCalled = false;
  bool submitCalled = false;

  @override
  Future<ProfileShowcaseDraftEntity?> getDraft() async => draft;

  @override
  Future<ProfileShowcaseDraftEntity?> saveDraft(
    ProfileShowcaseDraftInput input,
  ) async {
    savedInput = input;
    if (throwOnSave) {
      throw const ProfileShowcaseDraftRequestException(
        message: 'Connection timeout',
      );
    }
    draft = ProfileShowcaseDraftEntity(
      id: 3,
      selfIntro: input.selfIntro,
      interestTags: input.interestTags,
      lifestyleTags: input.lifestyleTags,
      openerNote: input.openerNote,
      updatedAt: DateTime.utc(2026, 6, 15, 10),
    );
    return draft;
  }

  @override
  Future<ProfileShowcaseDraftEntity?> submitForReview() async {
    submitCalled = true;
    if (throwOnSubmit) {
      throw const ProfileShowcaseDraftRequestException(
        message: 'Connection timeout',
      );
    }
    final current =
        draft ?? const ProfileShowcaseDraftEntity(selfIntro: '私有草稿');
    draft = ProfileShowcaseDraftEntity(
      id: current.id,
      selfIntro: current.selfIntro,
      interestTags: current.interestTags,
      lifestyleTags: current.lifestyleTags,
      openerNote: current.openerNote,
      moderationStatus: 'pending',
      publicDisplayEligible: false,
      matchingScoringEligible: false,
      updatedAt: DateTime.utc(2026, 6, 15, 11),
    );
    return draft;
  }

  @override
  Future<void> clearDraft() async {
    clearCalled = true;
    draft = null;
  }
}

class _FakePublicationRepository
    implements ProfileShowcasePublicationRepository {
  _FakePublicationRepository({this.throwOnPublish = false});

  ProfileShowcasePublicationEntity publication =
      ProfileShowcasePublicationEntity.notPublished;
  bool throwOnPublish;
  bool publishCalled = false;

  @override
  Future<ProfileShowcasePublicationEntity> getPublication() async {
    return publication;
  }

  @override
  Future<ProfileShowcasePublicationEntity> publishApprovedDraft() async {
    publishCalled = true;
    if (throwOnPublish) {
      throw const ProfileShowcasePublicationRequestException(
        message: 'Connection timeout',
      );
    }
    publication = const ProfileShowcasePublicationEntity(
      id: 11,
      sourceDraftId: 5,
      publicationStatus: 'published',
      moderationStatus: 'approved',
      publicDisplayEligible: true,
      matchingScoringEligible: false,
    );
    return publication;
  }
}

void main() {
  test(
    'controller loads saved private draft and keeps metadata boundary',
    () async {
      final repo = _FakeDraftRepository(
        draft: ProfileShowcaseDraftEntity(
          id: 2,
          selfIntro: '已保存的私有草稿',
          interestTags: const ['咖啡'],
          moderationStatus: 'not_submitted',
          publicDisplayEligible: false,
          matchingScoringEligible: false,
        ),
      );
      final container = ProviderContainer(
        overrides: [
          profileShowcaseDraftRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final state = await container.read(
        profileShowcaseDraftControllerProvider.future,
      );

      expect(state.hasSavedPrivateDraft, isTrue);
      expect(state.statusLabel, '私有草稿已保存');
      expect(state.boundaryText, contains('不会公开展示'));
      expect(state.boundaryText, contains('尚未提交安全审核'));
      expect(state.boundaryText, contains('不会改变匹配结果'));
    },
  );

  test(
    'controller save success and clear use safe private draft states',
    () async {
      final repo = _FakeDraftRepository();
      final container = ProviderContainer(
        overrides: [
          profileShowcaseDraftRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);
      await container.read(profileShowcaseDraftControllerProvider.future);

      await container
          .read(profileShowcaseDraftControllerProvider.notifier)
          .save(
            const ProfileShowcaseDraftInput(
              selfIntro: '保存为私有草稿',
              interestTags: ['慢热'],
            ),
          );

      var state = container.read(profileShowcaseDraftControllerProvider).value!;
      expect(repo.savedInput?.selfIntro, '保存为私有草稿');
      expect(state.hasSavedPrivateDraft, isTrue);
      expect(state.dirty, isFalse);
      expect(state.saveError, isNull);

      await container
          .read(profileShowcaseDraftControllerProvider.notifier)
          .clearDraft();

      state = container.read(profileShowcaseDraftControllerProvider).value!;
      expect(repo.clearCalled, isTrue);
      expect(state.hasSavedPrivateDraft, isFalse);
      expect(state.clearMessage, '私有草稿已清除。');
    },
  );

  test('controller save failure preserves dirty unsaved state', () async {
    final repo = _FakeDraftRepository(throwOnSave: true);
    final container = ProviderContainer(
      overrides: [
        profileShowcaseDraftRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    await container.read(profileShowcaseDraftControllerProvider.future);

    await container
        .read(profileShowcaseDraftControllerProvider.notifier)
        .save(const ProfileShowcaseDraftInput(selfIntro: '还没保存'));

    final state = container.read(profileShowcaseDraftControllerProvider).value!;
    expect(state.dirty, isTrue);
    expect(state.saveError, '网络暂时不可用，当前内容还没有保存为私有草稿。');
    expect(state.statusLabel, '当前修改还没有保存为私有草稿');
  });

  test(
    'controller submit success keeps pending private non-scoring state',
    () async {
      final repo = _FakeDraftRepository(
        draft: const ProfileShowcaseDraftEntity(
          id: 5,
          selfIntro: '准备提交的私有草稿',
          moderationStatus: 'not_submitted',
        ),
      );
      final container = ProviderContainer(
        overrides: [
          profileShowcaseDraftRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);
      await container.read(profileShowcaseDraftControllerProvider.future);

      await container
          .read(profileShowcaseDraftControllerProvider.notifier)
          .submitForReview();

      final state = container
          .read(profileShowcaseDraftControllerProvider)
          .value!;
      expect(repo.submitCalled, isTrue);
      expect(state.isPendingReview, isTrue);
      expect(state.statusLabel, '已提交审核，等待处理');
      expect(state.boundaryText, contains('审核完成前不会发布'));
      expect(state.boundaryText, contains('不会改变匹配结果'));
      expect(state.submitMessage, contains('仍是私有草稿'));
      expect(state.serverDraft?.publicDisplayEligible, isFalse);
      expect(state.serverDraft?.matchingScoringEligible, isFalse);
    },
  );

  test('controller maps owner visible review result copy safely', () async {
    final cases = {
      'approved': ('审核通过，仍是私有草稿', '审核已通过，但当前状态尚未提供发布确认', '审核通过'),
      'rejected': ('审核未通过，可修改后再提交', '这份草稿未通过审核，可以修改后重新提交', '需修改'),
      'needs_revision': ('需要修改后再提交审核', '这份草稿需要补充或调整后再提交审核', '需完善'),
      'manual_review_required': ('需要人工复核，仍是私有草稿', '这份草稿需要人工复核', '人工复核'),
      'error': ('审核状态暂不可用', '审核状态暂不可用', '状态待确认'),
    };

    for (final entry in cases.entries) {
      final repo = _FakeDraftRepository(
        draft: ProfileShowcaseDraftEntity(
          id: 6,
          selfIntro: '已有审核结果的私有草稿',
          moderationStatus: entry.key,
          publicDisplayEligible: false,
          matchingScoringEligible: false,
        ),
      );
      final container = ProviderContainer(
        overrides: [
          profileShowcaseDraftRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final state = await container.read(
        profileShowcaseDraftControllerProvider.future,
      );

      expect(state.statusLabel, entry.value.$1);
      expect(state.boundaryText, contains(entry.value.$2));
      expect(state.boundaryText, contains('不会改变匹配结果'));
      expect(state.compactReviewLabel, entry.value.$3);
      expect(state.serverDraft?.publicDisplayEligible, isFalse);
      expect(state.serverDraft?.matchingScoringEligible, isFalse);
    }
  });

  test('approved draft requires explicit public display eligibility', () async {
    final repo = _FakeDraftRepository(
      draft: const ProfileShowcaseDraftEntity(
        id: 7,
        selfIntro: '具备展示资格的私有草稿',
        moderationStatus: 'approved',
        publicDisplayEligible: true,
        matchingScoringEligible: false,
      ),
    );
    final container = ProviderContainer(
      overrides: [
        profileShowcaseDraftRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);

    final state = await container.read(
      profileShowcaseDraftControllerProvider.future,
    );

    expect(state.statusLabel, '审核通过，可确认发布');
    expect(state.boundaryText, contains('可以单独确认发布'));
    expect(state.compactReviewLabel, '可确认发布');
    expect(state.serverDraft?.publicDisplayEligible, isTrue);
  });

  test('controller submit failure does not claim pending success', () async {
    final repo = _FakeDraftRepository(
      throwOnSubmit: true,
      draft: const ProfileShowcaseDraftEntity(id: 5, selfIntro: '准备提交的私有草稿'),
    );
    final container = ProviderContainer(
      overrides: [
        profileShowcaseDraftRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    await container.read(profileShowcaseDraftControllerProvider.future);

    await container
        .read(profileShowcaseDraftControllerProvider.notifier)
        .submitForReview();

    final state = container.read(profileShowcaseDraftControllerProvider).value!;
    expect(state.isPendingReview, isFalse);
    expect(state.submitMessage, isNull);
    expect(state.submitError, '网络暂时不可用，当前草稿还没有提交安全审核。');
  });

  test('controller validation blocks overclaim-prone invalid save', () async {
    final repo = _FakeDraftRepository();
    final container = ProviderContainer(
      overrides: [
        profileShowcaseDraftRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    await container.read(profileShowcaseDraftControllerProvider.future);

    await container
        .read(profileShowcaseDraftControllerProvider.notifier)
        .save(
          ProfileShowcaseDraftInput(
            interestTags: List<String>.generate(11, (index) => '标签$index'),
          ),
        );

    final state = container.read(profileShowcaseDraftControllerProvider).value!;
    expect(state.validationErrors['interest_tags'], '兴趣标签最多 10 个。');
    expect(state.saveError, '有些内容暂时不能保存，请检查长度和标签数量。');
    expect(repo.savedInput, isNull);
  });

  test('publication controller publishes without scoring claim', () async {
    final repo = _FakePublicationRepository();
    final container = ProviderContainer(
      overrides: [
        profileShowcasePublicationRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    await container.read(profileShowcasePublicationControllerProvider.future);

    await container
        .read(profileShowcasePublicationControllerProvider.notifier)
        .publishApprovedDraft();

    final state = container
        .read(profileShowcasePublicationControllerProvider)
        .value!;
    expect(repo.publishCalled, isTrue);
    expect(state.isPublished, isTrue);
    expect(state.statusLabel, '已发布版本');
    expect(state.message, contains('推荐评分仍未开启'));
    expect(state.publication.publicDisplayEligible, isTrue);
    expect(state.publication.matchingScoringEligible, isFalse);
  });

  test(
    'publication controller failure does not claim public display',
    () async {
      final repo = _FakePublicationRepository(throwOnPublish: true);
      final container = ProviderContainer(
        overrides: [
          profileShowcasePublicationRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);
      await container.read(profileShowcasePublicationControllerProvider.future);

      await container
          .read(profileShowcasePublicationControllerProvider.notifier)
          .publishApprovedDraft();

      final state = container
          .read(profileShowcasePublicationControllerProvider)
          .value!;
      expect(state.isPublished, isFalse);
      expect(state.message, isNull);
      expect(state.error, '网络暂时不可用，当前草稿尚未发布。');
    },
  );

  test('published dirty edits keep the active version unchanged', () {
    const publicationState = ProfileShowcasePublicationUiState(
      loaded: true,
      publication: ProfileShowcasePublicationEntity(
        id: 9,
        sourceDraftId: 4,
        publicationStatus: 'published',
        publicDisplayEligible: true,
        matchingScoringEligible: false,
        publicFields: ProfileShowcaseDraftInput(selfIntro: '已发布内容'),
      ),
    );
    const draftState = ProfileShowcaseDraftUiState(
      loaded: true,
      dirty: true,
      serverDraft: ProfileShowcaseDraftEntity(id: 4, selfIntro: '已发布内容'),
      editor: ProfileShowcaseDraftInput(selfIntro: '尚未保存的新修改'),
    );

    expect(publicationState.guidanceText(draftState), '有未公开的新修改；当前已发布版本保持不变。');
    expect(publicationState.statusLabel, '已发布版本');
  });

  test('saved draft divergence is shown only from owner snapshot evidence', () {
    const publicationState = ProfileShowcasePublicationUiState(
      loaded: true,
      publication: ProfileShowcasePublicationEntity(
        id: 9,
        sourceDraftId: 4,
        publicationStatus: 'published',
        publicDisplayEligible: true,
        matchingScoringEligible: false,
        publicFields: ProfileShowcaseDraftInput(
          selfIntro: '已发布内容',
          interestTags: ['咖啡'],
        ),
      ),
    );
    const divergentDraft = ProfileShowcaseDraftUiState(
      loaded: true,
      serverDraft: ProfileShowcaseDraftEntity(
        id: 4,
        selfIntro: '已保存但未发布的新草稿',
        interestTags: ['咖啡'],
      ),
    );
    const alignedDraft = ProfileShowcaseDraftUiState(
      loaded: true,
      serverDraft: ProfileShowcaseDraftEntity(
        id: 4,
        selfIntro: '已发布内容',
        interestTags: ['咖啡'],
      ),
    );

    expect(
      publicationState.guidanceText(divergentDraft),
      '有未公开的新草稿；当前已发布版本保持不变。',
    );
    expect(
      publicationState.guidanceText(alignedDraft),
      contains('已发布版本与私有草稿分别管理'),
    );
  });
}

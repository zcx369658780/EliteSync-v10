import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_ghost_button.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync_module/design_system/components/fields/app_text_field.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_tag.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_showcase_draft_entity.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/profile_showcase_draft_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/state/personal_showcase_model.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/state/profile_showcase_draft_ui_state.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/showcase_photo_editor.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/authenticated_showcase_photo.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

class PersonalShowcasePage extends ConsumerWidget {
  const PersonalShowcasePage({super.key, this.snapshotOverride});

  final PersonalShowcaseSnapshot? snapshotOverride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).asData?.value;
    final accountKey = ValueKey((
      session?.user?.id,
      ref.read(sessionProvider.notifier).currentAuthenticationIntent,
    ));
    final override = snapshotOverride;
    if (override != null) {
      return PersonalShowcaseContent(key: accountKey, snapshot: override);
    }

    final async = ref.watch(personalShowcaseProvider);
    return async.when(
      loading: () => const AppScaffold(
        appBar: AppTopBar(title: '展示自己', mode: AppTopBarMode.backTitle),
        body: AppLoadingSkeleton(lines: 7),
      ),
      error: (e, _) => const AppScaffold(
        appBar: AppTopBar(title: '展示自己', mode: AppTopBarMode.backTitle),
        body: AppErrorState(
          title: '展示信息暂不可用',
          description: '暂时无法读取展示内容，请稍后重试。',
        ),
      ),
      data: (snapshot) =>
          PersonalShowcaseContent(key: accountKey, snapshot: snapshot),
    );
  }
}

class PersonalShowcaseContent extends StatelessWidget {
  const PersonalShowcaseContent({super.key, required this.snapshot});

  final PersonalShowcaseSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AppScaffold(
      appBar: const AppTopBar(title: '展示自己', mode: AppTopBarMode.backTitle),
      body: ListView(
        padding: EdgeInsets.only(top: t.spacing.sm, bottom: t.spacing.xxl),
        children: [
          SectionReveal(
            delay: const Duration(milliseconds: 40),
            child: _PrivateDraftSaveCard(snapshot: snapshot),
          ),
          SizedBox(height: t.spacing.md),
          const SectionReveal(
            delay: Duration(milliseconds: 80),
            child: _PublicDisplayPublicationCard(),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 100),
            child: _ShowcaseProgressCard(snapshot: snapshot),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 120),
            child: const _PreviewCard(),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 160),
            child: _ExpressionCluesSection(snapshot: snapshot),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 200),
            child: _OpenerSupportCard(advice: snapshot.expressionAdvice),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 240),
            child: _NoOverclaimCard(detailAvailable: snapshot.detailAvailable),
          ),
        ],
      ),
    );
  }
}

class _ShowcaseProgressCard extends StatelessWidget {
  const _ShowcaseProgressCard({required this.snapshot});

  final PersonalShowcaseSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AppCard(
      backgroundColor: t.browseSurface,
      border: Border.all(color: t.browseBorder),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '继续整理展示内容',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: t.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: t.spacing.sm),
          Text(
            snapshot.pendingSuggestions.isEmpty
                ? '已有可供整理的表达线索；是否保存、提交或展示，仍由你确认。'
                : '下一步可以补充：${snapshot.pendingSuggestions.first}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
          ),
          SizedBox(height: t.spacing.sm),
        ],
      ),
    );
  }
}

class _PrivateDraftSaveCard extends ConsumerStatefulWidget {
  const _PrivateDraftSaveCard({required this.snapshot});

  final PersonalShowcaseSnapshot snapshot;

  @override
  ConsumerState<_PrivateDraftSaveCard> createState() =>
      _PrivateDraftSaveCardState();
}

class _PrivateDraftSaveCardState extends ConsumerState<_PrivateDraftSaveCard> {
  late final TextEditingController _displayName;
  late final TextEditingController _city;
  late final TextEditingController _relationshipGoal;
  late final TextEditingController _selfIntro;
  late final TextEditingController _interestTags;
  late final TextEditingController _lifestyleTags;
  late final TextEditingController _openerNote;
  Object? _lastAppliedDraftKey;

  @override
  void initState() {
    super.initState();
    final seed = _seedFromSnapshot(widget.snapshot);
    _displayName = TextEditingController(text: seed.displayName);
    _city = TextEditingController(text: seed.city);
    _relationshipGoal = TextEditingController(text: seed.relationshipGoal);
    _selfIntro = TextEditingController(text: seed.selfIntro);
    _interestTags = TextEditingController(text: seed.interestTags.join('、'));
    _lifestyleTags = TextEditingController(text: seed.lifestyleTags.join('、'));
    _openerNote = TextEditingController(text: seed.openerNote);
  }

  @override
  void dispose() {
    _displayName.dispose();
    _city.dispose();
    _relationshipGoal.dispose();
    _selfIntro.dispose();
    _interestTags.dispose();
    _lifestyleTags.dispose();
    _openerNote.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final async = ref.watch(profileShowcaseDraftControllerProvider);
    final draftState = async.asData?.value;
    final publication = ref
        .watch(profileShowcasePublicationControllerProvider)
        .asData
        ?.value;
    final busy =
        draftState?.isBusy == true ||
        publication?.publishing == true ||
        async.isLoading;
    final editor = draftState?.editor ?? ProfileShowcaseDraftInput.empty;
    final photos = {
      for (final photo in draftState?.serverDraft?.photos ?? <ShowcasePhoto>[])
        photo.id: photo,
    };
    _syncControllers(draftState);

    return AppCard(
      backgroundColor: t.browseSurface,
      border: Border.all(color: t.browseBorder),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                draftState?.hasSavedPrivateDraft == true
                    ? Icons.cloud_done_outlined
                    : Icons.edit_note_outlined,
                color: t.brandSecondary,
              ),
              SizedBox(width: t.spacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '保存私有草稿',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      draftState?.statusLabel ?? '正在读取私有草稿...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: t.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              AppTag(
                label: draftState?.hasSavedPrivateDraft == true
                    ? '私有草稿'
                    : '本地草稿',
                variant: draftState?.hasSavedPrivateDraft == true
                    ? AppTagVariant.success
                    : AppTagVariant.brand,
              ),
            ],
          ),
          if (async.isLoading) ...[
            SizedBox(height: t.spacing.sm),
            const AppLoadingSkeleton(lines: 2),
          ],
          if ((draftState?.loadError ?? '').isNotEmpty) ...[
            SizedBox(height: t.spacing.sm),
            _DraftNotice(
              icon: Icons.warning_amber_rounded,
              text: draftState!.loadError!,
              color: t.warning,
            ),
          ],
          SizedBox(height: t.spacing.md),
          AppTextField(
            controller: _displayName,
            label: '展示昵称',
            maxLength: 80,
            enabled: !busy,
            errorText: draftState?.validationErrors['display_name'],
            onChanged: (_) => _markDirty(),
          ),
          SizedBox(height: t.spacing.sm),
          AppTextField(
            controller: _city,
            label: '展示城市',
            maxLength: 80,
            enabled: !busy,
            errorText: draftState?.validationErrors['city'],
            onChanged: (_) => _markDirty(),
          ),
          SizedBox(height: t.spacing.sm),
          AppTextField(
            controller: _relationshipGoal,
            label: '展示关系目标',
            maxLength: 80,
            enabled: !busy,
            errorText: draftState?.validationErrors['relationship_goal'],
            onChanged: (_) => _markDirty(),
          ),
          SizedBox(height: t.spacing.sm),
          AppTextField(
            controller: _selfIntro,
            enabled: !busy,
            label: '一句自我介绍',
            hint: '写一句最近的生活状态或想被理解的方式',
            maxLength: 500,
            minLines: 2,
            maxLines: 4,
            errorText: draftState?.validationErrors['self_intro'],
            onChanged: (_) => _markDirty(),
          ),
          SizedBox(height: t.spacing.sm),
          AppTextField(
            controller: _interestTags,
            enabled: !busy,
            label: '兴趣标签',
            hint: '咖啡、徒步、电影，最多 10 个',
            errorText: draftState?.validationErrors['interest_tags'],
            onChanged: (_) => _markDirty(),
          ),
          SizedBox(height: t.spacing.xxs),
          const _FieldExplanation(
            fieldLabel: '兴趣标签',
            text: '用顿号或逗号分隔；保存为用户确认的私有草稿。',
          ),
          SizedBox(height: t.spacing.sm),
          AppTextField(
            controller: _lifestyleTags,
            enabled: !busy,
            label: '生活线索',
            hint: '周末早起、稳定作息、常去书店',
            errorText: draftState?.validationErrors['lifestyle_tags'],
            onChanged: (_) => _markDirty(),
          ),
          SizedBox(height: t.spacing.xxs),
          const _FieldExplanation(
            fieldLabel: '生活线索',
            text: '只作为展示线索，不会改变匹配结果。',
          ),
          SizedBox(height: t.spacing.sm),
          AppTextField(
            controller: _openerNote,
            enabled: !busy,
            label: '聊天开场话题',
            hint: '别人可以从哪个轻问题开始了解你？',
            maxLength: 280,
            minLines: 2,
            maxLines: 4,
            errorText: draftState?.validationErrors['opener_note'],
            onChanged: (_) => _markDirty(),
          ),
          SizedBox(height: t.spacing.sm),
          Text('展示范围', style: Theme.of(context).textTheme.titleMedium),
          for (final audience in showcaseAudienceLabels.entries)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(audience.value),
              value: editor.audiences.contains(audience.key),
              onChanged: busy
                  ? null
                  : (selected) {
                      final values = [...editor.audiences];
                      if (selected == true) {
                        values.add(audience.key);
                      } else {
                        values.remove(audience.key);
                      }
                      ref
                          .read(profileShowcaseDraftControllerProvider.notifier)
                          .edit(_currentInput().copyWith(audiences: values));
                    },
            ),
          const Text('仅当前符合所选范围的对象可读取发布版。提交前至少选择一个范围。'),
          SizedBox(height: t.spacing.md),
          ShowcasePhotoEditor(
            photos: [
              for (final id in editor.photoIds)
                if (photos[id] != null)
                  AuthenticatedShowcasePhoto(
                    key: ValueKey(photos[id]!.contentPath),
                    contentPath: photos[id]!.contentPath,
                    refreshKey: draftState?.serverDraft?.revision,
                  )
                else
                  const Center(child: Text('照片待刷新')),
            ],
            busy: busy || draftState?.loadError != null,
            onAdd: () => ref
                .read(profileShowcaseDraftControllerProvider.notifier)
                .uploadPhoto(),
            onRemove: (index) => _changePhotoOrder(index, remove: true),
            onMoveEarlier: (index) =>
                _changePhotoOrder(index, destination: index - 1),
            onMoveLater: (index) =>
                _changePhotoOrder(index, destination: index + 1),
          ),
          const Text('添加照片前请先保存当前修改。排序和移除在保存草稿后生效。'),
          if (ref
              .read(profileShowcaseDraftControllerProvider.notifier)
              .hasPendingUpload)
            TextButton(
              onPressed: busy
                  ? null
                  : () => ref
                        .read(profileShowcaseDraftControllerProvider.notifier)
                        .discardPendingUpload(),
              child: const Text('取消本次照片上传'),
            ),
          if (draftState?.serverDraft?.revision != null)
            Text('当前草稿版本：${draftState!.serverDraft!.revision}'),
          if (draftState?.serverDraft?.submission != null) ...[
            SizedBox(height: t.spacing.md),
            Text('最近提交版本：${draftState!.serverDraft!.submission!.revision}'),
            Text(
              '处理状态：${_reviewStatusTagLabel(draftState.serverDraft!.submission!.state)}',
            ),
            if (draftState.serverDraft!.submission!.feedback != null)
              Text('处理反馈：${draftState.serverDraft!.submission!.feedback}'),
            _ShowcaseFieldsPreview(
              input: draftState.serverDraft!.submission!.snapshot,
              photos: draftState.serverDraft!.photos,
            ),
          ],
          SizedBox(height: t.spacing.sm),
          _DraftNotice(
            icon: Icons.privacy_tip_outlined,
            text: draftState?.boundaryText ?? '这份草稿不会公开展示，也不会改变匹配结果。',
            color: t.info,
          ),
          if (draftState?.hasSavedPrivateDraft == true) ...[
            SizedBox(height: t.spacing.sm),
            _DraftMetadataWrap(draft: draftState!.serverDraft!),
          ],
          if ((draftState?.saveError ?? '').isNotEmpty) ...[
            SizedBox(height: t.spacing.sm),
            _DraftNotice(
              icon: Icons.error_outline_rounded,
              text: draftState!.saveError!,
              color: t.error,
            ),
          ],
          if ((draftState?.submitError ?? '').isNotEmpty) ...[
            SizedBox(height: t.spacing.sm),
            _DraftNotice(
              icon: Icons.error_outline_rounded,
              text: draftState!.submitError!,
              color: t.error,
            ),
          ],
          if ((draftState?.submitMessage ?? '').isNotEmpty) ...[
            SizedBox(height: t.spacing.sm),
            _DraftNotice(
              icon: Icons.hourglass_top_rounded,
              text: _sanitizeShowcasePublicCopy(draftState!.submitMessage!),
              color: t.info,
            ),
          ],
          if ((draftState?.clearMessage ?? '').isNotEmpty) ...[
            SizedBox(height: t.spacing.sm),
            _DraftNotice(
              icon: Icons.check_circle_outline_rounded,
              text: draftState!.clearMessage!,
              color: t.success,
            ),
          ],
          if (draftState != null) ...[
            SizedBox(height: t.spacing.sm),
            _DraftNotice(
              icon: Icons.touch_app_outlined,
              text: draftState.ctaGuidanceText,
              color: t.brandSecondary,
            ),
          ],
          SizedBox(height: t.spacing.md),
          AppPrimaryButton(
            label: draftState?.saving == true
                ? '正在保存'
                : (draftState?.saveError ?? '').isNotEmpty
                ? '重试保存私有草稿'
                : '保存为私有草稿',
            isLoading: draftState?.saving == true,
            onPressed:
                busy ||
                    draftState?.loaded != true ||
                    draftState?.loadError != null
                ? null
                : () => ref
                      .read(profileShowcaseDraftControllerProvider.notifier)
                      .save(_currentInput()),
            prefixIcon: const Icon(Icons.save_outlined, size: 18),
          ),
          SizedBox(height: t.spacing.sm),
          Wrap(
            spacing: t.spacing.sm,
            runSpacing: t.spacing.xs,
            children: [
              AppSecondaryButton(
                label:
                    draftState?.hasReviewResult == true ||
                        draftState?.isPendingReview == true
                    ? '刷新审核状态'
                    : '重新读取',
                style: AppSecondaryButtonStyle.outline,
                prefixIcon: const Icon(Icons.refresh_rounded, size: 18),
                onPressed: busy
                    ? null
                    : () => ref
                          .read(profileShowcaseDraftControllerProvider.notifier)
                          .refreshDraft(),
              ),
              AppSecondaryButton(
                label: draftState?.submitCtaLabel ?? '提交安全审核',
                isLoading: draftState?.submitting == true,
                prefixIcon: const Icon(Icons.verified_user_outlined, size: 18),
                onPressed: busy || draftState?.canSubmitForReview != true
                    ? null
                    : () => ref
                          .read(profileShowcaseDraftControllerProvider.notifier)
                          .submitForReview(),
              ),
              AppGhostButton(
                label: '清除私有草稿',
                isDestructive: true,
                onPressed: busy || draftState?.hasSavedPrivateDraft != true
                    ? null
                    : () => _confirmClear(context, draftState!),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _syncControllers(ProfileShowcaseDraftUiState? draftState) {
    if (draftState == null || draftState.dirty) return;
    final draft = draftState.serverDraft;
    final key = (draft?.id, draft?.revision, draft?.updatedAt);
    if (_lastAppliedDraftKey == key) return;
    _lastAppliedDraftKey = key;
    final input = draft?.toInput() ?? _seedFromSnapshot(widget.snapshot);
    _displayName.text = input.displayName;
    _city.text = input.city;
    _relationshipGoal.text = input.relationshipGoal;
    _selfIntro.text = input.selfIntro;
    _interestTags.text = input.interestTags.join('、');
    _lifestyleTags.text = input.lifestyleTags.join('、');
    _openerNote.text = input.openerNote;
  }

  void _markDirty() {
    ref
        .read(profileShowcaseDraftControllerProvider.notifier)
        .edit(_currentInput());
  }

  ProfileShowcaseDraftInput _currentInput() {
    final input =
        ref.read(profileShowcaseDraftControllerProvider).asData?.value.editor ??
        ProfileShowcaseDraftInput.empty;
    return input.copyWith(
      displayName: _displayName.text,
      city: _city.text,
      relationshipGoal: _relationshipGoal.text,
      selfIntro: _selfIntro.text,
      interestTags: _splitTags(_interestTags.text),
      lifestyleTags: _splitTags(_lifestyleTags.text),
      openerNote: _openerNote.text,
    );
  }

  void _changePhotoOrder(int index, {int? destination, bool remove = false}) {
    final input = _currentInput();
    final ids = [...input.photoIds];
    final id = ids.removeAt(index);
    if (!remove) ids.insert(destination!, id);
    ref
        .read(profileShowcaseDraftControllerProvider.notifier)
        .edit(input.copyWith(photoIds: ids));
  }

  Future<void> _confirmClear(
    BuildContext context,
    ProfileShowcaseDraftUiState draftState,
  ) async {
    final session = ref.read(sessionProvider).asData?.value;
    final revision = draftState.serverDraft?.revision ?? 0;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('清除这份私有草稿？'),
        content: Text(draftState.clearDraftConfirmationText),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('清除私有草稿'),
          ),
        ],
      ),
    );
    if (confirmed == true &&
        mounted &&
        identical(session, ref.read(sessionProvider).asData?.value)) {
      await ref
          .read(profileShowcaseDraftControllerProvider.notifier)
          .clearDraft(expectedRevision: revision);
    }
  }
}

class _FieldExplanation extends StatelessWidget {
  const _FieldExplanation({required this.fieldLabel, required this.text});

  final String fieldLabel;
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Semantics(
      container: true,
      label: '$fieldLabel。$text',
      excludeSemantics: true,
      child: SizedBox(
        width: double.infinity,
        child: Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
        ),
      ),
    );
  }
}

class _DraftNotice extends StatelessWidget {
  const _DraftNotice({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      padding: EdgeInsets.all(t.spacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(t.radius.md),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          SizedBox(width: t.spacing.xs),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: t.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PublicDisplayPublicationCard extends ConsumerWidget {
  const _PublicDisplayPublicationCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.appTokens;
    final draftState = ref
        .watch(profileShowcaseDraftControllerProvider)
        .asData
        ?.value;
    final publicationAsync = ref.watch(
      profileShowcasePublicationControllerProvider,
    );
    final publicationState = publicationAsync.asData?.value;
    final canPublish = publicationState?.canPublish(draftState) == true;

    return AppCard(
      backgroundColor: t.secondarySurface.withValues(alpha: 0.82),
      border: Border.all(color: t.browseBorder),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.public_outlined, color: t.brandPrimary),
              SizedBox(width: t.spacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '发布版本',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      publicationState?.statusLabel ?? '正在读取展示状态...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: t.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              AppTag(
                label: publicationState?.isPublished == true ? '已发布' : '未发布',
                variant: publicationState?.isPublished == true
                    ? AppTagVariant.success
                    : AppTagVariant.brand,
              ),
            ],
          ),
          if (publicationAsync.isLoading) ...[
            SizedBox(height: t.spacing.sm),
            const AppLoadingSkeleton(lines: 2),
          ],
          SizedBox(height: t.spacing.sm),
          _DraftNotice(
            icon: Icons.info_outline_rounded,
            text:
                publicationState?.guidanceText(draftState) ??
                '发布需要你主动确认；审核通过不会自动发布，也不会改变匹配结果。',
            color: t.info,
          ),
          if ((publicationState?.error ?? '').isNotEmpty) ...[
            SizedBox(height: t.spacing.sm),
            _DraftNotice(
              icon: Icons.error_outline_rounded,
              text: publicationState!.error!,
              color: t.error,
            ),
          ],
          if ((publicationState?.message ?? '').isNotEmpty) ...[
            SizedBox(height: t.spacing.sm),
            _DraftNotice(
              icon: Icons.check_circle_outline_rounded,
              text: _sanitizeShowcasePublicCopy(publicationState!.message!),
              color: t.success,
            ),
          ],
          if (publicationState?.publication.id != null) ...[
            SizedBox(height: t.spacing.md),
            Text(
              '发布版本：${publicationState!.publication.revision}；来源草稿版本：${publicationState.publication.sourceRevision}',
            ),
            _ShowcaseFieldsPreview(
              input: publicationState.publication.publicFields,
              photos: publicationState.publication.photos,
            ),
          ],
          SizedBox(height: t.spacing.md),
          Wrap(
            spacing: t.spacing.sm,
            runSpacing: t.spacing.xs,
            children: [
              AppSecondaryButton(
                label: '刷新发布状态',
                style: AppSecondaryButtonStyle.outline,
                prefixIcon: const Icon(Icons.refresh_rounded, size: 18),
                onPressed: publicationState?.publishing == true
                    ? null
                    : () => ref
                          .read(
                            profileShowcasePublicationControllerProvider
                                .notifier,
                          )
                          .refreshPublication(),
              ),
              if (canPublish)
                AppSecondaryButton(
                  label: '确认发布这份审核通过的草稿',
                  isLoading: publicationState?.publishing == true,
                  prefixIcon: const Icon(Icons.public_rounded, size: 18),
                  onPressed: () => _confirmPublish(context, ref),
                ),
              if (publicationState?.isPublished == true)
                AppGhostButton(
                  label: '撤回展示',
                  isDestructive: true,
                  onPressed: publicationState?.publishing == true
                      ? null
                      : () => _confirmWithdraw(context, ref),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmPublish(BuildContext context, WidgetRef ref) async {
    final session = ref.read(sessionProvider).asData?.value;
    final draft = ref
        .read(profileShowcaseDraftControllerProvider)
        .asData
        ?.value;
    final publication = ref
        .read(profileShowcasePublicationControllerProvider)
        .asData
        ?.value;
    if (draft == null || publication == null) return;
    final revision = draft.serverDraft?.revision ?? 0;
    final publicationRevision = publication.publication.revision;
    final audiences = draft.editor.audiences
        .map((key) => showcaseAudienceLabels[key] ?? key)
        .join('、');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('确认发布这份草稿？'),
        content: Text(
          '发布草稿版本 $revision，展示范围：${audiences.isEmpty ? "尚未选择" : audiences}。内容仅供当前符合所选范围的对象读取。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('确认发布'),
          ),
        ],
      ),
    );
    if (confirmed == true &&
        context.mounted &&
        identical(session, ref.read(sessionProvider).asData?.value)) {
      await ref
          .read(profileShowcasePublicationControllerProvider.notifier)
          .publishApprovedDraft(
            expectedDraftRevision: revision,
            expectedPublicationRevision: publicationRevision,
          );
    }
  }

  Future<void> _confirmWithdraw(BuildContext context, WidgetRef ref) async {
    final session = ref.read(sessionProvider).asData?.value;
    final revision = ref
        .read(profileShowcasePublicationControllerProvider)
        .asData
        ?.value
        .publication
        .revision;
    if (revision == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('撤回当前展示？'),
        content: const Text('撤回后，对方的新读取请求按当前权限停止提供展示内容。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('确认撤回'),
          ),
        ],
      ),
    );
    if (confirmed == true &&
        context.mounted &&
        identical(session, ref.read(sessionProvider).asData?.value)) {
      await ref
          .read(profileShowcasePublicationControllerProvider.notifier)
          .withdraw(expectedPublicationRevision: revision);
    }
  }
}

class _DraftMetadataWrap extends StatelessWidget {
  const _DraftMetadataWrap({required this.draft});

  final ProfileShowcaseDraftEntity draft;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        const AppTag(label: '仅私有草稿', variant: AppTagVariant.outlined),
        AppTag(
          label: draft.draftStatus == 'cleared' ? '已清除' : '草稿中',
          variant: AppTagVariant.neutral,
        ),
        AppTag(
          label: _reviewStatusTagLabel(draft.moderationStatus),
          variant: _reviewStatusTagVariant(draft.moderationStatus),
        ),
        const AppTag(label: '不会公开展示', variant: AppTagVariant.outlined),
        const AppTag(label: '不改变匹配结果', variant: AppTagVariant.outlined),
        const AppTag(label: '来自你的确认编辑', variant: AppTagVariant.brand),
      ],
    );
  }
}

String _reviewStatusTagLabel(String status) {
  return switch (status) {
    'pending' => '已提交审核，等待处理',
    'approved' => '审核通过，可确认发布',
    'rejected' => '审核未通过',
    'needs_revision' => '需要修改后再提交',
    'manual_review_required' => '需要人工复核',
    'error' => '审核状态暂不可用',
    _ => '尚未提交安全审核',
  };
}

AppTagVariant _reviewStatusTagVariant(String status) {
  return switch (status) {
    'approved' => AppTagVariant.success,
    'rejected' || 'needs_revision' || 'error' => AppTagVariant.warning,
    'manual_review_required' => AppTagVariant.brand,
    'pending' => AppTagVariant.warning,
    _ => AppTagVariant.neutral,
  };
}

ProfileShowcaseDraftInput _seedFromSnapshot(PersonalShowcaseSnapshot _) =>
    ProfileShowcaseDraftInput.empty;

List<String> _splitTags(String value) {
  return value
      .split(RegExp(r'[、,，\n]'))
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toSet()
      .toList(growable: false);
}

class _PreviewCard extends ConsumerWidget {
  const _PreviewCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref
        .watch(profileShowcaseDraftControllerProvider)
        .asData
        ?.value;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('当前私有草稿预览', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _ShowcaseFieldsPreview(
            input: draft?.editor ?? ProfileShowcaseDraftInput.empty,
            photos: draft?.serverDraft?.photos ?? const [],
          ),
        ],
      ),
    );
  }
}

class _ShowcaseFieldsPreview extends StatelessWidget {
  const _ShowcaseFieldsPreview({required this.input, required this.photos});

  final ProfileShowcaseDraftInput input;
  final List<ShowcasePhoto> photos;

  @override
  Widget build(BuildContext context) {
    final references = {for (final photo in photos) photo.id: photo};
    final fields = {
      '展示昵称': input.displayName,
      '展示城市': input.city,
      '展示关系目标': input.relationshipGoal,
      '自我介绍': input.selfIntro,
      '兴趣标签': input.interestTags.join('、'),
      '生活线索': input.lifestyleTags.join('、'),
      '开场话题': input.openerNote,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final field in fields.entries)
          if (field.value.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('${field.key}：${field.value}'),
            ),
        Text(
          input.audiences.isEmpty
              ? '展示范围尚未选择'
              : '展示范围：${input.audiences.map((key) => showcaseAudienceLabels[key] ?? key).join('、')}',
        ),
        if (input.photoIds.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final id in input.photoIds)
                SizedBox.square(
                  dimension: 144,
                  child: references[id] == null
                      ? const Center(child: Text('照片当前不可用'))
                      : AuthenticatedShowcasePhoto(
                          contentPath: references[id]!.contentPath,
                        ),
                ),
            ],
          ),
      ],
    );
  }
}

class _ExpressionCluesSection extends StatelessWidget {
  const _ExpressionCluesSection({required this.snapshot});

  final PersonalShowcaseSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '展示完整度',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: t.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: t.spacing.sm),
        ...snapshot.checklist.map(
          (item) => Padding(
            padding: EdgeInsets.only(bottom: t.spacing.sm),
            child: _ChecklistTile(item: item),
          ),
        ),
        SizedBox(height: t.spacing.sm),
        Text(
          '照片或头像不是继续使用的前置条件。',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: t.textSecondary, height: 1.45),
        ),
      ],
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({required this.item});

  final ShowcaseChecklistItem item;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AppCard(
      padding: EdgeInsets.all(t.spacing.md),
      backgroundColor: t.browseSurface,
      border: Border.all(color: t.browseBorder),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_iconFor(item.iconName), color: _colorFor(context, item.status)),
          SizedBox(width: t.spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: t.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    _StatusPill(status: item.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: t.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String name) {
    switch (name) {
      case 'target':
        return Icons.favorite_border_rounded;
      case 'tags':
        return Icons.interests_outlined;
      case 'lifestyle':
        return Icons.weekend_outlined;
      case 'photo':
        return Icons.photo_camera_outlined;
      case 'astro':
        return Icons.auto_awesome_outlined;
      case 'chat':
        return Icons.chat_bubble_outline_rounded;
      case 'intro':
      default:
        return Icons.notes_outlined;
    }
  }

  Color _colorFor(BuildContext context, ShowcaseItemStatus status) {
    final t = context.appTokens;
    switch (status) {
      case ShowcaseItemStatus.completed:
        return t.success;
      case ShowcaseItemStatus.available:
        return t.info;
      case ShowcaseItemStatus.empty:
        return t.warning;
      case ShowcaseItemStatus.later:
        return t.textTertiary;
    }
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final ShowcaseItemStatus status;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor(t),
        borderRadius: BorderRadius.circular(t.radius.pill),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: _textColor(t),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _backgroundColor(AppThemeTokens t) {
    switch (status) {
      case ShowcaseItemStatus.completed:
        return t.success.withValues(alpha: 0.16);
      case ShowcaseItemStatus.available:
        return t.info.withValues(alpha: 0.16);
      case ShowcaseItemStatus.empty:
        return t.warning.withValues(alpha: 0.18);
      case ShowcaseItemStatus.later:
        return t.overlay.withValues(alpha: 0.42);
    }
  }

  Color _textColor(AppThemeTokens t) {
    switch (status) {
      case ShowcaseItemStatus.completed:
        return t.success;
      case ShowcaseItemStatus.available:
        return t.info;
      case ShowcaseItemStatus.empty:
        return t.warning;
      case ShowcaseItemStatus.later:
        return t.textSecondary;
    }
  }
}

class _OpenerSupportCard extends StatelessWidget {
  const _OpenerSupportCard({required this.advice});

  final List<String> advice;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AppCard(
      backgroundColor: t.browseSurface,
      border: Border.all(color: t.browseBorder),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '聊天开场话题',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: t.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: t.spacing.sm),
          Text(
            '这些句子可以成为首聊前的轻问题，不会自动发送消息。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
          SizedBox(height: t.spacing.sm),
          ...advice.map(
            (line) => Padding(
              padding: EdgeInsets.only(bottom: t.spacing.xs),
              child: Text(
                '· $line',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoOverclaimCard extends StatelessWidget {
  const _NoOverclaimCard({required this.detailAvailable});

  final bool detailAvailable;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final unavailableText = detailAvailable ? '' : '部分资料暂不可用时，会先展示可补充建议。';
    return AppCard(
      backgroundColor: t.info.withValues(alpha: 0.10),
      border: Border.all(color: t.info.withValues(alpha: 0.26)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: t.info, size: 18),
              SizedBox(width: t.spacing.xs),
              Text(
                '展示边界',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: t.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '这些信息帮助别人理解你，不保证匹配结果；也不会自动保存为新的个人资料。星盘内容只作为关系参考，不替你做决定。$unavailableText',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

String _sanitizeShowcasePublicCopy(String value) {
  return value
      .replaceAll('推荐评分仍未开启', '这不会改变匹配结果')
      .replaceAll('不会用于推荐评分', '不会改变匹配结果')
      .replaceAll('不会进入推荐评分', '不会改变匹配结果')
      .replaceAll('不会影响推荐评分', '不会改变匹配结果')
      .replaceAll('匹配权重', '匹配结果');
}

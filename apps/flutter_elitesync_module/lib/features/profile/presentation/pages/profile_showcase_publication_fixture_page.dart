import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_tag.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_showcase_draft_entity.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_showcase_publication_entity.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/state/profile_showcase_draft_ui_state.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/state/profile_showcase_publication_ui_state.dart';

class ProfileShowcasePublicationFixturePage extends StatefulWidget {
  const ProfileShowcasePublicationFixturePage({super.key});

  @override
  State<ProfileShowcasePublicationFixturePage> createState() =>
      _ProfileShowcasePublicationFixturePageState();
}

class _ProfileShowcasePublicationFixturePageState
    extends State<ProfileShowcasePublicationFixturePage> {
  final Set<String> _confirmedStates = {};

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Scaffold(
      backgroundColor: t.browseBackground,
      appBar: AppBar(
        title: const Text('公开展示状态夹具'),
        backgroundColor: t.browseBackground,
        foregroundColor: t.textPrimary,
      ),
      body: ListView(
        padding: EdgeInsets.all(t.spacing.md),
        children: [
          const _FixtureIntroCard(),
          SizedBox(height: t.spacing.md),
          ..._fixtureStates.map(
            (fixture) => Padding(
              padding: EdgeInsets.only(bottom: t.spacing.sm),
              child: _PublicationFixtureCard(
                fixture: fixture,
                confirmed: _confirmedStates.contains(fixture.id),
                onConfirm: () => _confirmPublication(fixture),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmPublication(_PublicationFixture fixture) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('打开这份草稿展示？'),
        content: const Text('这是本地夹具确认弹窗：展示只代表可被看到的展示投影，推荐评分仍未开启。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('确认打开展示'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _confirmedStates.add(fixture.id);
      });
    }
  }
}

class _FixtureIntroCard extends StatelessWidget {
  const _FixtureIntroCard();

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AppCard(
      backgroundColor: t.browseSurface,
      border: Border.all(color: t.browseBorder),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppTag(label: 'DEBUG ONLY', variant: AppTagVariant.warning),
          SizedBox(height: t.spacing.sm),
          Text(
            '仅用于本地设备截图覆盖',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: t.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: t.spacing.xs),
          Text(
            '这些公开展示状态来自 Flutter 本地夹具，不调用后端、不写入资料、不发布真实展示，也不会进入推荐评分。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: t.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _PublicationFixtureCard extends StatelessWidget {
  const _PublicationFixtureCard({
    required this.fixture,
    required this.confirmed,
    required this.onConfirm,
  });

  final _PublicationFixture fixture;
  final bool confirmed;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final publicationState = fixture.publicationState(confirmed: confirmed);
    final draftState = fixture.draftState;
    final canPublish = fixture.canExposePublishAction(publicationState);
    final statusLabel = confirmed ? '本地夹具已确认展示' : publicationState.statusLabel;

    return AppCard(
      backgroundColor: t.browseSurface,
      border: Border.all(color: t.browseBorder),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(fixture.icon, color: fixture.color(t)),
              SizedBox(width: t.spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fixture.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: t.spacing.xs),
                    Text(
                      statusLabel,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: t.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              AppTag(
                label: publicationState.isPublished || confirmed
                    ? '展示中'
                    : '未展示',
                variant: publicationState.isPublished || confirmed
                    ? AppTagVariant.success
                    : AppTagVariant.brand,
              ),
            ],
          ),
          SizedBox(height: t.spacing.sm),
          _FixtureNotice(text: publicationState.guidanceText(draftState)),
          if ((publicationState.error ?? '').isNotEmpty) ...[
            SizedBox(height: t.spacing.sm),
            _FixtureNotice(text: publicationState.error!, warning: true),
          ],
          SizedBox(height: t.spacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppTag(label: '状态：${fixture.id}', variant: AppTagVariant.neutral),
              const AppTag(label: '本地夹具', variant: AppTagVariant.outlined),
              const AppTag(label: '不调用后端', variant: AppTagVariant.outlined),
              const AppTag(label: '不进入推荐评分', variant: AppTagVariant.outlined),
              AppTag(
                label: 'matching_scoring_eligible=false',
                variant: AppTagVariant.warning,
              ),
            ],
          ),
          SizedBox(height: t.spacing.md),
          AppSecondaryButton(
            label: fixture.publishActionLabel(publicationState),
            style: AppSecondaryButtonStyle.outline,
            prefixIcon: const Icon(Icons.public_rounded, size: 18),
            onPressed: canPublish ? onConfirm : null,
          ),
        ],
      ),
    );
  }
}

class _FixtureNotice extends StatelessWidget {
  const _FixtureNotice({required this.text, this.warning = false});

  final String text;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final color = warning ? t.warning : t.info;
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
          Icon(
            warning ? Icons.error_outline_rounded : Icons.privacy_tip_outlined,
            size: 18,
            color: color,
          ),
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

class _PublicationFixture {
  const _PublicationFixture({
    required this.id,
    required this.title,
    required this.draftState,
    required this.publication,
    required this.icon,
    required this.color,
    this.error,
  });

  final String id;
  final String title;
  final ProfileShowcaseDraftUiState? draftState;
  final ProfileShowcasePublicationEntity publication;
  final IconData icon;
  final Color Function(AppThemeTokens t) color;
  final String? error;

  ProfileShowcasePublicationUiState publicationState({
    required bool confirmed,
  }) {
    if (confirmed) {
      return ProfileShowcasePublicationUiState(
        loaded: true,
        message: '本地夹具已确认展示；推荐评分仍未开启。',
        publication: ProfileShowcasePublicationEntity(
          id: 900,
          sourceDraftId: draftState?.serverDraft?.id,
          publicationStatus: 'published',
          moderationStatus: 'approved',
          publicDisplayEligible: true,
          matchingScoringEligible: false,
          publicFields:
              draftState?.serverDraft?.toInput() ??
              ProfileShowcaseDraftInput.empty,
          publishedAt: DateTime.utc(2026, 6, 16),
        ),
      );
    }

    return ProfileShowcasePublicationUiState(
      loaded: true,
      publication: publication,
      error: error,
    );
  }

  bool canExposePublishAction(ProfileShowcasePublicationUiState state) {
    if ((state.error ?? '').isNotEmpty) {
      return false;
    }
    if (state.publication.publicationStatus == 'unavailable') {
      return false;
    }
    return state.canPublish(draftState);
  }

  String publishActionLabel(ProfileShowcasePublicationUiState state) {
    if (state.isPublished) {
      return state.publishCtaLabel;
    }
    if (!canExposePublishAction(state)) {
      return '暂不可打开展示';
    }
    return state.publishCtaLabel;
  }
}

final _fixtureStates = [
  _PublicationFixture(
    id: 'unavailable',
    title: 'No Draft / 状态不可用',
    draftState: null,
    publication: const ProfileShowcasePublicationEntity(
      publicationStatus: 'unavailable',
      publicDisplayEligible: false,
      matchingScoringEligible: false,
    ),
    icon: Icons.info_outline_rounded,
    color: (t) => t.info,
  ),
  _PublicationFixture(
    id: 'approved_not_published',
    title: 'Approved Draft / 可手动展示',
    draftState: _draftState(
      id: 701,
      selfIntro: '可展示但仍然私有的展示草稿。',
      moderationStatus: 'approved',
    ),
    publication: ProfileShowcasePublicationEntity.notPublished,
    icon: Icons.verified_outlined,
    color: (t) => t.success,
  ),
  _PublicationFixture(
    id: 'published',
    title: 'Published Projection / 当前展示中',
    draftState: _draftState(
      id: 702,
      selfIntro: '已经由用户确认展示的展示投影。',
      moderationStatus: 'approved',
    ),
    publication: ProfileShowcasePublicationEntity(
      id: 7020,
      sourceDraftId: 702,
      publicationStatus: 'published',
      moderationStatus: 'approved',
      publicDisplayEligible: true,
      matchingScoringEligible: false,
      publicFields: const ProfileShowcaseDraftInput(
        selfIntro: '已经由用户确认展示的展示投影。',
        interestTags: ['慢约会', '低压表达'],
        lifestyleTags: ['常驻 Nanyang'],
        openerNote: '可以从最近的生活节奏聊起。',
      ),
      publishedAt: DateTime.utc(2026, 6, 16),
    ),
    icon: Icons.public_rounded,
    color: (t) => t.brandPrimary,
  ),
  _PublicationFixture(
    id: 'unsafe_scoring_fail_closed',
    title: 'Unsafe Scoring Payload / 评分载荷关闭',
    draftState: _draftState(
      id: 703,
      selfIntro: '测试包含不安全评分字段的载荷。',
      moderationStatus: 'approved',
    ),
    publication: const ProfileShowcasePublicationEntity(
      publicationStatus: 'unavailable',
      publicDisplayEligible: false,
      matchingScoringEligible: false,
    ),
    icon: Icons.shield_outlined,
    color: (t) => t.warning,
    error: '收到不安全评分载荷时保持不可用；不会打开展示，也不会进入推荐评分。',
  ),
  _PublicationFixture(
    id: 'api_error',
    title: 'API Error / 状态读取失败',
    draftState: _draftState(
      id: 704,
      selfIntro: '用于展示状态读取失败时的保守提示。',
      moderationStatus: 'approved',
    ),
    publication: const ProfileShowcasePublicationEntity(
      publicationStatus: 'unavailable',
      publicDisplayEligible: false,
      matchingScoringEligible: false,
    ),
    icon: Icons.error_outline_rounded,
    color: (t) => t.error,
    error: '展示状态暂不可用；私有草稿仍可继续编辑。',
  ),
];

ProfileShowcaseDraftUiState _draftState({
  required int id,
  required String selfIntro,
  required String moderationStatus,
}) {
  final input = ProfileShowcaseDraftInput(
    selfIntro: selfIntro,
    interestTags: const ['慢约会', '低压表达'],
    lifestyleTags: const ['常驻 Nanyang'],
    openerNote: '可以从最近的生活节奏聊起。',
  );

  return ProfileShowcaseDraftUiState(
    loaded: true,
    serverDraft: ProfileShowcaseDraftEntity(
      id: id,
      selfIntro: input.selfIntro,
      interestTags: input.interestTags,
      lifestyleTags: input.lifestyleTags,
      openerNote: input.openerNote,
      moderationStatus: moderationStatus,
      publicDisplayEligible: false,
      matchingScoringEligible: false,
    ),
    editor: input,
  );
}

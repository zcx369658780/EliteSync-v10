import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_tag.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/match/presentation/state/date_drop_main_chain_model.dart';
import 'package:flutter_elitesync_module/features/match/presentation/widgets/date_drop_journey_card.dart';
import 'package:flutter_elitesync_module/features/match/presentation/widgets/date_drop_main_chain_cards.dart';
import 'package:flutter_elitesync_module/features/match/presentation/widgets/date_drop_readiness_card.dart';

class LocalOnlyVisualFixturePage extends StatelessWidget {
  const LocalOnlyVisualFixturePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;

    return Scaffold(
      backgroundColor: t.browseBackground,
      appBar: AppBar(
        title: const Text('8.1 本地视觉预览'),
        backgroundColor: t.browseBackground,
        foregroundColor: t.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(t.spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _FixtureIntroCard(),
            SizedBox(height: t.spacing.md),
            const _AstroFixtureSection(),
            SizedBox(height: t.spacing.md),
            const _MatchFixtureSection(),
            SizedBox(height: t.spacing.md),
            const _MessagesFixtureSection(),
            SizedBox(height: t.spacing.md),
            const _FixtureNonClaimsCard(),
          ],
        ),
      ),
    );
  }
}

class _FixtureIntroCard extends StatelessWidget {
  const _FixtureIntroCard();

  @override
  Widget build(BuildContext context) {
    return const _SectionCard(
      marker: 'FIXTURE_OVERVIEW_TOP',
      title: '本地视觉预览 · DEBUG ONLY',
      subtitle:
          '用于 8.1 Astro / Match / Messages 视觉证据截图。以下内容是确定性的本地样例数据，不调用后端，不读取账号，不写入资料、星盘、匹配或聊天。',
      tags: ['local-only', 'dev/internal', 'deterministic sample data'],
      children: [
        _BoundaryNote(label: '不声明生产可用', body: '这个页面只帮助检查布局、层级、文案边界和动作状态。'),
        _BoundaryNote(label: '不声明运行时正确', body: '不验证登录、接口、数据库、推荐权重、星盘计算或消息持久化。'),
      ],
    );
  }
}

class _AstroFixtureSection extends StatelessWidget {
  const _AstroFixtureSection();

  @override
  Widget build(BuildContext context) {
    return const _SectionCard(
      marker: 'FIXTURE_ASTRO_BAZI_ZIWEI',
      title: 'Astro · chart-first deep pages',
      subtitle: '先看图表结构，再展开解释。样例只用于视觉层级，不代表真实星盘、八字或紫微计算。',
      tags: ['Astro overview', 'Bazi chart-first', 'Ziwei split-view'],
      children: [
        _AstroOverviewPreview(),
        SizedBox(height: 12),
        _BaziChartPreview(),
        SizedBox(height: 12),
        _ZiweiChartPreview(),
        SizedBox(height: 12),
        _ProgressiveDetailPreview(
          title: '渐进详情示例',
          body: '展开后阅读关系参考、边界说明和来源提示；收起时保留图表与关键状态。',
        ),
      ],
    );
  }
}

class _AstroOverviewPreview extends StatelessWidget {
  const _AstroOverviewPreview();

  @override
  Widget build(BuildContext context) {
    return const _SoftPanel(
      title: 'Astro overview / reference entry',
      body: '入口先说明：这些内容是关系参考，不决定关系结果，也不替代真实资料确认。',
      chips: ['关系参考', '来源边界', '不替你决定'],
    );
  }
}

class _BaziChartPreview extends StatelessWidget {
  const _BaziChartPreview();

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    const pillars = [
      ('年柱', '甲子', '木 / 水'),
      ('月柱', '丙寅', '火 / 木'),
      ('日柱', '戊辰', '土 / 土'),
      ('时柱', '庚申', '金 / 金'),
    ];

    return AppCard(
      padding: EdgeInsets.all(t.spacing.md),
      border: Border.all(color: t.brandPrimary.withValues(alpha: 0.18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _MiniHeader(title: 'Bazi four-pillar grid', label: '本地样例'),
          SizedBox(height: t.spacing.sm),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.6,
            crossAxisSpacing: t.spacing.xs,
            mainAxisSpacing: t.spacing.xs,
            children: pillars
                .map(
                  (pillar) => _MetricTile(
                    label: pillar.$1,
                    value: pillar.$2,
                    detail: pillar.$3,
                  ),
                )
                .toList(),
          ),
          SizedBox(height: t.spacing.sm),
          const _WuXingBar(),
          SizedBox(height: t.spacing.xs),
          const Text('样例不代表真实八字排盘，只验证图表优先级和信息密度。'),
        ],
      ),
    );
  }
}

class _ZiweiChartPreview extends StatelessWidget {
  const _ZiweiChartPreview();

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    const palaces = [
      '命宫',
      '兄弟',
      '夫妻',
      '子女',
      '财帛',
      '疾厄',
      '迁移',
      '仆役',
      '官禄',
      '田宅',
      '福德',
      '父母',
    ];

    return AppCard(
      padding: EdgeInsets.all(t.spacing.md),
      border: Border.all(color: t.success.withValues(alpha: 0.18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _MiniHeader(
            title: 'Ziwei split-view palace grid',
            label: '本地样例',
          ),
          SizedBox(height: t.spacing.sm),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.28,
            crossAxisSpacing: t.spacing.xs,
            mainAxisSpacing: t.spacing.xs,
            children: palaces
                .map(
                  (palace) => _PalaceTile(
                    name: palace,
                    note: palace == '命宫' ? '主星样例' : '参考',
                  ),
                )
                .toList(),
          ),
          SizedBox(height: t.spacing.xs),
          const Text('样例宫位只用于视觉检查，不声明紫微命盘真值。'),
        ],
      ),
    );
  }
}

class _MatchFixtureSection extends StatelessWidget {
  const _MatchFixtureSection();

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return _SectionCard(
      marker: 'FIXTURE_MATCH_DATE_DROP',
      title: 'Match / Date Drop · compact status',
      subtitle: '展示等待、揭晓、开场和反馈的视觉状态。所有动作都是视觉示例，不触发真实匹配或聊天。',
      tags: const ['Match top', 'Date Drop waiting', 'manual opener'],
      children: [
        const DateDropJourneyCard(
          stage: DateDropJourneyStage.waiting,
          compact: true,
        ),
        SizedBox(height: t.spacing.sm),
        const DateDropReadinessCard(
          stage: DateDropReadinessStage.reveal,
          primarySignal: '共同节奏：周末慢活动',
          secondarySignal: '边界：先理解再聊天',
          compact: true,
        ),
        SizedBox(height: t.spacing.sm),
        DateDropMainChainCard(
          model: const DateDropMainChainModel(
            state: DateDropChainState.noCandidate,
            preparationReferences: ['展示自己', '关系目标', '兴趣线索'],
            lightActions: ['完善展示自己', '安静等待揭晓'],
            openerSuggestions: ['等待揭晓后再手动编辑开场。'],
            feedbackOptions: ['稍后反馈节奏是否合适'],
            boundaryNotes: ['等待态不提前打开解释或聊天。', '不改变真实推荐权重。'],
            showcasePrompt: '确认资料表达后，等待本轮节奏推进。',
          ),
        ),
        SizedBox(height: t.spacing.sm),
        DateDropMainChainCard(
          model: const DateDropMainChainModel(
            state: DateDropChainState.revealed,
            preparationReferences: ['共同线索', '节奏差异', '可聊话题'],
            lightActions: ['阅读解释', '编辑开场草稿', '稍后反馈'],
            openerSuggestions: ['你最近也会给自己留一段慢下来的时间吗？', '这个话题只是草稿，需要你手动发送。'],
            feedbackOptions: ['想继续了解', '方向不太适合', '资料还不够'],
            boundaryNotes: ['开场建议不会自动发送。', '解释不代表关系结论。', '反馈不声明实时改权重。'],
            showcasePrompt: '揭晓后先看为什么值得了解，再决定是否聊天。',
          ),
        ),
        SizedBox(height: t.spacing.sm),
        const _DisabledActionRow(
          marker: 'FIXTURE_MATCH_MANUAL_SEND',
          label: '开场草稿 · 手动发送',
          body: '“我看到你也喜欢周末散步，可以从一个轻松问题开始。” 这里只展示草稿，不发送消息。',
        ),
      ],
    );
  }
}

class _MessagesFixtureSection extends StatelessWidget {
  const _MessagesFixtureSection();

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return _SectionCard(
      marker: 'FIXTURE_MESSAGES_COMPOSER',
      title: 'Messages · list/detail/composer',
      subtitle: '展示列表层级、会话头部、气泡可读性和手动发送边界。不连接 WebSocket，不读取或写入消息。',
      tags: const ['Messages list', 'conversation detail', 'manual send'],
      children: [
        const _ConversationListPreview(),
        SizedBox(height: t.spacing.sm),
        const _ConversationDetailPreview(),
        SizedBox(height: t.spacing.sm),
        const _DisabledActionRow(
          marker: 'FIXTURE_MESSAGES_NO_AUTO_SEND',
          label: 'Composer · 手动发送状态',
          body: '输入框展示“想回复时再发送”；fixture 中按钮禁用，明确不自动发送、不写入聊天记录。',
        ),
      ],
    );
  }
}

class _FixtureNonClaimsCard extends StatelessWidget {
  const _FixtureNonClaimsCard();

  @override
  Widget build(BuildContext context) {
    return const _SectionCard(
      marker: 'FIXTURE_NON_CLAIMS_LABEL',
      title: 'Non-claims / 边界',
      subtitle:
          'no production claim · no backend claim · no runtime claim · no truth claim · no release claim',
      tags: ['no visual PASS until captured', 'no secrets', 'no persistence'],
      children: [
        _BoundaryNote(label: 'no backend', body: '不验证接口、数据库、账号、登录态或服务器可达性。'),
        _BoundaryNote(
          label: 'no runtime',
          body: '不验证 Date Drop 生命周期、聊天发送、消息监听或持久化。',
        ),
        _BoundaryNote(
          label: 'no production',
          body: '不用于 public APK、更新、发布或 Version API 结论。',
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.marker,
    required this.title,
    required this.subtitle,
    required this.tags,
    required this.children,
  });

  final String marker;
  final String title;
  final String subtitle;
  final List<String> tags;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AppCard(
      padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            marker,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: t.textTertiary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: t.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: t.textSecondary,
              height: 1.48,
            ),
          ),
          SizedBox(height: t.spacing.sm),
          Wrap(
            spacing: t.spacing.xs,
            runSpacing: t.spacing.xs,
            children: tags.map((tag) => AppTag(label: tag)).toList(),
          ),
          SizedBox(height: t.spacing.md),
          ...children,
        ],
      ),
    );
  }
}

class _MiniHeader extends StatelessWidget {
  const _MiniHeader({required this.title, required this.label});

  final String title;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Wrap(
      spacing: t.spacing.xs,
      runSpacing: t.spacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: t.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        AppTag(label: label, variant: AppTagVariant.outlined),
      ],
    );
  }
}

class _SoftPanel extends StatelessWidget {
  const _SoftPanel({
    required this.title,
    required this.body,
    required this.chips,
  });

  final String title;
  final String body;
  final List<String> chips;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      padding: EdgeInsets.all(t.spacing.md),
      decoration: BoxDecoration(
        color: t.secondarySurface,
        borderRadius: BorderRadius.circular(t.radius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: t.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: t.spacing.xxs),
          Text(body, style: TextStyle(color: t.textSecondary, height: 1.45)),
          SizedBox(height: t.spacing.sm),
          Wrap(
            spacing: t.spacing.xs,
            runSpacing: t.spacing.xs,
            children: chips
                .map(
                  (chip) => AppTag(label: chip, variant: AppTagVariant.brand),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.detail,
  });

  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      padding: EdgeInsets.all(t.spacing.sm),
      decoration: BoxDecoration(
        color: t.secondarySurface,
        borderRadius: BorderRadius.circular(t.radius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: t.textTertiary)),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: t.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(detail, style: TextStyle(color: t.textSecondary)),
        ],
      ),
    );
  }
}

class _WuXingBar extends StatelessWidget {
  const _WuXingBar();

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    const items = [
      ('木', 0.72),
      ('火', 0.58),
      ('土', 0.82),
      ('金', 0.64),
      ('水', 0.46),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: t.spacing.xxs),
              child: Row(
                children: [
                  SizedBox(width: 24, child: Text(item.$1)),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: item.$2,
                      minHeight: 8,
                      backgroundColor: t.secondarySurface,
                      color: t.brandPrimary,
                      borderRadius: BorderRadius.circular(t.radius.pill),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _PalaceTile extends StatelessWidget {
  const _PalaceTile({required this.name, required this.note});

  final String name;
  final String note;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      padding: EdgeInsets.all(t.spacing.xs),
      decoration: BoxDecoration(
        color: t.secondarySurface,
        borderRadius: BorderRadius.circular(t.radius.sm),
        border: Border.all(color: t.overlay),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: t.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: t.spacing.xxs),
          Text(note, style: TextStyle(color: t.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}

class _ProgressiveDetailPreview extends StatelessWidget {
  const _ProgressiveDetailPreview({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: const Text('fixture progressive details'),
      children: [Align(alignment: Alignment.centerLeft, child: Text(body))],
    );
  }
}

class _DisabledActionRow extends StatelessWidget {
  const _DisabledActionRow({
    required this.marker,
    required this.label,
    required this.body,
  });

  final String marker;
  final String label;
  final String body;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      padding: EdgeInsets.all(t.spacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: t.overlay),
        borderRadius: BorderRadius.circular(t.radius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(marker, style: TextStyle(color: t.textTertiary)),
          SizedBox(height: t.spacing.xxs),
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: t.spacing.xxs),
          Text(body, style: TextStyle(color: t.textSecondary, height: 1.45)),
          SizedBox(height: t.spacing.sm),
          const AppSecondaryButton(label: 'fixture 中不可发送', onPressed: null),
        ],
      ),
    );
  }
}

class _ConversationListPreview extends StatelessWidget {
  const _ConversationListPreview();

  @override
  Widget build(BuildContext context) {
    return const _SoftPanel(
      title: 'Messages list / row hierarchy',
      body: '林夏 · Date Drop 线索已揭晓 · 最后消息：可以慢慢聊，不急着下结论。',
      chips: ['紧凑头像区', '关系上下文', '未读 2'],
    );
  }
}

class _ConversationDetailPreview extends StatelessWidget {
  const _ConversationDetailPreview();

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    const messages = [
      ('对方', '我也喜欢周末留一点空白时间。'),
      ('你', '这个点很像我，先从轻松散步聊起可以吗？'),
      ('对方', '可以，慢一点聊会更舒服。'),
    ];

    return AppCard(
      padding: EdgeInsets.all(t.spacing.md),
      border: Border.all(color: t.info.withValues(alpha: 0.18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _MiniHeader(title: 'Conversation detail', label: 'manual-send'),
          SizedBox(height: t.spacing.sm),
          const Text('关系上下文：Date Drop 已揭晓 · 低压开场中'),
          SizedBox(height: t.spacing.sm),
          ...messages.map(
            (message) => Align(
              alignment: message.$1 == '你'
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 280),
                margin: EdgeInsets.only(bottom: t.spacing.xs),
                padding: EdgeInsets.all(t.spacing.sm),
                decoration: BoxDecoration(
                  color: message.$1 == '你'
                      ? t.brandPrimary
                      : t.secondarySurface,
                  borderRadius: BorderRadius.circular(t.radius.md),
                ),
                child: Text(
                  message.$2,
                  style: TextStyle(
                    color: message.$1 == '你' ? Colors.white : t.textPrimary,
                    height: 1.42,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BoundaryNote extends StatelessWidget {
  const _BoundaryNote({required this.label, required this.body});

  final String label;
  final String body;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Padding(
      padding: EdgeInsets.only(bottom: t.spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 18, color: t.success),
          SizedBox(width: t.spacing.xs),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: t.textSecondary,
                  height: 1.45,
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: TextStyle(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(text: body),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

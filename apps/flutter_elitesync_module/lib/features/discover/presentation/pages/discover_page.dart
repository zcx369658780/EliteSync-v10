import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/components/feedback/app_feedback.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/browse_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_empty_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/highlight_text.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/discover/presentation/controllers/discover_feed_controller.dart';
import 'package:flutter_elitesync_module/features/home/data/mapper/home_mapper.dart';
import 'package:flutter_elitesync_module/features/home/domain/entities/home_feed_entity.dart';
import 'package:flutter_elitesync_module/features/home/presentation/copy/public_content_copy.dart';
import 'package:flutter_elitesync_module/features/home/presentation/providers/home_provider.dart';

String normalizeDiscoverVisibleCopy(String value) =>
    normalizePublicContentCopy(value);

class DiscoverPage extends ConsumerStatefulWidget {
  const DiscoverPage({super.key});

  @override
  ConsumerState<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends ConsumerState<DiscoverPage>
    with AutomaticKeepAliveClientMixin<DiscoverPage> {
  late final DiscoverFeedController _controller;

  @override
  void initState() {
    super.initState();
    final remote = ref.read(homeRemoteDataSourceProvider);
    _controller = DiscoverFeedController(
      remote: remote,
      mapper: const HomeMapper(),
    )..addListener(_onControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _controller.initialize(),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _showDiscoverActionSheet(HomeFeedEntity item) async {
    final t = context.appTokens;
    final keywords = _discoverKeywords(item);
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              t.spacing.pageHorizontal,
              0,
              t.spacing.pageHorizontal,
              t.spacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '内容说明',
                  style: Theme.of(sheetContext).textTheme.labelLarge?.copyWith(
                    color: t.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: t.spacing.xxs),
                Text(
                  normalizeDiscoverVisibleCopy(item.title),
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: t.spacing.xs),
                Text(
                  '可以先看看主题和分享，再决定是否继续了解。',
                  style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                    color: t.textSecondary,
                    height: 1.45,
                  ),
                ),
                if (keywords.isNotEmpty) ...[
                  SizedBox(height: t.spacing.sm),
                  Text(
                    '可继续留意：${keywords.take(3).join('、')}',
                    style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
                SizedBox(height: t.spacing.md),
                AppPrimaryButton(
                  label: '查看详情',
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    context.push(
                      '${AppRouteNames.contentDetail}/${item.id}',
                      extra: item,
                    );
                  },
                ),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      tapTargetSize: MaterialTapTargetSize.padded,
                    ),
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      AppFeedback.showInfo(context, '已先收起这条内容，稍后再看也可以');
                    },
                    child: const Text('稍后再看'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = _controller.state;
    return BrowseScaffold(
      header: const _DiscoverHeader(),
      body: state.isLoading
          ? const AppLoadingSkeleton(lines: 8)
          : state.error != null
          ? AppErrorState(
              title: '发现内容加载失败',
              description: '暂时无法加载发现内容，请稍后重试。',
              retryLabel: '重新加载',
              onRetry: _controller.loadInitial,
            )
          : RefreshIndicator(
              onRefresh: _controller.loadInitial,
              child: _DiscoverContent(
                items: state.items,
                onOpenItem: (item) => context.push(
                  '${AppRouteNames.contentDetail}/${item.id}',
                  extra: item,
                ),
                onExplainItem: _showDiscoverActionSheet,
              ),
            ),
    );
  }

  List<String> _discoverKeywords(HomeFeedEntity item) {
    final keywords = <String>[
      ...item.tags
          .map((e) => normalizeDiscoverVisibleCopy(e).trim())
          .where((e) => e.isNotEmpty)
          .take(3),
    ];
    if (keywords.isEmpty && item.title.trim().isNotEmpty) {
      keywords.add(normalizeDiscoverVisibleCopy(item.title).trim());
    }
    return keywords;
  }

  @override
  bool get wantKeepAlive => true;
}

class _DiscoverHeader extends StatelessWidget {
  const _DiscoverHeader();

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
      decoration: BoxDecoration(
        color: t.browseSurface,
        borderRadius: BorderRadius.circular(t.radius.xl),
        border: Border.all(color: t.browseBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '发现',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: t.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            '浏览少量关系与活动灵感，感兴趣时再看详情。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscoverContent extends StatelessWidget {
  const _DiscoverContent({
    required this.items,
    required this.onOpenItem,
    required this.onExplainItem,
  });

  final List<HomeFeedEntity> items;
  final ValueChanged<HomeFeedEntity> onOpenItem;
  final ValueChanged<HomeFeedEntity> onExplainItem;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final visibleItems = items.take(3).toList();
    final remainingItems = visibleItems.skip(1).toList();
    return ListView(
      padding: EdgeInsets.fromLTRB(0, t.spacing.xs, 0, t.spacing.huge),
      children: [
        if (visibleItems.isNotEmpty) ...[
          _RelationshipInspirationCard(
            item: visibleItems.first,
            onOpenItem: onOpenItem,
            onExplainItem: onExplainItem,
          ),
          SizedBox(height: t.spacing.sm),
        ],
        if (visibleItems.isEmpty)
          const AppEmptyState(
            title: '暂时没有新的内容',
            description: '暂时没有可浏览的内容，可以稍后再回来看看。',
          )
        else if (remainingItems.isNotEmpty) ...[
          _SectionTitle(title: '其他灵感'),
          SizedBox(height: t.spacing.sm),
          for (var i = 0; i < remainingItems.length; i++) ...[
            _DiscoverCard(
              itemId: remainingItems[i].id,
              title: remainingItems[i].title,
              subtitle: remainingItems[i].summary,
              accent: _accentOf(i),
              icon: _iconOf(i),
              onOpen: () => onOpenItem(remainingItems[i]),
              onExplain: () => onExplainItem(remainingItems[i]),
            ),
            SizedBox(height: t.spacing.sm),
          ],
        ],
      ],
    );
  }
}

class _RelationshipInspirationCard extends StatelessWidget {
  const _RelationshipInspirationCard({
    required this.item,
    required this.onOpenItem,
    required this.onExplainItem,
  });

  final HomeFeedEntity item;
  final ValueChanged<HomeFeedEntity> onOpenItem;
  final ValueChanged<HomeFeedEntity> onExplainItem;

  @override
  Widget build(BuildContext context) {
    return AppInfoSectionCard(
      title: '先看一个主题',
      subtitle: '按兴趣打开一个关系话题',
      leadingIcon: Icons.favorite_border_rounded,
      child: _InlineInspirationPreview(
        itemId: item.id,
        title: item.title,
        subtitle: item.summary,
        onOpen: () => onOpenItem(item),
        onExplain: () => onExplainItem(item),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: t.textPrimary,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _InlineInspirationPreview extends StatelessWidget {
  const _InlineInspirationPreview({
    required this.itemId,
    required this.title,
    required this.subtitle,
    required this.onOpen,
    required this.onExplain,
  });

  final String itemId;
  final String title;
  final String subtitle;
  final VoidCallback onOpen;
  final VoidCallback onExplain;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Material(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: t.spacing.xxs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    normalizeDiscoverVisibleCopy(title),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: t.spacing.xxs),
                  Text(
                    normalizeDiscoverVisibleCopy(subtitle),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _ItemActions(
            itemId: itemId,
            itemTitle: normalizeDiscoverVisibleCopy(title),
            onOpen: onOpen,
            onExplain: onExplain,
          ),
        ],
      ),
    );
  }
}

class _DiscoverCard extends StatelessWidget {
  const _DiscoverCard({
    required this.itemId,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.icon,
    required this.onOpen,
    required this.onExplain,
  });

  final String itemId;
  final String title;
  final String subtitle;
  final Color accent;
  final IconData icon;
  final VoidCallback onOpen;
  final VoidCallback onExplain;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final displayTitle = normalizeDiscoverVisibleCopy(title);
    final displaySubtitle = normalizeDiscoverVisibleCopy(subtitle);
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(t.spacing.cardPadding),
        decoration: BoxDecoration(
          color: t.browseSurface,
          borderRadius: BorderRadius.circular(t.radius.lg),
          border: Border.all(color: t.browseBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Row(
                children: [
                  ExcludeSemantics(
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: accent.withValues(alpha: 0.20),
                      ),
                      child: Icon(icon, color: accent),
                    ),
                  ),
                  SizedBox(width: t.spacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HighlightText(
                          text: displayTitle,
                          query: '',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: t.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                          highlightStyle: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: t.brandPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        SizedBox(height: t.spacing.xxs),
                        Text(
                          displaySubtitle,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: t.textSecondary, height: 1.35),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _ItemActions(
              itemId: itemId,
              itemTitle: displayTitle,
              onOpen: onOpen,
              onExplain: onExplain,
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemActions extends StatelessWidget {
  const _ItemActions({
    required this.itemId,
    required this.itemTitle,
    required this.onOpen,
    required this.onExplain,
  });

  final String itemId;
  final String itemTitle;
  final VoidCallback onOpen;
  final VoidCallback onExplain;

  @override
  Widget build(BuildContext context) {
    final stackActions = MediaQuery.textScalerOf(context).scale(1) > 1.5;
    final foreground = context.appTokens.textPrimary;
    final actions = [
      TextButton(
        key: ValueKey('discover-open-$itemId'),
        style: TextButton.styleFrom(
          foregroundColor: foreground,
          minimumSize: const Size.fromHeight(48),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
        onPressed: onOpen,
        child: Semantics(
          label: '查看详情：$itemTitle',
          excludeSemantics: true,
          child: const Text('查看详情'),
        ),
      ),
      TextButton(
        key: ValueKey('discover-explain-$itemId'),
        style: TextButton.styleFrom(
          foregroundColor: foreground,
          minimumSize: const Size.fromHeight(48),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
        onPressed: onExplain,
        child: Semantics(
          label: '内容说明：$itemTitle',
          excludeSemantics: true,
          child: const Text('内容说明'),
        ),
      ),
    ];
    if (stackActions) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: actions,
      );
    }
    return Row(
      children: [for (final action in actions) Expanded(child: action)],
    );
  }
}

Color _accentOf(int index) {
  const colors = [Color(0xFF7CB8FF), Color(0xFF79D7C9), Color(0xFF9A8CFF)];
  return colors[index % colors.length];
}

IconData _iconOf(int index) {
  const icons = [
    Icons.lightbulb_outline_rounded,
    Icons.auto_awesome_rounded,
    Icons.bookmark_border_rounded,
  ];
  return icons[index % icons.length];
}

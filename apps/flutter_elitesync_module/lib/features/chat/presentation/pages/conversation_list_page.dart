import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/design_system/components/brand/browse_top_search_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/brand/category_tab_strip.dart';
import 'package:flutter_elitesync_module/design_system/components/feedback/app_feedback.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/browse_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_empty_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/conversation_entity.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/chat_route_state.dart';
import 'package:flutter_elitesync_module/features/chat/domain/utils/conversation_snapshot_utils.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/providers/chat_providers.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/widgets/conversation_list_item.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/performance_mode_provider.dart';

class ConversationListPage extends ConsumerStatefulWidget {
  const ConversationListPage({super.key});

  @override
  ConsumerState<ConversationListPage> createState() =>
      _ConversationListPageState();
}

class _ConversationListPageState extends ConsumerState<ConversationListPage>
    with AutomaticKeepAliveClientMixin<ConversationListPage> {
  int _tabIndex = 0;
  final ValueNotifier<String> _searchQueryNotifier = ValueNotifier<String>('');
  static const _tabs = ['全部', '未读', '已读'];
  final ScrollController _listController = ScrollController();
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  Timer? _searchUiDebounce;
  List<String> _recentSearches = const [];
  bool _searchFocused = false;
  bool _quickRefreshing = false;
  List<ConversationEntity> _snapshotItems = const [];
  bool _snapshotHydrated = false;
  final Map<int, double> _tabScrollOffsets = <int, double>{};
  List<ConversationEntity> _cachedSourceItems = const [];
  String _cachedFilterQuery = '';
  int _cachedTabIndex = 0;
  List<ConversationEntity> _cachedFilteredItems = const [];
  final Map<String, String> _searchIndex = <String, String>{};
  bool _latestHasUnread = true;
  bool _normalizingHiddenUnreadTab = false;

  void _openConversation(ConversationEntity item) {
    try {
      final routeState = ChatRouteState.fromConversation(item);
      context.push(
        '${AppRouteNames.chatRoom}/${routeState.canonicalSegment}',
        extra: routeState,
      );
    } on ArgumentError {
      AppFeedback.showInfo(context, '当前会话暂时无法打开，请刷新后重试');
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode()
      ..addListener(() {
        if (!mounted) return;
        setState(() => _searchFocused = _searchFocusNode.hasFocus);
      });
    _loadUiPrefs();
    _loadSearchHistory();
    _loadConversationSnapshot();
  }

  Future<void> _loadUiPrefs() async {
    final local = ref.read(localStorageProvider);
    final savedTab = await local.getInt(CacheKeys.messagesSelectedTab);
    if (!mounted) return;
    setState(() {
      _tabIndex = (savedTab ?? 0).clamp(0, _tabs.length - 1);
    });
  }

  Future<void> _saveUiPrefs() async {
    final local = ref.read(localStorageProvider);
    await local.setInt(CacheKeys.messagesSelectedTab, _tabIndex);
  }

  Future<void> _loadSearchHistory() async {
    final local = ref.read(localStorageProvider);
    final raw = await local.getString(CacheKeys.messagesSearchHistory);
    if (!mounted || raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        setState(() {
          _recentSearches = decoded
              .map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .take(8)
              .toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _addSearchHistory(String term) async {
    final t = term.trim();
    if (t.isEmpty) return;
    final next = [
      t,
      ..._recentSearches.where((e) => e.toLowerCase() != t.toLowerCase()),
    ].take(8).toList();
    setState(() => _recentSearches = next);
    await ref
        .read(localStorageProvider)
        .setString(CacheKeys.messagesSearchHistory, jsonEncode(next));
  }

  void _onSearchChanged(String value) {
    final v = value.trim();
    _searchUiDebounce?.cancel();
    _searchUiDebounce = Timer(const Duration(milliseconds: 90), () {
      if (!mounted || _searchQueryNotifier.value == v) return;
      _searchQueryNotifier.value = v;
    });
  }

  Future<void> _clearSearch() async {
    _searchUiDebounce?.cancel();
    _searchController.clear();
    _searchQueryNotifier.value = '';
  }

  Future<void> _onSearchSubmitted(String value) async {
    final v = value.trim();
    if (v.isEmpty) return;
    await _addSearchHistory(v);
    _searchFocusNode.unfocus();
  }

  @override
  void dispose() {
    _searchUiDebounce?.cancel();
    _searchQueryNotifier.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _listController.dispose();
    super.dispose();
  }

  void _restoreScrollForTab(int tab) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_listController.positions.length != 1) return;
      final raw = _tabScrollOffsets[tab] ?? 0;
      final target = raw.clamp(0, _listController.position.maxScrollExtent);
      final liteMode =
          ref.read(performanceLiteModeProvider).asData?.value ?? false;
      final t = context.appTokens;
      _listController.animateTo(
        target.toDouble(),
        duration: liteMode ? t.motionFast : t.motionNormal,
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _normalizeHiddenUnreadTab(bool hasUnread) {
    _latestHasUnread = hasUnread;
    if (hasUnread || _tabIndex != 1 || _normalizingHiddenUnreadTab) return;
    _normalizingHiddenUnreadTab = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _normalizingHiddenUnreadTab = false;
      if (!mounted || _latestHasUnread || _tabIndex != 1) return;
      setState(() => _tabIndex = 0);
      unawaited(_saveUiPrefs());
    });
  }

  List<ConversationEntity> _applyFilter(List<ConversationEntity> input) {
    final q = _searchQueryNotifier.value.trim().toLowerCase();
    final hasUnread = input.any((item) => item.unread > 0);
    final effectiveTabIndex = !hasUnread && _tabIndex == 1 ? 0 : _tabIndex;
    if (identical(input, _cachedSourceItems) &&
        q == _cachedFilterQuery &&
        effectiveTabIndex == _cachedTabIndex) {
      return _cachedFilteredItems;
    }
    _cachedSourceItems = input;
    _cachedFilterQuery = q;
    _cachedTabIndex = effectiveTabIndex;

    Iterable<ConversationEntity> current = input;
    final ids = input.map((e) => e.id).toSet();
    _searchIndex.removeWhere((key, _) => !ids.contains(key));
    for (final item in input) {
      _searchIndex[item.id] = '${item.name} ${item.lastMessage}'.toLowerCase();
    }

    if (effectiveTabIndex == 1) current = current.where((e) => e.unread > 0);
    if (effectiveTabIndex == 2) current = current.where((e) => e.unread == 0);

    if (q.isNotEmpty) {
      current = current.where((e) => (_searchIndex[e.id] ?? '').contains(q));
    }
    final filtered = current.toList();
    _cachedFilteredItems = filtered;
    return filtered;
  }

  Future<void> _quickRefresh() async {
    if (_quickRefreshing) return;
    setState(() => _quickRefreshing = true);
    try {
      ref.invalidate(conversationListProvider);
      final state = await ref.read(conversationListProvider.future);
      if ((state.error ?? '').isNotEmpty) {
        if (mounted) AppFeedback.showInfo(context, '会话更新失败，请稍后重试');
        return;
      }
      await _saveConversationSnapshot(state.items);
      if (!mounted) return;
      AppFeedback.showInfo(context, '已刷新会话列表');
    } finally {
      if (mounted) {
        setState(() => _quickRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final async = ref.watch(conversationListProvider);
    return async.when(
      loading: () => _snapshotHydrated
          ? _buildSnapshotLoadingScaffold(context)
          : const AppLoadingSkeleton(lines: 7),
      error: (e, _) => AppErrorState(
        title: '会话加载失败',
        description: '暂时无法更新会话。你可以重试，或先回到本轮慢约会。',
        retryLabel: '重新加载',
        onRetry: () => ref.invalidate(conversationListProvider),
      ),
      data: (state) {
        final liteMode =
            ref.watch(performanceLiteModeProvider).asData?.value ?? false;
        if (state.items.isNotEmpty) {
          _snapshotItems = state.items;
          _snapshotHydrated = true;
          unawaited(_saveConversationSnapshot(state.items));
        }
        if ((state.error ?? '').isNotEmpty && _snapshotHydrated) {
          return _buildSnapshotLoadingScaffold(
            context,
            refreshUnavailable: true,
          );
        }
        if ((state.error ?? '').isNotEmpty && !_snapshotHydrated) {
          return AppErrorState(
            title: '会话加载失败',
            description: '暂时无法取得当前会话，请重试。',
            retryLabel: '重新加载',
            onRetry: () => ref.invalidate(conversationListProvider),
          );
        }
        return ValueListenableBuilder<String>(
          valueListenable: _searchQueryNotifier,
          builder: (context, searchQuery, _) {
            final t = context.appTokens;
            final showRecentChips = _searchFocused && searchQuery.isEmpty;
            if (state.items.isEmpty && _snapshotHydrated) {
              _snapshotItems = const [];
              _snapshotHydrated = false;
              unawaited(
                ref
                    .read(localStorageProvider)
                    .remove(CacheKeys.messagesConversationSnapshot),
              );
            }
            final sourceItems = state.items;
            final filtered = _applyFilter(sourceItems);
            final hasUnread = sourceItems.any((item) => item.unread > 0);
            final hasRead = sourceItems.any((item) => item.unread == 0);
            final showSearch = sourceItems.length > 1;
            final showTabs = hasUnread && hasRead;
            _normalizeHiddenUnreadTab(hasUnread);
            final visibleTabs = hasUnread ? _tabs : const ['全部', '已读'];
            final visibleTabIndex = hasUnread
                ? _tabIndex
                : (_tabIndex == 2 ? 1 : 0);
            final hasAnyConversations = sourceItems.isNotEmpty;
            final hasActiveFilter =
                (hasUnread ? _tabIndex : (_tabIndex == 1 ? 0 : _tabIndex)) !=
                    0 ||
                searchQuery.trim().isNotEmpty;
            return BrowseScaffold(
              header: Column(
                children: [
                  if (showSearch)
                    BrowseTopSearchBar(
                      hint: '搜索会话、昵称、关键词',
                      editable: true,
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onChanged: _onSearchChanged,
                      onSubmitted: (v) => _onSearchSubmitted(v),
                      onClear: _clearSearch,
                      onRightActionTap: _quickRefresh,
                      rightIcon: _quickRefreshing
                          ? Icons.hourglass_top_rounded
                          : Icons.refresh_rounded,
                    ),
                  AnimatedSize(
                    duration: liteMode ? t.motionFast : t.motionNormal,
                    curve: Curves.easeOutCubic,
                    child: searchQuery.isNotEmpty
                        ? Column(
                            children: [
                              SizedBox(height: t.spacing.xs),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '已筛选关键词: $searchQuery（找到 ${filtered.length} 条）',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: t.textSecondary),
                                    ),
                                  ),
                                  AppChoiceChip(
                                    label: '清除',
                                    leading: const Icon(Icons.close_rounded),
                                    onTap: _clearSearch,
                                  ),
                                ],
                              ),
                            ],
                          )
                        : (showRecentChips && _recentSearches.isNotEmpty)
                        ? Column(
                            children: [
                              SizedBox(height: t.spacing.xs),
                              SizedBox(
                                height: 32,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _recentSearches.length,
                                  separatorBuilder: (_, index) =>
                                      SizedBox(width: t.spacing.xs),
                                  itemBuilder: (context, index) {
                                    final term = _recentSearches[index];
                                    return AppChoiceChip(
                                      label: term,
                                      onTap: () {
                                        _searchController.text = term;
                                        _searchController.selection =
                                            TextSelection.collapsed(
                                              offset: term.length,
                                            );
                                        _onSearchChanged(term);
                                        _searchFocusNode.unfocus();
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                  if (showTabs) ...[
                    SizedBox(height: t.spacing.sm),
                    CategoryTabStrip(
                      tabs: visibleTabs,
                      selectedIndex: visibleTabIndex,
                      onSelected: (index) {
                        final nextTabId = hasUnread
                            ? index
                            : (index == 0 ? 0 : 2);
                        setState(() {
                          _searchFocusNode.unfocus();
                          if (_listController.positions.length == 1) {
                            _tabScrollOffsets[_tabIndex] =
                                _listController.offset;
                          }
                          _tabIndex = nextTabId;
                          _saveUiPrefs();
                          _restoreScrollForTab(nextTabId);
                        });
                      },
                    ),
                  ],
                ],
              ),
              body: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(conversationListProvider);
                  await ref.read(conversationListProvider.future);
                },
                child: AnimatedSwitcher(
                  duration: liteMode ? t.motionFast : t.motionNormal,
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: filtered.isEmpty
                      ? ListView(
                          key: const ValueKey('messages-empty'),
                          children: [
                            const SizedBox(height: 80),
                            if (hasAnyConversations && hasActiveFilter)
                              AppEmptyState(
                                title: '没有符合当前筛选的会话',
                                description: '可清空筛选，或回到全部会话查看本轮慢约会对话。',
                                actionLabel: '清空筛选',
                                onAction: () {
                                  _tabIndex = 0;
                                  _clearSearch();
                                  setState(() {});
                                },
                              )
                            else
                              AppEmptyState(
                                title: '还没有可聊对象',
                                description: '互相确认慢约会后，对话会出现在这里。可以先回到本轮慢约会。',
                                actionLabel: '回到慢约会',
                                onAction: () => context.go(AppRouteNames.match),
                              ),
                          ],
                        )
                      : ListView.separated(
                          key: ValueKey(
                            'messages-list-$_tabIndex-${searchQuery.isEmpty ? "none" : "query"}',
                          ),
                          controller: _listController,
                          padding: EdgeInsets.only(
                            top: t.spacing.xs,
                            bottom: t.spacing.huge,
                          ),
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: t.spacing.xs),
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            return RepaintBoundary(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: t.browseSurface,
                                  borderRadius: BorderRadius.circular(
                                    t.radius.lg,
                                  ),
                                  border: Border.all(color: t.browseBorder),
                                ),
                                child: ConversationListItem(
                                  item: item,
                                  highlightQuery: searchQuery,
                                  onTap: () => _openConversation(item),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSnapshotLoadingScaffold(
    BuildContext context, {
    bool refreshUnavailable = false,
  }) {
    final t = context.appTokens;
    // Retained rows support continuity, but their unread counters are not
    // current truth while the provider refresh is still pending.
    final sourceItems = _snapshotItems
        .map(
          (item) => ConversationEntity(
            id: item.id,
            name: item.name,
            lastMessage: item.lastMessage,
            lastTime: item.lastTime,
            unread: 0,
          ),
        )
        .toList(growable: false);
    final filtered = _applyFilter(sourceItems);
    _normalizeHiddenUnreadTab(false);
    const visibleTabs = ['全部', '已读'];
    final visibleTabIndex = _tabIndex == 2 ? 1 : 0;
    final hasAnyConversations = sourceItems.isNotEmpty;
    final showSearch = sourceItems.length > 1;
    final hasActiveFilter =
        (_tabIndex == 1 ? 0 : _tabIndex) != 0 ||
        _searchQueryNotifier.value.trim().isNotEmpty;

    return BrowseScaffold(
      header: Column(
        children: [
          if (showSearch)
            BrowseTopSearchBar(
              hint: '搜索上次会话（离线内容）',
              editable: true,
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: _onSearchChanged,
              onSubmitted: (v) => _onSearchSubmitted(v),
              onClear: _clearSearch,
              onRightActionTap: _quickRefresh,
              rightIcon: Icons.refresh_rounded,
            ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(t.spacing.sm),
            decoration: BoxDecoration(
              color: t.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(t.radius.lg),
              border: Border.all(color: t.warning.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  refreshUnavailable ? '当前无法更新 · 以下为上次内容' : '正在更新 · 以下为上次内容',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: t.warning,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: t.spacing.xxs),
                Text(
                  '离线内容仅供参考；未读状态不是当前服务器事实。',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
                ),
                TextButton.icon(
                  onPressed: _quickRefresh,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('重新获取当前会话'),
                ),
              ],
            ),
          ),
          if (sourceItems.length > 1) ...[
            SizedBox(height: t.spacing.xs),
            CategoryTabStrip(
              tabs: visibleTabs,
              selectedIndex: visibleTabIndex,
              onSelected: (index) {
                final nextTabId = index == 0 ? 0 : 2;
                setState(() {
                  _searchFocusNode.unfocus();
                  if (_listController.positions.length == 1) {
                    _tabScrollOffsets[_tabIndex] = _listController.offset;
                  }
                  _tabIndex = nextTabId;
                  _saveUiPrefs();
                  _restoreScrollForTab(nextTabId);
                });
              },
            ),
          ],
        ],
      ),
      body: filtered.isEmpty
          ? ListView(
              children: [
                const SizedBox(height: 80),
                if (hasAnyConversations && hasActiveFilter)
                  AppEmptyState(
                    title: '没有符合当前筛选的会话',
                    description: '可清空筛选，或回到全部会话查看本轮慢约会对话。',
                    actionLabel: '清空筛选',
                    onAction: () {
                      _tabIndex = 0;
                      _clearSearch();
                      setState(() {});
                    },
                  )
                else
                  AppEmptyState(
                    title: '还没有可聊对象',
                    description: '互相确认慢约会后，对话会出现在这里。可以先回到本轮慢约会。',
                    actionLabel: '回到慢约会',
                    onAction: () => context.go(AppRouteNames.match),
                  ),
              ],
            )
          : ListView.separated(
              controller: _listController,
              padding: EdgeInsets.only(
                top: t.spacing.xs,
                bottom: t.spacing.huge,
              ),
              itemCount: filtered.length,
              separatorBuilder: (context, index) =>
                  SizedBox(height: t.spacing.xs),
              itemBuilder: (context, index) {
                final item = filtered[index];
                return RepaintBoundary(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: t.browseSurface,
                      borderRadius: BorderRadius.circular(t.radius.lg),
                      border: Border.all(color: t.browseBorder),
                    ),
                    child: Semantics(
                      container: true,
                      label: '${item.name}，上次会话内容，仅供参考',
                      child: ExcludeSemantics(
                        child: IgnorePointer(
                          child: ConversationListItem(
                            item: item,
                            highlightQuery: _searchQueryNotifier.value,
                            onTap: () {},
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _loadConversationSnapshot() async {
    final env = ref.read(appEnvProvider);
    final raw = await ref
        .read(localStorageProvider)
        .getString(CacheKeys.messagesConversationSnapshot);
    if (!mounted || raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;
      final list = decoded
          .whereType<Map<String, dynamic>>()
          .map(decodeConversationSnapshotItem)
          .toList();
      final sanitized = sanitizeConversationSnapshot(
        list,
        allowMockIds: env.useMockChat,
      );
      if (sanitized.isEmpty) {
        await ref
            .read(localStorageProvider)
            .remove(CacheKeys.messagesConversationSnapshot);
        return;
      }
      setState(() {
        _snapshotItems = sanitized;
        _snapshotHydrated = true;
      });
    } catch (_) {}
  }

  Future<void> _saveConversationSnapshot(List<ConversationEntity> items) async {
    final env = ref.read(appEnvProvider);
    final sanitized = sanitizeConversationSnapshot(
      items,
      allowMockIds: env.useMockChat,
    );
    if (sanitized.isEmpty) {
      await ref
          .read(localStorageProvider)
          .remove(CacheKeys.messagesConversationSnapshot);
      return;
    }
    final payload = sanitized.map(encodeConversationSnapshotItem).toList();
    await ref
        .read(localStorageProvider)
        .setString(CacheKeys.messagesConversationSnapshot, jsonEncode(payload));
  }

  @override
  bool get wantKeepAlive => true;
}

// Retained temporarily for source compatibility with downstream forks.
// ignore: unused_element
String _notificationEntryLabel(int? unread) {
  if (unread == null || unread <= 0 || unread > 20) return '通知中心';
  return '通知 $unread';
}

// ignore: unused_element
class _MessagesOverviewStatusCard extends StatelessWidget {
  const _MessagesOverviewStatusCard({
    required this.conversationCount,
    required this.unreadCount,
    required this.notificationLabel,
    required this.onFlowTap,
    required this.onMatchTap,
    required this.onNotificationTap,
    // ignore: unused_element_parameter
    this.isRefreshing = false,
    // ignore: unused_element_parameter
    this.statusOverride,
  });

  final int conversationCount;
  final int unreadCount;
  final String notificationLabel;
  final bool isRefreshing;
  final String? statusOverride;
  final VoidCallback onFlowTap;
  final VoidCallback onMatchTap;
  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final theme = Theme.of(context);
    final statusText =
        statusOverride ??
        (isRefreshing
            ? '正在更新 · 显示上次内容'
            : (unreadCount > 0 ? '$unreadCount 条未读' : '暂无未读'));

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(t.spacing.sm),
      decoration: BoxDecoration(
        color: t.browseSurface,
        borderRadius: BorderRadius.circular(t.radius.lg),
        border: Border.all(color: t.browseBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(t.radius.md),
                  gradient: LinearGradient(
                    colors: [
                      t.brandPrimary.withValues(alpha: 0.9),
                      t.brandSecondary.withValues(alpha: 0.72),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              SizedBox(width: t.spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '本轮慢约会对话',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: t.spacing.xxs),
                    Text(
                      isRefreshing ? '上次内容仅供参考' : '选择一段对话继续了解',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: t.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _MessagesStatusPill(
                label: statusText,
                icon: isRefreshing
                    ? Icons.sync_rounded
                    : (unreadCount > 0
                          ? Icons.mark_chat_unread_rounded
                          : Icons.check_circle_outline_rounded),
                highlighted: unreadCount > 0 || isRefreshing,
              ),
            ],
          ),
          SizedBox(height: t.spacing.sm),
          Text(
            isRefreshing
                ? '上次共有 $conversationCount 条会话；更新完成前，不把未读数量视为当前状态。'
                : '共 $conversationCount 条会话 · 消息由你确认后手动发送',
            style: theme.textTheme.bodySmall?.copyWith(color: t.textSecondary),
          ),
          SizedBox(height: t.spacing.xs),
          Wrap(
            spacing: t.spacing.xs,
            runSpacing: t.spacing.xs,
            children: [
              TextButton.icon(
                onPressed: onFlowTap,
                icon: const Icon(Icons.info_outline_rounded, size: 18),
                label: const Text('会话说明'),
              ),
              TextButton.icon(
                onPressed: onNotificationTap,
                icon: const Icon(Icons.notifications_none_rounded, size: 18),
                label: Text(notificationLabel),
              ),
              TextButton.icon(
                onPressed: onMatchTap,
                icon: const Icon(Icons.favorite_outline_rounded, size: 18),
                label: const Text('去匹配'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MessagesStatusPill extends StatelessWidget {
  const _MessagesStatusPill({
    required this.label,
    required this.icon,
    required this.highlighted,
  });

  final String label;
  final IconData icon;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final color = highlighted ? t.brandPrimary : t.textTertiary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: highlighted ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

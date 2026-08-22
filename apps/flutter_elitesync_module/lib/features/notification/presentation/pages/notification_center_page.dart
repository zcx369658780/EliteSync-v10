import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/chat_route_state.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/providers/chat_providers.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/components/feedback/app_feedback.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/browse_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/core/telemetry/frontend_telemetry.dart';
import 'package:flutter_elitesync_module/features/notification/domain/entities/notification_item_entity.dart';
import 'package:flutter_elitesync_module/features/notification/presentation/providers/notification_provider.dart';

class NotificationCenterPage extends ConsumerStatefulWidget {
  const NotificationCenterPage({super.key});

  @override
  ConsumerState<NotificationCenterPage> createState() =>
      _NotificationCenterPageState();
}

class _NotificationCenterPageState
    extends ConsumerState<NotificationCenterPage> {
  String _categoryLabel(String kind) {
    return switch (kind) {
      'message' ||
      'rtc_call_invite' ||
      'rtc_call_accepted' ||
      'rtc_call_rejected' ||
      'rtc_call_missed' ||
      'rtc_call_ended' => '回到聊天',
      'match_like' || 'match_success' => '慢约会提醒',
      _ => '反馈与资料准备',
    };
  }

  String _kindLabel(String kind) {
    return switch (kind) {
      'message' => '继续聊天',
      'status_like' || 'status_comment' => '资料回流',
      'match_like' || 'match_success' => '本轮进度',
      'rtc_call_invite' ||
      'rtc_call_accepted' ||
      'rtc_call_rejected' ||
      'rtc_call_missed' ||
      'rtc_call_ended' => '聊天节奏',
      _ => '准备提醒',
    };
  }

  String _actionLabel(NotificationItemEntity item) {
    if (item.routeName.trim().isEmpty) return '仅标记已读';
    return switch (item.kind) {
      'message' => '回到聊天',
      'status_like' || 'status_comment' => '查看资料提醒',
      'match_like' || 'match_success' => '查看本轮进度',
      'rtc_call_invite' => '回到聊天节奏',
      'rtc_call_missed' || 'rtc_call_rejected' || 'rtc_call_ended' => '查看聊天结果',
      _ => '打开',
    };
  }

  int _intRouteArg(String key, NotificationItemEntity item) {
    final value = item.routeArgs[key];
    if (value is int) return value;
    if (value is num) {
      if (!value.isFinite || value != value.truncateToDouble()) return 0;
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _routeHint(NotificationItemEntity item) {
    final routeName = item.routeName.trim();
    if (routeName.isEmpty) return '无跳转目标，可先标记已读。';
    return switch (routeName) {
      'chat_room' => '回到这段对话，继续手动编辑草稿。',
      'status_author' => '回到对方资料，看看是否需要补充表达。',
      'match_detail' || 'match_result' || 'match_intention' => '回到本轮慢约会进度。',
      'questionnaire_history' => '回到问卷记录，确认自己的准备状态。',
      'content_detail' => '回到相关内容，继续查看提醒来源。',
      'rtc_call' => '回到聊天节奏相关页面。',
      'settings' => '回到设置与帮助入口。',
      'social_baseline' => '回到资料准备与反馈入口。',
      _ => '暂不支持该跳转目标。',
    };
  }

  IconData _iconOf(String kind) {
    return switch (kind) {
      'message' => Icons.chat_bubble_outline,
      'status_like' => Icons.favorite_border,
      'status_comment' => Icons.mode_comment_outlined,
      'match_like' => Icons.waving_hand_outlined,
      'match_success' => Icons.favorite_rounded,
      'rtc_call_invite' => Icons.call_outlined,
      'rtc_call_accepted' => Icons.call,
      'rtc_call_rejected' => Icons.call_end,
      'rtc_call_missed' => Icons.phone_missed_outlined,
      'rtc_call_ended' => Icons.call_end_outlined,
      _ => Icons.notifications_outlined,
    };
  }

  @override
  void initState() {
    super.initState();
    ref
        .read(frontendTelemetryProvider)
        .notificationCenterOpened(sourcePage: 'notification_center');
  }

  Future<void> _refresh() async {
    ref.invalidate(notificationListProvider);
    ref.invalidate(notificationUnreadCountProvider);
    await ref.read(notificationListProvider.future);
  }

  Future<void> _markAllRead() async {
    final unread = ref.read(notificationUnreadCountProvider).asData?.value;
    try {
      await ref.read(notificationRemoteDataSourceProvider).markAllRead();
    } catch (_) {
      if (mounted) {
        AppFeedback.showInfo(context, '操作未完成，请稍后重试');
      }
      return;
    }
    ref
        .read(frontendTelemetryProvider)
        .notificationAllRead(
          sourcePage: 'notification_center',
          unreadCount: unread,
        );
    ref.invalidate(notificationListProvider);
    ref.invalidate(notificationUnreadCountProvider);
    if (!mounted) return;
    AppFeedback.showInfo(context, '已全部标记为已读');
  }

  Future<bool> _markRead(NotificationItemEntity item) async {
    if (item.isRead) return true;
    try {
      await ref.read(notificationRemoteDataSourceProvider).markRead(item.id);
    } catch (_) {
      if (mounted) {
        AppFeedback.showInfo(context, '操作未完成，请稍后重试');
      }
      return false;
    }
    ref
        .read(frontendTelemetryProvider)
        .notificationItemOpened(
          sourcePage: 'notification_center',
          kind: item.kind,
        );
    ref.invalidate(notificationListProvider);
    ref.invalidate(notificationUnreadCountProvider);
    return true;
  }

  Future<bool> _openNotification(NotificationItemEntity item) async {
    final routeName = item.routeName.trim();
    if (routeName.isEmpty) {
      AppFeedback.showInfo(context, '这条通知没有可打开页面，可先标记已读');
      return false;
    }
    if (routeName == 'chat_room') {
      final conversationId = _intRouteArg('conversation_id', item);
      if (conversationId <= 0) {
        AppFeedback.showInfo(context, '聊天目标缺失，暂无法打开');
        return false;
      }
      try {
        final conversation = await ref.read(
          conversationDetailProvider(conversationId).future,
        );
        final peerUserId = conversation.peerUserId;
        if (!mounted || peerUserId == null || peerUserId <= 0) {
          if (mounted) {
            AppFeedback.showInfo(context, '暂时无法打开这段会话，请稍后重试');
          }
          return false;
        }
        if (conversation.conversationId != null &&
            conversation.conversationId != conversationId) {
          AppFeedback.showInfo(context, '暂时无法打开这段会话，请稍后重试');
          return false;
        }
        final routeState = ChatRouteState.stored(
          conversationId: conversationId,
          peerUserId: peerUserId,
          matchId: conversation.matchId,
          title: conversation.name,
        );
        context.push(
          '${AppRouteNames.chatRoom}/${routeState.canonicalSegment}',
          extra: routeState,
        );
        return true;
      } catch (_) {
        if (mounted) {
          AppFeedback.showInfo(context, '暂时无法打开这段会话，请稍后重试');
        }
        return false;
      }
    }
    if (routeName == 'status_author') {
      final userId = _intRouteArg('user_id', item);
      final name = (item.routeArgs['name'] ?? '用户资料').toString();
      if (userId > 0) {
        context.push(
          '${AppRouteNames.statusAuthor}/$userId?name=${Uri.encodeComponent(name)}',
        );
        return true;
      }
      AppFeedback.showInfo(context, '动态作者信息缺失，暂无法打开');
      return false;
    }
    if (routeName == 'match_detail') {
      context.go(AppRouteNames.matchDetail);
      return true;
    }
    if (routeName == 'match_result') {
      context.go(AppRouteNames.matchResult);
      return true;
    }
    if (routeName == 'match_intention') {
      context.go(AppRouteNames.matchIntention);
      return true;
    }
    if (routeName == 'questionnaire_history') {
      context.go(AppRouteNames.questionnaireHistory);
      return true;
    }
    if (routeName == 'content_detail') {
      final contentId = (item.routeArgs['content_id'] ?? '').toString();
      if (contentId.isNotEmpty) {
        context.push('${AppRouteNames.contentDetail}/$contentId');
        return true;
      }
      AppFeedback.showInfo(context, '内容目标缺失，暂无法打开');
      return false;
    }
    if (routeName == 'rtc_call') {
      final callId = _intRouteArg('call_id', item);
      final title = (item.routeArgs['title'] ?? item.title).toString();
      if (callId > 0) {
        switch (item.kind) {
          case 'rtc_call_invite':
            context.push(
              '${AppRouteNames.rtcIncomingCall}/$callId',
              extra: title,
            );
            return true;
          case 'rtc_call_rejected':
          case 'rtc_call_missed':
          case 'rtc_call_ended':
            context.push(
              '${AppRouteNames.rtcCallResult}/$callId',
              extra: title,
            );
            return true;
          default:
            context.push('${AppRouteNames.rtcCall}/$callId', extra: title);
            return true;
        }
      }
      AppFeedback.showInfo(context, '通话目标缺失，暂无法打开');
      return false;
    }
    if (routeName == 'settings') {
      context.go(AppRouteNames.settings);
      return true;
    }
    if (routeName == 'social_baseline') {
      context.push(AppRouteNames.socialBaseline);
      return true;
    }
    AppFeedback.showInfo(context, '暂无法打开该通知');
    return false;
  }

  Future<void> _openAndMarkRead(NotificationItemEntity item) async {
    final opened = await _openNotification(item);
    if (!opened || !mounted) return;
    await _markRead(item);
  }

  Future<void> _markReadOnly(NotificationItemEntity item) async {
    final marked = await _markRead(item);
    if (!marked || !mounted) return;
    AppFeedback.showInfo(context, '已标记为已读');
  }

  Future<void> _handlePrimaryAction(NotificationItemEntity item) async {
    if (item.routeName.trim().isEmpty) {
      await _markReadOnly(item);
      return;
    }
    await _openAndMarkRead(item);
  }

  void _handleLater(NotificationItemEntity item) {
    AppFeedback.showInfo(context, '已保留在通知中心，稍后可继续处理');
  }

  String _formatTime(String raw) {
    if (raw.isEmpty) return '刚刚';
    final time = DateTime.tryParse(raw);
    if (time == null) return raw;
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes} 分钟前';
    if (diff.inDays < 1) return '${diff.inHours} 小时前';
    return '${time.month}-${time.day}';
  }

  Widget _buildNotificationCard(NotificationItemEntity item, dynamic t) {
    return Container(
      decoration: BoxDecoration(
        color: t.browseSurface,
        borderRadius: BorderRadius.circular(t.radius.lg),
        border: Border.all(
          color: item.isRead
              ? t.browseBorder
              : t.brandPrimary.withValues(alpha: 0.18),
        ),
      ),
      padding: EdgeInsets.all(t.spacing.cardPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: item.isRead
                  ? t.textSecondary.withValues(alpha: 0.12)
                  : t.brandPrimary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(t.radius.md),
            ),
            child: Icon(
              _iconOf(item.kind),
              size: 18,
              color: item.isRead ? t.textSecondary : t.brandPrimary,
            ),
          ),
          SizedBox(width: t.spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: t.textPrimary,
                          fontWeight: item.isRead
                              ? FontWeight.w600
                              : FontWeight.w700,
                        ),
                      ),
                    ),
                    if (!item.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(
                          top: t.spacing.xxs,
                          left: t.spacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: t.brandPrimary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                if (item.body.trim().isNotEmpty) ...[
                  SizedBox(height: t.spacing.xxs),
                  Text(
                    item.body.trim(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: t.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
                SizedBox(height: t.spacing.xs),
                Row(
                  children: [
                    AppChoiceChip(
                      label: _categoryLabel(item.kind),
                      selected: !item.isRead,
                      onTap: null,
                    ),
                    SizedBox(width: t.spacing.xs),
                    AppChoiceChip(label: _kindLabel(item.kind), onTap: null),
                    SizedBox(width: t.spacing.xs),
                    Text(
                      _formatTime(item.createdAt),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
                    ),
                  ],
                ),
                SizedBox(height: t.spacing.xs),
                Text(
                  _routeHint(item),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: t.textSecondary,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: t.spacing.xs),
                Wrap(
                  spacing: t.spacing.xs,
                  runSpacing: t.spacing.xs,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _handlePrimaryAction(item),
                      icon: Icon(_iconOf(item.kind)),
                      label: Text(_actionLabel(item)),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _handleLater(item),
                      icon: const Icon(Icons.schedule_outlined),
                      label: const Text('稍后处理'),
                    ),
                    if (!item.isRead)
                      OutlinedButton.icon(
                        onPressed: () => _markReadOnly(item),
                        icon: const Icon(Icons.done_rounded),
                        label: const Text('标记已读'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(notificationListProvider);
    final unreadAsync = ref.watch(notificationUnreadCountProvider);
    final t = context.appTokens;

    return BrowseScaffold(
      header: Row(
        children: [
          Expanded(
            child: Text(
              '通知中心',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: t.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            onPressed: _refresh,
            icon: Icon(Icons.refresh_rounded, color: t.textSecondary),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: listAsync.when(
          loading: () => const AppLoadingSkeleton(lines: 6),
          error: (e, _) => ListView(
            padding: EdgeInsets.only(bottom: t.spacing.huge),
            children: [
              AppErrorState(
                title: '通知加载失败',
                description: '暂时无法加载通知，请稍后重试。',
                retryLabel: '重新加载',
                onRetry: _refresh,
              ),
            ],
          ),
          data: (items) {
            final unread =
                unreadAsync.asData?.value ??
                items.where((e) => !e.isRead).length;
            if (items.isEmpty) {
              return ListView(
                padding: EdgeInsets.only(bottom: t.spacing.huge),
                children: [
                  AppInfoSectionCard(
                    title: '站内提醒',
                    subtitle: '慢约会、聊天和资料准备的关键回流会收在这里',
                    leadingIcon: Icons.notifications_active_outlined,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '当前没有提醒。有新的慢约会进度、聊天回流或资料准备事项时，会先在这里帮助你回到当前节奏。',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: t.textSecondary),
                          ),
                        ),
                        AppChoiceChip(
                          label: '去首页',
                          leading: const Icon(Icons.home_outlined),
                          onTap: () => context.go(AppRouteNames.home),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: t.spacing.sm),
                  const _LocalReturnPreviewCard(),
                ],
              );
            }

            return ListView(
              padding: EdgeInsets.only(bottom: t.spacing.huge),
              children: [
                AppInfoSectionCard(
                  title: '站内提醒',
                  subtitle: '慢约会、聊天和资料准备的应用内回流中心',
                  leadingIcon: Icons.notifications_active_outlined,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _unreadSummaryText(unread),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: t.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      AppChoiceChip(
                        label: '全部已读',
                        leading: const Icon(Icons.done_all_rounded),
                        onTap: _markAllRead,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: t.spacing.sm),
                const _LocalReturnPreviewCard(),
                SizedBox(height: t.spacing.md),
                ...items.map(
                  (item) => Padding(
                    padding: EdgeInsets.only(bottom: t.spacing.sm),
                    child: _buildNotificationCard(item, t),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

String _unreadSummaryText(int unread) {
  if (unread > 20) return '有未读提醒';
  return '未读 $unread 条';
}

class _LocalReturnPreviewCard extends StatelessWidget {
  const _LocalReturnPreviewCard();

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AppInfoSectionCard(
      title: '提醒内容示例',
      subtitle: '以下仅为可能出现的提醒示例，不代表当前通知；不会自动发送消息，也不会替你改资料或匹配结果',
      leadingIcon: Icons.low_priority_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ReturnPreviewLine(
            title: '本轮慢约会即将揭晓',
            body: '有新的进度时，可以回到本轮节奏，不制造刷人压力。',
          ),
          SizedBox(height: t.spacing.xs),
          const _ReturnPreviewLine(
            title: '聊天可以低压继续',
            body: '回到聊天页继续手动编辑草稿，发送前仍由你确认。',
          ),
          SizedBox(height: t.spacing.xs),
          const _ReturnPreviewLine(
            title: '资料准备提醒',
            body: '完善展示自己后，后续推荐会更容易被理解。',
          ),
          SizedBox(height: t.spacing.xs),
          const _ReturnPreviewLine(
            title: '聊完后可以反馈方向',
            body: '反馈只帮助整理后续方向，不会直接改变本轮匹配结果。',
          ),
        ],
      ),
    );
  }
}

class _ReturnPreviewLine extends StatelessWidget {
  const _ReturnPreviewLine({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.notifications_none_rounded, size: 18, color: t.brandPrimary),
        SizedBox(width: t.spacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: t.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                body,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

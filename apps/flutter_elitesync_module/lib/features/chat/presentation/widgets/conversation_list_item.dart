import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/highlight_text.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/conversation_entity.dart';
import 'package:flutter_elitesync_module/features/chat/domain/utils/message_visibility_utils.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/utils/profile_display_sanitizer.dart';

class ConversationListItem extends StatelessWidget {
  const ConversationListItem({
    super.key,
    required this.item,
    required this.onTap,
    this.highlightQuery = '',
  });
  final ConversationEntity item;
  final VoidCallback onTap;
  final String highlightQuery;

  String _conversationStatus() {
    if (item.unread > 0) {
      return '${item.unread} 条未读';
    }
    return '暂无未读';
  }

  IconData _conversationStatusIcon() {
    if (item.unread > 0) return Icons.mark_chat_unread_rounded;
    return Icons.mark_chat_read_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final displayName = sanitizeProfileDisplayName(item.name);
    final preview = displayChatPreviewText(item.lastMessage);
    final status = _conversationStatus();
    return Semantics(
      button: true,
      label: '$displayName，$status，$preview',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(t.radius.lg),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: t.spacing.sm,
              vertical: t.spacing.sm,
            ),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            t.brandPrimary.withValues(alpha: 0.9),
                            t.brandSecondary.withValues(alpha: 0.78),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: t.brandPrimary.withValues(alpha: 0.12),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        displayName.isEmpty ? '?' : displayName.substring(0, 1),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    if (item.unread > 0)
                      Positioned(
                        right: -1,
                        top: -1,
                        child: Container(
                          width: 11,
                          height: 11,
                          decoration: BoxDecoration(
                            color: t.brandPrimary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: t.browseSurface,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: t.spacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: HighlightText(
                              text: displayName,
                              query: highlightQuery,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: t.textPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                              highlightStyle: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color: t.brandPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                          SizedBox(width: t.spacing.xs),
                          Text(
                            item.lastTime,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: t.textTertiary),
                          ),
                        ],
                      ),
                      SizedBox(height: t.spacing.xxs),
                      Text(
                        preview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: item.unread > 0
                              ? t.textPrimary
                              : t.textSecondary,
                          fontWeight: item.unread > 0
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: t.spacing.xs),
                      Row(
                        children: [
                          Expanded(
                            child: Wrap(
                              spacing: t.spacing.xxs,
                              runSpacing: t.spacing.xxs,
                              children: [
                                _ConversationRowChip(
                                  icon: Icons.hourglass_empty_rounded,
                                  label: '慢约会',
                                  highlighted: false,
                                ),
                                _ConversationRowChip(
                                  icon: _conversationStatusIcon(),
                                  label: status,
                                  highlighted: item.unread > 0,
                                ),
                              ],
                            ),
                          ),
                          if (item.unread > 0) ...[
                            SizedBox(width: t.spacing.xs),
                            Container(
                              constraints: const BoxConstraints(minWidth: 20),
                              height: 20,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              decoration: BoxDecoration(
                                color: t.brandPrimary,
                                borderRadius: BorderRadius.circular(99),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${item.unread}',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConversationRowChip extends StatelessWidget {
  const _ConversationRowChip({
    required this.icon,
    required this.label,
    required this.highlighted,
  });

  final IconData icon;
  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final color = highlighted ? t.brandPrimary : t.textTertiary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: highlighted ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

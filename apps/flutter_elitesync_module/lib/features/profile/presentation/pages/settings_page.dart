import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/controls/app_switch.dart';
import 'package:flutter_elitesync_module/design_system/components/feedback/app_confirm_dialog.dart';
import 'package:flutter_elitesync_module/design_system/components/feedback/app_feedback.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_mode.dart';
import 'package:flutter_elitesync_module/features/auth/presentation/providers/auth_guard_provider.dart';
import 'package:flutter_elitesync_module/features/match/presentation/dev/relationship_runtime_local_preview_harness.dart';
import 'package:flutter_elitesync_module/features/onboarding/presentation/first_use_onboarding_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/settings_group.dart';
import 'package:flutter_elitesync_module/shared/models/user_role.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/performance_mode_provider.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_elitesync_module/shared/providers/theme_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _pushEnabled = true;
  bool _pushLoaded = false;
  bool _performanceLiteMode = false;
  bool _adminAccessAllowed = false;
  String _contentRankerMode = 'auto';

  @override
  void initState() {
    super.initState();
    _loadPushSetting();
    _loadAdminAccess();
  }

  Future<void> _loadPushSetting() async {
    final local = ref.read(localStorageProvider);
    final value = await local.getBool(CacheKeys.pushNotificationEnabled);
    final perfLite = await local.getBool(CacheKeys.performanceLiteMode);
    final rankerMode =
        (await local.getString(
          CacheKeys.contentRankerMode,
        ))?.trim().toLowerCase() ??
        'auto';
    if (!mounted) return;
    setState(() {
      _pushEnabled = value ?? true;
      _performanceLiteMode = perfLite ?? false;
      _contentRankerMode =
          (rankerMode == 'weighted' ||
              rankerMode == 'legacy' ||
              rankerMode == 'auto')
          ? rankerMode
          : 'auto';
      _pushLoaded = true;
    });
  }

  Future<void> _loadAdminAccess() async {
    final session = await ref.read(sessionProvider.future);
    if (UserRole.isAdmin(session.user?.role)) {
      if (!mounted) return;
      setState(() => _adminAccessAllowed = true);
      return;
    }

    final result = await ref.read(apiClientProvider).get('/api/v1/admin/users');
    if (!mounted) return;
    setState(() => _adminAccessAllowed = result is NetworkSuccess);
  }

  Future<void> _togglePush(bool value) async {
    final local = ref.read(localStorageProvider);
    try {
      final saved = await local.setBool(
        CacheKeys.pushNotificationEnabled,
        value,
      );
      if (!saved) throw StateError('local write rejected');
    } catch (_) {
      if (mounted) {
        AppFeedback.showError(context, '暂时无法保存站内提醒设置，请重试');
      }
      return;
    }
    if (!mounted) return;
    setState(() => _pushEnabled = value);
  }

  Future<void> _togglePerformanceLiteMode(bool value) async {
    final local = ref.read(localStorageProvider);
    try {
      final saved = await local.setBool(CacheKeys.performanceLiteMode, value);
      if (!saved) throw StateError('local write rejected');
    } catch (_) {
      if (mounted) {
        AppFeedback.showError(context, '暂时无法保存性能模式设置，请重试');
      }
      return;
    }
    ref.invalidate(performanceLiteModeProvider);
    if (!mounted) return;
    setState(() => _performanceLiteMode = value);
    AppFeedback.showInfo(context, value ? '已开启性能模式（动画降低）' : '已关闭性能模式');
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: '退出登录',
      message: '退出后将返回登录页，需要重新输入账号和密码。',
      confirmLabel: '退出',
      cancelLabel: '取消',
      destructive: true,
    );
    if (!confirmed) return;
    await ref.read(logoutUseCaseProvider).call();
    try {
      const channel = MethodChannel('elitesync/bootstrap');
      await channel.invokeMethod<void>('clearBootstrap');
    } catch (_) {}
    await ref.read(sessionProvider.notifier).setUnauthenticated();
    if (context.mounted) {
      context.go(AppRouteNames.login);
    }
  }

  Future<void> _clearContentCache({bool showFeedback = true}) async {
    final local = ref.read(localStorageProvider);
    await local.remove(CacheKeys.homeFeedSnapshot);
    await local.remove(CacheKeys.discoverFeedSnapshot);
    await local.remove(CacheKeys.homeSearchHistory);
    await local.remove(CacheKeys.discoverSearchHistory);
    await local.remove(CacheKeys.messagesConversationSnapshot);
    if (!mounted) return;
    if (showFeedback) {
      AppFeedback.showSuccess(context, '本机内容缓存已清理，下次进入时会重新获取内容');
    }
  }

  Future<void> _clearBrowseContentCache() async {
    final local = ref.read(localStorageProvider);
    await local.remove(CacheKeys.homeFeedSnapshot);
    await local.remove(CacheKeys.discoverFeedSnapshot);
    await local.remove(CacheKeys.homeSearchHistory);
    await local.remove(CacheKeys.discoverSearchHistory);
  }

  Future<void> _replayFirstUseOnboarding() async {
    if (!mounted) return;
    final result = await showFirstUseOnboarding(
      context: context,
      storage: ref.read(localStorageProvider),
      mode: FirstUseOnboardingMode.replay,
    );
    if (!mounted || result != FirstUseOnboardingResult.completed) return;
    context.go(AppRouteNames.home);
  }

  Future<void> _showRelationshipRuntimePreviewSheet() async {
    if (!kDebugMode || !ref.read(appEnvProvider).isDev) return;

    final t = context.appTokens;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.88,
          ),
          child: SingleChildScrollView(
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
                  '关系运行态本地预览',
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: t.spacing.xs),
                Text(
                  '仅在调试 / 开发环境显示，只展示本地样例。这里不注册公开路由、不接 AppShell 或正式 Match 流程，也不触发数据连接、不写入数据库、不代表真实运行态就绪。',
                  style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                    color: t.textSecondary,
                    height: 1.45,
                  ),
                ),
                SizedBox(height: t.spacing.md),
                const RelationshipRuntimeLocalPreviewHarness(
                  enabled: kDebugMode,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _resetContentPreference() async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: '重置浏览内容顺序？',
      message: '将清除本机记录的内容标签偏好，并恢复默认浏览顺序。',
      confirmLabel: '重置',
      cancelLabel: '取消',
      destructive: true,
    );
    if (!confirmed) return;
    final local = ref.read(localStorageProvider);
    await local.remove(CacheKeys.contentPreferredTag);
    await local.remove(CacheKeys.contentPreferredTagsMap);
    await local.remove(CacheKeys.homeFeedSnapshot);
    await local.remove(CacheKeys.discoverFeedSnapshot);
    if (!mounted) return;
    AppFeedback.showInfo(context, '本机浏览内容顺序已重置');
  }

  Future<void> _confirmClearContentCache() async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: '清空本机内容缓存？',
      message: '将清除首页、发现和会话的本机内容快照；不会删除账号或聊天记录。',
      confirmLabel: '清空',
      cancelLabel: '取消',
      destructive: true,
    );
    if (!confirmed) return;
    await _clearContentCache();
  }

  String get _rankerLabel {
    switch (_contentRankerMode) {
      case 'weighted':
        return '优先展示更感兴趣的内容';
      case 'legacy':
        return '按原有顺序展示';
      default:
        return '按系统推荐排列';
    }
  }

  Future<void> _cycleContentRankerMode() async {
    final next = switch (_contentRankerMode) {
      'auto' => 'weighted',
      'weighted' => 'legacy',
      _ => 'auto',
    };
    final local = ref.read(localStorageProvider);
    try {
      final saved = await local.setString(CacheKeys.contentRankerMode, next);
      if (!saved) throw StateError('local write rejected');
    } catch (_) {
      if (mounted) {
        AppFeedback.showError(context, '暂时无法保存浏览内容顺序，请重试');
      }
      return;
    }
    if (mounted) {
      setState(() => _contentRankerMode = next);
    }
    try {
      await _clearBrowseContentCache();
    } catch (_) {
      if (mounted) {
        AppFeedback.showError(context, '浏览内容顺序已保存，但本机内容暂时无法刷新，请重新进入查看');
      }
      return;
    }
    if (!mounted) return;
    AppFeedback.showInfo(context, '浏览内容顺序已切换：$_rankerLabel');
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final themeMode = ref.watch(themeModeProvider);
    final env = ref.watch(appEnvProvider);
    final session = ref.watch(sessionProvider);
    final isSessionAdmin = session.maybeWhen(
      data: (state) => UserRole.isAdmin(state.user?.role),
      orElse: () => false,
    );
    final showAdminEntries = isSessionAdmin || _adminAccessAllowed;
    final showRelationshipPreviewEntry = env.isDev && kDebugMode;
    final isDark =
        themeMode == AppThemeMode.dark ||
        (themeMode == AppThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);
    Future<void> setDark(bool value) => ref
        .read(themeModeProvider.notifier)
        .setThemeMode(value ? AppThemeMode.dark : AppThemeMode.light);
    return AppScaffold(
      appBar: const AppTopBar(title: '设置', mode: AppTopBarMode.backTitle),
      body: ListView(
        padding: EdgeInsets.fromLTRB(0, t.spacing.sm, 0, t.spacing.xl),
        children: [
          const SectionReveal(
            child: PageTitleRail(
              title: '设置中心',
              subtitle: '账号、安全、消息、反馈和版本信息都在这里',
            ),
          ),
          SizedBox(height: t.spacing.sm),
          SectionReveal(
            delay: const Duration(milliseconds: 50),
            child: SettingsGroup(
              title: '显示与外观',
              children: [
                SettingsItemTile(
                  title: '夜间模式',
                  subtitle: '切换白天 / 黑夜配色',
                  icon: Icons.dark_mode_outlined,
                  trailing: AppSwitch(value: isDark, onChanged: setDark),
                  onTap: () => setDark(!isDark),
                ),
                Divider(height: 1, color: t.overlay.withValues(alpha: 0.35)),
                SettingsItemTile(
                  title: '盘面设置',
                  subtitle: '星盘元素、预设档位与恢复默认',
                  icon: Icons.auto_awesome_outlined,
                  onTap: () => context.push(AppRouteNames.astroChartSettings),
                ),
              ],
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 60),
            child: _pushLoaded
                ? SettingsGroup(
                    title: '提醒与性能',
                    children: [
                      SettingsItemTile(
                        title: '站内提醒',
                        subtitle: '控制应用内提醒入口；系统推送以设备权限和后续支持为准',
                        icon: Icons.notifications_outlined,
                        trailing: AppSwitch(
                          value: _pushEnabled,
                          onChanged: _togglePush,
                        ),
                        onTap: () => _togglePush(!_pushEnabled),
                      ),
                      Divider(
                        height: 1,
                        color: t.overlay.withValues(alpha: 0.35),
                      ),
                      SettingsItemTile(
                        title: '性能模式',
                        subtitle: '降低动画与背景渲染，改善卡顿',
                        icon: Icons.bolt_outlined,
                        trailing: AppSwitch(
                          value: _performanceLiteMode,
                          onChanged: _togglePerformanceLiteMode,
                        ),
                        onTap: () =>
                            _togglePerformanceLiteMode(!_performanceLiteMode),
                      ),
                    ],
                  )
                : SettingsGroup(
                    title: '提醒与性能',
                    children: [
                      SettingsItemTile(
                        title: '站内提醒',
                        subtitle: '加载中...',
                        icon: Icons.notifications_outlined,
                      ),
                      Divider(
                        height: 1,
                        color: t.overlay.withValues(alpha: 0.35),
                      ),
                      SettingsItemTile(
                        title: '性能模式',
                        subtitle: '降低动画与背景渲染，改善卡顿',
                        icon: Icons.bolt_outlined,
                        trailing: AppSwitch(
                          value: _performanceLiteMode,
                          onChanged: _togglePerformanceLiteMode,
                        ),
                        onTap: () =>
                            _togglePerformanceLiteMode(!_performanceLiteMode),
                      ),
                    ],
                  ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 80),
            child: SettingsGroup(
              title: '资料与隐私',
              children: [
                SettingsItemTile(
                  title: '隐私设置',
                  subtitle: '查看当前隐私边界与安全说明',
                  icon: Icons.privacy_tip_outlined,
                  onTap: () => context.push(AppRouteNames.privacySettings),
                ),
              ],
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 90),
            child: SettingsGroup(
              title: '账号与安全',
              children: [
                SettingsItemTile(
                  title: '更新登录密码',
                  subtitle: '按账号安全流程修改当前登录密码',
                  icon: Icons.lock_outline_rounded,
                  onTap: () => context.push(AppRouteNames.changePassword),
                ),
              ],
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 145),
            child: SettingsGroup(
              title: '帮助与反馈',
              children: [
                SettingsItemTile(
                  title: '新手引导',
                  subtitle: '随时重新查看使用说明',
                  icon: Icons.help_outline_rounded,
                  onTap: _replayFirstUseOnboarding,
                ),
                Divider(height: 1, color: t.overlay.withValues(alpha: 0.35)),
                SettingsItemTile(
                  title: '帮我们改进体验',
                  subtitle: '在本机整理可复制反馈，由你选择发送方式',
                  icon: Icons.rate_review_outlined,
                  onTap: () => context.push(
                    Uri(
                      path: AppRouteNames.innerTestFeedback,
                      queryParameters: {
                        'category': 'profile_data',
                        'source': 'settings',
                      },
                    ).toString(),
                  ),
                ),
                Divider(height: 1, color: t.overlay.withValues(alpha: 0.35)),
                SettingsItemTile(
                  title: '版本中心',
                  subtitle: '查看当前安装版本、手动检查更新和更新说明',
                  icon: Icons.system_update_alt_rounded,
                  onTap: () => context.push(AppRouteNames.aboutUpdate),
                ),
              ],
            ),
          ),
          SizedBox(height: t.spacing.md),
          if (showAdminEntries) ...[
            SizedBox(height: t.spacing.md),
            if (showRelationshipPreviewEntry) ...[
              SectionReveal(
                delay: const Duration(milliseconds: 155),
                child: SettingsGroup(
                  title: '开发者预览',
                  children: [
                    SettingsItemTile(
                      title: '关系运行态本地预览',
                      subtitle: '仅调试 / 开发环境，本地样例，不接数据连接或数据库',
                      icon: Icons.developer_mode_rounded,
                      onTap: _showRelationshipRuntimePreviewSheet,
                    ),
                  ],
                ),
              ),
              SizedBox(height: t.spacing.md),
            ],
            SectionReveal(
              delay: const Duration(milliseconds: 160),
              child: SettingsGroup(
                title: '运营管理',
                children: [
                  SettingsItemTile(
                    title: '运营看板',
                    subtitle: '最小指标概览与入口展示',
                    icon: Icons.dashboard_outlined,
                    onTap: () => context.push(AppRouteNames.adminDashboard),
                  ),
                  Divider(height: 1, color: t.overlay.withValues(alpha: 0.35)),
                  SettingsItemTile(
                    title: '运营后台',
                    subtitle: '举报与用户状态查看入口',
                    icon: Icons.admin_panel_settings_outlined,
                    onTap: () => context.push(AppRouteNames.adminModeration),
                  ),
                  Divider(height: 1, color: t.overlay.withValues(alpha: 0.35)),
                  SettingsItemTile(
                    title: '认证审核',
                    subtitle: '人工审核列表与当前状态',
                    icon: Icons.verified_user_outlined,
                    onTap: () => context.push(AppRouteNames.adminVerification),
                  ),
                  Divider(height: 1, color: t.overlay.withValues(alpha: 0.35)),
                  SettingsItemTile(
                    title: '用户列表',
                    subtitle: '查看用户状态与记录',
                    icon: Icons.people_outline,
                    onTap: () => context.push(AppRouteNames.adminUsers),
                  ),
                ],
              ),
            ),
          ],
          SectionReveal(
            delay: const Duration(milliseconds: 170),
            child: SettingsGroup(
              title: '本机缓存与重置',
              children: [
                SettingsItemTile(
                  title: '浏览内容顺序',
                  subtitle: '当前：$_rankerLabel（仅调整本机浏览偏好）',
                  icon: Icons.tune_rounded,
                  onTap: _cycleContentRankerMode,
                ),
                Divider(height: 1, color: t.overlay.withValues(alpha: 0.35)),
                SettingsItemTile(
                  title: '重置浏览内容顺序',
                  subtitle: '清除点击形成的标签偏好并回到默认排序',
                  icon: Icons.restart_alt_rounded,
                  variant: SettingsItemVariant.destructive,
                  onTap: _resetContentPreference,
                ),
                Divider(height: 1, color: t.overlay.withValues(alpha: 0.35)),
                SettingsItemTile(
                  title: '清空本机内容缓存',
                  subtitle: '清除首页、发现和会话的本机内容快照',
                  icon: Icons.cleaning_services_outlined,
                  variant: SettingsItemVariant.destructive,
                  onTap: _confirmClearContentCache,
                ),
              ],
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 180),
            child: SettingsGroup(
              title: '退出账号',
              children: [
                SettingsItemTile(
                  title: '退出登录',
                  subtitle: '安全退出当前账号',
                  icon: Icons.logout_rounded,
                  trailing: Icon(Icons.logout_rounded, color: t.error),
                  variant: SettingsItemVariant.destructive,
                  onTap: () => _handleLogout(context, ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

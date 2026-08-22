import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/app/router/app_route_observer.dart';
import 'package:flutter_elitesync_module/app/router/app_shell.dart';
import 'package:flutter_elitesync_module/core/ui/app_motion.dart';
import 'package:flutter_elitesync_module/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_elitesync_module/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:flutter_elitesync_module/features/admin/presentation/pages/admin_moderation_page.dart';
import 'package:flutter_elitesync_module/features/admin/presentation/pages/admin_report_detail_page.dart';
import 'package:flutter_elitesync_module/features/admin/presentation/pages/admin_verification_page.dart';
import 'package:flutter_elitesync_module/features/admin/presentation/pages/admin_users_page.dart';
import 'package:flutter_elitesync_module/features/admin/presentation/pages/admin_matching_operations_page.dart';
import 'package:flutter_elitesync_module/features/auth/presentation/pages/register_page.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/pages/chat_room_page.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/chat_route_state.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/providers/chat_providers.dart';
import 'package:flutter_elitesync_module/features/feedback/presentation/pages/inner_test_feedback_page.dart';
import 'package:flutter_elitesync_module/features/debug/presentation/pages/local_only_visual_fixture_page.dart';
import 'package:flutter_elitesync_module/features/home/domain/entities/home_feed_entity.dart';
import 'package:flutter_elitesync_module/features/home/presentation/pages/content_detail_page.dart';
import 'package:flutter_elitesync_module/features/notification/presentation/pages/notification_center_page.dart';
import 'package:flutter_elitesync_module/features/social/presentation/pages/social_baseline_page.dart';
import 'package:flutter_elitesync_module/features/rtc/presentation/pages/rtc_call_page.dart';
import 'package:flutter_elitesync_module/features/rtc/presentation/pages/rtc_incoming_call_page.dart';
import 'package:flutter_elitesync_module/features/rtc/presentation/pages/rtc_call_result_page.dart';
import 'package:flutter_elitesync_module/features/rtc/presentation/pages/rtc_permission_page.dart';
import 'package:flutter_elitesync_module/features/match/presentation/pages/match_countdown_page.dart';
import 'package:flutter_elitesync_module/features/match/presentation/pages/match_detail_page.dart';
import 'package:flutter_elitesync_module/features/match/presentation/pages/match_intention_page.dart';
import 'package:flutter_elitesync_module/features/match/presentation/pages/match_feedback_page.dart';
import 'package:flutter_elitesync_module/features/match/presentation/pages/match_result_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/astro_bazi_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/astro_advanced_preview_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/astro_natal_chart_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/astro_overview_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/astro_profile_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/astro_chart_settings_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/astro_ziwei_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/mbti_center_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/about_update_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/change_password_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/personal_showcase_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/profile_showcase_publication_fixture_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/profile_showcase_review_fixture_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/privacy_settings_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/settings_page.dart';
import 'package:flutter_elitesync_module/features/questionnaire/presentation/pages/questionnaire_page.dart';
import 'package:flutter_elitesync_module/features/questionnaire/presentation/pages/questionnaire_history_page.dart';
import 'package:flutter_elitesync_module/features/questionnaire/presentation/pages/questionnaire_result_page.dart';
import 'package:flutter_elitesync_module/features/verification/presentation/pages/verification_status_page.dart';
import 'package:flutter_elitesync_module/features/verification/presentation/pages/verification_submit_page.dart';
import 'package:flutter_elitesync_module/features/status/presentation/pages/status_author_page.dart';
import 'package:flutter_elitesync_module/features/status/presentation/pages/status_square_page.dart';
import 'package:flutter_elitesync_module/shared/providers/navigation_guard_provider.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  ref.watch(navigationGuardProvider);
  final routeObserver = ref.watch(appRouteObserverProvider);

  final env = ref.read(appEnvProvider);
  return GoRouter(
    observers: [routeObserver],
    initialLocation: env.initialRoute ?? AppRouteNames.splash,
    errorBuilder: (context, state) => const InvalidRouteRecoveryPage(),
    redirect: (context, state) {
      final nav = ref.read(navigationGuardProvider);
      final path = state.uri.path;
      final isAuthPage =
          path == AppRouteNames.login || path == AppRouteNames.register;
      final isDevFixtureRoute =
          env.isDev && path == AppRouteNames.localOnlyVisualFixture;
      final isPublic =
          path == AppRouteNames.splash || isAuthPage || isDevFixtureRoute;

      if (nav.isBootstrapLoading) return AppRouteNames.splash;

      if (!nav.isLoggedIn && !isPublic) {
        return AppRouteNames.login;
      }

      if (nav.isLoggedIn && isAuthPage) {
        return AppRouteNames.home;
      }

      return null;
    },
    routes: [
      if (env.isDev)
        GoRoute(
          path: AppRouteNames.profileShowcaseReviewFixture,
          pageBuilder: (context, state) =>
              _fadeSlidePage(state, const ProfileShowcaseReviewFixturePage()),
        ),
      if (env.isDev)
        GoRoute(
          path: AppRouteNames.profileShowcasePublicationFixture,
          pageBuilder: (context, state) => _fadeSlidePage(
            state,
            const ProfileShowcasePublicationFixturePage(),
          ),
        ),
      if (env.isDev)
        GoRoute(
          path: AppRouteNames.localOnlyVisualFixture,
          pageBuilder: (context, state) =>
              _fadeSlidePage(state, const LocalOnlyVisualFixturePage()),
        ),
      GoRoute(
        path: AppRouteNames.splash,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const SplashPage()),
      ),
      GoRoute(
        path: AppRouteNames.login,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const LoginPage()),
      ),
      GoRoute(
        path: AppRouteNames.register,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const RegisterPage()),
      ),
      GoRoute(
        path: AppRouteNames.verificationStatus,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const VerificationStatusPage()),
      ),
      GoRoute(
        path: AppRouteNames.verificationSubmit,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const VerificationSubmitPage()),
      ),
      GoRoute(
        path: AppRouteNames.questionnaire,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const QuestionnairePage()),
      ),
      GoRoute(
        path: AppRouteNames.questionnaireResult,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const QuestionnaireResultPage()),
      ),
      GoRoute(
        path: AppRouteNames.questionnaireHistory,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const QuestionnaireHistoryPage()),
      ),
      GoRoute(
        path: AppRouteNames.matchCountdown,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const MatchCountdownPage()),
      ),
      GoRoute(
        path: AppRouteNames.matchResult,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const MatchResultPage()),
      ),
      GoRoute(
        path: AppRouteNames.matchDetail,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const MatchDetailPage()),
      ),
      GoRoute(
        path: AppRouteNames.matchIntention,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const MatchIntentionPage()),
      ),
      GoRoute(
        path: AppRouteNames.matchFeedback,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const MatchFeedbackPage()),
      ),
      GoRoute(
        path: AppRouteNames.innerTestFeedback,
        pageBuilder: (context, state) => _fadeSlidePage(
          state,
          InnerTestFeedbackPage(
            initialCategoryId: state.uri.queryParameters['category'],
            sourceSurface: state.uri.queryParameters['source'],
          ),
        ),
      ),
      GoRoute(
        path: '${AppRouteNames.chatRoom}/:chatIdentity',
        pageBuilder: (context, state) {
          final segment = state.pathParameters['chatIdentity'] ?? '';
          final routeState = chatRouteStateFromPath(
            segment: segment,
            extra: state.extra,
          );
          if (routeState != null) {
            return _fadeSlidePage(state, ChatRoomPage(routeState: routeState));
          }
          final storedConversationId = storedConversationIdFromSegment(segment);
          return _fadeSlidePage(
            state,
            storedConversationId == null
                ? const _InvalidChatRoutePage()
                : _StoredConversationRoutePage(
                    conversationId: storedConversationId,
                  ),
          );
        },
      ),
      GoRoute(
        path: AppRouteNames.statusSquare,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const StatusSquarePage()),
      ),
      GoRoute(
        path: AppRouteNames.notificationCenter,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const NotificationCenterPage()),
      ),
      GoRoute(
        path: AppRouteNames.socialBaseline,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const SocialBaselinePage()),
      ),
      GoRoute(
        path: AppRouteNames.personalShowcase,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const PersonalShowcasePage()),
      ),
      GoRoute(
        path: '${AppRouteNames.rtcCall}/:callId',
        pageBuilder: (context, state) {
          final callId =
              int.tryParse(state.pathParameters['callId'] ?? '') ?? 0;
          final title = (state.extra as String?) ?? '通话';
          return _fadeSlidePage(
            state,
            RtcCallPage(callId: callId, title: title),
          );
        },
      ),
      GoRoute(
        path: '${AppRouteNames.rtcIncomingCall}/:callId',
        pageBuilder: (context, state) {
          final callId =
              int.tryParse(state.pathParameters['callId'] ?? '') ?? 0;
          final title = (state.extra as String?) ?? '来电';
          return _fadeSlidePage(
            state,
            RtcIncomingCallPage(callId: callId, title: title),
          );
        },
      ),
      GoRoute(
        path: '${AppRouteNames.rtcCallResult}/:callId',
        pageBuilder: (context, state) {
          final callId =
              int.tryParse(state.pathParameters['callId'] ?? '') ?? 0;
          final title = (state.extra as String?) ?? '通话结果';
          return _fadeSlidePage(
            state,
            RtcCallResultPage(callId: callId, title: title),
          );
        },
      ),
      GoRoute(
        path: AppRouteNames.rtcPermission,
        pageBuilder: (context, state) {
          final title = state.uri.queryParameters['title'] ?? '通话权限';
          return _fadeSlidePage(state, RtcPermissionPage(title: title));
        },
      ),
      GoRoute(
        path: '${AppRouteNames.statusAuthor}/:userId',
        pageBuilder: (context, state) {
          final userId =
              int.tryParse(state.pathParameters['userId'] ?? '') ?? 0;
          final name = state.uri.queryParameters['name'] ?? '用户资料';
          return _fadeSlidePage(
            state,
            StatusAuthorPage(userId: userId, name: name),
          );
        },
      ),
      GoRoute(
        path: '${AppRouteNames.contentDetail}/:contentId',
        pageBuilder: (context, state) {
          final id = state.pathParameters['contentId'] ?? '';
          final extra = state.extra;
          final content = extra is HomeFeedEntity ? extra : null;
          return _fadeSlidePage(
            state,
            ContentDetailPage(contentId: id, content: content),
          );
        },
      ),
      GoRoute(
        path: AppRouteNames.editProfile,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const EditProfilePage()),
      ),
      GoRoute(
        path: AppRouteNames.astroOverview,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const AstroOverviewPage()),
      ),
      GoRoute(
        path: AppRouteNames.astroBazi,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const AstroBaziPage()),
      ),
      GoRoute(
        path: AppRouteNames.astroNatalChart,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const AstroNatalChartPage()),
      ),
      GoRoute(
        path: AppRouteNames.astroAdvancedPreview,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const AstroAdvancedPreviewPage()),
      ),
      GoRoute(
        path: AppRouteNames.astroChartSettings,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const AstroChartSettingsPage()),
      ),
      GoRoute(
        path: AppRouteNames.astroZiwei,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const AstroZiweiPage()),
      ),
      GoRoute(
        path: AppRouteNames.settings,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const SettingsPage()),
      ),
      GoRoute(
        path: AppRouteNames.changePassword,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const ChangePasswordPage()),
      ),
      GoRoute(
        path: AppRouteNames.privacySettings,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const PrivacySettingsPage()),
      ),
      GoRoute(
        path: AppRouteNames.adminDashboard,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const AdminDashboardPage()),
      ),
      GoRoute(
        path: AppRouteNames.adminModeration,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const AdminModerationPage()),
      ),
      GoRoute(
        path: AppRouteNames.adminVerification,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const AdminVerificationPage()),
      ),
      GoRoute(
        path: AppRouteNames.adminUsers,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const AdminUsersPage()),
      ),
      GoRoute(
        path: AppRouteNames.adminMatchingOperations,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const AdminMatchingOperationsPage()),
      ),
      GoRoute(
        path: '${AppRouteNames.adminModerationReportDetail}/:reportId',
        pageBuilder: (context, state) {
          final reportId =
              int.tryParse(state.pathParameters['reportId'] ?? '') ?? 0;
          return _fadeSlidePage(
            state,
            AdminReportDetailPage(reportId: reportId),
          );
        },
      ),
      GoRoute(
        path: AppRouteNames.aboutUpdate,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const AboutUpdatePage()),
      ),
      GoRoute(
        path: AppRouteNames.mbtiCenter,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const MbtiCenterPage()),
      ),
      GoRoute(
        path: AppRouteNames.astroProfile,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const AstroProfilePage()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteNames.home,
                builder: (context, state) => const HomeShellPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteNames.discover,
                builder: (context, state) => const DiscoverShellPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteNames.match,
                builder: (context, state) => const MatchShellPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteNames.messages,
                builder: (context, state) => const MessagesShellPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteNames.profile,
                builder: (context, state) => const ProfileShellPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

ChatRouteState? chatRouteStateFromPath({
  required String segment,
  Object? extra,
}) {
  if (extra is ChatRouteState && extra.canonicalSegment == segment) {
    return extra;
  }
  final legacyPeerId = int.tryParse(segment);
  if (legacyPeerId == null || legacyPeerId <= 0) return null;
  return ChatRouteState.legacyPeer(
    peerUserId: legacyPeerId,
    title: extra is String ? extra : '聊天',
  );
}

int? storedConversationIdFromSegment(String segment) {
  const prefix = 'conversation-';
  if (!segment.startsWith(prefix)) return null;
  final value = int.tryParse(segment.substring(prefix.length));
  return value != null && value > 0 ? value : null;
}

class _StoredConversationRoutePage extends ConsumerWidget {
  const _StoredConversationRoutePage({required this.conversationId});

  final int conversationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(conversationDetailProvider(conversationId));
    return detail.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => _ChatRouteResolutionError(
        onRetry: () =>
            ref.invalidate(conversationDetailProvider(conversationId)),
      ),
      data: (conversation) {
        final peerUserId = conversation.peerUserId;
        if (peerUserId == null ||
            peerUserId <= 0 ||
            (conversation.conversationId != null &&
                conversation.conversationId != conversationId)) {
          return _ChatRouteResolutionError(
            onRetry: () =>
                ref.invalidate(conversationDetailProvider(conversationId)),
          );
        }
        final routeState = ChatRouteState.stored(
          conversationId: conversationId,
          peerUserId: peerUserId,
          matchId: conversation.matchId,
          title: conversation.name,
        );
        return ChatRoomPage(routeState: routeState);
      },
    );
  }
}

class _InvalidChatRoutePage extends StatelessWidget {
  const _InvalidChatRoutePage();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('当前会话地址无效，请返回消息列表重新选择')));
}

class _ChatRouteResolutionError extends StatelessWidget {
  const _ChatRouteResolutionError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('暂时无法打开这段会话，请稍后重试'),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('重试')),
        ],
      ),
    ),
  );
}

class InvalidRouteRecoveryPage extends StatelessWidget {
  const InvalidRouteRecoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('页面未找到')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.explore_off_outlined, size: 48),
              const SizedBox(height: 16),
              const Text('这个页面暂时无法打开'),
              const SizedBox(height: 8),
              const Text('你可以返回首页，或回到上一页继续浏览。'),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go(AppRouteNames.home),
                child: const Text('返回首页'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(AppRouteNames.home);
                  }
                },
                child: const Text('返回上一页'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

CustomTransitionPage<void> _fadeSlidePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppMotion.routeForward,
    reverseTransitionDuration: AppMotion.routeReverse,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: AppMotion.routeCurve,
        reverseCurve: AppMotion.routeReverseCurve,
      );
      return FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curved),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

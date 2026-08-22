import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/app/router/app_router.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/core/storage/secure_storage_service.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_summary_entity.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_detail_entity.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/birth_place_suggestion_entity.dart';
import 'package:flutter_elitesync_module/features/profile/domain/repository/profile_repository.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/state/profile_ui_state.dart';
import 'package:flutter_elitesync_module/features/questionnaire/domain/entities/question_item.dart';
import 'package:flutter_elitesync_module/features/questionnaire/domain/entities/questionnaire_attempt.dart';
import 'package:flutter_elitesync_module/features/questionnaire/domain/entities/questionnaire_bundle.dart';
import 'package:flutter_elitesync_module/features/questionnaire/domain/entities/questionnaire_submission_result.dart';
import 'package:flutter_elitesync_module/features/questionnaire/domain/repository/questionnaire_repository.dart';
import 'package:flutter_elitesync_module/features/questionnaire/domain/usecases/submit_questionnaire_usecase.dart';
import 'package:flutter_elitesync_module/features/questionnaire/presentation/pages/questionnaire_page.dart';
import 'package:flutter_elitesync_module/features/questionnaire/presentation/pages/questionnaire_result_page.dart';
import 'package:flutter_elitesync_module/features/questionnaire/presentation/providers/questionnaire_provider.dart';
import 'package:flutter_elitesync_module/features/questionnaire/presentation/state/questionnaire_state.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

const _summary = ProfileSummaryEntity(
  nickname: 'SmokeUser22',
  birthday: '1998-01-01',
  birthTime: '10:30',
  birthPlace: '北京动物园',
  birthLat: 39.947735,
  birthLng: 116.343376,
  city: 'Nanyang',
  target: 'dating',
  verified: true,
  moderationStatus: 'normal',
  moderationNote: null,
  completion: 0.78,
  tags: ['ENFJ', '射手座', '生活节奏稳定', '婚恋目标已确认'],
  readiness: ProfileReadinessEntity(
    contractVersion: 'profile_readiness_v1',
    matchingEligibility: MatchingEligibilityEntity(
      eligible: false,
      reasonCode: 'questionnaire_incomplete',
      requiredAnswerCount: 10,
      answeredAnswerCount: 7,
      missingAnswerCount: 3,
      nextActionCode: 'complete_questionnaire',
    ),
    showcase: ShowcaseReadinessEntity(
      draftState: 'private_draft',
      reviewStatus: 'pending',
      publicationStatus: 'not_published',
      publishedVersionCurrent: false,
      affectsMatchingEligibility: false,
    ),
  ),
);

extension on ProfileSummaryEntity {
  ProfileSummaryEntity copyWithReadinessForTest(ProfileReadinessEntity value) {
    return ProfileSummaryEntity(
      nickname: nickname,
      birthday: birthday,
      birthTime: birthTime,
      birthPlace: birthPlace,
      birthLat: birthLat,
      birthLng: birthLng,
      city: city,
      target: target,
      verified: verified,
      moderationStatus: moderationStatus,
      moderationNote: moderationNote,
      completion: this.completion,
      tags: tags,
      readiness: value,
    );
  }
}

GoRouter _router() {
  return GoRouter(
    initialLocation: AppRouteNames.profile,
    routes: [
      GoRoute(
        path: AppRouteNames.profile,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: AppRouteNames.astroOverview,
        builder: (context, state) =>
            const Scaffold(body: Text('ASTRO OVERVIEW ROUTE')),
      ),
      GoRoute(
        path: AppRouteNames.personalShowcase,
        builder: (context, state) =>
            const Scaffold(body: Text('PERSONAL SHOWCASE ROUTE')),
      ),
      GoRoute(
        path: AppRouteNames.editProfile,
        builder: (context, state) =>
            const Scaffold(body: Text('EDIT PROFILE ROUTE')),
      ),
      GoRoute(
        path: AppRouteNames.settings,
        builder: (context, state) =>
            const Scaffold(body: Text('SETTINGS ROUTE')),
      ),
      GoRoute(
        path: AppRouteNames.privacySettings,
        builder: (context, state) =>
            const Scaffold(body: Text('PRIVACY ROUTE')),
      ),
      GoRoute(
        path: AppRouteNames.notificationCenter,
        builder: (context, state) =>
            const Scaffold(body: Text('NOTIFICATION ROUTE')),
      ),
      GoRoute(
        path: AppRouteNames.innerTestFeedback,
        builder: (context, state) =>
            const Scaffold(body: Text('FEEDBACK ROUTE')),
      ),
      GoRoute(
        path: AppRouteNames.aboutUpdate,
        builder: (context, state) =>
            const Scaffold(body: Text('VERSION ROUTE')),
      ),
      GoRoute(
        path: AppRouteNames.adminDashboard,
        builder: (context, state) =>
            const Scaffold(body: Text('ADMIN DASHBOARD ROUTE')),
      ),
      GoRoute(
        path: AppRouteNames.questionnaire,
        builder: (context, state) =>
            const Scaffold(body: Text('QUESTIONNAIRE ROUTE')),
      ),
      GoRoute(
        path: AppRouteNames.match,
        builder: (context, state) => const Scaffold(body: Text('MATCH ROUTE')),
      ),
    ],
  );
}

Future<_SessionTestStorage> _sessionStorage({String role = 'user'}) async {
  final localStorage = _FakeLocalStorageService();
  final secureStorage = _FakeSecureStorageService();

  await secureStorage.write(CacheKeys.accessToken, 'test-token');
  await localStorage.setJson(CacheKeys.lastKnownProfile, {
    'id': role == 'admin' ? 8 : 7,
    'phone': role == 'admin' ? '13772423130' : '17094346566',
    'nickname': 'tester',
    'role': role,
  });

  return _SessionTestStorage(
    localStorage: localStorage,
    secureStorage: secureStorage,
  );
}

Future<Widget> _wrap({
  String role = 'user',
  bool adminProbeAllowed = false,
  ProfileUiState profileState = const ProfileUiState(summary: _summary),
  bool profileThrows = false,
}) async {
  final sessionStorage = await _sessionStorage(role: role);
  return ProviderScope(
    overrides: [
      localStorageProvider.overrideWithValue(sessionStorage.localStorage),
      secureStorageProvider.overrideWithValue(sessionStorage.secureStorage),
      apiClientProvider.overrideWithValue(
        _FakeApiClient(adminProbeAllowed: adminProbeAllowed),
      ),
      profileProvider.overrideWith((ref) async {
        if (profileThrows) throw StateError('internal profile failure');
        return profileState;
      }),
    ],
    child: MaterialApp.router(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      routerConfig: _router(),
    ),
  );
}

class _SessionTestStorage {
  const _SessionTestStorage({
    required this.localStorage,
    required this.secureStorage,
  });

  final _FakeLocalStorageService localStorage;
  final _FakeSecureStorageService secureStorage;
}

class _FakeLocalStorageService extends LocalStorageService {
  final Map<String, Object?> _values = {};

  @override
  Future<bool> setString(String key, String value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<String?> getString(String key) async => _values[key] as String?;

  @override
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<Map<String, dynamic>?> getJson(String key) async {
    final value = _values[key];
    return value is Map<String, dynamic> ? value : null;
  }

  @override
  Future<bool> remove(String key) async {
    _values.remove(key);
    return true;
  }
}

class _FakeSecureStorageService extends SecureStorageService {
  final Map<String, String> _values = {};

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }
}

class _FakeApiClient extends ApiClient {
  _FakeApiClient({this.adminProbeAllowed = false}) : super(dio: Dio());

  final bool adminProbeAllowed;

  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    if (path == '/api/v1/admin/users') {
      return adminProbeAllowed
          ? NetworkSuccess({'items': <Map<String, Object?>>[]})
          : const NetworkFailure(
              message: 'admin access required',
              statusCode: 403,
            );
    }
    return const NetworkSuccess(<String, dynamic>{});
  }
}

class _ExistingDetailRepository implements ProfileRepository {
  @override
  Future<ProfileDetailEntity> getDetail() async => const ProfileDetailEntity(
    nickname: '保留昵称',
    gender: 'female',
    birthday: '1995-05-06',
    birthTime: '08:30',
    city: '杭州',
    target: 'dating',
    birthPlace: '浙江省杭州市',
    birthLat: 30.2741,
    birthLng: 120.1551,
  );

  @override
  Future<ProfileSummaryEntity> getSummary() => throw UnimplementedError();

  @override
  Future<List<BirthPlaceSuggestionEntity>> searchBirthPlaces({
    required String query,
    String region = '',
  }) async => const [];

  @override
  Future<Map<String, dynamic>> update(ProfileDetailEntity detail) =>
      throw UnimplementedError();
}

class _SmokeQuestionnaireNotifier extends QuestionnaireNotifier {
  @override
  Future<QuestionnaireState> build() async => const QuestionnaireState(
    version: 'q_v2',
    bankVersion: 'qb_v1',
    attemptVersion: 'qa_v1',
    label: '现有匹配问卷',
    nonOfficialNotice: '本地进度不代表匹配资格。',
    total: 1,
    estimatedMinutes: 1,
    questions: [
      QuestionItem(id: 1, title: '选择答案', options: ['答案 A'], version: 1),
    ],
  );
}

class _SmokeQuestionnaireRepository implements QuestionnaireRepository {
  int submittedAnswers = 0;

  @override
  Future<QuestionnaireSubmissionResult> submitAnswers(
    Map<int, int> answers,
  ) async {
    submittedAnswers = answers.length;
    return const QuestionnaireSubmissionResult(
      questionnaireVersion: 'q_v2',
      bankVersion: 'qb_v1',
      attemptVersion: 'qa_v1',
      profileLabel: '已提交',
      profileHighlights: ['server persisted'],
      profileComplete: true,
    );
  }

  @override
  Future<QuestionnaireBundle> fetchQuestionnaire() =>
      throw UnimplementedError();

  @override
  Future<List<QuestionnaireAttempt>> fetchHistory() async => const [];

  @override
  Future<void> saveDraft({
    required int currentIndex,
    required Map<int, int> answers,
  }) async {}
}

String _visibleText(WidgetTester tester) {
  return tester
      .widgetList<Text>(find.byType(Text))
      .map((text) => text.data ?? '')
      .where((text) => text.isNotEmpty)
      .join('\n');
}

void main() {
  test(
    'production router retains ordinary profile management destinations',
    () {
      final container = ProviderContainer(
        overrides: [
          appEnvProvider.overrideWithValue(
            const AppEnv(
              flavor: AppFlavor.prod,
              appName: 'EliteSync Router Test',
              apiBaseUrl: 'http://localhost',
              useMockData: false,
            ),
          ),
          authStatusProvider.overrideWithValue(AuthStatus.authenticated),
        ],
      );
      addTearDown(container.dispose);
      final router = container.read(appRouterProvider);
      addTearDown(router.dispose);
      final paths = <String>{};

      void collect(List<RouteBase> routes) {
        for (final route in routes) {
          if (route is GoRoute) paths.add(route.path);
          collect(route.routes);
        }
      }

      collect(router.configuration.routes);
      expect(
        paths,
        containsAll(<String>{
          AppRouteNames.profile,
          AppRouteNames.editProfile,
          AppRouteNames.personalShowcase,
          AppRouteNames.settings,
        }),
      );
    },
  );

  testWidgets('opening the real Edit Profile page preserves existing values', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(
            _ExistingDetailRepository(),
          ),
          localStorageProvider.overrideWithValue(_FakeLocalStorageService()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const EditProfilePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    expect(tester.widget<TextField>(fields.at(0)).controller!.text, '保留昵称');
    expect(
      tester.widget<TextField>(fields.at(1)).controller!.text,
      '1995-05-06',
    );
    expect(tester.widget<TextField>(fields.at(2)).controller!.text, '08:30');
    expect(tester.widget<TextField>(fields.at(3)).controller!.text, '浙江省杭州市');
    expect(tester.widget<TextField>(fields.at(4)).controller!.text, '杭州');
  });

  testWidgets(
    'R3 disposable smoke closes questionnaire to fresh eligibility loop',
    (tester) async {
      final sessionStorage = await _sessionStorage();
      final questionnaireRepository = _SmokeQuestionnaireRepository();
      var profileRequests = 0;
      final eligible = _summary.copyWithReadinessForTest(
        const ProfileReadinessEntity(
          contractVersion: 'profile_readiness_v1',
          matchingEligibility: MatchingEligibilityEntity(
            eligible: true,
            reasonCode: 'eligible',
            nextActionCode: 'wait_for_matching',
          ),
        ),
      );
      final router = GoRouter(
        initialLocation: AppRouteNames.profile,
        routes: [
          GoRoute(
            path: AppRouteNames.profile,
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: AppRouteNames.questionnaire,
            builder: (context, state) => const QuestionnairePage(),
          ),
          GoRoute(
            path: AppRouteNames.questionnaireResult,
            builder: (context, state) => const QuestionnaireResultPage(),
          ),
          GoRoute(
            path: AppRouteNames.match,
            builder: (context, state) =>
                const Scaffold(body: Text('CANONICAL MATCHING SURFACE')),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageProvider.overrideWithValue(sessionStorage.localStorage),
            secureStorageProvider.overrideWithValue(
              sessionStorage.secureStorage,
            ),
            apiClientProvider.overrideWithValue(_FakeApiClient()),
            questionnaireProvider.overrideWith(_SmokeQuestionnaireNotifier.new),
            submitQuestionnaireUseCaseProvider.overrideWithValue(
              SubmitQuestionnaireUseCase(questionnaireRepository),
            ),
            profileProvider.overrideWith((ref) async {
              profileRequests += 1;
              if (profileRequests == 1) {
                return const ProfileUiState(summary: _summary);
              }
              if (profileRequests == 2) {
                return const ProfileUiState(
                  summary: _summary,
                  error: 'temporary transport failure',
                );
              }
              return ProfileUiState(summary: eligible);
            }),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('继续完成问卷'), findsOneWidget);
      expect(find.text('进入匹配'), findsNothing);
      await tester.tap(find.text('继续完成问卷'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('答案 A'));
      for (var i = 0; i < 20; i += 1) {
        await tester.pump(const Duration(milliseconds: 100));
        if (router.routeInformationProvider.value.uri.path ==
            AppRouteNames.questionnaireResult) {
          break;
        }
      }
      await tester.pump(const Duration(seconds: 1));

      expect(questionnaireRepository.submittedAnswers, 1);
      expect(
        router.routeInformationProvider.value.uri.path,
        AppRouteNames.questionnaireResult,
      );
      expect(find.text('查看匹配资格'), findsOneWidget);
      await tester.ensureVisible(find.text('查看匹配资格'));
      await tester.pump();
      await tester.tap(find.text('查看匹配资格'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(profileRequests, 2);
      expect(find.text('匹配资格暂不可用'), findsOneWidget);
      expect(find.text('进入匹配'), findsNothing);
      await tester.drag(find.byType(ListView), const Offset(0, 320));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(profileRequests, 3);
      expect(find.text('进入匹配'), findsOneWidget);
      await tester.tap(find.text('进入匹配'));
      await tester.pumpAndSettle();
      expect(find.text('CANONICAL MATCHING SURFACE'), findsOneWidget);
    },
    tags: const ['r3_smoke'],
  );

  testWidgets(
    'ProfilePage separates server eligibility from publication truth',
    (tester) async {
      await tester.pumpWidget(await _wrap());
      await tester.pumpAndSettle();

      expect(find.text('还不能参与匹配'), findsOneWidget);
      expect(find.text('还需完成 3 项匹配问卷'), findsOneWidget);
      expect(find.text('Showcase：审核中，内容仍为私密'), findsOneWidget);
      expect(find.text('Showcase 状态不改变匹配资格'), findsOneWidget);
      expect(find.text('继续完成问卷'), findsOneWidget);
    },
  );

  testWidgets('ProfilePage routes the canonical incomplete action', (
    tester,
  ) async {
    await tester.pumpWidget(await _wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('继续完成问卷'));
    await tester.pumpAndSettle();

    expect(find.text('QUESTIONNAIRE ROUTE'), findsOneWidget);
  });

  testWidgets('ProfilePage exposes Matching only for fresh eligible truth', (
    tester,
  ) async {
    final eligible = _summary.copyWithReadinessForTest(
      const ProfileReadinessEntity(
        contractVersion: 'profile_readiness_v1',
        matchingEligibility: MatchingEligibilityEntity(
          eligible: true,
          reasonCode: 'eligible',
          nextActionCode: 'wait_for_matching',
        ),
      ),
    );
    await tester.pumpWidget(
      await _wrap(profileState: ProfileUiState(summary: eligible)),
    );
    await tester.pumpAndSettle();

    expect(find.text('进入匹配'), findsOneWidget);
    expect(find.text('继续完成问卷'), findsNothing);
    await tester.tap(find.text('进入匹配'));
    await tester.pumpAndSettle();

    expect(find.text('MATCH ROUTE'), findsOneWidget);
  });

  testWidgets(
    'ProfilePage does not present cached eligibility as fresh truth',
    (tester) async {
      await tester.pumpWidget(
        await _wrap(
          profileState: const ProfileUiState(
            summary: _summary,
            error: 'transport offline',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('匹配资格暂不可用'), findsOneWidget);
      expect(find.text('还不能参与匹配'), findsNothing);
      expect(find.text('继续完成问卷'), findsNothing);
      expect(find.text('进入匹配'), findsNothing);
    },
  );

  testWidgets(
    'ProfilePage fails closed on an unexpected publication relationship',
    (tester) async {
      const unexpected = ProfileSummaryEntity(
        nickname: '测试用户',
        birthday: '1995-12-03',
        birthTime: '08:30',
        birthPlace: '武汉',
        birthLat: 30.5928,
        birthLng: 114.3055,
        city: '武汉',
        target: '认真关系',
        verified: true,
        moderationStatus: 'normal',
        moderationNote: null,
        completion: 0.78,
        tags: <String>[],
        readiness: ProfileReadinessEntity(
          contractVersion: 'profile_readiness_v1',
          matchingEligibility: MatchingEligibilityEntity(eligible: true),
          showcase: ShowcaseReadinessEntity(affectsMatchingEligibility: true),
        ),
      );
      await tester.pumpWidget(
        await _wrap(profileState: const ProfileUiState(summary: unexpected)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Showcase 与匹配资格的关系暂不可确认，请刷新'), findsOneWidget);
      expect(find.text('Showcase 状态不改变匹配资格'), findsNothing);
    },
  );

  testWidgets('ProfilePage presents F2 personal preparation hierarchy', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(await _wrap());
    await tester.pumpAndSettle();

    expect(find.text('我的'), findsOneWidget);
    expect(find.text('示例用户'), findsOneWidget);
    expect(find.text('SmokeUser22'), findsNothing);
    expect(find.text('南阳'), findsOneWidget);
    expect(find.text('Nanyang'), findsNothing);

    expect(find.text('可选表达与参考'), findsOneWidget);
    expect(find.text('基础资料'), findsOneWidget);
    expect(find.text('编辑个人资料'), findsOneWidget);
    expect(find.text('个人展示'), findsOneWidget);
    expect(find.text('星盘关系参考'), findsOneWidget);
    expect(find.text('仅作理解参考，不决定匹配或关系结果'), findsOneWidget);
    expect(find.text('星盘'), findsNothing);
    expect(find.text('查看星盘'), findsNothing);
    expect(find.text('进入'), findsNothing);
    expect(find.text('更多'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
    expect(find.text('帮助与说明'), findsNothing);
    expect(find.text('体验反馈'), findsNothing);
    expect(find.text('版本中心'), findsNothing);
    expect(find.byType(AppInfoSectionCard), findsNWidgets(4));
    final copy = _visibleText(tester);
    for (final forbidden in ['完成度', '准备度', '排名', '提高匹配', '保证成功']) {
      expect(copy, isNot(contains(forbidden)));
    }
  });

  testWidgets('ProfilePage removes heavy showcase and reference modules', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(await _wrap());
    await tester.pumpAndSettle();

    final visibleText = _visibleText(tester);
    for (final removed in [
      '整理资料草稿',
      '准备线索',
      '入口线索',
      '自我介绍',
      '生活方式',
      '照片/头像',
      '约会参考与线索',
      '关系目标',
      '基础展示',
      '关键词',
      '生活线索',
      '表达线索',
      '慢约会准备',
      '本地草稿',
      '不会直接写入正式资料',
      '不会自动改推荐权重',
    ]) {
      expect(visibleText, isNot(contains(removed)));
    }
  });

  testWidgets('ProfilePage keeps simplified surface usable at narrow width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(await _wrap());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('星盘关系参考'), findsOneWidget);
    expect(find.text('可选表达与参考'), findsOneWidget);
    expect(find.text('个人展示'), findsOneWidget);
    expect(find.text('仅作理解参考，不决定匹配或关系结果'), findsOneWidget);
    expect(find.text('星盘'), findsNothing);
    expect(find.text('查看星盘'), findsNothing);
    expect(find.text('进入'), findsNothing);
    expect(find.byTooltip('打开设置'), findsOneWidget);
    final showcaseRow = find.ancestor(
      of: find.text('个人展示'),
      matching: find.byType(InkWell),
    );
    expect(tester.getSize(showcaseRow).height, greaterThanOrEqualTo(48));
    semantics.dispose();
  });

  testWidgets('ProfilePage tabs through personal-management actions', (
    tester,
  ) async {
    await tester.pumpWidget(await _wrap());
    await tester.pumpAndSettle();
    final labels = ['编辑个人资料', '个人展示', '星盘关系参考', '设置'];
    var next = 0;
    for (var press = 0; press < 20 && next < labels.length; press++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final focusedContext = tester.binding.focusManager.primaryFocus?.context;
      if (focusedContext != null &&
          find
              .descendant(
                of: find.byElementPredicate(
                  (element) => element == focusedContext,
                ),
                matching: find.text(labels[next]),
              )
              .evaluate()
              .isNotEmpty) {
        next++;
      }
    }
    expect(next, labels.length);
  });

  testWidgets('ProfilePage opens the secondary Astro reference', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(await _wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('星盘关系参考'));
    await tester.pumpAndSettle();

    expect(find.text('ASTRO OVERVIEW ROUTE'), findsOneWidget);
  });

  testWidgets('ProfilePage exposes exactly one Showcase route entry', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(await _wrap());
    await tester.pumpAndSettle();

    expect(find.text('个人展示'), findsOneWidget);
    await tester.tap(find.text('个人展示'));
    await tester.pumpAndSettle();
    expect(find.text('PERSONAL SHOWCASE ROUTE'), findsOneWidget);
  });

  testWidgets('ProfilePage exposes exactly one base-profile edit entry', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(await _wrap());
    await tester.pumpAndSettle();

    expect(find.text('编辑个人资料'), findsOneWidget);
    await tester.tap(find.text('编辑个人资料'));
    await tester.pumpAndSettle();
    expect(find.text('EDIT PROFILE ROUTE'), findsOneWidget);
  });

  testWidgets('ProfilePage keeps Settings route connected', (tester) async {
    await tester.pumpWidget(await _wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('打开设置'));
    await tester.pumpAndSettle();

    expect(find.text('SETTINGS ROUTE'), findsOneWidget);
  });

  testWidgets('ProfilePage keeps one Showcase entry when profile is empty', (
    tester,
  ) async {
    await tester.pumpWidget(
      await _wrap(profileState: const ProfileUiState(summary: null)),
    );
    await tester.pumpAndSettle();

    expect(find.text('个人展示'), findsOneWidget);
    expect(find.text('资料暂不可用'), findsOneWidget);
    await tester.tap(find.text('个人展示'));
    await tester.pumpAndSettle();
    expect(find.text('PERSONAL SHOWCASE ROUTE'), findsOneWidget);
  });

  testWidgets('ProfilePage keeps one Showcase entry after provider error', (
    tester,
  ) async {
    await tester.pumpWidget(await _wrap(profileThrows: true));
    await tester.pumpAndSettle();

    expect(find.text('个人展示'), findsOneWidget);
    expect(find.text('资料加载失败'), findsOneWidget);
    expect(find.textContaining('internal profile failure'), findsNothing);
    await tester.tap(find.text('个人展示'));
    await tester.pumpAndSettle();
    expect(find.text('PERSONAL SHOWCASE ROUTE'), findsOneWidget);
  });

  testWidgets('ProfilePage hides admin entry for ordinary user', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(await _wrap());
    await tester.pumpAndSettle();

    expect(find.text('管理入口'), findsNothing);
    expect(find.text('运营看板'), findsNothing);
    expect(find.textContaining('运营后台'), findsNothing);
    expect(find.text('设置'), findsOneWidget);
  });

  testWidgets(
    'ProfilePage shows admin management entry for admin session only',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(await _wrap(role: ' Admin '));
      await tester.pumpAndSettle();

      expect(find.text('运营工具'), findsOneWidget);
      expect(find.text('运营看板'), findsOneWidget);
      expect(find.textContaining('管理员可见的入口展示'), findsOneWidget);
      expect(
        _visibleText(tester).indexOf('运营工具'),
        greaterThan(_visibleText(tester).indexOf('设置')),
      );

      await tester.tap(find.text('运营看板'));
      await tester.pumpAndSettle();

      expect(find.text('ADMIN DASHBOARD ROUTE'), findsOneWidget);
    },
  );

  testWidgets(
    'ProfilePage shows admin entry when admin probe succeeds without cached admin role',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        await _wrap(role: 'user', adminProbeAllowed: true),
      );
      await tester.pumpAndSettle();

      expect(find.text('运营工具'), findsOneWidget);
      expect(find.text('运营看板'), findsOneWidget);
    },
  );
}

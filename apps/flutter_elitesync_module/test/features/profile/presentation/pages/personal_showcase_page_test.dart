import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_showcase_draft_entity.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_showcase_publication_entity.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_summary_entity.dart';
import 'package:flutter_elitesync_module/features/profile/domain/repository/profile_showcase_draft_repository.dart';
import 'package:flutter_elitesync_module/features/profile/domain/repository/profile_showcase_publication_repository.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/personal_showcase_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/profile_showcase_draft_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/state/personal_showcase_model.dart';
import 'package:flutter_test/flutter_test.dart';

const _summary = ProfileSummaryEntity(
  nickname: '星语者',
  birthday: '1998-11-25',
  birthTime: '20:30',
  birthPlace: '南阳',
  city: '南阳市',
  target: 'dating',
  verified: true,
  moderationStatus: 'normal',
  moderationNote: null,
  completion: 0.78,
  tags: ['ENFJ', '慢热', '周末咖啡'],
);

Widget _wrap(PersonalShowcaseSnapshot snapshot) {
  return ProviderScope(
    overrides: [
      profileShowcaseDraftRepositoryProvider.overrideWithValue(
        _FakeDraftRepository(),
      ),
      profileShowcasePublicationRepositoryProvider.overrideWithValue(
        _FakePublicationRepository(),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      home: PersonalShowcasePage(snapshotOverride: snapshot),
    ),
  );
}

Widget _wrapWithRepo(
  PersonalShowcaseSnapshot snapshot,
  _FakeDraftRepository repo,
) {
  return ProviderScope(
    overrides: [
      profileShowcaseDraftRepositoryProvider.overrideWithValue(repo),
      profileShowcasePublicationRepositoryProvider.overrideWithValue(
        _FakePublicationRepository(),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      home: PersonalShowcasePage(snapshotOverride: snapshot),
    ),
  );
}

Widget _wrapWithRepos(
  PersonalShowcaseSnapshot snapshot,
  _FakeDraftRepository draftRepo,
  _FakePublicationRepository publicationRepo,
) {
  return ProviderScope(
    overrides: [
      profileShowcaseDraftRepositoryProvider.overrideWithValue(draftRepo),
      profileShowcasePublicationRepositoryProvider.overrideWithValue(
        publicationRepo,
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      home: PersonalShowcasePage(snapshotOverride: snapshot),
    ),
  );
}

class _FakeDraftRepository implements ProfileShowcaseDraftRepository {
  ProfileShowcaseDraftEntity? draft;
  ProfileShowcaseDraftInput? savedInput;
  bool throwOnSave = false;
  bool throwOnSubmit = false;
  int submitCount = 0;

  @override
  Future<ProfileShowcaseDraftEntity?> getDraft() async => draft;

  @override
  Future<ProfileShowcaseDraftEntity?> saveDraft(
    ProfileShowcaseDraftInput input,
  ) async {
    if (throwOnSave) {
      throw Exception('Service unavailable');
    }
    savedInput = input;
    draft = ProfileShowcaseDraftEntity(
      id: 1,
      selfIntro: input.selfIntro,
      interestTags: input.interestTags,
      lifestyleTags: input.lifestyleTags,
      openerNote: input.openerNote,
      updatedAt: DateTime.utc(2026, 6, 15),
    );
    return draft;
  }

  @override
  Future<ProfileShowcaseDraftEntity?> submitForReview() async {
    submitCount += 1;
    if (throwOnSubmit) {
      throw Exception('Connection timeout');
    }
    final current =
        draft ?? const ProfileShowcaseDraftEntity(selfIntro: '私有草稿');
    draft = ProfileShowcaseDraftEntity(
      id: current.id,
      selfIntro: current.selfIntro,
      interestTags: current.interestTags,
      lifestyleTags: current.lifestyleTags,
      openerNote: current.openerNote,
      moderationStatus: 'pending',
      publicDisplayEligible: false,
      matchingScoringEligible: false,
      updatedAt: DateTime.utc(2026, 6, 15, 12),
    );
    return draft;
  }

  @override
  Future<void> clearDraft() async {
    draft = null;
  }
}

class _FakePublicationRepository
    implements ProfileShowcasePublicationRepository {
  _FakePublicationRepository();

  ProfileShowcasePublicationEntity publication =
      ProfileShowcasePublicationEntity.notPublished;
  bool throwOnGet = false;
  int publishCount = 0;

  @override
  Future<ProfileShowcasePublicationEntity> getPublication() async {
    if (throwOnGet) {
      throw Exception('Service unavailable');
    }
    return publication;
  }

  @override
  Future<ProfileShowcasePublicationEntity> publishApprovedDraft() async {
    publishCount += 1;
    publication = const ProfileShowcasePublicationEntity(
      id: 22,
      sourceDraftId: 4,
      publicationStatus: 'published',
      moderationStatus: 'approved',
      publicDisplayEligible: true,
      matchingScoringEligible: false,
    );
    return publication;
  }
}

String _visibleText(WidgetTester tester) {
  return tester
      .widgetList<Text>(find.byType(Text))
      .map((text) => text.data ?? '')
      .where((text) => text.isNotEmpty)
      .join('\n');
}

void main() {
  for (final config in const [
    (name: 'normal width', size: Size(400, 1400), textScale: 1.0),
    (name: 'approximately 320dp', size: Size(320, 1400), textScale: 1.0),
    (name: '1.3x large text', size: Size(400, 1400), textScale: 1.3),
  ]) {
    testWidgets(
      'PersonalShowcasePage exposes complete field explanations at ${config.name}',
      (tester) async {
        tester.view.physicalSize = config.size;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = config.textScale;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final semantics = tester.ensureSemantics();

        final snapshot = PersonalShowcaseSnapshot.fromProfile(
          summary: _summary,
        );
        await tester.pumpWidget(_wrap(snapshot));
        await tester.pumpAndSettle();

        const privacyCopy = '用顿号或逗号分隔；保存为用户确认的私有草稿。';
        const matchCopy = '只作为展示线索，不会改变匹配结果。';
        expect(find.text(privacyCopy), findsOneWidget);
        expect(find.text(matchCopy), findsOneWidget);
        expect(find.textContaining('私有草稿…'), findsNothing);
        expect(find.textContaining('匹配结果…'), findsNothing);
        await tester.ensureVisible(find.text(privacyCopy));
        await tester.pump();
        expect(find.bySemanticsLabel('兴趣标签。$privacyCopy'), findsOneWidget);
        await tester.ensureVisible(find.text(matchCopy));
        await tester.pump();
        expect(find.bySemanticsLabel('生活线索。$matchCopy'), findsOneWidget);

        final privacyText = tester.widget<Text>(find.text(privacyCopy));
        final matchText = tester.widget<Text>(find.text(matchCopy));
        expect(privacyText.maxLines, isNull);
        expect(privacyText.overflow, isNull);
        expect(matchText.maxLines, isNull);
        expect(matchText.overflow, isNull);
        expect(tester.takeException(), isNull);
        semantics.dispose();
      },
    );
  }

  testWidgets('PersonalShowcasePage stays usable at narrow width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    final snapshot = PersonalShowcaseSnapshot.fromProfile(summary: _summary);
    await tester.pumpWidget(_wrap(snapshot));
    await tester.pumpAndSettle();

    expect(find.text('保存私有草稿'), findsOneWidget);
    expect(find.text('保存为私有草稿'), findsOneWidget);
    expect(find.text('展示自己'), findsOneWidget);
    expect(find.text('聊天开场话题'), findsOneWidget);
    expect(find.text('低压开场线索'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('PersonalShowcasePage shows local draft boundary', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final snapshot = PersonalShowcaseSnapshot.fromProfile(summary: _summary);

    await tester.pumpWidget(_wrap(snapshot));
    await tester.pumpAndSettle();

    expect(find.text('继续整理展示内容'), findsOneWidget);
    expect(find.textContaining('下一步可以补充'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.textContaining('% ·'), findsNothing);
    expect(find.text('本地草稿'), findsWidgets);
    expect(find.text('保存私有草稿'), findsOneWidget);
    expect(find.text('保存为私有草稿'), findsOneWidget);
    expect(find.textContaining('不会自动发送'), findsWidgets);
    expect(find.textContaining('不会改变匹配结果'), findsWidgets);
    expect(find.textContaining('推荐评分'), findsNothing);
    expect(find.textContaining('匹配权重'), findsNothing);
    expect(find.textContaining('不会自动改推荐权重'), findsNothing);
    expect(find.textContaining('后续可基于你的确认生成展示标签'), findsNothing);
    expect(find.text('保存后再提交审核'), findsOneWidget);
    expect(find.text('提交安全审核'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('展示边界'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('展示边界'), findsOneWidget);
    expect(
      find.textContaining(
        '这些信息帮助别人理解你，不保证匹配结果；也不会自动保存为新的个人资料。星盘内容只作为关系参考，不替你做决定。',
      ),
      findsOneWidget,
    );
    expect(find.text('查看星盘关系参考'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('PersonalShowcasePage avoids misleading local draft claims', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final snapshot = PersonalShowcaseSnapshot.fromProfile(
      summary: const ProfileSummaryEntity(
        nickname: '星语者',
        birthday: '1998-11-25',
        birthTime: '20:30',
        birthPlace: '南阳',
        city: '',
        target: '',
        verified: true,
        moderationStatus: 'normal',
        moderationNote: null,
        completion: 0.34,
        tags: [],
      ),
    );

    await tester.pumpWidget(_wrap(snapshot));
    await tester.pumpAndSettle();

    final visibleText = _visibleText(tester);
    expect(visibleText, contains('还没有保存过私有草稿'));
    expect(visibleText, isNot(contains('后续可基于你的确认生成展示标签')));

    for (final forbidden in [
      '已保存到服务端',
      '已保存',
      '已同步',
      '已通过内容安全',
      '内容安全已通过',
      '已公开',
      '已发布',
      '已生成真实标签',
      '已更新推荐权重',
      '已用于推荐',
      '算法已学习',
      '资料已生效',
      '永久保存',
    ]) {
      expect(visibleText, isNot(contains(forbidden)));
    }
  });

  testWidgets('PersonalShowcasePage saves and clears private draft safely', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = _FakeDraftRepository();
    final snapshot = PersonalShowcaseSnapshot.fromProfile(summary: _summary);

    await tester.pumpWidget(_wrapWithRepo(snapshot, repo));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '我喜欢慢慢认识人');
    await tester.enterText(find.byType(TextField).at(1), '咖啡、徒步');
    await tester.scrollUntilVisible(
      find.text('聊天开场话题').first,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    final openerField = find.byType(TextField).at(3);
    await tester.enterText(openerField, '可以先聊聊最近喜欢的咖啡');
    await tester.scrollUntilVisible(
      find.text('保存为私有草稿').first,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('保存为私有草稿'));
    await tester.pumpAndSettle();

    expect(repo.savedInput?.selfIntro, '我喜欢慢慢认识人');
    expect(repo.savedInput?.interestTags, ['咖啡', '徒步']);
    expect(repo.savedInput?.openerNote, '可以先聊聊最近喜欢的咖啡');
    expect(find.text('私有草稿'), findsWidgets);
    expect(find.textContaining('不会公开展示'), findsWidgets);
    expect(find.textContaining('尚未提交安全审核'), findsWidgets);
    expect(find.textContaining('不会改变匹配结果'), findsWidgets);

    await tester.tap(find.text('清除私有草稿'));
    await tester.pumpAndSettle();
    expect(find.text('清除这份私有草稿？'), findsOneWidget);
    expect(find.textContaining('正式资料、星盘、推荐和聊天不会因此改变'), findsOneWidget);
    await tester.tap(find.text('清除私有草稿').last);
    await tester.pumpAndSettle();

    expect(repo.draft, isNull);
    expect(find.text('私有草稿已清除。'), findsOneWidget);
  });

  testWidgets('PersonalShowcasePage submits private draft with pending copy', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = _FakeDraftRepository()
      ..draft = const ProfileShowcaseDraftEntity(
        id: 2,
        selfIntro: '准备提交审核的私有草稿',
      );
    final snapshot = PersonalShowcaseSnapshot.fromProfile(summary: _summary);

    await tester.pumpWidget(_wrapWithRepo(snapshot, repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('提交安全审核'));
    await tester.pumpAndSettle();

    expect(find.text('已提交审核，等待处理'), findsWidgets);
    expect(find.textContaining('仍是私有草稿'), findsOneWidget);
    expect(find.textContaining('审核完成前不会发布'), findsWidgets);
    expect(find.textContaining('不会改变匹配结果'), findsWidgets);
  });

  testWidgets(
    'PersonalShowcasePage displays review result without publish claim',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repo = _FakeDraftRepository()
        ..draft = const ProfileShowcaseDraftEntity(
          id: 4,
          selfIntro: '已经审核通过但仍然私有',
          moderationStatus: 'approved',
          publicDisplayEligible: false,
          matchingScoringEligible: false,
        );
      final snapshot = PersonalShowcaseSnapshot.fromProfile(summary: _summary);

      await tester.pumpWidget(_wrapWithRepo(snapshot, repo));
      await tester.pumpAndSettle();

      final visibleText = _visibleText(tester);
      expect(visibleText, contains('审核通过，仍是私有草稿'));
      expect(visibleText, contains('审核已通过，但当前状态尚未提供发布确认'));
      expect(visibleText, contains('仍是私有草稿，也不会改变匹配结果'));
      expect(visibleText, isNot(contains('可展示，暂不公开')));
      expect(find.text('手动打开这份可展示草稿'), findsNothing);
      expect(visibleText, isNot(contains('已公开')));
      expect(visibleText, isNot(contains('已发布')));
      expect(visibleText, isNot(contains('已用于推荐')));
    },
  );

  testWidgets('PersonalShowcasePage keeps approved edits private', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = _FakeDraftRepository()
      ..draft = const ProfileShowcaseDraftEntity(
        id: 8,
        selfIntro: '已经审核通过但仍然私有',
        moderationStatus: 'approved',
        publicDisplayEligible: false,
        matchingScoringEligible: false,
      );
    final snapshot = PersonalShowcaseSnapshot.fromProfile(summary: _summary);

    await tester.pumpWidget(_wrapWithRepo(snapshot, repo));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '我想补充新的私有表达');
    await tester.pumpAndSettle();

    final visibleText = _visibleText(tester);
    expect(visibleText, contains('上一版审核通过不代表新内容可以发布'));
    expect(visibleText, contains('审核通过，仍是私有草稿'));
    expect(visibleText, isNot(contains('可展示，暂不公开')));
    expect(visibleText, isNot(contains('已公开')));
    expect(visibleText, isNot(contains('已用于推荐')));
  });

  testWidgets('PersonalShowcasePage displays revision guidance safely', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = _FakeDraftRepository()
      ..draft = const ProfileShowcaseDraftEntity(
        id: 5,
        selfIntro: '需要修改的私有草稿',
        moderationStatus: 'needs_revision',
      );
    final snapshot = PersonalShowcaseSnapshot.fromProfile(summary: _summary);

    await tester.pumpWidget(_wrapWithRepo(snapshot, repo));
    await tester.pumpAndSettle();

    final visibleText = _visibleText(tester);
    expect(visibleText, contains('需要修改后再提交审核'));
    expect(visibleText, contains('重新提交审核'));
    expect(visibleText, contains('当前仍是私有草稿'));
    expect(visibleText, contains('当前仍不会公开展示'));
    expect(visibleText, contains('也不会改变匹配结果'));
  });

  testWidgets('PersonalShowcasePage resubmits rejected private draft safely', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = _FakeDraftRepository()
      ..draft = const ProfileShowcaseDraftEntity(
        id: 6,
        selfIntro: '可以重新提交的私有草稿',
        moderationStatus: 'rejected',
      );
    final snapshot = PersonalShowcaseSnapshot.fromProfile(summary: _summary);

    await tester.pumpWidget(_wrapWithRepo(snapshot, repo));
    await tester.pumpAndSettle();

    expect(find.text('重新提交审核'), findsOneWidget);
    expect(find.textContaining('不会改变匹配结果'), findsWidgets);

    await tester.tap(find.text('重新提交审核'));
    await tester.pumpAndSettle();

    expect(repo.submitCount, 1);
    expect(find.text('已提交审核，等待处理'), findsWidgets);
    expect(find.textContaining('仍是私有草稿'), findsWidgets);
    expect(find.textContaining('不会改变匹配结果'), findsWidgets);
  });

  testWidgets('PersonalShowcasePage disables unsafe review-result CTAs', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = _FakeDraftRepository()
      ..draft = const ProfileShowcaseDraftEntity(
        id: 7,
        selfIntro: '等待审核的私有草稿',
        moderationStatus: 'pending',
      );
    final snapshot = PersonalShowcaseSnapshot.fromProfile(summary: _summary);

    await tester.pumpWidget(_wrapWithRepo(snapshot, repo));
    await tester.pumpAndSettle();

    final visibleText = _visibleText(tester);
    expect(visibleText, contains('刷新审核状态'));
    expect(visibleText, contains('审核中，等待处理'));
    expect(visibleText, contains('审核中不会发布'));
    expect(visibleText, isNot(contains('公开展示成功')));

    await tester.tap(find.text('审核中，等待处理'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(repo.submitCount, 0);
  });

  testWidgets(
    'PersonalShowcasePage publishes approved draft after confirmation',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final draftRepo = _FakeDraftRepository()
        ..draft = const ProfileShowcaseDraftEntity(
          id: 4,
          selfIntro: '已经审核通过但仍然私有',
          moderationStatus: 'approved',
          publicDisplayEligible: true,
          matchingScoringEligible: false,
        );
      final publicationRepo = _FakePublicationRepository();
      final snapshot = PersonalShowcaseSnapshot.fromProfile(summary: _summary);

      await tester.pumpWidget(
        _wrapWithRepos(snapshot, draftRepo, publicationRepo),
      );
      await tester.pumpAndSettle();

      expect(find.text('确认发布这份审核通过的草稿'), findsOneWidget);
      expect(find.textContaining('审核通过，可确认发布'), findsWidgets);
      expect(find.textContaining('发布仍需要你单独确认'), findsOneWidget);

      await tester.tap(find.text('确认发布这份审核通过的草稿'));
      await tester.pumpAndSettle();
      expect(find.text('确认发布这份草稿？'), findsOneWidget);
      expect(find.textContaining('不承诺对其他用户的可见范围'), findsOneWidget);
      expect(find.textContaining('不会改变匹配结果'), findsWidgets);

      await tester.tap(find.text('确认发布'));
      await tester.pumpAndSettle();

      expect(publicationRepo.publishCount, 1);
      expect(find.text('已发布版本'), findsWidgets);
      expect(find.textContaining('不会改变匹配结果'), findsWidgets);
      expect(find.textContaining('已用于推荐'), findsNothing);
    },
  );

  testWidgets(
    'PersonalShowcasePage hides publish CTA in unavailable and no draft states',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final draftRepo = _FakeDraftRepository();
      final publicationRepo = _FakePublicationRepository()
        ..publication = const ProfileShowcasePublicationEntity(
          publicationStatus: 'unavailable',
        );
      final snapshot = PersonalShowcaseSnapshot.fromProfile(summary: _summary);

      await tester.pumpWidget(
        _wrapWithRepos(snapshot, draftRepo, publicationRepo),
      );
      await tester.pumpAndSettle();

      final visibleText = _visibleText(tester);
      expect(visibleText, contains('暂不可确认发布'));
      expect(visibleText, contains('还没有保存过私有草稿'));
      expect(find.text('刷新发布状态'), findsOneWidget);
      expect(find.text('确认发布这份审核通过的草稿'), findsNothing);

      await tester.tap(find.text('刷新发布状态'));
      await tester.pumpAndSettle();
      expect(publicationRepo.publishCount, 0);
    },
  );

  testWidgets(
    'PersonalShowcasePage hides publish CTA when publication status fails',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final draftRepo = _FakeDraftRepository()
        ..draft = const ProfileShowcaseDraftEntity(
          id: 5,
          selfIntro: '已经审核通过但公开状态不可用',
          moderationStatus: 'approved',
        );
      final publicationRepo = _FakePublicationRepository()..throwOnGet = true;
      final snapshot = PersonalShowcaseSnapshot.fromProfile(summary: _summary);

      await tester.pumpWidget(
        _wrapWithRepos(snapshot, draftRepo, publicationRepo),
      );
      await tester.pumpAndSettle();

      final visibleText = _visibleText(tester);
      expect(visibleText, contains('发布状态暂不可用'));
      expect(find.text('刷新发布状态'), findsOneWidget);
      expect(find.text('确认发布这份审核通过的草稿'), findsNothing);
    },
  );

  testWidgets(
    'PersonalShowcasePage reframes submit review after save unavailable',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repo = _FakeDraftRepository()..throwOnSave = true;
      final snapshot = PersonalShowcaseSnapshot.fromProfile(summary: _summary);

      await tester.pumpWidget(_wrapWithRepo(snapshot, repo));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), '失败后保留这段草稿');
      await tester.tap(find.text('保存为私有草稿'));
      await tester.pumpAndSettle();

      final visibleText = _visibleText(tester);
      expect(visibleText, contains('服务暂时不可用，请稍后再保存私有草稿。'));
      expect(visibleText, contains('保存失败时不会提交安全审核'));
      expect(find.text('重试保存私有草稿'), findsOneWidget);
      expect(find.text('保存为私有草稿'), findsNothing);
      expect(find.text('状态恢复后再提交审核'), findsOneWidget);
      expect(find.text('提交安全审核'), findsNothing);

      await tester.tap(find.text('状态恢复后再提交审核'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(repo.submitCount, 0);

      repo.throwOnSave = false;
      await tester.tap(find.text('重试保存私有草稿'));
      await tester.pumpAndSettle();
      expect(repo.savedInput?.selfIntro, '失败后保留这段草稿');
      expect(find.text('重试保存私有草稿'), findsNothing);
    },
  );

  testWidgets(
    'PersonalShowcasePage keeps manual review conservative and clear scoped',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repo = _FakeDraftRepository()
        ..draft = const ProfileShowcaseDraftEntity(
          id: 9,
          selfIntro: '人工复核中的私有草稿',
          moderationStatus: 'manual_review_required',
        );
      final snapshot = PersonalShowcaseSnapshot.fromProfile(summary: _summary);

      await tester.pumpWidget(_wrapWithRepo(snapshot, repo));
      await tester.pumpAndSettle();

      final visibleText = _visibleText(tester);
      expect(visibleText, contains('人工复核中'));
      expect(visibleText, contains('不要重复提交或假设结果'));
      expect(visibleText, isNot(contains('审核员')));
      expect(visibleText, isNot(contains('服务商')));
      expect(visibleText, isNot(contains('审计记录')));

      await tester.tap(find.text('人工复核中'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(repo.submitCount, 0);

      await tester.tap(find.text('清除私有草稿'));
      await tester.pumpAndSettle();
      expect(find.text('清除这份私有草稿？'), findsOneWidget);
      expect(find.textContaining('不会改变人工复核状态'), findsOneWidget);
      expect(find.textContaining('审核记录'), findsNothing);
    },
  );

  testWidgets('PersonalShowcasePage submit error does not claim success', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = _FakeDraftRepository()
      ..draft = const ProfileShowcaseDraftEntity(
        id: 3,
        selfIntro: '准备提交审核的私有草稿',
      )
      ..throwOnSubmit = true;
    final snapshot = PersonalShowcaseSnapshot.fromProfile(summary: _summary);

    await tester.pumpWidget(_wrapWithRepo(snapshot, repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('提交安全审核'));
    await tester.pumpAndSettle();

    final visibleText = _visibleText(tester);
    expect(visibleText, contains('当前草稿还没有提交安全审核'));
    expect(visibleText, isNot(contains('已提交审核，等待处理')));
    expect(visibleText, isNot(contains('可展示前不会打开展示')));
  });
}

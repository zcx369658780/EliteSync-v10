import 'dart:async';
import 'dart:ui' show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/onboarding/application/first_use_onboarding_coordinator.dart';
import 'package:flutter_elitesync_module/features/onboarding/presentation/first_use_onboarding_page.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLocalStorageService extends LocalStorageService {
  String? value;
  bool throwOnWrite = false;
  bool neverCompleteWrite = false;
  int readCount = 0;
  int writeCount = 0;

  @override
  Future<String?> getString(String key) async {
    expect(key, CacheKeys.firstUseOnboardingV1Status);
    readCount += 1;
    return value;
  }

  @override
  Future<bool> setString(String key, String value) async {
    expect(key, CacheKeys.firstUseOnboardingV1Status);
    writeCount += 1;
    if (throwOnWrite) throw StateError('write failed');
    if (neverCompleteWrite) return Completer<bool>().future;
    this.value = value;
    return true;
  }
}

Future<void> _pumpLauncher(
  WidgetTester tester, {
  required _FakeLocalStorageService storage,
  required FirstUseOnboardingMode mode,
  bool disableAnimations = false,
  ValueNotifier<FirstUseOnboardingResult?>? result,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(disableAnimations: disableAnimations),
        child: child!,
      ),
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () async {
                final onboardingResult = await showFirstUseOnboarding(
                  context: context,
                  storage: storage,
                  mode: mode,
                );
                result?.value = onboardingResult;
              },
              child: const Text('OPEN'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('OPEN'));
  await tester.pumpAndSettle();
}

Widget _automaticEntryApp({
  required _FakeLocalStorageService storage,
  required bool eligible,
}) {
  return MaterialApp(
    theme: AppTheme.light,
    home: FirstUseOnboardingAutomaticEntry(
      storage: storage,
      eligible: eligible,
      child: const Scaffold(body: Text('ORDINARY APP')),
    ),
  );
}

void main() {
  test('the public contract contains exactly five truthful steps', () {
    expect(firstUseOnboardingSteps, hasLength(5));
    expect(
      firstUseOnboardingSteps.map((step) => (step.title, step.body)).toList(),
      [
        ('先从慢约进展开始', '首页用于查看慢约进展和下一步。'),
        ('按需要完善资料', '资料由你填写；是否还需补充，以页面之后显示的可靠提示为准。'),
        ('等待可靠的进展通知', '有可确认的安排或结果时，页面会显示相应说明；也可能暂时没有结果。'),
        ('符合条件后再使用消息', '只有服务确认可以继续交流后，消息入口才会开放。'),
        ('随时跳过或重新查看', '你可以跳过；之后可在“设置 > 新手引导”重新查看。'),
      ],
    );

    final copy = firstUseOnboardingSteps
        .expand((step) => [step.title, step.body])
        .join('\n');
    expect(copy, contains('首页'));
    expect(copy, contains('慢约进展'));
    expect(copy, contains('消息'));
    expect(copy, isNot(contains('Profile')));
    expect(copy, isNot(contains('Match')));
    expect(copy, isNot(contains('Messages')));
    for (final forbidden in [
      '本轮',
      '倒计时',
      '候选人',
      '匹配已开启',
      '资料已完成',
      '低压等待',
      'waiting_drop',
      '资料真值',
    ]) {
      expect(copy, isNot(contains(forbidden)));
    }
  });

  testWidgets('next and back move through the five-step flow', (tester) async {
    final storage = _FakeLocalStorageService();
    await _pumpLauncher(
      tester,
      storage: storage,
      mode: FirstUseOnboardingMode.automatic,
    );

    expect(find.text('1/5'), findsOneWidget);
    expect(find.text('先从慢约进展开始'), findsOneWidget);
    expect(find.text('上一步'), findsNothing);

    await tester.tap(find.text('继续'));
    await tester.pumpAndSettle();
    expect(find.text('2/5'), findsOneWidget);
    expect(find.text('按需要完善资料'), findsOneWidget);
    expect(find.text('上一步'), findsOneWidget);

    await tester.tap(find.text('上一步'));
    await tester.pumpAndSettle();
    expect(find.text('1/5'), findsOneWidget);
  });

  testWidgets(
    'skip is available on every step and persists before dismissing',
    (tester) async {
      final storage = _FakeLocalStorageService();
      final result = ValueNotifier<FirstUseOnboardingResult?>(null);
      await _pumpLauncher(
        tester,
        storage: storage,
        mode: FirstUseOnboardingMode.automatic,
        result: result,
      );

      for (var index = 0; index < firstUseOnboardingSteps.length; index += 1) {
        expect(find.text('跳过'), findsOneWidget);
        if (index < firstUseOnboardingSteps.length - 1) {
          await tester.tap(find.text('继续'));
          await tester.pumpAndSettle();
        }
      }

      await tester.tap(find.text('跳过'));
      await tester.pumpAndSettle();
      expect(find.text('OPEN'), findsOneWidget);
      expect(storage.value, FirstUseOnboardingStatus.skipped);
      expect(result.value, FirstUseOnboardingResult.skipped);
    },
  );

  testWidgets('finish persists completion and returns to the invoking app', (
    tester,
  ) async {
    final storage = _FakeLocalStorageService();
    final result = ValueNotifier<FirstUseOnboardingResult?>(null);
    await _pumpLauncher(
      tester,
      storage: storage,
      mode: FirstUseOnboardingMode.automatic,
      result: result,
    );

    for (
      var index = 0;
      index < firstUseOnboardingSteps.length - 1;
      index += 1
    ) {
      await tester.tap(find.text('继续'));
      await tester.pumpAndSettle();
    }

    expect(find.text('完成'), findsOneWidget);
    await tester.tap(find.text('完成'));
    await tester.pumpAndSettle();
    expect(find.text('OPEN'), findsOneWidget);
    expect(storage.value, FirstUseOnboardingStatus.completed);
    expect(result.value, FirstUseOnboardingResult.completed);
  });

  testWidgets('finish write failure still dismisses automatic flow', (
    tester,
  ) async {
    final storage = _FakeLocalStorageService()..throwOnWrite = true;
    await _pumpLauncher(
      tester,
      storage: storage,
      mode: FirstUseOnboardingMode.automatic,
    );

    for (
      var index = 0;
      index < firstUseOnboardingSteps.length - 1;
      index += 1
    ) {
      await tester.tap(find.text('继续'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('完成'));
    await tester.pumpAndSettle();

    expect(storage.writeCount, 1);
    expect(find.text('OPEN'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('finish write timeout still dismisses automatic flow', (
    tester,
  ) async {
    final storage = _FakeLocalStorageService()..neverCompleteWrite = true;
    await _pumpLauncher(
      tester,
      storage: storage,
      mode: FirstUseOnboardingMode.automatic,
    );

    for (
      var index = 0;
      index < firstUseOnboardingSteps.length - 1;
      index += 1
    ) {
      await tester.tap(find.text('继续'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('完成'));
    await tester.pump(const Duration(milliseconds: 749));
    expect(find.text('随时跳过或重新查看'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2));
    await tester.pumpAndSettle();

    expect(storage.writeCount, 1);
    expect(find.text('OPEN'), findsOneWidget);
  });

  testWidgets('replay preserves completion state when skipped', (tester) async {
    final storage = _FakeLocalStorageService()
      ..value = FirstUseOnboardingStatus.completed;
    final result = ValueNotifier<FirstUseOnboardingResult?>(null);
    await _pumpLauncher(
      tester,
      storage: storage,
      mode: FirstUseOnboardingMode.replay,
      result: result,
    );

    await tester.tap(find.text('跳过'));
    await tester.pumpAndSettle();

    expect(storage.value, FirstUseOnboardingStatus.completed);
    expect(storage.writeCount, 0);
    expect(find.text('OPEN'), findsOneWidget);
    expect(result.value, FirstUseOnboardingResult.skipped);
  });

  testWidgets('replay finish preserves completion state and returns safely', (
    tester,
  ) async {
    final storage = _FakeLocalStorageService()
      ..value = FirstUseOnboardingStatus.completed;
    final result = ValueNotifier<FirstUseOnboardingResult?>(null);
    await _pumpLauncher(
      tester,
      storage: storage,
      mode: FirstUseOnboardingMode.replay,
      result: result,
    );

    for (
      var index = 0;
      index < firstUseOnboardingSteps.length - 1;
      index += 1
    ) {
      await tester.tap(find.text('继续'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('完成'));
    await tester.pumpAndSettle();

    expect(storage.value, FirstUseOnboardingStatus.completed);
    expect(storage.writeCount, 0);
    expect(find.text('OPEN'), findsOneWidget);
    expect(result.value, FirstUseOnboardingResult.completed);
  });

  testWidgets('write failure still dismisses automatic flow', (tester) async {
    final storage = _FakeLocalStorageService()..throwOnWrite = true;
    await _pumpLauncher(
      tester,
      storage: storage,
      mode: FirstUseOnboardingMode.automatic,
    );

    await tester.tap(find.text('跳过'));
    await tester.pumpAndSettle();

    expect(find.text('OPEN'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('never-completing write times out and still dismisses', (
    tester,
  ) async {
    final storage = _FakeLocalStorageService()..neverCompleteWrite = true;
    await _pumpLauncher(
      tester,
      storage: storage,
      mode: FirstUseOnboardingMode.automatic,
    );

    await tester.tap(find.text('跳过'));
    await tester.pump(const Duration(milliseconds: 749));
    expect(find.text('先从慢约进展开始'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('OPEN'), findsOneWidget);
    expect(storage.writeCount, 1);
  });

  testWidgets('system back follows safe skip persistence before returning', (
    tester,
  ) async {
    final storage = _FakeLocalStorageService();
    final result = ValueNotifier<FirstUseOnboardingResult?>(null);
    await _pumpLauncher(
      tester,
      storage: storage,
      mode: FirstUseOnboardingMode.automatic,
      result: result,
    );

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(storage.value, FirstUseOnboardingStatus.skipped);
    expect(find.text('OPEN'), findsOneWidget);
    expect(result.value, FirstUseOnboardingResult.skipped);
  });

  testWidgets('replay system back returns skipped without changing state', (
    tester,
  ) async {
    final storage = _FakeLocalStorageService()
      ..value = FirstUseOnboardingStatus.completed;
    final result = ValueNotifier<FirstUseOnboardingResult?>(null);
    await _pumpLauncher(
      tester,
      storage: storage,
      mode: FirstUseOnboardingMode.replay,
      result: result,
    );

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(result.value, FirstUseOnboardingResult.skipped);
    expect(storage.value, FirstUseOnboardingStatus.completed);
    expect(storage.writeCount, 0);
    expect(find.text('OPEN'), findsOneWidget);
  });

  testWidgets('reduced motion removes the step transition', (tester) async {
    final storage = _FakeLocalStorageService();
    await _pumpLauncher(
      tester,
      storage: storage,
      mode: FirstUseOnboardingMode.replay,
      disableAnimations: true,
    );

    expect(
      find.byKey(const Key('first-use-onboarding-transition')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('first-use-onboarding-scroll')),
      findsOneWidget,
    );
  });

  testWidgets('controls remain reachable on a small viewport', (tester) async {
    tester.view.physicalSize = const Size(320, 520);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final storage = _FakeLocalStorageService();

    await _pumpLauncher(
      tester,
      storage: storage,
      mode: FirstUseOnboardingMode.replay,
    );

    expect(find.text('跳过'), findsOneWidget);
    expect(find.text('继续'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('local actions and symbols use high-contrast theme token pairs', (
    tester,
  ) async {
    final storage = _FakeLocalStorageService();
    await _pumpLauncher(
      tester,
      storage: storage,
      mode: FirstUseOnboardingMode.replay,
    );

    final primaryFinder = find.byKey(
      const Key('first-use-onboarding-primary-action'),
    );
    final primaryMaterial = tester.widget<Material>(primaryFinder);
    final tokens = Theme.of(
      tester.element(primaryFinder),
    ).extension<AppThemeTokens>()!;
    final foreground = tokens.pageBackground;
    final background = primaryMaterial.color!;
    final lighter =
        foreground.computeLuminance() > background.computeLuminance()
        ? foreground.computeLuminance()
        : background.computeLuminance();
    final darker = foreground.computeLuminance() > background.computeLuminance()
        ? background.computeLuminance()
        : foreground.computeLuminance();

    expect((lighter + 0.05) / (darker + 0.05), greaterThanOrEqualTo(4.5));
    expect(tester.getSize(primaryFinder).height, greaterThanOrEqualTo(52));

    final skipFinder = find.byKey(
      const Key('first-use-onboarding-skip-action'),
    );
    final skip = tester.widget<TextButton>(skipFinder);
    expect(skip.style?.foregroundColor?.resolve({}), tokens.textPrimary);
    expect(tester.getSize(skipFinder).height, greaterThanOrEqualTo(48));

    final progress = tester.widget<LinearProgressIndicator>(
      find.byKey(const Key('first-use-onboarding-progress')),
    );
    expect(progress.color, tokens.textPrimary);

    final iconContainer = tester.widget<Container>(
      find.byKey(const Key('first-use-onboarding-step-icon')),
    );
    expect(
      (iconContainer.decoration! as BoxDecoration).color,
      tokens.textPrimary,
    );
    final icon = tester.widget<Icon>(
      find.descendant(
        of: find.byKey(const Key('first-use-onboarding-step-icon')),
        matching: find.byType(Icon),
      ),
    );
    expect(icon.color, tokens.pageBackground);
  });

  testWidgets('progress and controls expose one explicit semantic label', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final storage = _FakeLocalStorageService();
    await _pumpLauncher(
      tester,
      storage: storage,
      mode: FirstUseOnboardingMode.replay,
    );

    expect(find.bySemanticsLabel('第 1 步，共 5 步'), findsOneWidget);
    expect(find.bySemanticsLabel('跳过首次使用引导'), findsOneWidget);
    expect(find.bySemanticsLabel('进入下一步'), findsOneWidget);
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('跳过首次使用引导'))
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('进入下一步'))
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );

    await tester.tap(find.text('继续'));
    await tester.pumpAndSettle();
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('返回上一步'))
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );

    for (
      var index = 1;
      index < firstUseOnboardingSteps.length - 1;
      index += 1
    ) {
      await tester.tap(find.text('继续'));
      await tester.pumpAndSettle();
    }
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('完成首次使用引导'))
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );
    semantics.dispose();
  });

  testWidgets(
    'eligible automatic entry presents when revision state is absent',
    (tester) async {
      final storage = _FakeLocalStorageService();
      await tester.pumpWidget(
        _automaticEntryApp(storage: storage, eligible: true),
      );
      await tester.pumpAndSettle();

      expect(storage.readCount, 1);
      expect(find.text('先从慢约进展开始'), findsOneWidget);
      expect(find.text('ORDINARY APP'), findsOneWidget);
    },
  );

  testWidgets(
    'ineligible entry does not read state and presents when eligible',
    (tester) async {
      final storage = _FakeLocalStorageService();
      await tester.pumpWidget(
        _automaticEntryApp(storage: storage, eligible: false),
      );
      await tester.pumpAndSettle();

      expect(storage.readCount, 0);
      expect(find.text('先从慢约进展开始'), findsNothing);

      await tester.pumpWidget(
        _automaticEntryApp(storage: storage, eligible: true),
      );
      await tester.pumpAndSettle();

      expect(storage.readCount, 1);
      expect(find.text('先从慢约进展开始'), findsOneWidget);
    },
  );

  testWidgets('pre-auth surface without app shell never checks onboarding', (
    tester,
  ) async {
    final storage = _FakeLocalStorageService();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: Text('LOGIN')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('LOGIN'), findsOneWidget);
    expect(storage.readCount, 0);
    expect(find.text('先从慢约进展开始'), findsNothing);
  });

  testWidgets('stored handled state suppresses automatic presentation', (
    tester,
  ) async {
    final storage = _FakeLocalStorageService()
      ..value = FirstUseOnboardingStatus.completed;
    await tester.pumpWidget(
      _automaticEntryApp(storage: storage, eligible: true),
    );
    await tester.pumpAndSettle();

    expect(storage.readCount, 1);
    expect(find.text('ORDINARY APP'), findsOneWidget);
    expect(find.text('先从慢约进展开始'), findsNothing);
  });

  testWidgets('automatic entry rebuild remains idempotent in one session', (
    tester,
  ) async {
    final storage = _FakeLocalStorageService();
    await tester.pumpWidget(
      _automaticEntryApp(storage: storage, eligible: true),
    );
    await tester.pumpAndSettle();
    expect(storage.readCount, 1);

    await tester.pumpWidget(
      _automaticEntryApp(storage: storage, eligible: true),
    );
    await tester.pumpAndSettle();

    expect(storage.readCount, 1);
    expect(find.text('先从慢约进展开始'), findsOneWidget);
  });
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/verification/domain/entities/verification_state_entity.dart';
import 'package:flutter_elitesync_module/features/verification/domain/repository/verification_repository.dart';
import 'package:flutter_elitesync_module/features/verification/presentation/pages/verification_submit_page.dart';
import 'package:flutter_elitesync_module/features/verification/presentation/providers/verification_provider.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/enums/verification_status.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';

class _Session extends SessionNotifier {
  int intent = 0;
  @override
  int get currentAuthenticationIntent => intent;

  @override
  SessionState build() => const SessionState(
    status: AuthStatus.authenticated,
    user: UserSummary(id: 1, phone: 'fictional-one'),
    accessToken: 'fixture-session',
  );

  void updateSameAccount() => state = AsyncData(state.requireValue.copyWith());

  void reauthenticate() {
    intent++;
    updateSameAccount();
  }

  void change() => state = const AsyncData(
    SessionState(
      status: AuthStatus.authenticated,
      user: UserSummary(id: 2, phone: 'fictional-two'),
    ),
  );
}

class _Repository implements VerificationRepository {
  int posts = 0;
  bool failSubmit = false;
  bool failReadback = false;
  bool staleReadback = false;
  Completer<void>? delayed;

  @override
  Future<VerificationStateEntity> getStatus() async {
    if (posts > 0 && failReadback) throw StateError('readback failed');
    return VerificationStateEntity(
      status: posts > 0 && !staleReadback
          ? VerificationStatus.pendingReview
          : VerificationStatus.unverified,
      title: '测试状态',
      description: '虚构认证输入',
    );
  }

  @override
  Future<void> submit({
    required String realName,
    required String idNumber,
  }) async {
    posts++;
    expect(realName, '测试姓名');
    expect(idNumber, 'TEST-ID-001');
    if (failSubmit) throw StateError('submit failed');
    await delayed?.future;
  }
}

Future<GoRouter> _show(WidgetTester tester, _Repository repository) async {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: Text('认证入口')),
      ),
      GoRoute(
        path: '/submit',
        builder: (_, _) => const VerificationSubmitPage(),
      ),
      GoRoute(
        path: '/other',
        builder: (_, _) => const Scaffold(body: Text('其他页面')),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sessionProvider.overrideWith(_Session.new),
        verificationRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  router.push('/submit');
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField).at(0), '测试姓名');
  await tester.enterText(find.byType(TextField).at(1), 'TEST-ID-001');
  return router;
}

void main() {
  for (final change in ['profile', 'verification']) {
    testWidgets('POST receipt survives in-flight $change replacement', (
      tester,
    ) async {
      final repository = _Repository()
        ..delayed = Completer<void>()
        ..failReadback = true;
      await _show(tester, repository);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(VerificationSubmitPage)),
      );
      await tester.tap(find.text('提交审核'));
      await tester.pump();
      if (change == 'profile') {
        (container.read(sessionProvider.notifier) as _Session)
            .updateSameAccount();
      } else {
        container.invalidate(verificationProvider);
      }
      await tester.pumpAndSettle();
      expect(
        await container
            .read(verificationProvider.notifier)
            .submit(realName: '测试姓名', idNumber: 'TEST-ID-001'),
        VerificationSubmissionResult.obsolete,
      );
      expect(repository.posts, 1);
      repository.delayed!.complete();
      await tester.pumpAndSettle();
      expect(
        container.read(verificationProvider.notifier).requiresConfirmation,
        isTrue,
      );
      expect(find.text('刷新提交状态'), findsOneWidget);
      await tester.tap(find.text('刷新提交状态'));
      await tester.pumpAndSettle();
      expect(repository.posts, 1);
      expect(find.textContaining('已接收提交'), findsOneWidget);
      repository.failReadback = false;
      await tester.tap(find.text('刷新提交状态'));
      await tester.pumpAndSettle();
      expect(repository.posts, 1);
      expect(find.text('认证入口'), findsOneWidget);
    });
  }

  testWidgets('old successful POST receipt cannot mark a new account', (
    tester,
  ) async {
    final repository = _Repository()..delayed = Completer<void>();
    await _show(tester, repository);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(VerificationSubmitPage)),
    );
    await tester.tap(find.text('提交审核'));
    await tester.pump();
    (container.read(sessionProvider.notifier) as _Session).change();
    await tester.pumpAndSettle();
    repository.delayed!.complete();
    await tester.pumpAndSettle();
    expect(
      container.read(verificationProvider.notifier).requiresConfirmation,
      isFalse,
    );
    expect(find.byType(VerificationSubmitPage), findsOneWidget);
    expect(repository.posts, 1);
  });

  testWidgets('same-account profile update retains GET-only confirmation', (
    tester,
  ) async {
    final repository = _Repository()..failReadback = true;
    await _show(tester, repository);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(VerificationSubmitPage)),
    );
    await tester.tap(find.text('提交审核'));
    await tester.pumpAndSettle();
    (container.read(sessionProvider.notifier) as _Session).updateSameAccount();
    await tester.pumpAndSettle();
    expect(find.text('刷新提交状态'), findsOneWidget);
    repository.failReadback = false;
    await tester.tap(find.text('刷新提交状态'));
    await tester.pumpAndSettle();
    expect(repository.posts, 1);
    expect(find.text('认证入口'), findsOneWidget);
  });

  for (final change in ['account', 'authentication']) {
    testWidgets('$change change clears the prior confirmation marker', (
      tester,
    ) async {
      final repository = _Repository()..failReadback = true;
      await _show(tester, repository);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(VerificationSubmitPage)),
      );
      await tester.tap(find.text('提交审核'));
      await tester.pumpAndSettle();
      final session = container.read(sessionProvider.notifier) as _Session;
      if (change == 'account') {
        session.change();
      } else {
        session.reauthenticate();
      }
      await tester.pumpAndSettle();
      expect(
        container.read(verificationProvider.notifier).requiresConfirmation,
        isFalse,
      );
      expect(find.text('刷新提交状态'), findsNothing);
      expect(repository.posts, 1);
    });
  }

  testWidgets('provider invalidation retains pending GET-only confirmation', (
    tester,
  ) async {
    final repository = _Repository()..failReadback = true;
    await _show(tester, repository);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(VerificationSubmitPage)),
    );
    await tester.tap(find.text('提交审核'));
    await tester.pumpAndSettle();
    container.invalidate(verificationProvider);
    await tester.pumpAndSettle();
    expect(find.text('刷新提交状态'), findsOneWidget);
    await tester.tap(find.text('刷新提交状态'));
    await tester.pumpAndSettle();
    expect(repository.posts, 1);
  });
  testWidgets('failed submission retains inputs and supports explicit retry', (
    tester,
  ) async {
    final repository = _Repository()..failSubmit = true;
    await _show(tester, repository);
    await tester.tap(find.text('提交审核'));
    await tester.pumpAndSettle();
    expect(find.byType(VerificationSubmitPage), findsOneWidget);
    expect(find.text('测试姓名'), findsOneWidget);
    expect(find.text('TEST-ID-001'), findsOneWidget);
    expect(find.textContaining('提交失败'), findsOneWidget);
    repository.failSubmit = false;
    await tester.tap(find.text('重试提交'));
    await tester.pumpAndSettle();
    expect(find.text('认证入口'), findsOneWidget);
    expect(repository.posts, 2);
  });

  testWidgets('accepted POST with failed readback only retries GET', (
    tester,
  ) async {
    final repository = _Repository()..failReadback = true;
    await _show(tester, repository);
    await tester.tap(find.text('提交审核'));
    await tester.pumpAndSettle();
    expect(find.byType(VerificationSubmitPage), findsOneWidget);
    expect(find.textContaining('已接收提交'), findsOneWidget);
    await tester.tap(find.text('刷新提交状态'));
    await tester.pumpAndSettle();
    expect(repository.posts, 1);
    repository.failReadback = false;
    await tester.tap(find.text('刷新提交状态'));
    await tester.pumpAndSettle();
    expect(find.text('认证入口'), findsOneWidget);
    expect(repository.posts, 1);
  });

  testWidgets('late submission never pops a covering route', (tester) async {
    final repository = _Repository()..delayed = Completer<void>();
    final router = await _show(tester, repository);
    await tester.tap(find.text('提交审核'));
    await tester.pump();
    router.push('/other');
    await tester.pump(const Duration(milliseconds: 500));
    repository.delayed!.complete();
    await tester.pumpAndSettle();
    expect(find.text('其他页面'), findsOneWidget);
  });

  testWidgets('unverified readback stays unconfirmed across page re-entry', (
    tester,
  ) async {
    final repository = _Repository()..staleReadback = true;
    final router = await _show(tester, repository);
    await tester.tap(find.text('提交审核'));
    await tester.pumpAndSettle();
    expect(find.textContaining('已接收提交'), findsOneWidget);
    router.pop();
    await tester.pumpAndSettle();
    router.push('/submit');
    await tester.pumpAndSettle();
    await tester.tap(find.text('刷新提交状态'));
    await tester.pumpAndSettle();
    expect(repository.posts, 1);
    expect(find.byType(VerificationSubmitPage), findsOneWidget);
  });

  testWidgets('disposed page ignores a late submission', (tester) async {
    final repository = _Repository()..delayed = Completer<void>();
    final router = await _show(tester, repository);
    await tester.tap(find.text('提交审核'));
    await tester.pump();
    router.go('/other');
    await tester.pump(const Duration(milliseconds: 500));
    repository.delayed!.complete();
    await tester.pumpAndSettle();
    expect(find.text('其他页面'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('provider state replacement discards a late submission', (
    tester,
  ) async {
    final repository = _Repository()..delayed = Completer<void>();
    await _show(tester, repository);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(VerificationSubmitPage)),
    );
    await tester.tap(find.text('提交审核'));
    await tester.pump();
    container.invalidate(verificationProvider);
    await tester.pump();
    repository.delayed!.complete();
    await tester.pumpAndSettle();
    expect(find.byType(VerificationSubmitPage), findsOneWidget);
    expect(container.read(verificationProvider).asData?.value.message, isNull);
  });

  testWidgets('account change discards a late submission result', (
    tester,
  ) async {
    final repository = _Repository()..delayed = Completer<void>();
    await _show(tester, repository);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(VerificationSubmitPage)),
    );
    await tester.tap(find.text('提交审核'));
    await tester.pump();
    (container.read(sessionProvider.notifier) as _Session).change();
    await tester.pump();
    repository.delayed!.complete();
    await tester.pumpAndSettle();
    expect(find.byType(VerificationSubmitPage), findsOneWidget);
    expect(container.read(verificationProvider).asData?.value.message, isNull);
    expect(find.text('测试姓名'), findsNothing);
    expect(find.text('TEST-ID-001'), findsNothing);
  });
}

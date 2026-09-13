import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/shared/presentation_state/app_presentation_state.dart';
import 'package:flutter_elitesync_module/shared/presentation_state/app_presentation_state_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('stale content is visibly marked and retries only the read', (
    tester,
  ) async {
    var readRetries = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppPresentationStateView(
            state: const AppPresentationState.stale(),
            onRetryRead: () => readRetries += 1,
            lastKnownContent: const Text('SYNTHETIC LAST-KNOWN CONTENT'),
          ),
        ),
      ),
    );

    expect(find.textContaining('可能已过期'), findsOneWidget);
    expect(find.textContaining('不是当前权威生命周期事实'), findsOneWidget);
    expect(find.text('SYNTHETIC LAST-KNOWN CONTENT'), findsOneWidget);

    await tester.tap(find.text('检查更新'));
    expect(readRetries, 1);
  });

  testWidgets('authority-not-established hides supplied protected content', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppPresentationStateView(
            state: AppPresentationState.authorityNotEstablished(),
            lastKnownContent: Text('SYNTHETIC PROTECTED CONTENT'),
          ),
        ),
      ),
    );

    expect(find.text('权威状态尚未建立'), findsOneWidget);
    expect(find.textContaining('受保护内容与操作保持关闭'), findsOneWidget);
    expect(find.text('SYNTHETIC PROTECTED CONTENT'), findsNothing);
  });
}

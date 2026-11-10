import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/features/connection/domain/product_connection_contract.dart';
import 'package:flutter_elitesync_module/features/connection/presentation/pages/connection_page.dart';
import 'package:flutter_elitesync_module/features/connection/presentation/state/connection_presentation_state.dart';

void main() {
  testWidgets('fails closed when no authoritative Connection state exists', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ConnectionPage()));

    expect(find.text('连接状态尚未建立'), findsOneWidget);
    expect(find.text('NOT YET ESTABLISHED'), findsWidgets);
    expect(find.textContaining('不会自动授权消息'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('can present an authoritative state without enabling mutations', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ConnectionPage(
          snapshot: ConnectionPresentationState.authoritative(
            ProductConnectionState.pending,
          ),
        ),
      ),
    );

    expect(find.text('CN_PENDING'), findsOneWidget);
    expect(find.text('等待另一方独立确认'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
  });
}

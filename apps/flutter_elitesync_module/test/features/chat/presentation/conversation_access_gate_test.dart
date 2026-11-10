import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/features/chat/domain/product_conversation_contract.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/widgets/conversation_access_gate.dart';
import 'package:flutter_elitesync_module/features/connection/domain/product_connection_contract.dart';

void main() {
  testWidgets('locked gate does not build or reveal protected content', (
    tester,
  ) async {
    var protectedBuilds = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: ConversationAccessGate(
          snapshot: const ConversationAccessSnapshot.notYetEstablished(),
          protectedBuilder: (context) {
            protectedBuilds += 1;
            return const Text('PRIVATE SYNTHETIC CONTENT');
          },
        ),
      ),
    );

    expect(protectedBuilds, 0);
    expect(find.text('PRIVATE SYNTHETIC CONTENT'), findsNothing);
    expect(find.text('消息权限尚未建立'), findsOneWidget);
    expect(find.textContaining('NOT YET ESTABLISHED'), findsWidgets);
    expect(find.textContaining('匹配不会开启对话'), findsOneWidget);
    expect(find.textContaining('拉黑与举报是两个独立控制'), findsOneWidget);
  });

  testWidgets(
    'only prerequisite-backed active access builds protected content',
    (tester) async {
      var protectedBuilds = 0;
      final activeAccess = ProductConversationAccessAdapter.resolve(
        connection: const ProductConnectionEvidence.authoritative(
          ProductConnectionState.active,
        ),
        messagingConsent: const MessagingConsentEvidence.authoritative(
          MessagingConsentState.mutual,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ConversationAccessGate(
            snapshot: activeAccess,
            protectedBuilder: (context) {
              protectedBuilds += 1;
              return const Text('SYNTHETIC AUTHORIZED CHILD');
            },
          ),
        ),
      );

      expect(protectedBuilds, 1);
      expect(find.text('SYNTHETIC AUTHORIZED CHILD'), findsOneWidget);
    },
  );
}

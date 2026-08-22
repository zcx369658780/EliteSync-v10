import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/widgets/message_input_bar.dart';

void main() {
  testWidgets('MessageInputBar exposes attachment picker for image and video', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: MessageInputBar(
            controller: TextEditingController(),
            onSend: () {},
            sending: false,
            onAttach: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.byTooltip('添加图片或视频'), findsOneWidget);
    await tester.tap(find.byTooltip('添加图片或视频'));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });

  testWidgets('MessageInputBar keeps send action explicit and stateful', (
    tester,
  ) async {
    var sendCount = 0;
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: MessageInputBar(
            controller: controller,
            onSend: () {
              sendCount += 1;
            },
            sending: false,
          ),
        ),
      ),
    );

    expect(find.text('写一句轻问候，确认后手动发送'), findsOneWidget);
    await tester.tap(find.byTooltip('手动发送'));
    await tester.pump();
    expect(sendCount, 0);

    await tester.enterText(find.byType(TextField), '你好，我们可以慢慢聊。');
    await tester.pump();
    await tester.tap(find.byTooltip('手动发送'));
    await tester.pump();
    expect(sendCount, 1);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: MessageInputBar(
            controller: controller,
            onSend: () {
              sendCount += 1;
            },
            sending: true,
            onAttach: () {},
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final attachButton = tester.widget<IconButton>(
      find.ancestor(
        of: find.byIcon(Icons.add_photo_alternate_outlined),
        matching: find.byType(IconButton),
      ),
    );
    expect(attachButton.onPressed, isNull);
  });
}

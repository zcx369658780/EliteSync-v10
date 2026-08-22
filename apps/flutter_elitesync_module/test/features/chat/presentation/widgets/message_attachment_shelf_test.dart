import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/widgets/message_attachment_shelf.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: ThemeMode.light,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('attachment shelf exposes visible upload states and retry', (
    tester,
  ) async {
    var attachCount = 0;
    await tester.pumpWidget(
      _wrap(
        MessageAttachmentShelf(
          onAttachTap: () {
            attachCount += 1;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('图片附件'), findsOneWidget);
    expect(find.text('当前状态：待上传'), findsOneWidget);
    expect(find.text('选择图片'), findsOneWidget);
    expect(find.text('正在上传'), findsWidgets);
    expect(find.text('正在处理'), findsWidgets);
    expect(find.text('上传失败'), findsWidgets);
    expect(find.text('可以发送'), findsWidgets);
    expect(find.textContaining('对象存储'), findsNothing);
    expect(find.textContaining('后台'), findsNothing);
    expect(find.textContaining('数据库'), findsNothing);

    await tester.tap(find.text('上传失败').last);
    await tester.pumpAndSettle();
    expect(find.text('当前状态：上传失败'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);

    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();
    expect(find.text('当前状态：正在上传'), findsOneWidget);

    await tester.tap(find.text('选择图片'));
    await tester.pumpAndSettle();
    expect(attachCount, 1);
    expect(find.text('当前状态：正在上传'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/browse_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/theme/light_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('background utility gesture adds no full-surface tap semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: Scaffold(
          body: BrowseScaffold(
            header: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text('Home title'), Text('Home subtitle')],
            ),
            body: Center(
              child: FilledButton(
                onPressed: () {},
                child: const Text('Action'),
              ),
            ),
          ),
        ),
      ),
    );

    final header = find.bySemanticsLabel(RegExp('Home title'));
    expect(header, findsOneWidget);
    expect(tester.getSemantics(header), containsSemantics(hasTapAction: false));
    expect(find.bySemanticsLabel('Action'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('background tap still unfocuses a focused child', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: Scaffold(
          body: BrowseScaffold(
            header: const Text('Home title'),
            body: Column(
              children: [
                TextField(focusNode: focusNode),
                const Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);

    await tester.tapAt(const Offset(400, 500));
    await tester.pump();
    expect(focusNode.hasFocus, isFalse);
  });
}

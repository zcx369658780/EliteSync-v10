import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/features/lifestyle_discovery/lifestyle_controller.dart';
import 'package:flutter_elitesync_module/features/lifestyle_discovery/lifestyle_page.dart';
import 'package:flutter_elitesync_module/features/lifestyle_discovery/lifestyle_providers.dart';

void main() {
  late Map<String, dynamic> data;
  late LifestyleController controller;
  setUp(() {
    final bank = jsonDecode(
      File('assets/config/lifestyle_discovery_v1.json').readAsStringSync(),
    );
    data = {
      'bank': bank,
      'answers': <String, dynamic>{},
      'derived_preferences': {},
      'revision': 0,
      'status': 'not_started',
      'questionnaire_version': 'lifestyle_v1',
    };
    controller = LifestyleController(
      read: () async => Map.of(data),
      send: (body) async {
        data['revision'] = (data['revision'] as int) + 1;
        data['status'] = body['action'] == 'skip' ? 'skipped' : 'in_progress';
        if (body['action'] == 'answer') {
          (data['answers'] as Map)[body['scene_id']] = {
            'option_id': body['option_id'],
          };
        }
        return Map.of(data);
      },
      readDraft: () async => null,
      writeDraft: (_) async => true,
      isCurrent: () => true,
    );
  });
  tearDown(() => controller.dispose());

  Future<void> mount(
    WidgetTester tester, {
    bool reduced = false,
    VoidCallback? onExit,
  }) async {
    tester.view.physicalSize = const Size(440, 960);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [lifestyleControllerProvider.overrideWithValue(controller)],
        child: MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: reduced),
            child: LifestyleDiscoveryPage(onExit: onExit),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('welcome skip saves skipped and exits freely', (tester) async {
    var exited = false;
    await mount(tester, onExit: () => exited = true);
    expect(find.text('生活方式探索'), findsWidgets);
    await tester.tap(find.byKey(const Key('lifestyle-skip')));
    await tester.pumpAndSettle();
    expect(data['status'], 'skipped');
    expect(exited, true);
  });

  testWidgets('navigation waits for in-flight autosave before advancing', (
    tester,
  ) async {
    final reply = Completer<Map<String, dynamic>>();
    controller.dispose();
    data['status'] = 'in_progress';
    controller = LifestyleController(
      read: () async => Map.of(data),
      send: (_) => reply.future,
      readDraft: () async => null,
      writeDraft: (_) async => true,
      isCurrent: () => true,
    );
    await mount(tester);
    await tester.tap(find.byKey(const Key('option-quiet')));
    await tester.pump();
    expect(
      tester
          .widget<TextButton>(find.byKey(const Key('lifestyle-back')))
          .onPressed,
      isNull,
    );
    reply.complete({...data, 'revision': 1});
    await tester.pumpAndSettle();
    expect(find.text('去一个新地方走走，你喜欢怎样安排？'), findsOneWidget);
  });

  testWidgets(
    'answer advances, back reverses and previous choice remains selected',
    (tester) async {
      await mount(tester);
      await tester.tap(find.byKey(const Key('lifestyle-start')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('option-quiet')));
      await tester.pumpAndSettle();
      expect(find.text('去一个新地方走走，你喜欢怎样安排？'), findsOneWidget);
      await tester.tap(find.byKey(const Key('lifestyle-back')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 70));
      expect(
        tester
            .widget<SlideTransition>(
              find.byKey(const Key('lifestyle-transition')),
            )
            .position
            .value
            .dx,
        lessThan(0),
      );
      await tester.pumpAndSettle();
      expect(find.text('在家放松时，你更喜欢哪种氛围？'), findsOneWidget);
      expect(
        tester
            .widget<Semantics>(find.byKey(const Key('choice-quiet')))
            .properties
            .selected,
        true,
      );
    },
  );

  testWidgets(
    'reduced motion has no scene translation and assets load offline',
    (tester) async {
      await mount(tester, reduced: true);
      await tester.tap(find.byKey(const Key('lifestyle-start')));
      await tester.pumpAndSettle();
      final slide = tester.widget<SlideTransition>(
        find.byKey(const Key('lifestyle-transition')),
      );
      expect(slide.position.value, Offset.zero);
      expect(find.byType(Image), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

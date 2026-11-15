import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/features/lifestyle_discovery/lifestyle_controller.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';

Map<String, dynamic> snapshot(int revision) => {
  'revision': revision,
  'questionnaire_version': 'lifestyle_v1',
  'status': revision == 0 ? 'not_started' : 'in_progress',
  'answers': <String, dynamic>{},
};

void main() {
  test(
    'durable command precedes network and retry preserves request identity',
    () async {
      Map<String, dynamic>? draft;
      final sent = <Map<String, dynamic>>[];
      final controller = LifestyleController(
        read: () async => snapshot(0),
        send: (body) async {
          expect(draft?['pending'], body);
          sent.add(Map.of(body));
          if (sent.length == 1) throw const RelationshipFailure('offline');
          return snapshot(1);
        },
        readDraft: () async => draft,
        writeDraft: (value) async {
          draft = value;
          return true;
        },
        isCurrent: () => true,
      );
      await controller.load();
      expect(await controller.answer('home_atmosphere', 'quiet'), false);
      expect(controller.pending, isNotNull);
      expect(await controller.retry(), true);
      expect(sent[0], sent[1]);
      expect(controller.pending, isNull);
      expect(controller.data?['revision'], 1);
      controller.dispose();
    },
  );

  test(
    'cold restart replays encrypted pending with original CAS and key',
    () async {
      final pending = {
        'action': 'answer',
        'request_key': 'same-key',
        'expected_revision': 0,
        'questionnaire_version': 'lifestyle_v1',
        'scene_id': 'home_atmosphere',
        'option_id': 'quiet',
      };
      final controller = LifestyleController(
        read: () async => snapshot(1),
        send: (body) async {
          expect(body, pending);
          return snapshot(1);
        },
        readDraft: () async => {'pending': pending},
        writeDraft: (_) async => true,
        isCurrent: () => true,
      );
      await controller.load();
      expect(controller.pending, isNull);
      expect(controller.data?['revision'], 1);
      controller.dispose();
    },
  );

  test(
    'conflict keeps draft and requires explicit discard before refresh',
    () async {
      final controller = LifestyleController(
        read: () async => snapshot(3),
        send: (_) async =>
            throw const RelationshipFailure('conflict', statusCode: 409),
        readDraft: () async => null,
        writeDraft: (_) async => true,
        isCurrent: () => true,
      );
      await controller.load();
      await controller.answer('home_atmosphere', 'quiet');
      expect(controller.conflict, true);
      expect(controller.pending, isNotNull);
      await controller.discardAndReload();
      expect(controller.pending, isNull);
      expect(controller.conflict, false);
      controller.dispose();
    },
  );

  test(
    'account change while saving prevents sending or applying old answer',
    () async {
      var current = true;
      final saved = Completer<bool>();
      var calls = 0;
      final controller = LifestyleController(
        read: () async => snapshot(0),
        send: (_) async {
          calls++;
          return snapshot(1);
        },
        readDraft: () async => null,
        writeDraft: (_) => saved.future,
        isCurrent: () => current,
      );
      await controller.load();
      final operation = controller.answer('home_atmosphere', 'quiet');
      current = false;
      saved.complete(true);
      expect(await operation, false);
      expect(calls, 0);
      expect(controller.data?['revision'], 0);
      controller.dispose();
    },
  );

  test('failed local durable write prevents network submission', () async {
    var calls = 0;
    final controller = LifestyleController(
      read: () async => snapshot(0),
      send: (_) async {
        calls++;
        return snapshot(1);
      },
      readDraft: () async => null,
      writeDraft: (_) async => false,
      isCurrent: () => true,
    );
    await controller.load();
    expect(await controller.answer('home_atmosphere', 'quiet'), false);
    expect(calls, 0);
    expect(controller.error, contains('本机'));
    controller.dispose();
  });
}

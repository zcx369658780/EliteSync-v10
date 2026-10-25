import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:livekit_client/src/core/engine.dart';

// Retain the real Engine, SignalClient and event listeners. Only the Engine
// lifecycle boundary exposed to Room is paused or made to fail by these tests.
class _ControlledEngine extends Engine {
  _ControlledEngine()
    : super(
        connectOptions: const ConnectOptions(),
        roomOptions: const RoomOptions(),
      );

  final cleanupEntered = Completer<void>();
  Completer<void>? cleanupGate;
  StateError? cleanupError;
  StateError? disposalError;
  int roomCleanupRequests = 0;
  int disposalRequests = 0;
  bool _insideEngineDisposal = false;

  @override
  Future<void> cleanUp() async {
    // Engine's own disposer also invokes cleanUp. Delegate that call to its
    // real implementation without reinjecting a Room-boundary failure/gate.
    if (_insideEngineDisposal) {
      await super.cleanUp();
      return;
    }
    roomCleanupRequests++;
    if (!cleanupEntered.isCompleted) cleanupEntered.complete();
    if (cleanupGate != null) await cleanupGate!.future;
    if (cleanupError != null) throw cleanupError!;
    await super.cleanUp();
  }

  @override
  Future<bool> dispose() async {
    disposalRequests++;
    _insideEngineDisposal = true;
    try {
      final result = await super.dispose();
      if (disposalError != null) throw disposalError!;
      return result;
    } finally {
      _insideEngineDisposal = false;
    }
  }

  void release() {
    if (cleanupGate != null && !cleanupGate!.isCompleted) {
      cleanupGate!.complete();
    }
  }

  Future<void> finishFixture() async {
    release();
    cleanupError = null;
    disposalError = null;
    // Bypass the instrumented dispose entry when cleaning a failing fixture;
    // otherwise teardown would change the counts asserted by the test.
    _insideEngineDisposal = true;
    try {
      await super.dispose();
    } finally {
      _insideEngineDisposal = false;
    }
  }
}

const _deadline = Duration(seconds: 2);

Future<Object?> _disposeOutcome(
  Room room, {
  void Function()? onComplete,
}) async {
  try {
    await room.dispose().timeout(_deadline);
    return null;
  } catch (error) {
    return error;
  } finally {
    onComplete?.call();
  }
}

Future<void> _drain() => Future<void>.delayed(Duration.zero);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const nativeChannel = MethodChannel('livekit_client');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late _ControlledEngine engine;
  late Room room;
  late List<String> nativeStops;

  setUp(() {
    nativeStops = [];
    messenger.setMockMethodCallHandler(nativeChannel, (call) async {
      if (call.method != 'stopAndroidAudioSession') {
        throw StateError('Unexpected native call: ${call.method}');
      }
      nativeStops.add(call.method);
      return null;
    });
    engine = _ControlledEngine();
    room = Room(engine: engine);
    // Fail fixture construction here, before any asserted disposal behavior.
    expect(engine.events.isDisposed, isFalse);
  });

  tearDown(() async {
    engine.release();
    await _disposeOutcome(room);
    await engine.finishFixture().timeout(_deadline);
    await room.events.dispose().timeout(_deadline);
    messenger.setMockMethodCallHandler(nativeChannel, null);
  });

  test('concurrent Room dispose calls both await the first cleanup', () async {
    engine.cleanupGate = Completer<void>();
    var firstCompleted = false;
    var secondCompleted = false;
    final first = _disposeOutcome(
      room,
      onComplete: () => firstCompleted = true,
    );
    await engine.cleanupEntered.future.timeout(_deadline);
    final second = _disposeOutcome(
      room,
      onComplete: () => secondCompleted = true,
    );
    await _drain();
    expect(firstCompleted, isFalse);
    expect(
      secondCompleted,
      isFalse,
      reason: 'Repeated Room.dispose must wait for in-flight cleanup',
    );
    expect(engine.roomCleanupRequests, 1);
    expect(engine.disposalRequests, 0);
    expect(nativeStops, isEmpty);
    engine.release();
    expect(await Future.wait([first, second]), everyElement(isNull));
    expect(engine.roomCleanupRequests, 1);
    expect(engine.disposalRequests, 1);
    // Android makes one native session stop; desktop makes none. In either
    // platform branch a repeated Room disposal must not repeat native teardown.
    expect(nativeStops.length, lessThanOrEqualTo(1));
    final stopsAfterDispose = List<String>.of(nativeStops);
    expect(await _disposeOutcome(room), isNull);
    expect(nativeStops, stopsAfterDispose);
    expect(engine.disposalRequests, 1);
    expect(engine.events.isDisposed, isTrue);
  });

  test(
    'Room attempts engine disposal after cleanup fails and propagates error',
    () async {
      final failure = StateError('room cleanup failure');
      engine.cleanupError = failure;
      engine.disposalError = StateError('later engine disposal failure');
      final result = await _disposeOutcome(room);
      expect(engine.roomCleanupRequests, 1);
      expect(
        engine.disposalRequests,
        1,
        reason: 'Cleanup failure must not skip engine disposal',
      );
      expect(result, same(failure));
      expect(engine.events.isDisposed, isTrue);
    },
  );

  test(
    'Room repeats the same engine disposal failure without repeating teardown',
    () async {
      final failure = StateError('engine disposal failure');
      engine.disposalError = failure;
      final first = await _disposeOutcome(room);
      final cleanupAfterFirst = engine.roomCleanupRequests;
      final stopsAfterFirst = List<String>.of(nativeStops);
      final second = await _disposeOutcome(room);
      final third = await _disposeOutcome(room);
      expect(first, same(failure));
      expect(second, same(failure));
      expect(third, same(failure));
      expect(engine.disposalRequests, 1);
      expect(cleanupAfterFirst, 1);
      expect(engine.roomCleanupRequests, cleanupAfterFirst);
      expect(nativeStops, stopsAfterFirst);
      expect(nativeStops.length, lessThanOrEqualTo(1));
      expect(engine.events.isDisposed, isTrue);
    },
  );
}

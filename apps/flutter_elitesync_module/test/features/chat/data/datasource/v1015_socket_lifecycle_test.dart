import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/features/chat/data/datasource/chat_socket_data_source.dart';

class _Local extends LocalStorageService {
  Completer<Map<String, dynamic>?>? pending;
  @override
  Future<Map<String, dynamic>?> getJson(String key) async =>
      pending == null ? {'id': 1} : await pending!.future;
}

class _Socket extends Stream<dynamic> implements WebSocket {
  final events = StreamController<dynamic>();
  int closes = 0;
  int cancels = 0;
  _Socket() {
    events.onCancel = () {
      cancels++;
    };
  }
  @override
  Duration? pingInterval;
  @override
  Future<void> close([int? code, String? reason]) async {
    closes++;
    if (!events.isClosed) unawaited(events.close());
  }

  @override
  StreamSubscription<dynamic> listen(
    void Function(dynamic)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => events.stream.listen(
    onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Harness {
  String identity = 'account-1:token-a:epoch-0';
  String token = 'synthetic-token-a';
  final local = _Local();
  final changes = StreamController<void>.broadcast(sync: true);
  final sockets = <_Socket>[];
  final headers = <Map<String, dynamic>>[];
  final uris = <Uri>[];
  final errors = <Object>[];
  ChatSocketConnector? connect;
  late final ChatSocketDataSource source;
  _Harness({
    bool callbackOnly = false,
    int retries = 2,
    Duration timeout = const Duration(seconds: 1),
    Duration delay = const Duration(milliseconds: 2),
  }) {
    source = ChatSocketDataSource(
      apiClient: ApiClient(dio: Dio()),
      localStorage: local,
      env: const AppEnv(
        flavor: AppFlavor.dev,
        appName: 'synthetic',
        apiBaseUrl: 'http://127.0.0.1:49572',
        wsBaseUrl: 'ws://127.0.0.1:49573',
        useMockData: false,
      ),
      accessToken: () async => token,
      sessionIdentity: () => identity,
      sessionChanges: callbackOnly ? null : changes.stream,
      connector: (uri, h, client) {
        headers.add(h);
        uris.add(uri);
        if (connect != null) return connect!(uri, h, client);
        final socket = _Socket();
        sockets.add(socket);
        return Future.value(socket);
      },
      maxReconnectAttempts: retries,
      reconnectDelay: delay,
      connectTimeout: timeout,
    );
  }
  void change(String next) {
    identity = next;
    changes.add(null);
  }

  Future<void> finish() async {
    source.dispose();
    await changes.close();
  }
}

Future<void> _tick([int milliseconds = 5]) =>
    Future<void>.delayed(Duration(milliseconds: milliseconds));

void main() {
  test(
    'valid current connection sends scoped URI and receives invalidation',
    () async {
      final h = _Harness();
      final seen = <String>[];
      final sub = h.source
          .observe('2')
          .listen(
            (v) => seen.add(v.id),
            onError: (Object e) => h.errors.add(e),
          );
      await _tick();
      expect(h.headers.single, {'Authorization': 'Bearer synthetic-token-a'});
      expect(
        h.uris.single.toString(),
        'ws://127.0.0.1:49573/api/v1/messages/ws/1?peer_id=2',
      );
      h.sockets.single.events.add('{"type":"conversation_changed","id":7}');
      await _tick();
      expect(seen, ['7']);
      expect(h.errors, isEmpty);
      await sub.cancel();
      await h.finish();
      expect(h.sockets.single.closes, 1);
      expect(h.sockets.single.cancels, 1);
    },
  );

  for (final next in [
    'account-2:token-b:epoch-0',
    'account-1:token-a:epoch-1',
    'logout',
  ]) {
    test(
      'identity $next actively closes idle socket without a frame',
      () async {
        final h = _Harness();
        var done = false;
        final sub = h.source
            .observe('2')
            .listen(
              (_) {},
              onError: (Object e) => h.errors.add(e),
              onDone: () => done = true,
            );
        await _tick();
        final old = h.sockets.single;
        h.change(next);
        await _tick();
        expect(old.closes, 1);
        expect(old.cancels, 1);
        expect(done, isTrue);
        expect(h.headers.length, 1);
        await sub.cancel();
        await h.finish();
      },
    );
  }

  test(
    'callback-only identity consumer actively closes without incoming frames',
    () async {
      final h = _Harness(callbackOnly: true);
      final sub = h.source
          .observe('2')
          .listen((_) {}, onError: (Object e) => h.errors.add(e));
      await _tick();
      h.identity = 'logout';
      await _tick(140);
      expect(h.sockets.single.closes, 1);
      await sub.cancel();
      await h.finish();
    },
  );

  test(
    'new token uses new observation; obsolete socket cannot deliver frames',
    () async {
      final h = _Harness();
      final oldSeen = <String>[];
      final newSeen = <String>[];
      final oldSub = h.source
          .observe('2')
          .listen((v) => oldSeen.add(v.id), onError: (Object _) {});
      await _tick();
      final oldSocket = h.sockets.single;
      h.token = 'synthetic-token-b';
      h.change('account-1:token-b:epoch-0');
      final newSub = h.source
          .observe('2')
          .listen((v) => newSeen.add(v.id), onError: (Object _) {});
      await _tick();
      expect(oldSocket.closes, 1);
      expect(h.headers.last['Authorization'], 'Bearer synthetic-token-b');
      h.sockets.last.events.add('{"type":"conversation_changed","id":9}');
      await _tick();
      expect(oldSeen, isEmpty);
      expect(newSeen, ['9']);
      await oldSub.cancel();
      await newSub.cancel();
      await h.finish();
    },
  );

  test(
    'switch during pending upgrade closes its late result and never retries',
    () async {
      final h = _Harness();
      final pending = Completer<WebSocket>();
      h.connect = (_, _, _) => pending.future;
      var delivered = 0;
      final sub = h.source
          .observe('2')
          .listen((_) => delivered++, onError: (Object _) {});
      await _tick();
      h.change('logout');
      await _tick();
      final lateSocket = _Socket();
      pending.complete(lateSocket);
      await _tick();
      expect(lateSocket.closes, 1);
      expect(delivered, 0);
      expect(h.headers.length, 1);
      await sub.cancel();
      await h.finish();
    },
  );

  test(
    'cancel while profile lookup is pending cannot start an upgrade',
    () async {
      final h = _Harness();
      h.local.pending = Completer();
      final sub = h.source.observe('2').listen((_) {}, onError: (Object _) {});
      await _tick();
      await sub.cancel();
      h.local.pending!.complete({'id': 1});
      await _tick();
      expect(h.headers, isEmpty);
      await h.finish();
    },
  );

  test(
    'cancel waiting retry releases delay and never dispatches old token',
    () async {
      final h = _Harness(delay: const Duration(milliseconds: 40));
      h.connect = (_, _, _) async =>
          throw const SocketException('synthetic failed upgrade');
      final sub = h.source
          .observe('2')
          .listen((_) {}, onError: (Object e) => h.errors.add(e));
      await _tick();
      expect(h.headers.length, 1);
      await sub.cancel();
      await _tick(60);
      expect(h.headers.length, 1);
      await h.finish();
    },
  );

  test(
    'reconnect attempts are finite and close the observation on exhaustion',
    () async {
      final h = _Harness(retries: 2);
      var done = false;
      h.connect = (_, _, _) async =>
          throw const SocketException('synthetic failed upgrade');
      final sub = h.source
          .observe('2')
          .listen(
            (_) {},
            onError: (Object e) => h.errors.add(e),
            onDone: () => done = true,
          );
      await _tick(35);
      expect(h.headers.length, 3);
      expect(h.errors.length, 3);
      expect(done, isTrue);
      await sub.cancel();
      await h.finish();
    },
  );

  test(
    'timeout late result is closed while a newer generation remains valid',
    () async {
      final h = _Harness(timeout: const Duration(milliseconds: 10));
      final first = Completer<WebSocket>();
      final second = _Socket();
      h.connect = (_, _, _) =>
          h.headers.length == 1 ? first.future : Future.value(second);
      final seen = <String>[];
      final sub = h.source
          .observe('2')
          .listen(
            (v) => seen.add(v.id),
            onError: (Object e) => h.errors.add(e),
          );
      await _tick(30);
      expect(h.headers.length, 2);
      final lateSocket = _Socket();
      first.complete(lateSocket);
      await _tick();
      expect(lateSocket.closes, 1);
      expect(second.closes, 0);
      second.events.add('{"type":"conversation_changed","id":10}');
      await _tick();
      expect(seen, ['10']);
      await sub.cancel();
      await h.finish();
    },
  );

  test('late timeout result closes even during the retry wait', () async {
    final h = _Harness(
      timeout: const Duration(milliseconds: 10),
      delay: const Duration(milliseconds: 50),
    );
    final pending = Completer<WebSocket>();
    h.connect = (_, _, _) => pending.future;
    final sub = h.source
        .observe('2')
        .listen((_) {}, onError: (Object e) => h.errors.add(e));
    await _tick(20);
    final lateSocket = _Socket();
    pending.complete(lateSocket);
    await _tick();
    expect(lateSocket.closes, 1);
    expect(h.headers.length, 1);
    await sub.cancel();
    await h.finish();
  });

  test(
    'malformed UTF8 callback reports error and closes without uncaught callback',
    () async {
      final h = _Harness(retries: 0);
      final sub = h.source
          .observe('2')
          .listen((_) {}, onError: (Object e) => h.errors.add(e));
      await _tick();
      final socket = h.sockets.single;
      socket.events.add([255]);
      await _tick();
      expect(h.errors.single, isA<FormatException>());
      expect(socket.closes, 1);
      await sub.cancel();
      await h.finish();
    },
  );

  test(
    'dispose before listen cannot create a timer, connection or live observation',
    () async {
      final h = _Harness();
      final stream = h.source.observe('2');
      h.source.dispose();
      var done = false;
      final sub = stream.listen((_) {}, onDone: () => done = true);
      await _tick();
      expect(done, isTrue);
      expect(h.headers, isEmpty);
      await sub.cancel();
      await h.finish();
    },
  );
}

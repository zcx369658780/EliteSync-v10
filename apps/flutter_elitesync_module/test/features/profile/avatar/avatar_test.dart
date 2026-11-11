import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_center_page.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_elitesync_module/features/profile/avatar/avatar_api.dart';
import 'package:flutter_elitesync_module/features/profile/avatar/avatar_management_page.dart';
import 'package:flutter_elitesync_module/features/profile/avatar/authenticated_avatar.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+a8WQAAAAASUVORK5CYII=',
);

class _OversizeFile extends XFile {
  _OversizeFile() : super('unused');
  bool readCalled = false;
  @override
  Future<int> length() async => 6 * 1024 * 1024;
  @override
  Future<Uint8List> readAsBytes() async {
    readCalled = true;
    throw StateError('must not read');
  }
}

class _Session extends SessionNotifier {
  @override
  SessionState build() => const SessionState(
    status: AuthStatus.authenticated,
    accessToken: 'fixture-A',
    user: UserSummary(id: 1, phone: 'fixture'),
  );
  void switchToken() => state = const AsyncData(
    SessionState(
      status: AuthStatus.authenticated,
      accessToken: 'fixture-B',
      user: UserSummary(id: 1, phone: 'fixture'),
    ),
  );
}

class _Relationships extends RelationshipApi {
  _Relationships() : super(ApiClient(dio: Dio()));
  @override
  Future<Map<String, dynamic>> call(
    String method,
    String path, [
    Map<String, dynamic>? body,
  ]) async => {
    'requests_enabled': false,
    'requests': [
      {
        'id': 1,
        'sender_id': 1,
        'recipient_id': 2,
        'state': 'PENDING',
        'purpose': 'friendship',
      },
    ],
    'friends': [
      {'peer_id': 2, 'public_id': 'ES-2'},
    ],
  };
}

class _Adapter implements HttpClientAdapter {
  int ownerId = 1;
  int revision = 0;
  bool hasAvatar = false;
  bool failSave = false;
  bool unsafePath = false;
  final requests = <RequestOptions>[];
  Completer<void>? holdContent;
  Completer<void>? holdSave;
  final saveEntered = Completer<void>();
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? body,
    Future<void>? cancel,
  ) async {
    requests.add(options);
    expectSync(options.followRedirects, isFalse);
    expectSync(options.extra[requestSessionGuardKey], isA<bool Function()>());
    if (options.path == '/api/v1/profile/avatar') {
      if (!saveEntered.isCompleted) {
        saveEntered.complete();
      }
      await holdSave?.future;
      if (failSave) {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );
      }
      revision++;
      hasAvatar = options.method != 'DELETE';
    }
    if (RegExp('/avatars/$ownerId/[0-9]+\$').hasMatch(options.path)) {
      await holdContent?.future;
      return ResponseBody.fromBytes(
        _png,
        200,
        headers: {
          Headers.contentTypeHeader: ['image/png'],
        },
      );
    }
    return ResponseBody.fromString(
      jsonEncode({
        'revision': revision,
        'avatar': hasAvatar
            ? {
                'owner_user_id': ownerId,
                'revision': revision,
                'content_path': unsafePath
                    ? 'https://outside.invalid/private'
                    : '/api/v1/avatars/$ownerId/$revision',
              }
            : null,
      }),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _Adapter adapter;
  late AvatarApi api;
  setUp(() {
    adapter = _Adapter();
    api = AvatarApi(
      Dio(BaseOptions(baseUrl: 'https://api.example.test'))
        ..httpClientAdapter = adapter,
    );
  });

  test('oversized selection is refused before bytes are read', () async {
    final file = _OversizeFile();
    await expectLater(
      api.pickAndSave(
        ownerId: 1,
        revision: 0,
        token: 'A',
        current: () => true,
        picker: () async => file,
      ),
      throwsStateError,
    );
    expect(file.readCalled, isFalse);
    expect(adapter.requests, isEmpty);
  });

  test('cancel picker makes no request', () async {
    expect(
      await api.pickAndSave(
        ownerId: 1,
        revision: 0,
        token: 'A',
        current: () => true,
        picker: () async => null,
      ),
      isNull,
    );
    expect(adapter.requests, isEmpty);
  });

  test('late picker after token switch cannot upload', () async {
    var current = true;
    final pick = Completer<XFile?>();
    final result = api.pickAndSave(
      ownerId: 1,
      revision: 0,
      token: 'A',
      current: () => current,
      picker: () => pick.future,
    );
    final assertion = expectLater(result, throwsStateError);
    current = false;
    pick.complete(XFile.fromData(_png, name: 'avatar.png'));
    await assertion;
    expect(adapter.requests, isEmpty);
  });

  test(
    'save sends expected revision and confirms by authenticated readback',
    () async {
      final saved = await api.pickAndSave(
        ownerId: 1,
        revision: 0,
        token: 'A',
        current: () => true,
        picker: () async => XFile.fromData(_png, name: 'avatar.png'),
      );
      expect(saved?.revision, 1);
      expect(adapter.requests.map((e) => e.method), ['POST', 'GET']);
      final form = adapter.requests.first.data as FormData;
      expect(form.fields.single.value, '0');
      expect(
        adapter.requests.every((e) => e.headers['Authorization'] == 'Bearer A'),
        isTrue,
      );
      final removed = await api.remove(1, 1, 'A', () => true);
      expect(removed.contentPath, isNull);
      expect(removed.revision, 2);
      expect(adapter.requests[2].data, {'expected_revision': 1});
    },
  );

  test('save network failure never reports confirmed snapshot', () async {
    adapter.failSave = true;
    await expectLater(
      api.pickAndSave(
        ownerId: 1,
        revision: 0,
        token: 'A',
        current: () => true,
        picker: () async => XFile.fromData(_png),
      ),
      throwsA(isA<DioException>()),
    );
    expect(adapter.requests.length, 1);
  });

  test(
    'strict relative path rejects external, query and owner substitutions',
    () {
      for (final path in [
        'https://api.example.test/api/v1/avatars/1/1',
        '//outside/1',
        '/api/v1/avatars/1/1?x=1',
        '/api/v1/avatars/2/1',
        '/api/v1/avatars/1/01',
      ]) {
        expect(validAvatarPath(path, 1, 1), isFalse);
      }
      expect(validAvatarPath('/api/v1/avatars/1/1', 1, 1), isTrue);
    },
  );

  test(
    'late save response after session switch is rejected before readback',
    () async {
      var current = true;
      adapter.holdSave = Completer<void>();
      final result = api.pickAndSave(
        ownerId: 1,
        revision: 0,
        token: 'A',
        current: () => current,
        picker: () async => XFile.fromData(_png),
      );
      final assertion = expectLater(result, throwsStateError);
      await adapter.saveEntered.future;
      current = false;
      adapter.holdSave!.complete();
      await assertion;
      expect(adapter.requests.length, 1);
    },
  );

  Future<ProviderContainer> mount(
    WidgetTester tester,
    Widget child, {
    AvatarPicker? picker,
  }) async {
    final container = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith(_Session.new),
        avatarApiProvider.overrideWithValue(api),
        if (picker != null) avatarPickerProvider.overrideWithValue(picker),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: Scaffold(body: child)),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets(
    'image clears and evicts on epoch, inactive and session changes',
    (tester) async {
      adapter.hasAvatar = true;
      adapter.revision = 1;
      final container = await mount(
        tester,
        const AuthenticatedAvatar(ownerId: 1),
      );
      expect(find.byType(Image), findsOneWidget);
      final old = tester.widget<Image>(find.byType(Image)).image;
      adapter.holdContent = Completer<void>();
      container.read(relationshipAuthorityEpochProvider.notifier).invalidate();
      await tester.pump();
      expect(find.byType(Image), findsNothing);
      expect(
        (await old.obtainCacheStatus(
          configuration: ImageConfiguration.empty,
        ))?.tracked,
        isFalse,
      );
      adapter.holdContent!.complete();
      adapter.holdContent = null;
      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsOneWidget);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(find.byType(Image), findsNothing);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      adapter.holdContent = Completer<void>();
      (container.read(sessionProvider.notifier) as _Session).switchToken();
      await tester.pump();
      expect(find.byType(Image), findsNothing);
      adapter.holdContent!.complete();
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('refresh after deletion drops the old memory image', (
    tester,
  ) async {
    adapter.hasAvatar = true;
    adapter.revision = 1;
    final container = await mount(
      tester,
      const AuthenticatedAvatar(ownerId: 1, refreshKey: 0),
    );
    expect(find.byType(Image), findsOneWidget);
    adapter.hasAvatar = false;
    adapter.revision = 2;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: AuthenticatedAvatar(ownerId: 1, refreshKey: 1)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('management success is shown only after saved readback', (
    tester,
  ) async {
    await mount(
      tester,
      const AvatarManagementPage(),
      picker: () async => XFile.fromData(_png),
    );
    await tester.tap(find.text('从相册更换头像'));
    await tester.pumpAndSettle();
    expect(find.text('头像已更新并读回确认。'), findsOneWidget);
    expect(adapter.revision, 1);
    expect(adapter.requests.where((r) => r.method == 'POST').length, 1);
  });

  testWidgets(
    'parent relationship refresh reauthorizes retained pending and friend avatars',
    (tester) async {
      tester.view.physicalSize = const Size(1000, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      adapter.ownerId = 2;
      adapter.revision = 1;
      adapter.hasAvatar = true;
      final container = ProviderContainer(
        overrides: [
          sessionProvider.overrideWith(_Session.new),
          avatarApiProvider.overrideWithValue(api),
          relationshipApiProvider.overrideWithValue(_Relationships()),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: RelationshipCenterPage()),
        ),
      );
      await tester.pumpAndSettle();
      // Scroll both retained rows into view so both real parent bindings load.
      await tester.ensureVisible(find.text('双向好友'));
      await tester.pumpAndSettle();
      final before = adapter.requests
          .where((r) => r.path == '/api/v1/avatars/2')
          .length;
      expect(before, greaterThanOrEqualTo(2));
      final oldImages = tester
          .widgetList<Image>(find.byType(Image))
          .map((image) => image.image)
          .toList();
      expect(oldImages.length, 2);
      adapter.hasAvatar = false;
      adapter.revision = 2;
      await tester.tap(find.byTooltip('刷新'));
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsNothing);
      expect(
        adapter.requests.where((r) => r.path == '/api/v1/avatars/2').length,
        greaterThanOrEqualTo(before + 2),
      );
      for (final image in oldImages) {
        expect(
          (await image.obtainCacheStatus(
            configuration: ImageConfiguration.empty,
          ))?.tracked,
          isFalse,
        );
      }
      expect(find.text('双向好友'), findsOneWidget);
    },
  );

  testWidgets('unsafe metadata never causes content request', (tester) async {
    adapter.hasAvatar = true;
    adapter.revision = 1;
    adapter.unsafePath = true;
    await mount(tester, const AuthenticatedAvatar(ownerId: 1));
    expect(find.byType(Image), findsNothing);
    expect(adapter.requests.length, 1);
  });

  testWidgets('management cancel and failed save show no success', (
    tester,
  ) async {
    var cancel = true;
    await mount(
      tester,
      const AvatarManagementPage(),
      picker: () async => cancel ? null : XFile.fromData(_png),
    );
    await tester.tap(find.text('从相册更换头像'));
    await tester.pumpAndSettle();
    expect(find.text('头像已更新并读回确认。'), findsNothing);
    expect(adapter.requests.where((r) => r.method == 'POST'), isEmpty);
    cancel = false;
    adapter.failSave = true;
    await tester.tap(find.text('从相册更换头像'));
    await tester.pumpAndSettle();
    expect(find.text('头像已更新并读回确认。'), findsNothing);
    expect(find.text('头像请求失败，请检查网络并刷新后重试。'), findsOneWidget);
  });
}

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/telemetry/app_telemetry_service.dart';
import 'package:flutter_elitesync_module/core/telemetry/frontend_telemetry.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/services/rtc_permission_service.dart';
import 'package:flutter_elitesync_module/features/rtc/presentation/pages/rtc_permission_page.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';

class _PermissionSession extends SessionNotifier {
  static SessionState member(int id) => SessionState(
    status: AuthStatus.authenticated,
    accessToken: 'permission-fixture-$id',
    user: UserSummary(id: id, phone: ''),
  );

  @override
  SessionState build() => member(1);

  void change(int id) => state = AsyncData(member(id));
}

class FakeAppTelemetryService extends AppTelemetryService {
  FakeAppTelemetryService()
    : super(
        apiClient: ApiClient(
          dio: Dio(BaseOptions(baseUrl: 'http://127.0.0.1')),
        ),
        appVersionProvider: () async => '0.04.06',
      );

  final List<Map<String, Object?>> calls = <Map<String, Object?>>[];

  @override
  Future<NetworkResult<Map<String, dynamic>>> postEvent(
    String path, {
    required String sourcePage,
    Object? body,
  }) async {
    calls.add({'path': path, 'sourcePage': sourcePage, 'body': body});
    return const NetworkSuccess(<String, dynamic>{});
  }
}

class FakeRtcPermissionService implements RtcPermissionService {
  FakeRtcPermissionService({required this.granted, this.cameraGranted = false});

  bool granted;
  bool cameraGranted;
  bool openSettingsCalled = false;
  bool failRequest = false;
  Completer<bool>? voiceRequest;
  Completer<bool>? cameraRequest;
  final List<String> requests = [];

  @override
  Future<bool> ensureVoiceCallPermission() async {
    requests.add('microphone');
    if (failRequest) throw StateError('permission fixture failure');
    granted = await (voiceRequest?.future ?? Future.value(granted));
    return granted;
  }

  @override
  Future<bool> ensureCameraPermission() async {
    requests.add('camera');
    cameraGranted =
        await (cameraRequest?.future ?? Future.value(cameraGranted));
    return cameraGranted;
  }

  @override
  Future<bool> hasVoiceCallPermission() async => granted;

  @override
  Future<bool> hasCameraPermission() async => cameraGranted;

  @override
  Future<bool> openSettings() async {
    openSettingsCalled = true;
    return true;
  }
}

Widget _wrap(Widget child, {required FakeRtcPermissionService service}) {
  final telemetry = FakeAppTelemetryService();
  return ProviderScope(
    overrides: [
      sessionProvider.overrideWith(_PermissionSession.new),
      appEnvProvider.overrideWithValue(
        const AppEnv(
          flavor: AppFlavor.dev,
          appName: 'EliteSync',
          apiBaseUrl: 'http://127.0.0.1',
          useMockData: true,
        ),
      ),
      frontendTelemetryProvider.overrideWithValue(
        FrontendTelemetry(telemetry: telemetry),
      ),
      rtcPermissionServiceProvider.overrideWithValue(service),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      home: child,
    ),
  );
}

Future<ValueNotifier<bool?>> _openGate(
  WidgetTester tester,
  FakeRtcPermissionService service, {
  bool requireCamera = false,
}) async {
  final result = ValueNotifier<bool?>(null);
  addTearDown(result.dispose);
  await tester.pumpWidget(
    _wrap(
      Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async {
              result.value = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    body: RtcPermissionPage(requireCamera: requireCamera),
                  ),
                ),
              );
            },
            child: const Text('打开权限页'),
          ),
        ),
      ),
      service: service,
    ),
  );
  await tester.tap(find.text('打开权限页'));
  await tester.pumpAndSettle();
  return result;
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized()
        .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  });

  testWidgets('RtcPermissionPage renders permission hints and actions', (
    tester,
  ) async {
    final service = FakeRtcPermissionService(granted: false);

    await tester.pumpWidget(
      _wrap(const RtcPermissionPage(title: '通话权限'), service: service),
    );

    await tester.pumpAndSettle();

    expect(find.text('通话权限'), findsWidgets);
    expect(find.text('麦克风权限'), findsOneWidget);
    expect(find.text('申请麦克风权限'), findsWidgets);
    expect(find.text('打开系统设置'), findsWidgets);
    expect(find.text('返回'), findsWidgets);
  });

  testWidgets('video requires camera even when microphone is already granted', (
    tester,
  ) async {
    final service = FakeRtcPermissionService(granted: true);
    final result = await _openGate(tester, service, requireCamera: true);
    expect(result.value, isNull);
    expect(find.text('麦克风和摄像头权限'), findsOneWidget);
    expect(find.text('申请通话权限'), findsOneWidget);
  });

  testWidgets('video camera denial keeps the gate open', (tester) async {
    final service = FakeRtcPermissionService(granted: true);
    final result = await _openGate(tester, service, requireCamera: true);
    await tester.tap(find.text('申请通话权限'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(service.requests, ['microphone', 'camera']);
    expect(result.value, isNull);
    expect(find.text('通话权限尚未完整开启，请在系统设置中授权后重试'), findsOneWidget);
  });

  testWidgets('video grants microphone before camera and returns success', (
    tester,
  ) async {
    final service = FakeRtcPermissionService(granted: false)
      ..voiceRequest = Completer()
      ..cameraRequest = Completer();
    final result = await _openGate(tester, service, requireCamera: true);
    await tester.tap(find.text('申请通话权限'));
    await tester.pump();
    expect(service.requests, ['microphone']);
    service.voiceRequest!.complete(true);
    await tester.pump();
    expect(service.requests, ['microphone', 'camera']);
    service.cameraRequest!.complete(true);
    await tester.pumpAndSettle();
    expect(result.value, isTrue);
  });

  testWidgets('permission result waits through inactive until resumed', (
    tester,
  ) async {
    final service = FakeRtcPermissionService(granted: false)
      ..voiceRequest = Completer();
    final result = await _openGate(tester, service);
    await tester.tap(find.text('申请麦克风权限'));
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    service.voiceRequest!.complete(true);
    await tester.pump();
    expect(result.value, isNull);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(result.value, isTrue);
  });

  testWidgets(
    'Home during the request cancels before camera and returns false',
    (tester) async {
      final service = FakeRtcPermissionService(granted: false)
        ..voiceRequest = Completer();
      final result = await _openGate(tester, service, requireCamera: true);
      await tester.tap(find.text('申请通话权限'));
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      service.voiceRequest!.complete(true);
      await tester.pump();
      expect(result.value, isNull);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(result.value, isFalse);
      expect(service.requests, ['microphone']);
    },
  );

  testWidgets('account change cancels a pending permission request', (
    tester,
  ) async {
    final service = FakeRtcPermissionService(granted: false)
      ..voiceRequest = Completer();
    final result = await _openGate(tester, service, requireCamera: true);
    await tester.tap(find.text('申请通话权限'));
    await tester.pump();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(RtcPermissionPage)),
    );
    (container.read(sessionProvider.notifier) as _PermissionSession).change(2);
    await tester.pump();
    service.voiceRequest!.complete(true);
    await tester.pumpAndSettle();
    expect(result.value, isFalse);
    expect(service.requests, ['microphone']);
  });

  testWidgets('permission exception keeps the gate available for retry', (
    tester,
  ) async {
    final service = FakeRtcPermissionService(granted: false)
      ..failRequest = true;
    final result = await _openGate(tester, service);
    await tester.tap(find.text('申请麦克风权限'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(result.value, isNull);
    expect(find.text('权限申请失败，请重试或前往系统设置'), findsOneWidget);
    expect(find.text('申请麦克风权限'), findsOneWidget);
  });
}

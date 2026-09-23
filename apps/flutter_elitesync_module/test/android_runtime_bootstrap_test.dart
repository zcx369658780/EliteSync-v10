import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/app/router/app_shell.dart';
import 'package:flutter_elitesync_module/main_demo.dart';
import 'package:flutter_elitesync_module/app/bootstrap/app_bootstrap.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _BootstrapStorage extends LocalStorageService {
  _BootstrapStorage(this.events, {this.fail = false});

  final List<String> events;
  final bool fail;

  @override
  Future<void> purgeLegacyPrivateChatCache() async {
    events.add('purge');
    if (fail) throw StateError('synthetic failure');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('shared bootstrap purges before presenting the app', () async {
    final events = <String>[];
    await runEliteSyncApp(
      createDemoAppEnv(),
      localStorage: _BootstrapStorage(events),
      launch: (Widget _) => events.add('display'),
    );
    expect(events, ['purge', 'display']);
  });

  test('failed bootstrap cleanup stays visible and retryable', () async {
    final events = <String>[];
    await runEliteSyncApp(
      createDemoAppEnv(),
      localStorage: _BootstrapStorage(events, fail: true),
      launch: (Widget _) => events.add('display'),
    );
    expect(events, ['purge', 'display']);
  });

  test('demo environment is local synthetic dev only', () {
    final env = createDemoAppEnv();

    expect(env.flavor, AppFlavor.dev);
    expect(env.appName, contains('Synthetic Dev'));
    expect(Uri.parse(env.apiBaseUrl).host, '127.0.0.1');
    expect(env.useMockData, isTrue);
    expect(env.useLiveKitRtc, isFalse);

    final container = ProviderContainer(
      overrides: [appEnvProvider.overrideWithValue(env)],
    );
    addTearDown(container.dispose);
    expect(container.read(appShellRtcInviteWatcherEnabledProvider), isFalse);
    expect(env.useMockAuth, isTrue);
    expect(env.useMockQuestionnaire, isTrue);
    expect(env.useMockHome, isTrue);
    expect(env.useMockMatch, isTrue);
    expect(env.useMockChat, isTrue);
    expect(env.useMockProfile, isTrue);
    expect(env.useMockAdmin, isTrue);
    expect(env.useSyntheticReadinessProjection, isTrue);
    expect(env.useSyntheticConnectionLifecycle, isTrue);
    expect(env.useSyntheticConversationLifecycle, isTrue);
    expect(env.useSyntheticHomeProjection, isTrue);
    expect(env.useMatchRoundContract, isTrue);
    expect(env.useAdminMatchingOperations, isFalse);
    expect(env.initialRoute, AppRouteNames.home);
    expect(env.initialRoute, '/home');
  });

  test('demo session seed is explicit synthetic state without authority', () {
    expect(syntheticDemoAccessToken, contains('SYNTHETIC_DEMO'));
    expect(syntheticDemoAccessToken, contains('NOT_AUTHORITY'));
    expect(syntheticDemoAccessToken, isNot(contains('Bearer ')));

    expect(syntheticDemoProfile.id, isNegative);
    expect(syntheticDemoProfile.phone, contains('synthetic'));
    expect(syntheticDemoProfile.phone, contains('no-real-phone'));
    expect(syntheticDemoProfile.nickname, contains('Synthetic Demo'));
    expect(syntheticDemoProfile.role, 'user');
    expect(syntheticDemoProfile.verified, isFalse);

    expect(syntheticDemoOnboardingStatus, 'completed');
  });
}

import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/main_demo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('demo environment is local synthetic dev only', () {
    final env = createDemoAppEnv();

    expect(env.flavor, AppFlavor.dev);
    expect(env.appName, contains('Synthetic Dev'));
    expect(Uri.parse(env.apiBaseUrl).host, '127.0.0.1');
    expect(env.useMockData, isTrue);
    expect(env.useLiveKitRtc, isFalse);
    expect(env.useMockAuth, isTrue);
    expect(env.useMockQuestionnaire, isTrue);
    expect(env.useMockHome, isTrue);
    expect(env.useMockMatch, isTrue);
    expect(env.useMockChat, isTrue);
    expect(env.useMockProfile, isTrue);
    expect(env.useMockAdmin, isTrue);
    expect(env.useMatchRoundContract, isFalse);
    expect(env.useAdminMatchingOperations, isFalse);
    expect(env.initialRoute, AppRouteNames.localOnlyVisualFixture);
    expect(env.initialRoute, '/debug/8-1-visual-fixture');
  });
}

import 'package:flutter/widgets.dart';
import 'package:flutter_elitesync_module/app/bootstrap/app_bootstrap.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';

AppEnv createDemoAppEnv() {
  return const AppEnv(
    flavor: AppFlavor.dev,
    appName: 'EliteSync Synthetic Dev',
    apiBaseUrl: 'http://127.0.0.1:9/',
    useMockData: true,
    useLiveKitRtc: false,
    useMockAuth: true,
    useMockQuestionnaire: true,
    useMockHome: true,
    useMockMatch: true,
    useMockChat: true,
    useMockProfile: true,
    useMockAdmin: true,
    useMatchRoundContract: false,
    useAdminMatchingOperations: false,
    initialRoute: AppRouteNames.localOnlyVisualFixture,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runEliteSyncApp(createDemoAppEnv());
}

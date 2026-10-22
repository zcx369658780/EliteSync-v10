// Independent test entry. Normal application entry points never import this.
import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/services/rtc_ice_diagnostic.dart';
import 'package:flutter_elitesync_module/main_prod.dart' as product;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const env = AppEnv(
    flavor: AppFlavor.dev,
    appName: 'ICE_DIAG_TEST_ONLY',
    apiBaseUrl: 'http://127.0.0.1:8031/',
    useMockData: false,
    useLiveKitRtc: true,
    restorationLocalBuild: true,
  );
  if (!await verifyIceDiagnosticHost(env)) {
    runApp(
      const MaterialApp(home: Scaffold(body: Text('ICE_DIAG_GUARD_REJECTED'))),
    );
    return;
  }
  await product.main();
}

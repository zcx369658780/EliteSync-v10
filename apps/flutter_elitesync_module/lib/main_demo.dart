import 'package:flutter/widgets.dart';
import 'package:flutter_elitesync_module/app/bootstrap/app_bootstrap.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/core/storage/secure_storage_service.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';

const syntheticDemoAccessToken = 'ELITESYNC_SYNTHETIC_DEMO_TOKEN_NOT_AUTHORITY';
const syntheticDemoOnboardingStatus = 'completed';
const syntheticDemoProfile = UserSummary(
  id: -13001,
  phone: 'synthetic-demo-no-real-phone',
  nickname: 'EliteSync Synthetic Demo User',
  role: 'user',
);

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
    useSyntheticReadinessProjection: true,
    useSyntheticConnectionLifecycle: true,
    useMatchRoundContract: true,
    useAdminMatchingOperations: false,
    initialRoute: AppRouteNames.home,
  );
}

Future<void> seedSyntheticDemoSession({
  SecureStorageService? secureStorage,
  LocalStorageService? localStorage,
}) async {
  final secure = secureStorage ?? SecureStorageService();
  final local = localStorage ?? LocalStorageService();

  await secure.write(CacheKeys.accessToken, syntheticDemoAccessToken);
  await secure.delete(CacheKeys.refreshToken);
  await local.setJson(
    CacheKeys.lastKnownProfile,
    syntheticDemoProfile.toJson(),
  );
  await local.setBool(CacheKeys.onboardingDone, true);
  await local.setString(
    CacheKeys.firstUseOnboardingV1Status,
    syntheticDemoOnboardingStatus,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await seedSyntheticDemoSession();
  runEliteSyncApp(createDemoAppEnv());
}

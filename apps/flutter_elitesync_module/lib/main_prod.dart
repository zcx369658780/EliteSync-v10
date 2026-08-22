import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_elitesync_module/app/bootstrap/app_bootstrap.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';

@immutable
class InternalFeatureGateResolution {
  const InternalFeatureGateResolution({
    required this.flavor,
    required this.useMatchRoundContract,
    required this.useAdminMatchingOperations,
  });

  final AppFlavor flavor;
  final bool useMatchRoundContract;
  final bool useAdminMatchingOperations;
}

@visibleForTesting
InternalFeatureGateResolution resolveInternalFeatureGates({
  required bool c2LocalBuild,
  required bool internalDevPreview,
  required bool matchRoundContract,
  required bool adminMatchingOperations,
}) {
  final hasInternalParent = c2LocalBuild || internalDevPreview;
  return InternalFeatureGateResolution(
    flavor: hasInternalParent ? AppFlavor.dev : AppFlavor.prod,
    useMatchRoundContract: hasInternalParent && matchRoundContract,
    useAdminMatchingOperations: hasInternalParent && adminMatchingOperations,
  );
}

Future<Map<String, String>> _readHostBootstrap() async {
  try {
    const channel = MethodChannel('elitesync/bootstrap');
    final payload = await channel.invokeMapMethod<dynamic, dynamic>(
      'getBootstrap',
    );
    if (payload == null) return const {};
    return payload.map(
      (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
    );
  } catch (_) {
    return const {};
  }
}

String _firstNonEmpty(List<String> values) {
  for (final value in values) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) return trimmed;
  }
  return '';
}

@visibleForTesting
String resolveApiBaseUrl({required Map<String, String> hostBootstrap}) {
  final hostOverride = _firstNonEmpty([hostBootstrap['apiBaseUrl'] ?? '']);
  if (hostOverride.isNotEmpty) {
    return hostOverride.endsWith('/') ? hostOverride : '$hostOverride/';
  }
  final override = String.fromEnvironment('ELITESYNC_API_BASE_URL').trim();
  if (override.isNotEmpty) {
    return override.endsWith('/') ? override : '$override/';
  }
  return 'http://101.133.161.203/';
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hostBootstrap = await _readHostBootstrap();
  const internalDevPreview = bool.fromEnvironment(
    'ELITESYNC_INTERNAL_DEV_PREVIEW',
  );
  const c2LocalBuild = bool.fromEnvironment('ELITESYNC_C2_LOCAL_BUILD');
  final internalFeatures = resolveInternalFeatureGates(
    c2LocalBuild: c2LocalBuild,
    internalDevPreview: internalDevPreview,
    matchRoundContract: const bool.fromEnvironment(
      'ELITESYNC_MATCH_ROUND_CONTRACT',
    ),
    adminMatchingOperations: const bool.fromEnvironment(
      'ELITESYNC_ADMIN_MATCHING_OPERATIONS',
    ),
  );
  final flavor = internalFeatures.flavor;
  final initialRoute = _firstNonEmpty([
    String.fromEnvironment('ELITESYNC_INITIAL_ROUTE'),
    hostBootstrap['initialRoute'] ?? '',
  ]);

  // ignore: avoid_print
  print(
    'MAIN_PROD_BOOTSTRAP initialRoute=${initialRoute.isNotEmpty ? initialRoute : "null"} flavor=${flavor.name}',
  );

  runEliteSyncApp(
    AppEnv(
      flavor: flavor,
      appName: flavor == AppFlavor.dev ? 'EliteSync Dev' : 'EliteSync',
      // The Android host app embeds the Flutter release AAR, which always
      // boots through main.dart -> main_prod.dart. Keep prod pointed at the
      // verified direct backend entry until the public domain chain is stable.
      apiBaseUrl: resolveApiBaseUrl(hostBootstrap: hostBootstrap),
      useMockData: false,
      useLiveKitRtc: true,
      useMockAuth: false,
      useMockQuestionnaire: false,
      useMockHome: false,
      useMockMatch: false,
      useMockChat: false,
      useMockProfile: false,
      useMockAdmin: false,
      useMatchRoundContract: internalFeatures.useMatchRoundContract,
      useAdminMatchingOperations: internalFeatures.useAdminMatchingOperations,
      initialRoute: initialRoute.isEmpty ? null : initialRoute,
    ),
  );
}

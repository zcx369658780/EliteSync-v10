import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_elitesync_module/app/bootstrap/app_bootstrap.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/chat_socket_endpoint.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/core/network/api_transport_policy.dart';

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
String resolveApiBaseUrl({
  required Map<String, String> hostBootstrap,
  bool allowLocalInsecure = false,
  bool functionBuild = const bool.fromEnvironment(
    'ELITESYNC_V2_FUNCTION_BUILD',
  ),
  String compiledOrigin = const String.fromEnvironment(
    'ELITESYNC_API_BASE_URL',
  ),
}) {
  final hostOverride = _firstNonEmpty([hostBootstrap['apiBaseUrl'] ?? '']);
  if (functionBuild) {
    if (compiledOrigin != functionApiOrigin || hostOverride != compiledOrigin) {
      throw StateError('V2 function native and Dart endpoints must match');
    }
    return compiledOrigin;
  }
  if (const bool.fromEnvironment('ELITESYNC_V1015_LOCAL_BUILD')) {
    if (hostOverride != 'http://127.0.0.1:8021/') {
      throw StateError('v10.1.5 requires its isolated local host.');
    }
    return hostOverride;
  }
  if (const bool.fromEnvironment('ELITESYNC_V1014_LOCAL_BUILD')) {
    if (hostOverride != 'http://127.0.0.1:8019/') {
      throw StateError('v10.1.4 requires its isolated local host.');
    }
    return hostOverride;
  }
  if (const bool.fromEnvironment('ELITESYNC_V1013_LOCAL_BUILD')) {
    if (hostOverride != 'http://127.0.0.1:8017/') {
      throw StateError('v10.1.3 requires its isolated local host.');
    }
    return hostOverride;
  }
  if (const bool.fromEnvironment('ELITESYNC_V1012_LOCAL_BUILD')) {
    if (hostOverride != 'http://127.0.0.1:8015/') {
      throw StateError('v10.1.2 requires its isolated local host.');
    }
    return hostOverride;
  }
  if (const bool.fromEnvironment('ELITESYNC_RELATIONSHIP_DEV_BUILD')) {
    if (hostOverride != 'http://127.0.0.1:8012/') {
      throw StateError(
        'Relationship development requires its isolated local host.',
      );
    }
    return hostOverride;
  }
  if (const bool.fromEnvironment('ELITESYNC_V1011_LOCAL_BUILD')) {
    if (hostOverride != 'http://127.0.0.1:8011/') {
      throw StateError('Dynamic chart build requires its isolated local host.');
    }
    return hostOverride;
  }
  if (const bool.fromEnvironment('ELITESYNC_V1010_LOCAL_BUILD')) {
    if (hostOverride != 'http://127.0.0.1:8010/') {
      throw StateError(
        'Natal restoration build requires its isolated local host.',
      );
    }
    return hostOverride;
  }
  if (const bool.fromEnvironment('ELITESYNC_V1006_LOCAL_BUILD') ||
      const bool.fromEnvironment('ELITESYNC_V1007_LOCAL_BUILD') ||
      const bool.fromEnvironment('ELITESYNC_V1008_LOCAL_BUILD') ||
      const bool.fromEnvironment('ELITESYNC_V1009_LOCAL_BUILD')) {
    if (hostOverride != 'http://127.0.0.1:8000/') {
      throw StateError(
        'Restoration build requires the matching local Android host.',
      );
    }
    return hostOverride;
  }
  if (hostOverride.isNotEmpty) {
    return validateApiBaseUrl(
      hostOverride,
      allowLocalInsecure: allowLocalInsecure,
    );
  }
  final override = compiledOrigin.trim();
  if (override.isNotEmpty) {
    return validateApiBaseUrl(override, allowLocalInsecure: allowLocalInsecure);
  }
  return 'https://slowdate.top/';
}

@visibleForTesting
String resolveWsBaseUrl({
  required String apiBaseUrl,
  required Map<String, String> hostBootstrap,
  required AppFlavor flavor,
  String? environmentOverride,
}) => resolveChatSocketBaseUrl(
  apiBaseUrl: apiBaseUrl,
  override: _firstNonEmpty([
    hostBootstrap['wsBaseUrl'] ?? '',
    environmentOverride ??
        const String.fromEnvironment('ELITESYNC_WS_BASE_URL'),
  ]),
  allowLocalInsecure: flavor == AppFlavor.dev,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hostBootstrap = await _readHostBootstrap();
  const functionBuild = bool.fromEnvironment('ELITESYNC_V2_FUNCTION_BUILD');
  String? functionCertificate;
  if (functionBuild) {
    try {
      resolveApiBaseUrl(hostBootstrap: hostBootstrap);
      final certificate = hostBootstrap['functionCertificate'];
      if (certificate == null || certificate.isEmpty) {
        throw StateError('V2 function certificate missing');
      }
      functionTlsContext(certificate);
      functionCertificate = certificate;
    } on Exception {
      _showFunctionConfigurationError();
      return;
    } on StateError {
      _showFunctionConfigurationError();
      return;
    }
  }
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
  const restoration =
      bool.fromEnvironment('ELITESYNC_V1015_LOCAL_BUILD') ||
      bool.fromEnvironment('ELITESYNC_V1014_LOCAL_BUILD') ||
      bool.fromEnvironment('ELITESYNC_V1013_LOCAL_BUILD') ||
      bool.fromEnvironment('ELITESYNC_V1012_LOCAL_BUILD') ||
      bool.fromEnvironment('ELITESYNC_RELATIONSHIP_DEV_BUILD') ||
      bool.fromEnvironment('ELITESYNC_V1006_LOCAL_BUILD') ||
      bool.fromEnvironment('ELITESYNC_V1007_LOCAL_BUILD') ||
      bool.fromEnvironment('ELITESYNC_V1008_LOCAL_BUILD') ||
      bool.fromEnvironment('ELITESYNC_V1009_LOCAL_BUILD') ||
      bool.fromEnvironment('ELITESYNC_V1010_LOCAL_BUILD') ||
      bool.fromEnvironment('ELITESYNC_V1011_LOCAL_BUILD');
  final flavor = restoration ? AppFlavor.dev : internalFeatures.flavor;
  final initialRoute = _firstNonEmpty([
    String.fromEnvironment('ELITESYNC_INITIAL_ROUTE'),
    hostBootstrap['initialRoute'] ?? '',
  ]);

  // ignore: avoid_print
  print(
    'MAIN_PROD_BOOTSTRAP initialRoute=${initialRoute.isNotEmpty ? initialRoute : "null"} flavor=${flavor.name}',
  );

  const rtcRestoration =
      bool.fromEnvironment('ELITESYNC_V1015_LOCAL_BUILD') ||
      bool.fromEnvironment('ELITESYNC_V1009_LOCAL_BUILD') ||
      bool.fromEnvironment('ELITESYNC_RELATIONSHIP_DEV_BUILD');
  final apiBaseUrl = resolveApiBaseUrl(
    hostBootstrap: hostBootstrap,
    allowLocalInsecure: flavor == AppFlavor.dev,
  );
  await runEliteSyncApp(
    AppEnv(
      flavor: flavor,
      appName: flavor == AppFlavor.dev ? 'EliteSync Dev' : 'EliteSync',
      // Match the host's existing secure default; endpoint availability and
      // production deployment remain separate from URL validation.
      apiBaseUrl: apiBaseUrl,
      wsBaseUrl: functionBuild
          ? ''
          : resolveWsBaseUrl(
              apiBaseUrl: apiBaseUrl,
              hostBootstrap: hostBootstrap,
              flavor: flavor,
            ),
      useMockData: false,
      useLiveKitRtc: !functionBuild && (rtcRestoration || !restoration),
      restorationLocalBuild: restoration,
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
      functionTlsCertificate: functionCertificate,
    ),
  );
}

void _showFunctionConfigurationError() {
  runApp(
    const MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Center(child: Text('测试包的服务地址或证书不匹配。请使用同一次构建的安装包。')),
        ),
      ),
    ),
  );
}

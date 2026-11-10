import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_profile_errors.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_chart_settings_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/natal_chart_svg_builder.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'natal_restoration_provider.dart';

Future<Map<String, dynamic>?> _fetchAstroProfile(
  Ref ref, {
  required String path,
  Map<String, dynamic>? query,
  String? fallbackPath,
  Map<String, dynamic>? fallbackQuery,
}) async {
  var active = true;
  ref.onDispose(() => active = false);
  final session = await ref.watch(sessionProvider.future);
  bool current() =>
      active &&
      natalSessionMatches(session, ref.read(sessionProvider).asData?.value);
  void requireCurrent() {
    if (!current()) {
      throw const AstroProfileApiException(
        message: '登录身份已变化，请重新读取。',
        statusCode: 401,
        code: 'stale_session',
      );
    }
  }

  requireCurrent();
  Future<NetworkResult<Map<String, dynamic>>> request(
    String requestPath,
    Map<String, dynamic>? requestQuery,
  ) {
    requireCurrent();
    return ref
        .read(apiClientProvider)
        .get(
          requestPath,
          query: requestQuery,
          options: natalSessionOptions(current),
        )
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw const AstroProfileApiException(
            message: '星盘请求超时，请检查网络后重试。',
            statusCode: 504,
            code: 'timeout',
          ),
        );
  }

  NetworkResult<Map<String, dynamic>> result = await request(path, query);
  requireCurrent();
  if (result is NetworkSuccess<Map<String, dynamic>>) {
    final exists = result.data['exists'] == true;
    if (!exists) return null;
    final profile = result.data['profile'];
    if (profile is Map<String, dynamic>) return profile;
    return null;
  }

  var failure = result as NetworkFailure<Map<String, dynamic>>;
  if (failure.statusCode == 404 && fallbackPath != null) {
    result = await request(fallbackPath, fallbackQuery);
    requireCurrent();
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      final exists = result.data['exists'] == true;
      if (!exists) return null;
      final profile = result.data['profile'];
      if (profile is Map<String, dynamic>) return profile;
      return null;
    }
    failure = result as NetworkFailure<Map<String, dynamic>>;
  }

  // AuthInterceptor owns token-bound session rejection. A delayed profile
  // response must never invoke an unconditional logout of a newer session.

  throw AstroProfileApiException(
    message: failure.message,
    statusCode: failure.statusCode,
    code: failure.code,
  );
}

final astroSummaryProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final routeMode = ref.watch(astroChartRouteProvider).routeMode.name;
  return _fetchAstroProfile(
    ref,
    path: '/api/v1/profile/astro/summary',
    query: {'route_mode': routeMode},
    fallbackPath: '/api/v1/profile/astro',
    fallbackQuery: {'include_chart': 0, 'route_mode': routeMode},
  );
});

final astroNatalChartProvider = FutureProvider<Map<String, dynamic>?>((
  ref,
) async {
  final routeMode = ref.watch(astroChartRouteProvider).routeMode.name;
  return _fetchAstroProfile(
    ref,
    path: '/api/v1/profile/astro/chart',
    query: {'route_mode': routeMode},
    fallbackPath: '/api/v1/profile/astro',
    fallbackQuery: {'route_mode': routeMode},
  );
});

final astroChartPreviewProvider = FutureProvider<String?>((ref) async {
  final profile = await ref.watch(astroNatalChartProvider.future);
  if (profile == null) return null;
  if (profile.containsKey('natal')) return null;
  final svg = buildNatalChartSvgFromProfile(profile).trim();
  return svg.isEmpty ? null : svg;
});

final astroServerProfileProvider = astroSummaryProvider;

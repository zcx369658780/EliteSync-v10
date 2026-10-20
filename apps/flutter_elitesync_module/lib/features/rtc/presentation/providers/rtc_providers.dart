import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_elitesync_module/features/rtc/data/datasource/rtc_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/entities/rtc_session_entity.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/services/rtc_livekit_service.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

final rtcRemoteDataSourceProvider = Provider<RtcRemoteDataSource>((ref) {
  final session = ref.watch(sessionProvider).asData?.value;
  return RtcRemoteDataSource(
    apiClient: ref.watch(apiClientProvider),
    isCurrent: () =>
        ref.mounted &&
        session?.isLoggedIn == true &&
        identical(ref.read(sessionProvider).asData?.value, session),
  );
});

final rtcCallsProvider = FutureProvider<List<RtcSessionEntity>>((ref) async {
  if (ref.watch(sessionProvider).asData?.value.isLoggedIn != true) return [];
  return ref.watch(rtcRemoteDataSourceProvider).fetchCalls();
});

final rtcCallProvider = FutureProvider.family<RtcSessionEntity, int>(
  (ref, callId) async {
    if (ref.watch(sessionProvider).asData?.value.isLoggedIn != true) {
      throw StateError('RTC requires current login');
    }
    return ref.watch(rtcRemoteDataSourceProvider).fetchCall(callId);
  },
  // The call page already polls. A second retry loop can hide revoked/unknown
  // authorization behind loading state instead of showing the fail-closed UI.
  retry: (_, _) => null,
);

final rtcLiveKitServiceProvider = ChangeNotifierProvider<RtcLiveKitService>((
  ref,
) {
  ref.watch(sessionProvider);
  return RtcLiveKitService(
    remoteDataSource: ref.watch(rtcRemoteDataSourceProvider),
    appEnv: ref.watch(appEnvProvider),
  );
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/features/notification/data/datasource/notification_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/notification/domain/entities/notification_item_entity.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';

final notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>((ref) {
      final env = ref.watch(appEnvProvider);
      return NotificationRemoteDataSource(
        apiClient: ref.watch(apiClientProvider),
        useMock: env.useMockData,
        identity: () =>
            '${ref.read(sessionProvider).asData?.value.accessToken}:${ref.read(relationshipAuthorityEpochProvider)}',
      );
    });

final notificationListProvider = FutureProvider<List<NotificationItemEntity>>((
  ref,
) async {
  ref.watch(relationshipAuthorityEpochProvider);
  if (ref.watch(sessionProvider).asData?.value.isLoggedIn != true) return [];
  return ref.read(notificationRemoteDataSourceProvider).fetchNotifications();
});

final notificationUnreadCountProvider = FutureProvider<int>((ref) async {
  ref.watch(relationshipAuthorityEpochProvider);
  if (ref.watch(sessionProvider).asData?.value.isLoggedIn != true) return 0;
  return ref.read(notificationRemoteDataSourceProvider).fetchUnreadCount();
});

final notificationPreferencesProvider = FutureProvider<bool>((ref) async {
  final local = ref.read(localStorageProvider);
  return await local.getBool(CacheKeys.pushNotificationEnabled) ?? true;
});

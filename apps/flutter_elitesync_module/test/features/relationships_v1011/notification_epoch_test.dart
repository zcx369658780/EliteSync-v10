import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_elitesync_module/features/notification/data/datasource/notification_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/notification/domain/entities/notification_item_entity.dart';
import 'package:flutter_elitesync_module/features/notification/presentation/providers/notification_provider.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'relationship_pages_test.dart' as support;

class _Session extends support.TestSession {
  void logout() =>
      state = const AsyncData(SessionState(status: AuthStatus.unauthenticated));
}

class _Remote extends NotificationRemoteDataSource {
  _Remote() : super(apiClient: ApiClient(dio: Dio()), useMock: false);
  final lists = <Completer<List<NotificationItemEntity>>>[];
  final counts = <Completer<int>>[];
  @override
  Future<List<NotificationItemEntity>> fetchNotifications({int limit = 50}) {
    final future = Completer<List<NotificationItemEntity>>();
    lists.add(future);
    return future.future;
  }

  @override
  Future<int> fetchUnreadCount() {
    final future = Completer<int>();
    counts.add(future);
    return future.future;
  }
}

class _View extends ConsumerWidget {
  const _View();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(notificationListProvider);
    final count = ref.watch(notificationUnreadCountProvider);
    return Column(
      children: [
        Text(
          list.when(
            skipLoadingOnReload: false,
            skipLoadingOnRefresh: false,
            data: (items) => items.map((e) => e.routeName).join(','),
            error: (_, _) => 'error',
            loading: () => 'loading',
          ),
        ),
        Text('count:${count.isLoading ? 0 : count.asData?.value ?? 0}'),
      ],
    );
  }
}

NotificationItemEntity _item(String route) =>
    NotificationItemEntity.fromJson({'id': 1, 'route_name': route});
void main() {
  testWidgets(
    'late A notifications cannot populate B and block epoch removes old count and route',
    (tester) async {
      final remote = _Remote();
      final container = ProviderContainer(
        overrides: [
          sessionProvider.overrideWith(_Session.new),
          notificationRemoteDataSourceProvider.overrideWithValue(remote),
        ],
      );
      addTearDown(container.dispose);
      await container.read(sessionProvider.future);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: _View())),
        ),
      );
      await tester.pumpAndSettle();
      (container.read(sessionProvider.notifier) as support.TestSession).change(
        2,
      );
      await tester.pumpAndSettle();
      remote.lists[1].complete([_item('/B_CURRENT')]);
      remote.counts[1].complete(2);
      await tester.pumpAndSettle();
      remote.lists[0].complete([_item('/A_PRIVATE')]);
      remote.counts[0].complete(9);
      await tester.pumpAndSettle();
      expect(find.text('/A_PRIVATE'), findsNothing);
      expect(find.text('count:9'), findsNothing);
      expect(find.text('/B_CURRENT'), findsOneWidget);
      container.read(relationshipAuthorityEpochProvider.notifier).invalidate();
      await tester.pumpAndSettle();
      expect(find.text('/B_CURRENT'), findsNothing);
      expect(find.text('count:2'), findsNothing);
      remote.lists[2].complete([]);
      remote.counts[2].complete(0);
      await tester.pumpAndSettle();
      expect(find.text('count:0'), findsOneWidget);
      (container.read(sessionProvider.notifier) as _Session).logout();
      await tester.pumpAndSettle();
      expect(await container.read(notificationListProvider.future), isEmpty);
      expect(await container.read(notificationUnreadCountProvider.future), 0);
      expect(remote.lists.length, 3);
    },
  );
}

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/features/notification/data/datasource/notification_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/notification/domain/entities/notification_item_entity.dart';
import 'package:flutter_elitesync_module/features/notification/presentation/providers/notification_provider.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Session extends SessionNotifier {
  @override
  SessionState build() => const SessionState(
    status: AuthStatus.authenticated,
    accessToken: 'fictional-notification-session-a',
  );

  void changeAccount() => state = const AsyncData(
    SessionState(
      status: AuthStatus.authenticated,
      accessToken: 'fictional-notification-session-b',
    ),
  );
}

class _Notifications extends NotificationRemoteDataSource {
  _Notifications() : super(apiClient: ApiClient(dio: Dio()), useMock: false);

  int listReads = 0;
  int unreadReads = 0;
  bool failList = false;
  bool failUnread = false;
  List<NotificationItemEntity> items = [];
  int unread = 0;
  Completer<List<NotificationItemEntity>>? pendingList;
  Completer<int>? pendingUnread;

  @override
  Future<List<NotificationItemEntity>> fetchNotifications({
    int limit = 50,
  }) async {
    listReads++;
    if (pendingList case final pending?) {
      pendingList = null;
      return pending.future;
    }
    if (failList) throw Exception('fictional notification list unavailable');
    return items;
  }

  @override
  Future<int> fetchUnreadCount() async {
    unreadReads++;
    if (pendingUnread case final pending?) {
      pendingUnread = null;
      return pending.future;
    }
    if (failUnread) throw Exception('fictional notification count unavailable');
    return unread;
  }
}

NotificationItemEntity _item(int id) => NotificationItemEntity.fromJson({
  'id': id,
  'kind': 'system',
  'title': 'fictional notification $id',
  'body': 'fictional body',
  'payload': <String, dynamic>{},
  'is_read': false,
  'created_at': '2026-11-12T00:00:00Z',
});

ProviderContainer _container(_Notifications source) => ProviderContainer.test(
  overrides: [
    sessionProvider.overrideWith(_Session.new),
    notificationRemoteDataSourceProvider.overrideWithValue(source),
  ],
);

void main() {
  test('list failure stops until explicit manual invalidation', () async {
    final source = _Notifications()..failList = true;
    final container = _container(source);
    await container.read(sessionProvider.future);
    container.listen(notificationListProvider, (_, _) {});
    await container.pump();
    expect(source.listReads, 1);

    // Riverpod's first default retry is 200 ms. Keep the real provider alive.
    await Future<void>.delayed(const Duration(milliseconds: 650));
    await container.pump();
    expect(source.listReads, 1);
    expect(container.read(notificationListProvider).hasError, isTrue);

    source
      ..failList = false
      ..items = [_item(7)];
    container.invalidate(notificationListProvider);
    final items = await container.read(notificationListProvider.future);
    expect(items.single.id, 7);
    expect(source.listReads, 2);
  });

  test('unread failure stops until explicit manual invalidation', () async {
    final source = _Notifications()..failUnread = true;
    final container = _container(source);
    await container.read(sessionProvider.future);
    container.listen(notificationUnreadCountProvider, (_, _) {});
    await container.pump();
    expect(source.unreadReads, 1);

    await Future<void>.delayed(const Duration(milliseconds: 650));
    await container.pump();
    expect(source.unreadReads, 1);
    expect(container.read(notificationUnreadCountProvider).hasError, isTrue);

    source
      ..failUnread = false
      ..unread = 4;
    container.invalidate(notificationUnreadCountProvider);
    expect(await container.read(notificationUnreadCountProvider.future), 4);
    expect(source.unreadReads, 2);
  });

  test('reopening the list reads current notifications once', () async {
    final source = _Notifications()..items = [_item(1)];
    final container = _container(source);
    await container.read(sessionProvider.future);
    final firstPage = container.listen(notificationListProvider, (_, _) {});
    expect(
      (await container.read(notificationListProvider.future)).single.id,
      1,
    );
    expect(source.listReads, 1);

    firstPage.close();
    await container.pump();
    source.items = [_item(2)];
    container.listen(notificationListProvider, (_, _) {});

    expect(
      (await container.read(notificationListProvider.future)).single.id,
      2,
    );
    expect(source.listReads, 2);
  });

  for (final changeAccount in [true, false]) {
    test('late list/count results cannot replace changed '
        '${changeAccount ? 'session' : 'authority epoch'}', () async {
      final oldList = Completer<List<NotificationItemEntity>>();
      final oldUnread = Completer<int>();
      final source = _Notifications()
        ..pendingList = oldList
        ..pendingUnread = oldUnread;
      final container = _container(source);
      await container.read(sessionProvider.future);
      container.listen(notificationListProvider, (_, _) {});
      container.listen(notificationUnreadCountProvider, (_, _) {});
      await container.pump();
      expect(source.listReads, 1);
      expect(source.unreadReads, 1);

      source
        ..items = [_item(9)]
        ..unread = 2;
      if (changeAccount) {
        (container.read(sessionProvider.notifier) as _Session).changeAccount();
      } else {
        container
            .read(relationshipAuthorityEpochProvider.notifier)
            .invalidate();
      }
      await container.pump();
      expect(
        (await container.read(notificationListProvider.future)).single.id,
        9,
      );
      expect(await container.read(notificationUnreadCountProvider.future), 2);

      oldList.complete([_item(1)]);
      oldUnread.complete(8);
      await container.pump();
      expect(
        container.read(notificationListProvider).requireValue.single.id,
        9,
      );
      expect(container.read(notificationUnreadCountProvider).requireValue, 2);
      expect(source.listReads, 2);
      expect(source.unreadReads, 2);
    });
  }
}

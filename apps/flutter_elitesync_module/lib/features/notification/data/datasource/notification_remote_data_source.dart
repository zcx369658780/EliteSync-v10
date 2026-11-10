import 'dart:async';
import 'dart:collection';
import 'package:dio/dio.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/auth_interceptor.dart';

import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/features/notification/domain/entities/notification_item_entity.dart';

/// A read-only notification list that also retains the server paging cursor.
/// It remains a List for existing providers and callers.
class NotificationPage extends UnmodifiableListView<NotificationItemEntity> {
  NotificationPage(super.items, {required this.hasMore, this.nextBeforeId});

  final bool hasMore;
  final int? nextBeforeId;
}

class NotificationRemoteDataSource {
  static const Duration _requestTimeout = Duration(seconds: 4);

  NotificationRemoteDataSource({
    required this.apiClient,
    required this.useMock,
    this.identity,
  });

  final ApiClient apiClient;
  final bool useMock;
  final String? Function()? identity;
  Options _options() {
    final started = identity?.call();
    return Options(
      extra: {
        if (identity != null)
          requestSessionGuardKey: () => identity!() == started,
      },
    );
  }

  Future<List<NotificationItemEntity>> fetchNotifications({int limit = 50}) =>
      _fetchPage(limit: limit);

  Future<NotificationPage> fetchOlderNotifications(
    int beforeId, {
    int limit = 50,
  }) => _fetchPage(beforeId: beforeId, limit: limit);

  Future<NotificationPage> _fetchPage({int? beforeId, int limit = 50}) async {
    if (useMock) return NotificationPage(const [], hasMore: false);
    final started = identity?.call();
    final result = await apiClient
        .get(
          '/api/v1/notifications',
          query: {'limit': limit, 'before_id': ?beforeId},
          options: _options(),
        )
        .timeout(_requestTimeout);
    if (identity != null && identity!() != started) {
      throw StateError('Notification session changed.');
    }
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      final list = result.data['items'] as List<dynamic>? ?? const [];
      final items = list
          .whereType<Map<String, dynamic>>()
          .map(NotificationItemEntity.fromJson)
          .toList();
      final hasMore = result.data['has_more'] as bool? ?? items.length >= limit;
      int? nextBeforeId = (result.data['next_before_id'] as num?)?.toInt();
      if (nextBeforeId == null && items.isNotEmpty) {
        nextBeforeId = items
            .map((item) => item.id)
            .reduce((a, b) => a < b ? a : b);
      }
      return NotificationPage(
        items,
        hasMore: hasMore,
        nextBeforeId: nextBeforeId,
      );
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<NotificationItemEntity> fetchNotification(int id) async {
    if (useMock || id <= 0) {
      throw StateError('Current notification lookup required.');
    }
    final result = await apiClient
        .get('/api/v1/notifications/$id', options: _options())
        .timeout(_requestTimeout);
    if (result is! NetworkSuccess<Map<String, dynamic>>) {
      throw StateError('Notification unavailable.');
    }
    final raw = result.data['item'];
    if (raw is! Map<String, dynamic>) {
      throw const FormatException('Invalid notification.');
    }
    final item = NotificationItemEntity.fromJson(raw);
    if (item.id != id) {
      throw const FormatException('Notification identity mismatch.');
    }
    return item;
  }

  Future<int> fetchUnreadCount() async {
    if (useMock) {
      return 0;
    }

    final result = await apiClient
        .get('/api/v1/notifications/unread-count', options: _options())
        .timeout(_requestTimeout);

    if (result is NetworkSuccess<Map<String, dynamic>>) {
      return (result.data['unread_total'] as num?)?.toInt() ?? 0;
    }

    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<void> markRead(int notificationId) async {
    if (useMock) return;
    final result = await apiClient
        .post('/api/v1/notifications/$notificationId/read', options: _options())
        .timeout(_requestTimeout);
    if (result is NetworkFailure<Map<String, dynamic>>) {
      throw Exception(result.message);
    }
  }

  Future<void> markAllRead() async {
    if (useMock) return;
    final result = await apiClient
        .post('/api/v1/notifications/read-all', options: _options())
        .timeout(_requestTimeout);
    if (result is NetworkFailure<Map<String, dynamic>>) {
      throw Exception(result.message);
    }
  }
}

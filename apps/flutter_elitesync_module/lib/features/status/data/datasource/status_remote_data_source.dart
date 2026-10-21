import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/auth_interceptor.dart';

import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/features/status/domain/entities/status_post_entity.dart';
import 'package:flutter_elitesync_module/features/status/domain/entities/status_author_entity.dart';
import 'package:flutter_elitesync_module/mocks/mock_data/status_mock.dart';

/// One bounded server-authorized page; the client never builds an infinite feed.
class StatusPostPage {
  const StatusPostPage({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
  });
  final List<StatusPostEntity> items;
  final String? nextCursor;
  final bool hasMore;
}

class StatusRemoteDataSource {
  static const Duration _requestTimeout = Duration(seconds: 4);

  StatusRemoteDataSource({
    required this.apiClient,
    required this.useMock,
    this.identity,
  });
  final String? Function()? identity;
  Options get _options {
    final token = identity?.call();
    return Options(
      extra: {
        if (identity != null)
          requestSessionGuardKey: () => identity!() == token,
      },
    );
  }

  final ApiClient apiClient;
  final bool useMock;

  Future<List<StatusPostEntity>> fetchStatusPosts({int limit = 20}) async =>
      (await fetchStatusPage(limit: limit)).items;

  Future<StatusPostPage> fetchStatusPage({
    int limit = 20,
    String? cursor,
  }) async {
    final pageLimit = limit.clamp(1, 20);
    final offset = cursor == null ? 0 : int.tryParse(cursor);
    if (offset == null || offset < 0) {
      throw ArgumentError('Invalid community page cursor');
    }
    final startedIdentity = identity?.call();
    if (useMock) {
      final all = StatusMock.posts
          .map((e) => StatusPostEntity.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      final items = all.skip(offset).take(pageLimit).toList();
      final more = offset + items.length < all.length;
      return StatusPostPage(
        items: items,
        nextCursor: more ? '${offset + items.length}' : null,
        hasMore: more,
      );
    }
    final result = await apiClient
        .get(
          '/api/v1/status/posts',
          query: {'limit': pageLimit, if (cursor != null) 'cursor': cursor},
          options: _options,
        )
        .timeout(_requestTimeout);
    if (identity != null && identity!() != startedIdentity) {
      throw StateError('Current account or audience changed; discard old page');
    }
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      final list = result.data['items'] as List<dynamic>? ?? const [];
      final meta = result.data['meta'] is Map
          ? result.data['meta'] as Map
          : const {};
      final candidate = meta['next_cursor']?.toString();
      final nextOffset = int.tryParse(candidate ?? '');
      final hasMore =
          meta['has_more'] == true && nextOffset != null && nextOffset > offset;
      return StatusPostPage(
        items: List.unmodifiable(
          list
              .whereType<Map<String, dynamic>>()
              .take(pageLimit)
              .map(StatusPostEntity.fromJson),
        ),
        nextCursor: hasMore ? candidate : null,
        hasMore: hasMore,
      );
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<StatusPostEntity> createStatusPost({
    required String title,
    required String body,
    String? locationName,
    String visibility = 'public',
    String audience = 'SELF',
    int? coverMediaAssetId,
  }) async {
    if (useMock) {
      final payload = <String, dynamic>{
        'id': DateTime.now().millisecondsSinceEpoch,
        'title': title,
        'body': body,
        'location_name': locationName ?? '同城',
        'visibility': visibility,
        'audience': audience,
        'can_delete': true,
        'likes_count': 0,
        'liked_by_viewer': false,
        'created_at': DateTime.now().toIso8601String(),
        'is_deleted': false,
        'cover_media_asset_id': coverMediaAssetId,
        'author': const {
          'id': 5,
          'name': '示例用户',
          'phone': '17094346566',
          'role': 'user',
          'account_type': 'test',
          'is_square_visible': true,
          'nickname': '示例用户',
          'city': '同城示例区域',
          'relationship_goal': 'dating',
        },
      };
      return StatusPostEntity.fromJson(payload);
    }

    final result = await apiClient
        .post(
          '/api/v1/status/posts',
          options: _options,
          body: {
            'title': title,
            'body': body,
            if (locationName != null && locationName.trim().isNotEmpty)
              'location_name': locationName.trim(),
            'visibility': visibility,
            'audience': audience,
            if (coverMediaAssetId != null && coverMediaAssetId > 0)
              'cover_media_asset_id': coverMediaAssetId,
          },
        )
        .timeout(_requestTimeout);

    if (result is NetworkSuccess<Map<String, dynamic>>) {
      final item = result.data['item'] as Map<String, dynamic>? ?? const {};
      return StatusPostEntity.fromJson(item);
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<void> updateAudience(int postId, String audience) async {
    final result = await apiClient.put(
      '/api/v1/status/posts/$postId/audience',
      body: {'audience': audience},
      options: _options,
    );
    if (result is NetworkFailure<Map<String, dynamic>>) {
      throw Exception(result.message);
    }
  }

  Future<StatusPostEntity> fetchStatusPost(int postId) async {
    if (useMock) {
      final match = StatusMock.posts.firstWhere(
        (e) => (e['id'] as num?)?.toInt() == postId,
        orElse: () => StatusMock.posts.first,
      );
      return StatusPostEntity.fromJson(Map<String, dynamic>.from(match));
    }
    final result = await apiClient
        .get('/api/v1/status/posts/$postId', options: _options)
        .timeout(_requestTimeout);
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      final item = result.data['item'] as Map<String, dynamic>? ?? const {};
      return StatusPostEntity.fromJson(item);
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<List<StatusPostEntity>> fetchAuthorStatuses(int userId) async {
    if (useMock) {
      return StatusMock.posts
          .map((e) => StatusPostEntity.fromJson(Map<String, dynamic>.from(e)))
          .where((post) => post.authorId == userId)
          .toList();
    }
    final result = await apiClient
        .get('/api/v1/status/authors/$userId', options: _options)
        .timeout(_requestTimeout);
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      final list = result.data['items'] as List<dynamic>? ?? const [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(StatusPostEntity.fromJson)
          .toList();
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<StatusAuthorEntity> fetchAuthorProfile(int userId) async {
    if (useMock) {
      final posts = await fetchAuthorStatuses(userId);
      final author = posts.isNotEmpty
          ? {
              'id': posts.first.authorId,
              'name': posts.first.authorName,
              'nickname': posts.first.authorName,
              'phone': posts.first.authorPhone,
              'city': posts.first.authorCity,
              'relationship_goal': posts.first.authorRelationshipGoal,
              'public_mbti': posts.first.authorPublicMbti,
              'public_personality': posts.first.authorPublicPersonality,
              'is_synthetic': posts.first.authorIsSynthetic,
              'is_square_visible': true,
            }
          : {
              'id': userId,
              'name': '用户 $userId',
              'nickname': '用户 $userId',
              'phone': '',
              'city': '',
              'relationship_goal': '',
              'public_mbti': '',
              'public_personality': const [],
              'is_synthetic': false,
              'is_square_visible': true,
            };
      return StatusAuthorEntity.fromJson({
        'author': author,
        'items': posts.map((e) => e.toJson()).toList(),
        'total': posts.length,
      });
    }
    final result = await apiClient
        .get('/api/v1/status/authors/$userId', options: _options)
        .timeout(_requestTimeout);
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      return StatusAuthorEntity.fromJson(result.data);
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<StatusPostEntity> likeStatusPost(int postId) async {
    if (useMock) {
      return fetchStatusPost(postId);
    }
    final result = await apiClient
        .post('/api/v1/status/posts/$postId/likes', options: _options)
        .timeout(_requestTimeout);
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      final item = result.data['item'] as Map<String, dynamic>? ?? const {};
      return StatusPostEntity.fromJson(item);
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<StatusPostEntity> unlikeStatusPost(int postId) async {
    if (useMock) {
      return fetchStatusPost(postId);
    }
    final result = await apiClient
        .delete('/api/v1/status/posts/$postId/likes', options: _options)
        .timeout(_requestTimeout);
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      final item = result.data['item'] as Map<String, dynamic>? ?? const {};
      return StatusPostEntity.fromJson(item);
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<void> reportStatusPost({
    required int postId,
    required String reasonCode,
    String? detail,
  }) async {
    if (useMock) return;
    final result = await apiClient
        .post(
          '/api/v1/status/posts/$postId/report',
          options: _options,
          body: {
            'reason_code': reasonCode,
            if (detail != null && detail.trim().isNotEmpty)
              'detail': detail.trim(),
          },
        )
        .timeout(_requestTimeout);
    if (result is NetworkFailure<Map<String, dynamic>>) {
      throw Exception(result.message);
    }
  }

  Future<void> deleteStatusPost(int postId) async {
    if (useMock) return;
    final result = await apiClient
        .delete('/api/v1/status/posts/$postId', options: _options)
        .timeout(_requestTimeout);
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      return;
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }
}

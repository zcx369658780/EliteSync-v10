import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/features/home/data/mapper/home_mapper.dart';
import 'package:flutter_elitesync_module/features/home/domain/entities/home_feed_entity.dart';
import 'package:flutter_elitesync_module/features/home/presentation/providers/home_provider.dart';

@immutable
class ContentDetailQuery {
  const ContentDetailQuery({required this.contentId, this.seed});

  final String contentId;
  final HomeFeedEntity? seed;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentDetailQuery &&
          runtimeType == other.runtimeType &&
          contentId == other.contentId;

  @override
  int get hashCode => contentId.hashCode;
}

final contentDetailProvider =
    FutureProvider.family<HomeFeedEntity, ContentDetailQuery>((
      ref,
      query,
    ) async {
      final remote = ref.read(homeRemoteDataSourceProvider);
      final mapper = const HomeMapper();
      final dto = await remote.fetchContentDetail(query.contentId);
      return mapper.feed(dto);
    });

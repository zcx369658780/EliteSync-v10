import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/session_bound_page.dart';
import 'package:flutter_elitesync_module/features/status/domain/entities/status_post_entity.dart';
import 'package:flutter_elitesync_module/features/status/presentation/widgets/status_post_card.dart';

class StatusPostDetailPage extends ConsumerStatefulWidget {
  const StatusPostDetailPage({super.key, required this.postId});

  final int postId;

  @override
  ConsumerState<StatusPostDetailPage> createState() => _StatusPostDetailState();
}

class _StatusPostDetailState extends SessionBoundPage<StatusPostDetailPage>
    with WidgetsBindingObserver {
  @override
  String get resource => '/status/posts/${widget.postId}';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    invalidatePendingProjection();
    if (state == AppLifecycleState.resumed) refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = data?['item'];
    return frame('作品详情', [
      if (!busy && item is Map<String, dynamic> && item['id'] == widget.postId)
        StatusPostCard(post: StatusPostEntity.fromJson(item))
      else if (!busy && error == null)
        const Text('当前作品不可读取。'),
    ]);
  }
}

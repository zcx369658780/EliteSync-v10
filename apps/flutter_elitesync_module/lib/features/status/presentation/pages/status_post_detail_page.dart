import 'package:flutter_elitesync_module/design_system/components/layout/ui_s3_canvas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/features/buddy_v1013/comment_panel.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import '../providers/status_posts_provider.dart';
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

  Future<void> _toggleLike(StatusPostEntity post) async {
    final result = await run(
      () => ref
          .read(relationshipApiProvider)
          .call(post.likedByViewer ? 'DELETE' : 'POST', '$resource/likes'),
      replace: true,
    );
    if (!mounted || result == null) return;
    ref.invalidate(statusPostPageProvider);
    ref.invalidate(statusPostsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final item = data?['item'];
    return frame('作品详情', [
      if (item is Map<String, dynamic> && item['id'] == widget.postId) ...[
        Builder(
          builder: (_) {
            final post = StatusPostEntity.fromJson(item);
            return StatusPostCard(
              post: post,
              onLikeToggle: () => _toggleLike(post),
              showInlineComments: UiS3Design.enabled,
            );
          },
        ),
        if (UiS3Design.enabled) CommentPanel(postId: widget.postId),
      ] else if (!busy && error == null)
        const Text('当前作品不可读取。'),
    ], backdrop: UiS3Backdrop.reading);
  }
}

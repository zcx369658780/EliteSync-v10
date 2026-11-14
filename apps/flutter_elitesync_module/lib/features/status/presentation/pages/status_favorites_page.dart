import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/session_bound_page.dart';
import 'package:flutter_elitesync_module/features/status/domain/entities/status_post_entity.dart';
import 'package:flutter_elitesync_module/features/status/presentation/widgets/status_post_card.dart';

class StatusFavoritesPage extends ConsumerStatefulWidget {
  const StatusFavoritesPage({super.key});

  @override
  ConsumerState<StatusFavoritesPage> createState() => _StatusFavoritesState();
}

class _StatusFavoritesState extends SessionBoundPage<StatusFavoritesPage>
    with WidgetsBindingObserver {
  String? _cursor;

  @override
  String get resource =>
      '/status/favorites?limit=20${_cursor == null ? '' : '&cursor=$_cursor'}';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onIdentityChanged() => _cursor = null;

  @override
  void onAuthorityChanged() => _cursor = null;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refresh();
    } else if (mounted) {
      invalidatePendingProjection();
    }
  }

  Future<void> _remove(int postId) async {
    final result = await run(
      () => ref.read(relationshipApiProvider).call(
        'PUT',
        '/status/posts/$postId/favorite',
        {'favorited': false},
      ),
    );
    if (result != null) await refresh();
  }

  @override
  Widget build(BuildContext context) {
    final items = rows(data?['items']);
    final meta = data?['meta'] is Map ? data!['meta'] as Map : const {};
    return frame('我的收藏', [
      if (data != null && items.isEmpty) const Text('当前页没有收藏。'),
      for (final item in items)
        if (item['available'] == true && item['post'] is Map)
          StatusPostCard(
            post: StatusPostEntity.fromJson(
              Map<String, dynamic>.from(item['post'] as Map),
            ),
            onTapAuthor: () => context.push(
              '/status-author/${(item['post'] as Map)['author']['id']}',
            ),
            onSaveForLater: busy ? null : () => _remove(item['post_id'] as int),
          )
        else
          Card(
            child: ListTile(
              title: const Text('这条收藏当前不可用'),
              subtitle: Text('${item['saved_at'] ?? ''}'),
              trailing: TextButton(
                onPressed: busy ? null : () => _remove(item['post_id'] as int),
                child: const Text('取消收藏'),
              ),
            ),
          ),
      if (meta['has_more'] == true)
        OutlinedButton(
          onPressed: busy
              ? null
              : () {
                  _cursor = meta['next_cursor']?.toString();
                  refresh();
                },
          child: const Text('更早收藏'),
        ),
      if (_cursor != null)
        TextButton(
          onPressed: busy
              ? null
              : () {
                  _cursor = null;
                  refresh();
                },
          child: const Text('返回最新收藏'),
        ),
    ]);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/features/status/data/datasource/status_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/status/presentation/providers/status_posts_provider.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

final editorialArticlesProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(statusRemoteDataSourceProvider).fetchEditorial();
}, retry: (_, _) => null);

final _channelProvider = FutureProvider.autoDispose
    .family<StatusPostPage, (String, String, String?, int, int)>((
      ref,
      filter,
    ) async {
      ref.watch(relationshipAuthorityEpochProvider);
      if (ref.watch(sessionProvider).asData?.value.isLoggedIn != true) {
        return const StatusPostPage(items: []);
      }
      return ref
          .watch(statusRemoteDataSourceProvider)
          .fetchStatusPage(
            channel: filter.$1,
            query: filter.$2.isEmpty ? null : filter.$2,
            cursor: filter.$3,
          );
    }, retry: (_, _) => null);

class HomeContentChannels extends ConsumerStatefulWidget {
  const HomeContentChannels({super.key});

  @override
  ConsumerState<HomeContentChannels> createState() =>
      _HomeContentChannelsState();
}

class _HomeContentChannelsState extends ConsumerState<HomeContentChannels>
    with WidgetsBindingObserver {
  String _channel = 'featured';
  String _query = '';
  String? _cursor;
  int _sessionGeneration = 0;
  bool _foreground = true;
  bool _routeCurrent = true;
  GoRouter? _router;
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = GoRouter.maybeOf(context);
    if (_router == next) return;
    _router?.routerDelegate.removeListener(_routeChanged);
    _router = next;
    _router?.routerDelegate.addListener(_routeChanged);
    _routeChanged();
  }

  void _routeChanged() {
    final next = _router?.state.uri.path;
    final current = next == null || next == AppRouteNames.home;
    if (_routeCurrent == current) return;
    setState(() => _routeCurrent = current);
    ref.invalidate(_channelProvider);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    setState(() => _foreground = state == AppLifecycleState.resumed);
    ref.invalidate(_channelProvider);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _router?.routerDelegate.removeListener(_routeChanged);
    _search.dispose();
    super.dispose();
  }

  void _submitQuery(String value) => setState(() {
    _query = value.trim();
    _cursor = null;
  });

  @override
  Widget build(BuildContext context) {
    ref.listen(
      sessionProvider.select((state) => state.asData?.value.accessToken),
      (_, _) {
        _search.clear();
        setState(() {
          _sessionGeneration++;
          _channel = 'featured';
          _query = '';
          _cursor = null;
        });
      },
    );
    ref.listen(
      relationshipAuthorityEpochProvider,
      (_, _) => setState(() => _cursor = null),
    );
    final session = ref.watch(sessionProvider).asData?.value;
    if (!_foreground || !_routeCurrent || session?.isLoggedIn != true) {
      return const SizedBox.shrink();
    }
    final epoch = ref.watch(relationshipAuthorityEpochProvider);
    final filter = (_channel, _query, _cursor, epoch, _sessionGeneration);
    final posts = ref.watch(_channelProvider(filter));
    final page = posts.isLoading ? null : posts.asData?.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'featured', label: Text('精选')),
            ButtonSegment(value: 'friends', label: Text('好友')),
          ],
          selected: {_channel},
          onSelectionChanged: (value) => setState(() {
            _channel = value.single;
            _cursor = null;
          }),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _search,
                decoration: const InputDecoration(labelText: '搜索当前频道'),
                textInputAction: TextInputAction.search,
                maxLength: 80,
                onSubmitted: _submitQuery,
              ),
            ),
            IconButton(
              tooltip: '搜索',
              icon: const Icon(Icons.search),
              onPressed: () => _submitQuery(_search.text),
            ),
            IconButton(
              tooltip: '刷新频道',
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.invalidate(_channelProvider(filter)),
            ),
          ],
        ),
        if (_channel == 'featured')
          ListTile(
            title: const Text('官方专题'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRouteNames.publicEditorial),
          ),
        if (posts.isLoading)
          const LinearProgressIndicator()
        else if (posts.hasError)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text('暂时无法读取作品，请刷新。'),
          )
        else if (page?.items.isEmpty == true)
          const Padding(padding: EdgeInsets.all(12), child: Text('当前没有可见作品。'))
        else if (page != null)
          for (final post in page.items)
            ListTile(
              title: Text(
                post.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                post.editorRecommended
                    ? '编辑推荐 · ${post.visibilityLabel}'
                    : post.visibilityLabel,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  context.push('${AppRouteNames.statusDetail}/${post.id}'),
            ),
        if (page != null && page.hasMore)
          TextButton(
            onPressed: () => setState(() => _cursor = page.nextCursor),
            child: const Text('下一页'),
          ),
        if (_cursor != null)
          TextButton(
            onPressed: () => setState(() => _cursor = null),
            child: const Text('返回第一页'),
          ),
        TextButton(
          onPressed: () => context.push(AppRouteNames.statusSquare),
          child: const Text('发布和管理我的作品'),
        ),
      ],
    );
  }
}

class PublicEditorialPage extends ConsumerWidget {
  const PublicEditorialPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref.watch(editorialArticlesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('官方专题'),
        actions: [
          IconButton(
            tooltip: '刷新官方专题',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(editorialArticlesProvider),
          ),
        ],
      ),
      body: articles.when(
        skipLoadingOnRefresh: false,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('暂时无法读取官方专题，请刷新。')),
        data: (items) => items.isEmpty
            ? const Center(child: Text('目前没有向访客开放的官方专题。'))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (final item in items)
                    ExpansionTile(
                      title: Text(item['title'] as String),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text(item['body'] as String)],
                    ),
                ],
              ),
      ),
    );
  }
}

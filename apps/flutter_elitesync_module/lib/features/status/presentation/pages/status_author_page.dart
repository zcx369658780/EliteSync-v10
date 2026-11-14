import 'dart:async';
import 'package:flutter_elitesync_module/features/status/domain/entities/status_post_entity.dart';
import 'package:flutter_elitesync_module/features/status/presentation/widgets/status_post_card.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/authenticated_showcase_photo.dart';

class StatusAuthorPage extends ConsumerStatefulWidget {
  const StatusAuthorPage({super.key, required this.userId});
  final int userId;

  @override
  ConsumerState<StatusAuthorPage> createState() => _StatusAuthorPageState();
}

class _StatusAuthorPageState extends ConsumerState<StatusAuthorPage>
    with WidgetsBindingObserver {
  Map<String, dynamic>? _fields;
  String? _message;
  bool _loading = true;
  List<StatusPostEntity> _posts = [];
  String? _postsMessage;
  bool _postsLoading = true;
  bool _hasMore = false;
  int? _nextCursor;
  int _generation = 0;
  CancelToken? _cancel;
  late final ProviderSubscription<AsyncValue<SessionState>> _session;
  late final ProviderSubscription<int> _authority;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _session = ref.listenManual(sessionProvider, (_, _) => unawaited(_load()));
    _authority = ref.listenManual(
      relationshipAuthorityEpochProvider,
      (_, _) => unawaited(_load()),
    );
    Future.microtask(_load);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) =>
      unawaited(_load());

  @override
  void didUpdateWidget(StatusAuthorPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) unawaited(_load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    _cancel?.cancel('Author authority changed');
    final generation = ++_generation;
    setState(() {
      _fields = null;
      _message = null;
      _loading = true;
      _posts = [];
      _postsMessage = null;
      _postsLoading = true;
      _hasMore = false;
      _nextCursor = null;
    });
    if (WidgetsBinding.instance.lifecycleState != null &&
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }
    final session = ref.read(sessionProvider).asData?.value;
    final epoch = ref.read(relationshipAuthorityEpochProvider);
    final token = session?.accessToken;
    if (session?.isLoggedIn != true ||
        token == null ||
        token.isEmpty ||
        widget.userId <= 0) {
      setState(() {
        _loading = false;
        _postsLoading = false;
        _message = '请登录后查看。';
      });
      return;
    }
    final cancel = CancelToken();
    _cancel = cancel;
    await Future.wait([
      _loadShowcase(generation, session!, epoch, token, cancel),
      _loadPosts(),
    ]);
  }

  bool _current(int generation, SessionState session, int epoch) =>
      mounted &&
      generation == _generation &&
      identical(session, ref.read(sessionProvider).asData?.value) &&
      epoch == ref.read(relationshipAuthorityEpochProvider) &&
      (WidgetsBinding.instance.lifecycleState == null ||
          WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed);

  Future<void> _loadShowcase(
    int generation,
    SessionState session,
    int epoch,
    String token,
    CancelToken cancel,
  ) async {
    bool current() => _current(generation, session, epoch);
    try {
      final result = await ref
          .read(dioProvider)
          .get<Map<String, dynamic>>(
            '/api/v1/profile/showcase/${widget.userId}',
            cancelToken: cancel,
            options: Options(
              followRedirects: false,
              headers: {'Authorization': 'Bearer $token'},
              extra: {requestSessionGuardKey: current},
            ),
          );
      if (!current()) return;
      final publication = result.data?['publication'];
      if (publication is! Map ||
          publication['publication_status'] != 'published' ||
          publication['public_fields'] is! Map) {
        throw const FormatException('展示资料响应无效');
      }
      setState(() {
        _fields = Map<String, dynamic>.from(
          publication['public_fields'] as Map,
        );
        _loading = false;
      });
    } catch (error) {
      if (!current()) return;
      final data = error is DioException ? error.response?.data : null;
      final envelope = data is Map ? data['error'] : null;
      final code = envelope is Map
          ? envelope['message']?.toString()
          : (data is Map ? data['message']?.toString() : null);
      final message = switch (code) {
        'showcase_not_published' => '对方尚未发布展示资料。',
        'showcase_withdrawn' => '对方已撤回展示资料。',
        _ =>
          error is DioException &&
                  [403, 404].contains(error.response?.statusCode)
              ? '当前无法访问此资料，请确认双方的关系和展示范围。'
              : '资料读取失败，请检查连接后重试。',
      };
      setState(() {
        _message = message;
        _loading = false;
      });
    }
  }

  Future<void> _loadPosts({bool more = false}) async {
    if (!mounted || (more && (_postsLoading || !_hasMore))) return;
    final generation = _generation;
    final session = ref.read(sessionProvider).asData?.value;
    final epoch = ref.read(relationshipAuthorityEpochProvider);
    final token = session?.accessToken;
    final cancel = _cancel;
    if (session?.isLoggedIn != true || token == null || cancel == null) return;
    bool current() => _current(generation, session!, epoch);
    if (!current()) return;
    final cursor = more ? _nextCursor : null;
    setState(() {
      _postsLoading = true;
      _postsMessage = null;
    });
    try {
      final response = await ref
          .read(dioProvider)
          .get<Map<String, dynamic>>(
            '/api/v1/status/authors/${widget.userId}',
            queryParameters: {'limit': 20, 'cursor': ?cursor},
            cancelToken: cancel,
            options: Options(
              followRedirects: false,
              headers: {'Authorization': 'Bearer $token'},
              extra: {requestSessionGuardKey: current},
            ),
          );
      if (!current()) return;
      final items = response.data?['items'];
      final meta = response.data?['meta'];
      if (items is! List ||
          items.length > 20 ||
          meta is! Map ||
          meta['has_more'] is! bool) {
        throw const FormatException('作者动态响应无效');
      }
      final hasMore = meta['has_more'] as bool;
      final nextCursor = int.tryParse(meta['next_cursor']?.toString() ?? '');
      if (hasMore &&
          (nextCursor == null || nextCursor <= 0 || nextCursor == cursor)) {
        throw const FormatException('作者动态游标无效');
      }
      final posts = items
          .map(
            (item) => StatusPostEntity.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
      setState(() {
        final previous = more ? _posts : <StatusPostEntity>[];
        final seen = previous.map((post) => post.id).toSet();
        _posts = [...previous, ...posts.where((post) => seen.add(post.id))];
        _hasMore = hasMore;
        _nextCursor = nextCursor;
        _postsLoading = false;
      });
    } catch (error) {
      if (!current()) return;
      setState(() {
        _postsLoading = false;
        _postsMessage =
            error is DioException &&
                [401, 403, 404].contains(error.response?.statusCode)
            ? '当前无法查看此作者动态。'
            : '动态读取失败，请检查连接后重试。';
        if (error is DioException &&
            [401, 403, 404].contains(error.response?.statusCode)) {
          _posts = [];
          _hasMore = false;
          _nextCursor = null;
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _generation++;
    _cancel?.cancel();
    _session.close();
    _authority.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fields = _fields;
    return Scaffold(
      appBar: AppBar(
        title: const Text('作者'),
        actions: [
          IconButton(
            onPressed: _load,
            tooltip: '刷新资料',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('展示资料'),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (fields == null) ...[
            Text(_message ?? '当前无可查看资料'),
            TextButton(onPressed: _load, child: const Text('重试读取')),
          ] else ...[
            for (final entry in const {
              'display_name': '展示称呼',
              'city': '城市',
              'relationship_goal': '关系目标',
              'self_intro': '自我介绍',
              'interest_tags': '兴趣',
              'lifestyle_tags': '生活方式',
              'opener_note': '开场话题',
            }.entries)
              if (fields[entry.key] != null &&
                  fields[entry.key].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    '${entry.value}\n${fields[entry.key] is List ? (fields[entry.key] as List).join('、') : fields[entry.key]}',
                  ),
                ),
            for (final photo
                in (fields['photos'] as List? ?? const []).whereType<Map>())
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AuthenticatedShowcasePhoto(
                  contentPath: photo['content_path'].toString(),
                ),
              ),
          ],
          const Divider(),
          const Text('作者动态'),
          for (final post in _posts)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: StatusPostCard(key: ValueKey(post.id), post: post),
            ),
          if (_postsLoading)
            const Center(child: CircularProgressIndicator())
          else if (_postsMessage != null) ...[
            Text(_postsMessage!),
            TextButton(
              onPressed: () => _loadPosts(more: _posts.isNotEmpty || _hasMore),
              child: const Text('重试动态'),
            ),
          ] else if (_posts.isEmpty && !_hasMore)
            const Text('暂无可查看的动态。'),
          if (!_postsLoading && _hasMore && _postsMessage == null)
            TextButton(
              onPressed: () => _loadPosts(more: true),
              child: const Text('加载更多动态'),
            ),
        ],
      ),
    );
  }
}

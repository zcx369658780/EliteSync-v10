import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'avatar_api.dart';
import 'authenticated_avatar.dart';

class AvatarManagementEntry extends ConsumerStatefulWidget {
  const AvatarManagementEntry({super.key});
  @override
  ConsumerState<AvatarManagementEntry> createState() =>
      _AvatarManagementEntryState();
}

class _AvatarManagementEntryState extends ConsumerState<AvatarManagementEntry> {
  int _refresh = 0;
  @override
  Widget build(BuildContext context) {
    final id = ref.watch(sessionProvider).asData?.value.user?.id;
    return Card(
      child: ListTile(
        leading: AuthenticatedAvatar(ownerId: id ?? 0, refreshKey: _refresh),
        title: const Text('头像管理'),
        subtitle: const Text('更换或移除头像；仅现有获准关系上下文可见'),
        trailing: const Icon(Icons.chevron_right),
        onTap: id == null
            ? null
            : () async {
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const AvatarManagementPage(),
                  ),
                );
                if (mounted) setState(() => _refresh++);
              },
      ),
    );
  }
}

class AvatarManagementPage extends ConsumerStatefulWidget {
  const AvatarManagementPage({super.key});
  @override
  ConsumerState<AvatarManagementPage> createState() =>
      _AvatarManagementPageState();
}

class _AvatarManagementPageState extends ConsumerState<AvatarManagementPage> {
  AvatarSnapshot? _snapshot;
  bool _busy = false;
  String? _notice;
  int _generation = 0;
  late final ProviderSubscription<AsyncValue<SessionState>> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = ref.listenManual(sessionProvider, (_, next) {
      _generation++;
      setState(() {
        _snapshot = null;
        _busy = false;
        _notice = null;
      });
      _run();
    });
    Future.microtask(_run);
  }

  Future<void> _run({bool change = false, bool remove = false}) async {
    if (!mounted || _busy) return;
    final session = ref.read(sessionProvider).asData?.value;
    final id = session?.user?.id;
    final token = session?.accessToken;
    if (session?.isLoggedIn != true || id == null || token == null) return;
    final generation = ++_generation;
    bool current() =>
        mounted &&
        generation == _generation &&
        identical(session, ref.read(sessionProvider).asData?.value);
    final previous = _snapshot;
    setState(() {
      _busy = true;
      _notice = null;
    });
    try {
      final api = ref.read(avatarApiProvider);
      final AvatarSnapshot? result;
      if (change && previous != null) {
        result = await api.pickAndSave(
          ownerId: id,
          revision: previous.revision,
          token: token,
          current: current,
          picker: ref.read(avatarPickerProvider),
        );
      } else if (remove && previous != null) {
        result = await api.remove(id, previous.revision, token, current);
      } else {
        result = await api.read(id, token, current);
      }
      if (!current()) return;
      setState(() {
        if (result != null) _snapshot = result;
        if ((change || remove) && result != null) _notice = '头像已更新并读回确认。';
      });
    } catch (error) {
      if (current()) {
        setState(() {
          _snapshot = null;
          _notice = avatarFailure(error);
        });
      }
    } finally {
      if (current()) setState(() => _busy = false);
    }
  }

  Future<void> _remove() async {
    final generation = _generation;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('移除头像？'),
        content: const Text('移除后恢复默认头像，旧头像地址立即失效。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('移除'),
          ),
        ],
      ),
    );
    if (mounted && generation == _generation && confirmed == true) {
      await _run(remove: true);
    }
  }

  @override
  void dispose() {
    _generation++;
    _subscription.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final id = ref.watch(sessionProvider).asData?.value.user?.id;
    return Scaffold(
      appBar: AppBar(title: const Text('头像管理')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: AuthenticatedAvatar(
              ownerId: id ?? 0,
              revision: _snapshot?.revision,
              refreshKey: _generation,
              size: 96,
            ),
          ),
          const SizedBox(height: 20),
          const Text('头像仅在现有获准的好友、邀请与会话上下文展示，并沿用拉黑限制。'),
          const SizedBox(height: 12),
          const Text('从相册选择JPEG或PNG，最大5 MiB。保存后服务端会缩至512像素并移除元数据。'),
          if (_busy) const LinearProgressIndicator(),
          if (_notice != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(_notice!),
            ),
          FilledButton(
            onPressed: _busy || _snapshot == null
                ? null
                : () => _run(change: true),
            child: const Text('从相册更换头像'),
          ),
          OutlinedButton(
            onPressed: _busy || _snapshot?.contentPath == null ? null : _remove,
            child: const Text('移除头像'),
          ),
          TextButton(
            onPressed: _busy ? null : () => _run(),
            child: const Text('刷新头像状态'),
          ),
        ],
      ),
    );
  }
}

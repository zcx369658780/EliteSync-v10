import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'relationship_api.dart';

/// Never retain a previous account's projection or apply its late response.
abstract class SessionBoundPage<T extends ConsumerStatefulWidget>
    extends ConsumerState<T> {
  Map<String, dynamic>? data;
  String? error;
  bool busy = false;
  int _generation = 0;
  String? _identity;
  late final ProviderSubscription<AsyncValue<SessionState>> _subscription;
  late final ProviderSubscription<int> _authoritySubscription;
  String get resource;
  void onIdentityChanged() {}
  void onAuthorityChanged() {}

  @override
  void initState() {
    super.initState();
    _authoritySubscription = ref.listenManual(
      relationshipAuthorityEpochProvider,
      (_, next) {
        _generation++;
        onAuthorityChanged();
        setState(() {
          data = null;
          busy = false;
          error = null;
        });
        if (_identity != null) refresh();
      },
    );
    _subscription = ref.listenManual(sessionProvider, (_, next) {
      final session = next.asData?.value;
      final identity = session?.isLoggedIn == true
          ? session?.accessToken
          : null;
      if (_identity == identity) return;
      _identity = identity;
      _generation++;
      onIdentityChanged();
      setState(() {
        data = null;
        error = null;
        busy = false;
      });
      if (identity != null) refresh();
    }, fireImmediately: true);
  }

  Future<void> refresh() => run(() async {
    final result = await ref
        .read(relationshipApiProvider)
        .call('GET', resource);
    return result;
  }, replace: true);

  Future<Map<String, dynamic>?> run(
    Future<Map<String, dynamic>> Function() work, {
    bool replace = false,
  }) async {
    if (busy || _identity == null) return null;
    final generation = _generation;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final result = await work();
      if (!mounted || generation != _generation) return null;
      setState(() {
        if (replace) data = result;
      });
      return result;
    } catch (e) {
      if (mounted && generation == _generation) {
        setState(() {
          error = '$e';
          if (replace) {
            data = null;
            onAuthorityChanged();
          }
        });
      }
      return null;
    } finally {
      if (mounted && generation == _generation) setState(() => busy = false);
    }
  }

  Future<void> mutate(
    String method,
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    final result = await run(
      () => ref.read(relationshipApiProvider).call(method, path, body),
    );
    if (result != null) {
      ref.read(relationshipAuthorityEpochProvider.notifier).invalidate();
    }
  }

  Widget frame(String title, List<Widget> children) => Scaffold(
    appBar: AppBar(
      title: Text(title),
      actions: [
        IconButton(
          tooltip: '刷新',
          onPressed: busy ? null : refresh,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (busy) const LinearProgressIndicator(),
        if (error != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text('未完成：$error', key: const Key('server-error')),
          ),
        if (_identity == null) const Text('请重新登录；旧账号资料已清除。') else ...children,
      ],
    ),
  );

  Future<bool> confirm(String title, String message) async {
    final generation = _generation;
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('确认'),
              ),
            ],
          ),
        ) ??
        false;
    return mounted && generation == _generation && confirmed;
  }

  @override
  void dispose() {
    _subscription.close();
    _authoritySubscription.close();
    _generation++;
    super.dispose();
  }
}

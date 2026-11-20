import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
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

  /// Drop pending reads when a private page leaves the foreground.
  void invalidatePendingProjection() {
    _generation++;
    setState(() {
      data = null;
      error = null;
      busy = false;
    });
  }

  Future<Map<String, dynamic>?> run(
    Future<Map<String, dynamic>> Function() work, {
    bool replace = false,
    void Function(Object error)? onFailure,
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
          onFailure?.call(e);
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
    if (data == null) return;
    final result = await run(
      () => ref.read(relationshipApiProvider).call(method, path, body),
      onFailure: (_) {
        // UNKNOWN is not permission to issue a fresh decision with a new request key.
        data = null;
        onAuthorityChanged();
        error = '操作结果尚未确认，请先刷新当前状态核对。';
      },
    );
    if (result != null) {
      ref.read(relationshipAuthorityEpochProvider.notifier).invalidate();
    }
  }

  Future<void> decideProposal(String id, int revision, String action) async {
    final label = switch (action) {
      'accept' => '接受候选',
      'decline' => '拒绝候选',
      _ => '撤回提案',
    };
    if (!await confirm(label, '请确认是否提交这次提案回应。')) return;
    final body = {
      'action': action,
      'revision': revision,
      'idempotency_key': const Uuid().v4(),
    };
    final path = '/journey/proposals/$id';
    final query = Uri(
      queryParameters: {
        for (final entry in body.entries) entry.key: entry.value.toString(),
      },
    ).query;
    final generation = _generation;
    final result = await run(
      () async {
        final api = ref.read(relationshipApiProvider);
        Future<Map<String, dynamic>> write() =>
            api.call('POST', '$path/decision', body);
        Future<Map<String, dynamic>> readResult() =>
            api.call('GET', '$path/decision-result?$query');
        try {
          return await write();
        } catch (failure) {
          if (!mounted ||
              generation != _generation ||
              (failure is RelationshipFailure &&
                  (failure.statusCode ?? 500) < 500 &&
                  failure.statusCode != 408)) {
            rethrow;
          }
          final receipt = await readResult();
          if (!mounted || generation != _generation) rethrow;
          if (receipt['command_status'] == 'APPLIED') return receipt;
          if (receipt['command_status'] == 'NOT_APPLIED') {
            if (!await confirm('重试原回应', '服务端尚未确认原操作。可用同一编号重试。')) {
              return receipt;
            }
            try {
              return await write();
            } catch (_) {
              if (!mounted || generation != _generation) rethrow;
              final checked = await readResult();
              if (checked['command_status'] == 'APPLIED') return checked;
              rethrow;
            }
          }
          rethrow;
        }
      },
      onFailure: (_) {
        data = null;
        onAuthorityChanged();
        error = '回应结果尚未确认，请刷新当前状态核对。';
      },
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
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
      children: [
        if (busy) const LinearProgressIndicator(),
        if (error != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              relationshipErrorLabel(error!),
              key: const Key('server-error'),
            ),
          ),
        if (_identity == null)
          const Text('请登录后继续')
        else
          for (final child in children)
            Padding(padding: const EdgeInsets.only(bottom: 12), child: child),
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

const buddyDiscoveryUnavailable = '搭子发现当前不可用，请重新检查搭子许可。';

String relationshipErrorLabel(String error) {
  if (error == buddyDiscoveryUnavailable) return buddyDiscoveryUnavailable;
  if (error.contains('enable Buddy')) return '请先开启搭子请求，再继续操作';
  if (error.contains('分享授权已撤回')) return '分享授权已撤回，请重新确认访问权限';
  if (error == 'Forbidden' || error == 'Forbidden.') {
    return '当前账号没有此项访问权限。';
  }
  if (error.contains('revision') || error.contains('stale')) {
    return '内容已更新，请刷新后再试';
  }
  if (error.contains('eligibility') ||
      error.contains('participation generation')) {
    return '报名状态已变化，请查看准备与参与状态';
  }
  return '暂时无法完成，请刷新重试';
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'relationship_api.dart';
import 'session_bound_page.dart';
import 'pending_logout_store.dart';

class AccountSecurityPage extends ConsumerStatefulWidget {
  const AccountSecurityPage({super.key});
  @override
  ConsumerState<AccountSecurityPage> createState() => _AccountSecurityState();
}

class _AccountSecurityState extends SessionBoundPage<AccountSecurityPage> {
  @override
  String get resource => '/account/sessions';
  final _password = TextEditingController();

  Future<void> _completePendingLogout() async {
    final result = await run(() async {
      final secure = ref.read(secureStorageProvider);
      final tokens = await PendingLogoutStore.read(secure);
      if (tokens.isEmpty) return {'message': '没有待确认的撤销'};
      var unconfirmed = 0;
      for (final token in tokens) {
        final result = await ref
            .read(restrictedAccountClientProvider)
            .post(
              '/api/v1/auth/logout',
              options: Options(headers: {'Authorization': 'Bearer $token'}),
            );
        if (result is NetworkFailure<Map<String, dynamic>>) {
          unconfirmed++;
          continue;
        }
        await PendingLogoutStore.remove(secure, token);
      }
      return {
        'message': unconfirmed == 0
            ? '全部待确认会话撤销已确认'
            : '$unconfirmed个旧会话的服务端撤销仍未确认，恢复凭据已保留。凭据无效也不代表整会话已撤销；可在设备列表核对撤销。',
      };
    });
    if (result != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${result['message']}')));
    }
  }

  Future<void> _logoutAll() async {
    final token = ref.read(sessionProvider).asData?.value.accessToken;
    if (!await confirm('退出全部设备？', '服务器确认后，所有设备的登录凭据将失效。')) return;
    if (!mounted ||
        ref.read(sessionProvider).asData?.value.accessToken != token) {
      return;
    }
    final result = await run(
      () => ref.read(relationshipApiProvider).call('POST', '/auth/logout-all'),
    );
    if (result == null || !mounted) return;
    await ref
        .read(sessionProvider.notifier)
        .setUnauthenticated(rejectedToken: token, notice: '已退出全部设备。');
    if (mounted) context.go(AppRouteNames.login);
  }

  Future<void> _closeAccount() async {
    final originalToken = ref.read(sessionProvider).asData?.value.accessToken;
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('申请关闭账号'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '提交后立即停止登录、展示和联系。处理可能稍后完成；共享会话、对方记录、必要审计及备份按边界保留，不承诺所有数据已彻底删除。真实用户保留政策尚待确定。本版实际清理只适用于服务端登记的虚构演练对象。',
                  ),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: '当前密码'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('确认申请注销'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed ||
        !mounted ||
        originalToken != ref.read(sessionProvider).asData?.value.accessToken) {
      _password.clear();
      return;
    }
    final password = _password.text;
    _password.clear();
    final token = ref.read(sessionProvider).asData?.value.accessToken;
    final actorId = ref.read(sessionProvider).asData?.value.user?.id;
    final secure = ref.read(secureStorageProvider);
    String closureKey;
    try {
      closureKey =
          await secure.read('account_closure_key_$actorId') ??
          const Uuid().v4();
      await secure.write('account_closure_key_$actorId', closureKey);
      await secure.write('account_closure_recovery_key', closureKey);
    } catch (_) {
      if (mounted) setState(() => error = '无法安全保存恢复凭据，尚未提交注销。');
      return;
    }
    if (ref.read(sessionProvider).asData?.value.accessToken != token) return;
    final result = await run(
      () => ref.read(relationshipApiProvider).call('DELETE', '/auth/account', {
        'current_password': password,
        'confirmation': 'CLOSE_MY_ACCOUNT',
        'idempotency_key': closureKey,
      }),
    );
    if (result == null || !mounted) return;
    final receipt = result['receipt_token'];
    final requestId = result['request_id'];
    if (receipt == null || requestId == null) {
      setState(() => error = '服务端未返回完整回执；请勿重复提交，请向支持人员核查账号状态。');
      return;
    }
    // The restricted receipt is never displayed in logs or normal profile caches.
    try {
      final secure = ref.read(secureStorageProvider);
      await secure.write('account_closure_request_id', '$requestId');
      await secure.write('account_closure_receipt', '$receipt');
    } catch (_) {
      if (mounted) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('账号已停用，回执未能保存在本机'),
            content: const Text('服务端已接收请求，但本机安全存储写入失败。请通过支持流程核查处理状态。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('知道了'),
              ),
            ],
          ),
        );
      }
    }
    await ref
        .read(sessionProvider.notifier)
        .setUnauthenticated(
          rejectedToken: token,
          notice: '注销申请已接收，账号已停用；数据处理仍待完成，共享及审计记录按规则保留。',
        );
    if (mounted) context.go(AppRouteNames.login);
  }

  @override
  Widget build(BuildContext context) => frame('账号安全与设备', [
    const Text('设备列表不含令牌、精确网络或硬件标识。撤销当前设备会退出本机。真实身份服务未配置时不显示已认证。'),
    if (data != null && rows(data?['sessions']).isEmpty)
      const Text('暂无可显示的设备会话'),
    for (final item in rows(data?['sessions']))
      Card(
        child: ListTile(
          title: Text(
            '${item['label'] ?? '登录设备'}${item['current'] == true ? '（当前）' : ''}',
          ),
          subtitle: Text(
            '登录：${item['created_at'] ?? ''}\n最近使用：${item['last_used_at'] ?? ''}',
          ),
          trailing: TextButton(
            onPressed: busy
                ? null
                : () async {
                    if (!await confirm('撤销设备会话？', '该会话的旧登录和刷新凭据将失效。')) return;
                    final token = ref
                        .read(sessionProvider)
                        .asData
                        ?.value
                        .accessToken;
                    final result = await run(
                      () => ref
                          .read(relationshipApiProvider)
                          .call('DELETE', '/account/sessions/${item['id']}'),
                    );
                    if (result == null || !mounted) return;
                    if (item['current'] == true) {
                      await ref
                          .read(sessionProvider.notifier)
                          .setUnauthenticated(
                            rejectedToken: token,
                            notice: '当前设备会话已撤销。',
                          );
                      if (context.mounted) context.go(AppRouteNames.login);
                    } else {
                      await refresh();
                    }
                  },
            child: const Text('撤销'),
          ),
        ),
      ),
    OutlinedButton(
      onPressed: busy ? null : _logoutAll,
      child: const Text('退出全部设备'),
    ),
    OutlinedButton(
      onPressed: busy ? null : _completePendingLogout,
      child: const Text('完成上次离线退出的待确认撤销'),
    ),
    const Divider(),
    TextButton(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const ClosureReceiptPage()),
      ),
      child: const Text('查看本机保存的注销处理回执'),
    ),
    FilledButton(
      onPressed: busy ? null : _closeAccount,
      child: const Text('申请注销账号'),
    ),
  ]);
  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }
}

/// Purpose-limited receipt lookup. This screen also works without a login.
class ClosureReceiptPage extends ConsumerStatefulWidget {
  const ClosureReceiptPage({super.key});
  @override
  ConsumerState<ClosureReceiptPage> createState() => _ReceiptState();
}

class _ReceiptState extends ConsumerState<ClosureReceiptPage> {
  String _status = '正在读取本机回执…';
  bool _busy = false;
  final _phone = TextEditingController();
  final _password = TextEditingController();
  Future<void> _recover() async {
    if (_busy) return;
    setState(() => _busy = true);
    final phone = _phone.text.trim();
    final password = _password.text;
    _password.clear();
    try {
      final secure = ref.read(secureStorageProvider);
      final key = await secure.read('account_closure_recovery_key');
      if (key == null) throw const RelationshipFailure('本机没有注销恢复凭据');
      final result =
          await RelationshipApi(ref.read(restrictedAccountClientProvider)).call(
            'POST',
            '/account/closure-recovery',
            {
              'phone': phone,
              'current_password': password,
              'idempotency_key': key,
            },
          );
      if (result['request_id'] == null || result['receipt_token'] == null) {
        throw const RelationshipFailure('回执不完整');
      }
      await secure.write(
        'account_closure_request_id',
        '${result['request_id']}',
      );
      await secure.write(
        'account_closure_receipt',
        '${result['receipt_token']}',
      );
      if (mounted) setState(() => _status = '已恢复受限回执，可重新查询处理进度。');
    } catch (_) {
      if (mounted) {
        setState(() => _status = '未能恢复回执。请核对原账号密码；私有数据已擦除后此恢复方式不再可用。');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _busy = true);
    try {
      final secure = ref.read(secureStorageProvider);
      final id = await secure.read('account_closure_request_id');
      final receipt = await secure.read('account_closure_receipt');
      if (id == null || receipt == null) {
        if (mounted) setState(() => _status = '本机没有保存的注销回执。');
        return;
      }
      final result =
          await RelationshipApi(ref.read(restrictedAccountClientProvider)).call(
            'POST',
            '/account/closure-receipts/${Uri.encodeComponent(id)}',
            {'receipt_token': receipt},
          );
      if (mounted) {
        setState(
          () => _status =
              '请求：${result['request_id']}\n状态：${result['status']}\n已处理 / 保留范围：${result['result'] ?? '仍在处理中'}',
        );
      }
    } catch (e) {
      if (mounted) setState(() => _status = '尚未确认最新处理状态：$e。可恢复网络后重查。');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('注销处理回执')),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          Text(_status),
          TextButton(
            onPressed: _busy ? null : _load,
            child: const Text('重新查询'),
          ),
          const Divider(),
          const Text('提交时响应丢失且未保存回执时，可用本机恢复凭据与原账号密码取回受限回执。此操作不会恢复账号登录。'),
          TextField(
            controller: _phone,
            decoration: const InputDecoration(labelText: '原账号手机号'),
            keyboardType: TextInputType.phone,
          ),
          TextField(
            controller: _password,
            decoration: const InputDecoration(labelText: '原账号密码'),
            obscureText: true,
          ),
          TextButton(
            onPressed: _busy ? null : _recover,
            child: const Text('恢复丢失的注销回执'),
          ),
        ],
      ),
    ),
  );
  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/account_security_page.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class AccountRecoveryHelpPage extends ConsumerStatefulWidget {
  const AccountRecoveryHelpPage({super.key});

  @override
  ConsumerState<AccountRecoveryHelpPage> createState() =>
      _AccountRecoveryHelpState();
}

class _AccountRecoveryHelpState extends ConsumerState<AccountRecoveryHelpPage> {
  bool _loading = false;
  bool _confirmed = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await ref
        .read(apiClientProvider)
        .get('/api/v1/auth/support-capabilities');
    if (!mounted) return;
    setState(() {
      _loading = false;
      _confirmed =
          result is NetworkSuccess<Map<String, dynamic>> &&
          result.data['password_recovery'] is Map &&
          result.data['password_recovery']['available'] == false &&
          result.data['password_recovery']['status'] ==
              'VERIFICATION_PROVIDER_NOT_CONFIGURED';
      if (!_confirmed) _error = '账号支持能力暂未读取成功，可重新读取。';
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('找回与账号帮助')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_loading) const LinearProgressIndicator(),
        if (_error != null) Text(_error!),
        if (_confirmed) const Text('密码找回验证渠道尚未接入，当前无法自助重置遗忘的密码。'),
        const SizedBox(height: 16),
        const Text('已登录并记得当前密码时，可在“设置 → 更新登录密码”修改。'),
        const SizedBox(height: 16),
        const Text('已申请注销时，可用本机回执查询处理状态。原手机号、当前密码和原注销编号可用于取回处理回执。'),
        const Text('注销回执用于查询处理进度，当前账号帮助未提供撤销注销或恢复账号入口。'),
        OutlinedButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const ClosureReceiptPage()),
          ),
          child: const Text('查看本机注销处理回执'),
        ),
        TextButton(
          onPressed: _loading ? null : _load,
          child: const Text('重新读取支持能力'),
        ),
      ],
    ),
  );
}

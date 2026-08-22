import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class _AuditStateSnapshot {
  const _AuditStateSnapshot({required this.stateLabel, this.version});

  final String stateLabel;
  final int? version;

  String get display => version == null ? stateLabel : '$stateLabel v$version';
}

class _MatchingAuditEntry {
  const _MatchingAuditEntry({
    required this.actionLabel,
    required this.actorLabel,
    required this.reasonLabel,
    required this.createdAtLabel,
    required this.transitionLabel,
  });

  final String actionLabel;
  final String actorLabel;
  final String reasonLabel;
  final String createdAtLabel;
  final String transitionLabel;

  static _MatchingAuditEntry? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final row = raw.map((key, value) => MapEntry(key.toString(), value));
    final action = row['action'];
    final actorType = row['actor_type'];
    final createdAt = row['created_at'];
    if (action is! String ||
        action.trim().isEmpty ||
        actorType is! String ||
        actorType.trim().isEmpty ||
        createdAt is! String) {
      return null;
    }
    final timestamp = DateTime.tryParse(createdAt);
    if (timestamp == null) return null;

    final afterState = row['after_state'];
    final before =
        _snapshot(afterState, nestedKey: 'before', allowDirect: false) ??
        _snapshot(row['before_state'], nestedKey: 'before', allowDirect: true);
    final after = _snapshot(afterState, nestedKey: 'after', allowDirect: true);
    final transition = switch ((before, after)) {
      (final before?, final after?) => '${before.display} → ${after.display}',
      (final before?, null) => '${before.display} → 状态信息不可用',
      (null, final after?) => after.display,
      _ => '状态信息不可用',
    };
    final actorId = row['actor_id'];

    return _MatchingAuditEntry(
      actionLabel: _actionLabel(action),
      actorLabel:
          '${_actorTypeLabel(actorType)}${actorId is num ? ' #${actorId.toInt()}' : ''}',
      reasonLabel: _reasonLabel(row['reason_code']),
      createdAtLabel: _formatTimestamp(timestamp),
      transitionLabel: transition,
    );
  }

  static _AuditStateSnapshot? _snapshot(
    Object? raw, {
    required String nestedKey,
    required bool allowDirect,
  }) {
    if (raw is! Map) return null;
    final outer = raw.map((key, value) => MapEntry(key.toString(), value));
    final nested = outer[nestedKey];
    if (nested is! Map && !allowDirect) return null;
    final source = nested is Map
        ? nested.map((key, value) => MapEntry(key.toString(), value))
        : outer;
    final state = source['state'];
    if (state is! String || state.trim().isEmpty) return null;
    final version = source['state_version'];
    return _AuditStateSnapshot(
      stateLabel: _stateLabel(state),
      version: version is num ? version.toInt() : null,
    );
  }

  static String _actionLabel(String value) => switch (value) {
    'prepare' => '准备轮次',
    'execute' || 'execution_request' => '创建执行请求',
    'reveal' => '揭晓轮次',
    'retry' => '重试运行',
    'close' => '关闭轮次',
    'schedule' => '安排轮次',
    _ => '未知操作',
  };

  static String _actorTypeLabel(String value) => switch (value) {
    'admin' => '管理员',
    'system' => '系统',
    'command' || 'cli' => '内部命令',
    _ => '未知执行方',
  };

  static String _reasonLabel(Object? value) => switch (value) {
    'c2_local_operator' => '内部运营操作',
    'scheduled_operation' => '计划内操作',
    'retry_after_failure' => '失败后重试',
    null || '' => '未记录原因',
    _ => '未分类原因',
  };

  static String _stateLabel(String value) => switch (value) {
    'scheduled' => '已安排',
    'preparing' => '待执行',
    'waiting' => '等待揭晓',
    'revealed' => '结果已揭晓',
    'no_candidate' => '本轮无合适候选',
    'failed' => '运行失败',
    'closed' => '已关闭',
    'pending' => '等待执行',
    'running' => '执行中',
    'succeeded' => '运行成功',
    _ => '未知状态',
  };

  static String _formatTimestamp(DateTime value) {
    final local = value.toLocal();
    String two(int number) => number.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}';
  }
}

class AdminMatchingOperationsPage extends ConsumerStatefulWidget {
  const AdminMatchingOperationsPage({super.key});

  @override
  ConsumerState<AdminMatchingOperationsPage> createState() =>
      _AdminMatchingOperationsPageState();
}

class _AdminMatchingOperationsPageState
    extends ConsumerState<AdminMatchingOperationsPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _rounds = const [];
  bool _consumerConfigured = false;
  bool _busy = false;
  String? _auditRoundKey;
  bool _auditLoading = false;
  String? _auditError;
  List<_MatchingAuditEntry> _audits = const [];
  int _auditRequestSerial = 0;

  ApiClient get _api => ref.read(apiClientProvider);

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    if (!ref.read(appEnvProvider).useAdminMatchingOperations) {
      setState(() {
        _loading = false;
        _error = '匹配运营入口仅在本地内部构建中可用。';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await _api.get('/api/v1/admin/matching/rounds');
    if (!mounted) return;
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      final raw = result.data['data'];
      setState(() {
        _rounds = raw is List
            ? raw
                  .whereType<Map>()
                  .map(
                    (row) => row.map(
                      (key, value) => MapEntry(key.toString(), value),
                    ),
                  )
                  .toList()
            : const [];
        final meta = result.data['meta'];
        _consumerConfigured = meta is Map && meta['consumer_configured'] == true;
        _loading = false;
      });
    } else {
      final failure = result as NetworkFailure<Map<String, dynamic>>;
      setState(() {
        _loading = false;
        _error = failure.message;
      });
    }
  }

  String _label(String state) => switch (state) {
    'preparing' => '待执行',
    'waiting' => '等待揭晓',
    'revealed' => '结果已揭晓',
    'no_candidate' => '本轮无合适候选',
    'failed' => '运行失败',
    'closed' => '已关闭',
    _ => '状态未知',
  };

  String _runStateLabel(String state) => switch (state) {
    'pending' => '等待执行',
    'running' => '执行中',
    'succeeded' => '运行成功',
    'failed' => '运行失败',
    _ => state.isEmpty ? '无' : '状态未知',
  };

  String _outcomeLabel(String outcome) => switch (outcome) {
    'matches_created' => '匹配已生成',
    'no_candidate' => '没有合适候选',
    _ => outcome.isEmpty ? '' : '结果未知',
  };

  Future<bool> _confirm(String title, String consequence) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(consequence),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('确认执行'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _action(Map<String, dynamic> round, String action) async {
    final roundKey = round['round_key']?.toString() ?? '';
    final version = (round['state_version'] as num?)?.toInt() ?? 0;
    if (roundKey.isEmpty || version <= 0) return;
    if ((action == 'reveal' || action == 'close') &&
        !await _confirm(
          action == 'reveal' ? '确认揭晓本轮？' : '确认关闭本轮？',
          action == 'reveal'
              ? '揭晓后，匹配用户将获得会话资格；操作会写入审计记录。'
              : '关闭后本轮不可恢复为等待状态；历史会话不会被删除。',
        )) {
      return;
    }
    setState(() => _busy = true);
    final headers = <String, dynamic>{
      'Idempotency-Key':
          'flutter-c2-$action-$roundKey-${DateTime.now().millisecondsSinceEpoch}',
      if (action == 'reveal' || action == 'close')
        'X-Matching-Confirmation': 'confirm:$roundKey:$action',
    };
    final result = await _api.post(
      '/api/v1/admin/matching/rounds/$roundKey/${action == 'execute' ? 'execution-requests' : action}',
      body: <String, dynamic>{
        'state_version': version,
        'reason_code': 'c2_local_operator',
      },
      options: Options(headers: headers),
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (result is NetworkFailure<Map<String, dynamic>>) {
      final message = switch (result.statusCode) {
        409 => '状态已变化或请求已冲突，正在重新加载当前事实。',
        503 when action == 'execute' => '本地手动执行器未配置；轮次本身尚未判定为失败。',
        401 || 403 => '当前账号没有匹配运营操作权限。',
        _ => '操作未成功，正在重新加载当前事实。',
      };
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
    await _load();
    if (!mounted || result is NetworkFailure<Map<String, dynamic>>) return;
    final replay = (result as NetworkSuccess<Map<String, dynamic>>).data['meta'];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          replay is Map && replay['idempotent_replay'] == true
              ? '请求已处理过；已按最新服务器状态完成核对。'
              : '操作已接受；已重新加载最新服务器状态。',
        ),
      ),
    );
  }

  Future<void> _openAudit(String roundKey) async {
    setState(() {
      _auditRoundKey = roundKey;
      _auditLoading = true;
      _auditError = null;
      _audits = const [];
    });
    await _loadAudit(roundKey);
  }

  Future<void> _loadAudit(String roundKey) async {
    final requestSerial = ++_auditRequestSerial;
    if (!_auditLoading || _auditRoundKey != roundKey) {
      setState(() {
        _auditLoading = true;
        _auditError = null;
      });
    }
    final result = await _api.get('/api/v1/admin/matching/rounds/$roundKey');
    if (!mounted ||
        requestSerial != _auditRequestSerial ||
        _auditRoundKey != roundKey) {
      return;
    }
    if (result is NetworkFailure<Map<String, dynamic>>) {
      setState(() {
        _auditLoading = false;
        _auditError = '审计记录暂时不可用，请重试。';
        _audits = const [];
      });
      return;
    }
    final data = (result as NetworkSuccess<Map<String, dynamic>>).data;
    final rawAudits = data['audits'];
    if (rawAudits is! List) {
      setState(() {
        _auditLoading = false;
        _auditError = '审计记录格式不可用，请重试。';
        _audits = const [];
      });
      return;
    }
    final parsed = <_MatchingAuditEntry>[];
    for (final raw in rawAudits) {
      final entry = _MatchingAuditEntry.tryParse(raw);
      if (entry == null) {
        setState(() {
          _auditLoading = false;
          _auditError = '审计记录格式不可用，请重试。';
          _audits = const [];
        });
        return;
      }
      parsed.add(entry);
    }
    setState(() {
      _auditLoading = false;
      _auditError = null;
      _audits = List.unmodifiable(parsed);
    });
  }

  void _closeAudit() {
    _auditRequestSerial += 1;
    setState(() {
      _auditRoundKey = null;
      _auditLoading = false;
      _auditError = null;
      _audits = const [];
    });
  }

  Widget _auditSection(String roundKey) {
    if (_auditLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text('正在读取审计记录…'),
          ],
        ),
      );
    }
    if (_auditError != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_auditError!),
            TextButton(
              key: ValueKey('audit-retry-$roundKey'),
              onPressed: () => _loadAudit(roundKey),
              child: const Text('重试审计记录'),
            ),
          ],
        ),
      );
    }
    if (_audits.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('当前没有审计记录。'),
            TextButton(
              key: ValueKey('audit-refresh-$roundKey'),
              onPressed: () => _loadAudit(roundKey),
              child: const Text('刷新审计记录'),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._audits.map(
            (audit) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Semantics(
                container: true,
                explicitChildNodes: true,
                label: '匹配操作审计记录',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('操作：${audit.actionLabel}'),
                    Text('执行方：${audit.actorLabel}'),
                    Text('原因：${audit.reasonLabel}'),
                    Text('时间：${audit.createdAtLabel}'),
                    Text('状态：${audit.transitionLabel}'),
                  ],
                ),
              ),
            ),
          ),
          TextButton(
            key: ValueKey('audit-refresh-$roundKey'),
            onPressed: () => _loadAudit(roundKey),
            child: const Text('刷新审计记录'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AppScaffold(
      appBar: AppBar(title: const Text('匹配运营')),
      body: _loading
          ? const AppLoadingSkeleton(lines: 7)
          : _error != null
          ? AppErrorState(
              title: '匹配运营状态不可用',
              description: _error!,
              retryLabel: '重新加载',
              onRetry: _load,
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: EdgeInsets.all(t.spacing.pageHorizontal),
                children: [
                  Text(
                    '轮次与运行',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '这里读取本地保存的轮次、运行和审计摘要。没有调度器或队列正在自动运行。',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: t.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: t.spacing.md),
                  if (_rounds.isEmpty)
                    const AppCard(child: Text('当前没有轮次。请先通过受保护的本地场景工具准备合成轮次。'))
                  else
                    ..._rounds.map((round) {
                      final state = round['state']?.toString() ?? '';
                      final activeRun = round['active_run'];
                      final run = activeRun is Map ? activeRun : const {};
                      final outcome = run['outcome']?.toString() ?? '';
                      final runState = run['state']?.toString() ?? '';
                      final pairCount =
                          (run['pair_count'] as num?)?.toInt() ?? 0;
                      final noCandidateCount =
                          (run['no_candidate_count'] as num?)?.toInt() ?? 0;
                      final roundKey = round['round_key']?.toString() ?? '';
                      final auditSelected = _auditRoundKey == roundKey;
                      final rawCapabilities = round['operation_capabilities'];
                      final capabilities = rawCapabilities is Map
                          ? rawCapabilities
                          : const {};
                      final action = capabilities['retry'] == true
                          ? 'retry'
                          : capabilities['reveal'] == true
                          ? 'reveal'
                          : capabilities['close'] == true
                          ? 'close'
                          : capabilities['execute'] == true && _consumerConfigured
                          ? 'execute'
                          : null;
                      final actionLabel = switch (action) {
                        'execute' => '创建执行请求',
                        'reveal' => '确认揭晓',
                        'retry' => '创建新重试',
                        'close' => '关闭本轮',
                        _ => '',
                      };
                      return Padding(
                        padding: EdgeInsets.only(bottom: t.spacing.md),
                        child: AppCard(
                          padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _label(state),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            color: t.textPrimary,
                                            fontWeight: FontWeight.w900,
                                          ),
                                    ),
                                  ),
                                  Text(
                                    'v${round['state_version'] ?? '-'}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(color: t.textSecondary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '最近运行：${_runStateLabel(runState)}${outcome.isEmpty ? '' : ' · ${_outcomeLabel(outcome)}'}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                '配对 $pairCount · 未匹配 $noCandidateCount · 用户投影 ${round['user_states_count'] ?? 0}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: t.textSecondary),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '补偿操作：未授权',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: t.warning),
                              ),
                              if (capabilities['execute'] == true &&
                                  !_consumerConfigured)
                                Text(
                                  '执行请求：本地手动执行器未配置（不代表匹配失败）',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: t.warning),
                                ),
                              TextButton.icon(
                                key: ValueKey('audit-open-$roundKey'),
                                onPressed: roundKey.isEmpty
                                    ? null
                                    : auditSelected
                                    ? _closeAudit
                                    : () => _openAudit(roundKey),
                                icon: Icon(
                                  auditSelected
                                      ? Icons.expand_less
                                      : Icons.history,
                                ),
                                label: Text(
                                  auditSelected ? '收起审计记录' : '查看审计记录',
                                ),
                              ),
                              if (auditSelected) _auditSection(roundKey),
                              if (action != null) ...[
                                SizedBox(height: t.spacing.md),
                                AppPrimaryButton(
                                  label: _busy ? '处理中…' : actionLabel,
                                  onPressed: _busy
                                      ? null
                                      : () => _action(round, action),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import '../providers/natal_restoration_provider.dart';
import 'dynamic_chart_wheel.dart';
import 'natal_restoration_charts.dart';

/// Historical reads stay separate from the current editable input and revision.
class ToolRevisionHistory extends ConsumerStatefulWidget {
  const ToolRevisionHistory({
    super.key,
    required this.endpoint,
    required this.detailKey,
  });

  final String endpoint;
  final String detailKey;

  @override
  ConsumerState<ToolRevisionHistory> createState() =>
      _ToolRevisionHistoryState();
}

class _ToolRevisionHistoryState extends ConsumerState<ToolRevisionHistory> {
  List<Map<String, dynamic>> _items = [];
  Map<String, dynamic>? _detail;
  int? _next;
  int _operation = 0;
  bool _busy = false, _loaded = false;
  String? _error;

  void _clear() {
    _operation++;
    _items = [];
    _detail = null;
    _next = null;
    _busy = false;
    _loaded = false;
    _error = null;
  }

  @override
  void didUpdateWidget(covariant ToolRevisionHistory oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.endpoint != widget.endpoint) _clear();
  }

  bool _current(SessionState session, int authority, int operation) =>
      mounted &&
      operation == _operation &&
      authority == ref.read(relationshipAuthorityEpochProvider) &&
      natalSessionMatches(session, ref.read(sessionProvider).asData?.value);

  Future<void> _read({bool more = false, int? id}) async {
    if (_busy) return;
    final operation = ++_operation;
    final authority = ref.read(relationshipAuthorityEpochProvider);
    final session = ref.read(sessionProvider).asData?.value;
    if (session == null || !session.isLoggedIn) return;
    setState(() {
      _busy = true;
      _error = null;
      if (id != null) _detail = null;
    });
    try {
      final response = await ref
          .read(apiClientProvider)
          .get(
            '${widget.endpoint}${id == null ? '' : '/$id'}',
            query: more ? {'before_id': _next} : null,
            options: natalSessionOptions(
              () => _current(session, authority, operation),
            ),
          );
      if (!_current(session, authority, operation)) return;
      if (response is NetworkFailure<Map<String, dynamic>>) {
        throw NatalRequestException(response.message, response.statusCode);
      }
      final data = (response as NetworkSuccess<Map<String, dynamic>>).data;
      setState(() {
        if (id != null) {
          if (data['historical'] != true || data[widget.detailKey] is! Map) {
            throw const NatalRequestException('历史响应格式无效。');
          }
          _detail = data;
        } else {
          if (data['items'] is! List) {
            throw const NatalRequestException('历史列表格式无效。');
          }
          final rows = natalList(data['items']).map(natalMap).toList();
          final known = more
              ? _items.map((row) => row['id']).toSet()
              : <dynamic>{};
          _items = [
            if (more) ..._items,
            ...rows.where((row) => !known.contains(row['id'])),
          ];
          _next = (data['next_before_id'] as num?)?.toInt();
          _loaded = true;
        }
      });
    } on NatalRequestException catch (error) {
      if (_current(session, authority, operation)) {
        setState(() {
          if ([401, 403, 404, 410].contains(error.statusCode)) {
            _items = [];
            _detail = null;
            _next = null;
            _loaded = false;
            _error = '当前历史不可用，请检查权限后重新读取。';
          } else {
            _error = '历史读取失败，已有输入未改动，可重试。';
          }
        });
      }
    } catch (_) {
      if (_current(session, authority, operation)) {
        setState(() => _error = '历史读取失败，已有输入未改动，可重试。');
      }
    } finally {
      if (_current(session, authority, operation)) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionProvider, (before, after) {
      if (!identical(before?.asData?.value, after.asData?.value)) {
        setState(_clear);
      }
    });
    ref.listen(relationshipAuthorityEpochProvider, (before, after) {
      if (before != after) setState(_clear);
    });
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('历史版本', style: Theme.of(context).textTheme.titleMedium),
            const Text('历史为只读记录。重新计算与编辑使用上方当前输入。'),
            OutlinedButton(
              onPressed: _busy ? null : () => _read(),
              child: const Text('读取历史版本'),
            ),
            if (_busy) const LinearProgressIndicator(),
            if (_error != null) Text(_error!),
            if (_loaded && _items.isEmpty) const Text('暂无已归档的旧版本。'),
            for (final item in _items)
              TextButton(
                key: ValueKey('tool-revision-${item['id']}'),
                onPressed: _busy
                    ? null
                    : () => _read(id: (item['id'] as num).toInt()),
                child: Text(
                  '查看旧版本 ${item['input_revision']} · ${item['archived_at'] ?? '时间未知'} · ${item['status']}',
                ),
              ),
            if (_next != null)
              OutlinedButton(
                onPressed: _busy ? null : () => _read(more: true),
                child: const Text('读取更早版本'),
              ),
            if (_detail != null) ...[
              Text('历史归档时间 ${_detail!['archived_at'] ?? '未知'}'),
              if (widget.detailKey == 'profile')
                NatalProjectionView(natal: natalMap(_detail!['profile']))
              else
                _dynamicDetail(natalMap(_detail!['chart'])),
            ],
          ],
        ),
      ),
    );
  }

  Widget _dynamicDetail(Map<String, dynamic> chart) {
    final results = natalMap(chart['results']);
    final first = natalMap(results['first']);
    final second = natalMap(results['second']);
    final events = natalList(results['events']);
    final ready =
        chart['result_revision'] == chart['input_revision'] &&
        chart['status'] == 'COMPUTED_UNVERIFIED' &&
        results.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '旧版本 ${chart['input_revision']} · ${chart['chart_type']} · ${chart['status']}',
        ),
        const Text('计算来源与参数来自该历史记录；独立精度 UNVERIFIED。'),
        if (ready) ...[
          if (first.isNotEmpty)
            DynamicChartWheel(
              first: first,
              second: second.isEmpty ? null : second,
              aspects: natalList(results['cross_aspects']),
            ),
          for (final entry in {'第一盘': first, '第二盘': second}.entries)
            for (final raw in natalList(entry.value['planets']))
              Text(
                '${entry.key} ${natalBodyLabel(natalMap(raw)['name'])} · 黄经 ${natalText(natalMap(raw)['longitude'])}',
              ),
          Text('事件数 ${events.length} · ${results['status']}'),
          if (results['reason'] != null) Text('计算说明 ${results['reason']}'),
          for (var i = 0; i < events.length; i++)
            ExpansionTile(
              title: Text('历史事件 ${i + 1} · ${natalMap(events[i])['utc']}'),
              children: [
                Text(
                  'bracket ${natalMap(events[i])['bracket_seconds']} 秒 · 残差 ${natalMap(events[i])['residual_degrees']}°',
                ),
                DynamicChartWheel(
                  first: first,
                  second: natalMap(natalMap(events[i])['chart']),
                  aspects: natalList(natalMap(events[i])['cross_aspects']),
                ),
                for (final raw in natalList(
                  natalMap(natalMap(events[i])['chart'])['planets'],
                ))
                  Text(
                    '${natalBodyLabel(natalMap(raw)['name'])} · 黄经 ${natalText(natalMap(raw)['longitude'])}',
                  ),
              ],
            ),
          if (results['window'] != null)
            Text(
              '计算时间窗口 ${const JsonEncoder.withIndent('  ').convert(results['window'])}',
            ),
        ] else
          const Text('该历史结果不可用或已过期。可检查当前输入后重新计算。'),
        ExpansionTile(
          title: const Text('历史输入与高级参数'),
          children: [
            SelectableText(
              const JsonEncoder.withIndent('  ').convert({
                'request': chart['request'],
                'settings': chart['settings'],
                'first_engine': first['engine'],
                'first_profile': first['effective_profile'],
                'first_data_sha256': first['data_sha256'],
              }),
            ),
          ],
        ),
      ],
    );
  }
}

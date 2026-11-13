import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'operational_status_card.dart';

class OperatingApplicationCard extends ConsumerStatefulWidget {
  const OperatingApplicationCard({super.key});
  @override
  ConsumerState<OperatingApplicationCard> createState() =>
      _OperatingApplicationCardState();
}

class _OperatingApplicationCardState
    extends ConsumerState<OperatingApplicationCard> {
  final _note = TextEditingController();
  int? _revision;
  int _generation = 0;
  bool _busy = false;
  String _status = '正在读取申请…';
  late final ProviderSubscription<AsyncValue<SessionState>> _session;

  @override
  void initState() {
    super.initState();
    _session = ref.listenManual(sessionProvider, (_, _) {
      _generation++;
      _note.clear();
      setState(() {
        _revision = null;
        _busy = false;
        _status = '请登录后读取申请。';
      });
      unawaited(_request(false));
    });
    Future.microtask(() => _request(false));
  }

  Future<void> _request(bool submit) async {
    final session = ref.read(sessionProvider).asData?.value;
    final token = session?.accessToken;
    if (!mounted || session?.isLoggedIn != true || token == null) return;
    final generation = ++_generation;
    bool current() =>
        mounted &&
        generation == _generation &&
        identical(session, ref.read(sessionProvider).asData?.value);
    setState(() => _busy = true);
    try {
      final options = Options(
        followRedirects: false,
        headers: {'Authorization': 'Bearer $token'},
        extra: {requestSessionGuardKey: current},
      );
      final dio = ref.read(dioProvider);
      final result = submit
          ? await dio.post<Map<String, dynamic>>(
              '/api/v1/profile/operating-application',
              data: {'note': _note.text.trim(), 'expected_revision': _revision},
              options: options,
            )
          : await dio.get<Map<String, dynamic>>(
              '/api/v1/profile/operating-application',
              options: options,
            );
      if (!current()) return;
      final data = result.data!;
      if (data['revision'] is! int) throw const FormatException('申请状态无效');
      final application = data['application'];
      setState(() {
        _revision = data['revision'] as int;
        _status = application is Map
            ? '申请状态 ${application['state']}\n${application['feedback'] ?? ''}'
            : '尚未提交运营参与申请';
        if (_note.text.isEmpty && application is Map) {
          _note.text = application['note']?.toString() ?? '';
        }
      });
      if (submit) ref.invalidate(operationalStatusProvider);
    } catch (error) {
      if (!current()) return;
      setState(
        () =>
            _status = error is DioException && error.response?.statusCode == 409
            ? '申请状态已变化，请刷新后再提交。'
            : '申请操作失败，输入已保留，可刷新状态或重试提交。',
      );
    } finally {
      if (current()) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _generation++;
    _session.close();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('运营参与申请'),
          const Text('说明参与意愿，审核反馈会保存到本账号。请勿填写证件信息。'),
          Text(_status),
          TextField(
            controller: _note,
            enabled: !_busy,
            maxLength: 500,
            maxLines: 3,
            decoration: const InputDecoration(labelText: '申请说明'),
          ),
          Wrap(
            children: [
              TextButton(
                onPressed: _busy ? null : () => _request(false),
                child: const Text('刷新申请状态'),
              ),
              FilledButton(
                onPressed: _busy || _revision == null
                    ? null
                    : () => _request(true),
                child: const Text('提交运营申请'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

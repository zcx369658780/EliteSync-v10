import 'dart:async';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_elitesync_module/features/chat/data/gateway/chat_media_gateway.dart';

final liveChatMediaGatewayProvider = Provider<ChatMediaGateway>(
  (ref) => PlatformChatMediaGateway(apiClient: ref.watch(apiClientProvider)),
);

class LiveChatPage extends ConsumerStatefulWidget {
  const LiveChatPage({super.key, required this.peerId});
  final int peerId;
  @override
  ConsumerState<LiveChatPage> createState() => _LiveChatPageState();
}

class _LiveChatPageState extends ConsumerState<LiveChatPage> {
  final _text = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  Map<int, Uint8List> _images = {};
  String? _error;
  bool _busy = false;
  bool _loading = false;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _uploadCancellation.cancel('Page disposed');
    _text.dispose();
    super.dispose();
  }

  SessionState? _session;
  int _epoch = 0;
  CancelToken _uploadCancellation = CancelToken();

  bool _current(SessionState session, int epoch) =>
      mounted &&
      epoch == _epoch &&
      identical(ref.read(sessionProvider).asData?.value, session);

  void _reject(String message) {
    if (!mounted) return;
    setState(() {
      _epoch++;
      _uploadCancellation.cancel('Request session invalidated');
      _uploadCancellation = CancelToken();
      _messages = [];
      _images = {};
      _error = message;
      _loading = false;
      _busy = false;
    });
  }

  Future<void> _load() async {
    if (_loading || !mounted) return;
    _loading = true;
    final epoch = _epoch;
    SessionState? started;
    try {
      final session = await ref.read(sessionProvider.future);
      started = session;
      if (!_current(session, epoch)) return;
      if (!session.isLoggedIn) {
        _reject('当前无法读取对话，请检查登录、连接与双方消息同意。');
        return;
      }
      _session = session;
      final response = await ref
          .read(apiClientProvider)
          .get(
            '/api/v1/messages',
            query: {'peer_id': widget.peerId},
            cancelToken: _uploadCancellation,
            options: Options(
              extra: {requestSessionGuardKey: () => _current(session, epoch)},
            ),
          );
      if (!_current(session, epoch)) return;
      if (response is! NetworkSuccess<Map<String, dynamic>>) {
        _reject('当前无法读取对话，请检查登录、连接与双方消息同意。');
        return;
      }
      final items = (response.data['items'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .toList();
      final images = <int, Uint8List>{};
      for (final message in items) {
        for (final attachment in (message['attachments'] as List? ?? [])) {
          final asset = attachment['media_asset'];
          if (asset is! Map || asset['media_type'] != 'image') continue;
          final id = (asset['id'] as num).toInt();
          final data = await ref
              .read(dioProvider)
              .get<List<int>>(
                '/api/v1/media/$id/content',
                cancelToken: _uploadCancellation,
                options: Options(
                  responseType: ResponseType.bytes,
                  extra: {
                    requestSessionGuardKey: () => _current(session, epoch),
                  },
                ),
              );
          if (!_current(session, epoch)) return;
          images[id] = Uint8List.fromList(data.data ?? []);
        }
      }
      if (!_current(session, epoch)) return;
      setState(() {
        _messages = items;
        _images = images;
        _error = null;
      });
    } catch (_) {
      if (started != null && _current(started, epoch)) {
        _reject('当前无法读取消息或附件，请检查登录、连接与双方消息同意。');
      }
    } finally {
      if (epoch == _epoch) _loading = false;
    }
  }

  Future<void> _post(SessionState session, int epoch, {int? asset}) async {
    if (!_current(session, epoch)) return;
    final text = _text.text.trim();
    if (text.isEmpty && asset == null) return;
    final result = await ref
        .read(apiClientProvider)
        .post(
          '/api/v1/messages',
          cancelToken: _uploadCancellation,
          options: Options(
            extra: {requestSessionGuardKey: () => _current(session, epoch)},
          ),
          body: {
            'receiver_id': widget.peerId,
            'content': text,
            'client_message_id': const Uuid().v4(),
            if (asset != null) 'attachment_ids': [asset],
          },
        );
    if (!_current(session, epoch)) return;
    if (result is! NetworkSuccess<Map<String, dynamic>>) {
      _reject('发送未完成，服务器未授权或当前会话已失效。');
      return;
    }
    _text.clear();
    await _load();
    if (!_current(session, epoch)) return;
  }

  Future<void> _send({int? asset}) async {
    if (_busy || !mounted) return;
    final session = ref.read(sessionProvider).asData?.value;
    if (session == null || !session.isLoggedIn) {
      _reject('发送未完成，服务器未授权或当前会话已失效。');
      return;
    }
    _session = session;
    final epoch = _epoch;
    setState(() => _busy = true);
    try {
      await _post(session, epoch, asset: asset);
    } catch (_) {
      if (_current(session, epoch)) _reject('发送未完成，服务器未授权或当前会话已失效。');
    } finally {
      if (_current(session, epoch)) setState(() => _busy = false);
    }
  }

  Future<void> _picture() async {
    if (_busy || !mounted) return;
    final session = ref.read(sessionProvider).asData?.value;
    if (session == null || !session.isLoggedIn) {
      _reject('图片上传或处理未完成，请检查登录与消息权限。');
      return;
    }
    _session = session;
    final epoch = _epoch;
    setState(() => _busy = true);
    try {
      final gateway = ref.read(liveChatMediaGatewayProvider);
      final picked = await gateway.pick(ChatAttachmentKind.image);
      if (!_current(session, epoch) || picked == null) return;
      if (gateway is! SessionBoundChatMediaGateway) {
        throw StateError('图片上传缺少会话保护');
      }
      final uploaded = await gateway.uploadForSession(
        ChatAttachmentKind.image,
        picked,
        isCurrent: () => _current(session, epoch),
        cancelToken: _uploadCancellation,
      );
      if (!_current(session, epoch)) return;
      if (uploaded.assetId == null || uploaded.status != 'ready') {
        throw StateError('图片尚未就绪');
      }
      await _post(session, epoch, asset: uploaded.assetId);
      if (!_current(session, epoch)) return;
    } catch (_) {
      if (_current(session, epoch)) _reject('图片上传或处理未完成，请检查登录与消息权限。');
    } finally {
      if (_current(session, epoch)) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionProvider, (previous, next) {
      if (_session != null && !identical(_session, next.asData?.value)) {
        setState(() {
          _epoch++;
          _uploadCancellation.cancel('Request session invalidated');
          _uploadCancellation = CancelToken();
          _session = null;
          _messages = [];
          _images = {};
          _loading = false;
          _busy = false;
          _text.clear();
          _error = '账号已变化，请重新打开对话。';
        });
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('对话'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          if (_error != null)
            Padding(padding: const EdgeInsets.all(12), child: Text(_error!)),
          Expanded(
            child: ListView(
              children: _messages
                  .map(
                    (m) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m['content']?.toString() ?? ''),
                            for (final a in (m['attachments'] as List? ?? []))
                              if (a['media_asset'] is Map)
                                if (_images[(a['media_asset']['id'] as num)
                                        .toInt()]
                                    case final bytes?)
                                  Image.memory(bytes, height: 140),
                            Text(
                              m['is_read'] == true ? '已读' : '未读',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          SafeArea(
            child: Row(
              children: [
                IconButton(
                  onPressed: _busy ? null : _picture,
                  icon: const Icon(Icons.image),
                  tooltip: '发送图片',
                ),
                Expanded(
                  child: TextField(
                    controller: _text,
                    decoration: const InputDecoration(hintText: '输入消息'),
                  ),
                ),
                TextButton(
                  onPressed: _busy ? null : () => _send(),
                  child: const Text('发送'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

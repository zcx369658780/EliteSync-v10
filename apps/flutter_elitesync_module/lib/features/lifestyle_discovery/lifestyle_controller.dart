import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../relationships_v1011/relationship_api.dart';

/// One durable B1 command at a time. Retries preserve both CAS and UUID.
class LifestyleController extends ChangeNotifier {
  LifestyleController({
    required this.read,
    required this.send,
    required this.readDraft,
    required this.writeDraft,
    required this.isCurrent,
  });

  final Future<Map<String, dynamic>> Function() read;
  final Future<Map<String, dynamic>> Function(Map<String, dynamic>) send;
  final Future<Map<String, dynamic>?> Function() readDraft;
  final Future<bool> Function(Map<String, dynamic>) writeDraft;
  final bool Function() isCurrent;
  Map<String, dynamic>? data;
  Map<String, dynamic>? pending;
  String? error;
  bool busy = false;
  bool conflict = false;
  bool _disposed = false;
  bool get current => !_disposed && isCurrent();

  void _notify() {
    if (current) notifyListeners();
  }

  Future<void> load() async {
    if (!current || busy) return;
    busy = true;
    error = null;
    _notify();
    try {
      final latest = await read();
      if (!current) return;
      final draft = await readDraft();
      if (!current) return;
      data = latest;
      pending = draft?['pending'] is Map
          ? Map<String, dynamic>.from(draft!['pending'] as Map)
          : null;
    } catch (_) {
      if (current) error = '暂时无法读取，请连接服务后重试。';
    } finally {
      busy = false;
      _notify();
    }
    if (current && pending != null) await retry();
  }

  Future<bool> answer(String sceneId, String optionId) =>
      command('answer', {'scene_id': sceneId, 'option_id': optionId});

  Future<bool> command(
    String action, [
    Map<String, dynamic> extra = const {},
  ]) async {
    if (!current || busy || pending != null || data == null) return false;
    pending = {
      'action': action,
      'expected_revision': data!['revision'],
      'questionnaire_version': data!['questionnaire_version'],
      'request_key': const Uuid().v4(),
      ...extra,
    };
    return retry();
  }

  Future<bool> retry() async {
    if (!current || busy || pending == null || conflict) return false;
    busy = true;
    error = null;
    _notify();
    final body = Map<String, dynamic>.from(pending!);
    try {
      final saved = await writeDraft({'pending': body});
      if (!current) return false;
      if (!saved) {
        error = '本机保存未确认，请重试。';
        return false;
      }
      final latest = await send(body);
      if (!current) return false;
      data = latest;
      // Failure to clear is recoverable by replaying the identical command.
      final cleared = await writeDraft({});
      if (!current) return false;
      if (!cleared) {
        error = '服务端已保存，本机回执待确认，请重试。';
        return false;
      }
      pending = null;
      return true;
    } on RelationshipFailure catch (failure) {
      if (current) {
        conflict = failure.statusCode == 409;
        error = conflict ? '答案已在其他地方更新。本机待同步选择已保留。' : '选择已保存在本机，连接恢复后可重试。';
      }
      return false;
    } catch (_) {
      if (current) error = '本机保存或同步尚未确认，请重试。';
      return false;
    } finally {
      busy = false;
      _notify();
    }
  }

  Future<void> discardAndReload() async {
    if (!current || busy) return;
    busy = true;
    _notify();
    try {
      final latest = await read();
      if (!current) return;
      final cleared = await writeDraft({});
      if (!current) return;
      if (!cleared) throw StateError('Draft cleanup unconfirmed');
      data = latest;
      pending = null;
      conflict = false;
      error = null;
    } catch (_) {
      if (current) error = '尚未读取最新答案或清理本机待同步项，请重试。';
    } finally {
      busy = false;
      _notify();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

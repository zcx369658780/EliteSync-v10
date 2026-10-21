// Independent R1 test entry point. Production entry points never import this.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_elitesync_module/core/storage/private_cache_service.dart';
import 'package:flutter_elitesync_module/core/storage/secure_storage_service.dart';
import 'package:uuid/uuid.dart';

bool retentionProbeAllowed({
  required bool probeEnabled,
  required bool localBuild,
  required String? hostDebugBuild,
}) => probeEnabled && localBuild && hostDebugBuild == 'true';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Map<dynamic, dynamic>? host;
  try {
    host = await const MethodChannel(
      'elitesync/bootstrap',
    ).invokeMapMethod<dynamic, dynamic>('getBootstrap');
  } catch (_) {
    // Missing native identity fails closed, including a standalone runner.
  }
  final allowed = retentionProbeAllowed(
    probeEnabled: const bool.fromEnvironment(
      'ELITESYNC_V1015_R1_RETENTION_PROBE',
    ),
    localBuild: const bool.fromEnvironment('ELITESYNC_V1015_R1_LOCAL_BUILD'),
    hostDebugBuild: host?['debugBuild']?.toString(),
  );
  // The Flutter AAR is compiled in release mode even in the debug-only host.
  // Native debug identity + compile flags are the runtime gates; Gradle also
  // requires the isolated probe applicationId and refuses release/profile tasks.
  runApp(MaterialApp(home: _ProbePage(allowed: allowed)));
}

class RetentionProbeFailure implements Exception {
  const RetentionProbeFailure(this.code);
  final String code;
}

abstract class RetentionProbeApi {
  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    String? token,
  });
  void close();
}

/// No endpoint override, redirect, arbitrary host, or response body logging.
class LocalRetentionProbeApi implements RetentionProbeApi {
  final _client = HttpClient()..connectionTimeout = const Duration(seconds: 15);

  @override
  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    if (!const {
      '/api/v1/auth/login',
      '/api/v1/auth/refresh',
      '/api/v1/conversations',
    }.contains(path)) {
      throw const RetentionProbeFailure('ENDPOINT_REJECTED');
    }
    return _request(method, path, body: body, token: token).timeout(
      const Duration(seconds: 25),
      onTimeout: () => throw const RetentionProbeFailure('HTTP_TIMEOUT'),
    );
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final request = await _client.openUrl(
      method,
      Uri.parse('http://127.0.0.1:8031$path'),
    );
    request.followRedirects = false;
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    if (token != null) {
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    }
    if (body != null) {
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(body));
    }
    final response = await request.close();
    if (response.statusCode != 200) {
      await response.drain<void>();
      throw RetentionProbeFailure('HTTP_${response.statusCode}');
    }
    final bytes = <int>[];
    await for (final chunk in response) {
      bytes.addAll(chunk);
      if (bytes.length > 1024 * 1024) {
        throw const RetentionProbeFailure('RESPONSE_LIMIT');
      }
    }
    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is! Map<String, dynamic>) {
      throw const RetentionProbeFailure('RESPONSE_SHAPE');
    }
    return decoded;
  }

  @override
  void close() => _client.close(force: true);
}

/// Both clocks are process-local seams; server T0 and Android wall time stay
/// unchanged. Advance to a T0-relative age, accounting for server_now - login_at.
class RetentionProbeClock {
  RetentionProbeClock({required this.loginAt, required this.serverNow});
  final DateTime loginAt;
  final DateTime serverNow;
  final DateTime wallAnchor = DateTime.now().toUtc();
  Duration elapsed = Duration.zero;
  DateTime wallNow() => wallAnchor.add(elapsed);
  void atAge(Duration age) {
    final next = age - serverNow.difference(loginAt);
    if (next.isNegative || next < elapsed) {
      throw const RetentionProbeFailure('CLOCK_NON_MONOTONIC');
    }
    elapsed = next;
  }
}

/// Counts completed native operations and injects failure only for an exact
/// per-run namespace. It never enumerates or clears another account's keys.
class _ProbeStorage extends SecureStorageService {
  _ProbeStorage(this.delegate, this.namespace);
  final SecureStorageService delegate;
  final String namespace;
  bool failObjectDelete = false;
  int completedDeletes = 0;
  int injectedFailures = 0;
  void _owned(String key) {
    if (!key.startsWith('$namespace:')) {
      throw const RetentionProbeFailure('NAMESPACE_REJECTED');
    }
  }

  @override
  Future<void> write(String key, String value) {
    _owned(key);
    return delegate.write(key, value);
  }

  @override
  Future<String?> read(String key) {
    _owned(key);
    return delegate.read(key);
  }

  @override
  Future<void> delete(String key) async {
    _owned(key);
    if (failObjectDelete && key != '$namespace:manifest') {
      injectedFailures++;
      throw const RetentionProbeFailure('INJECTED_NATIVE_DELETE_FAILURE');
    }
    await delegate.delete(key);
    completedDeletes++;
  }

  @override
  Future<void> deleteAll() async =>
      throw const RetentionProbeFailure('DELETE_ALL_FORBIDDEN');
}

class RetentionProbeRunner {
  RetentionProbeRunner({
    required this.storage,
    required this.api,
    required this.onReceipt,
    this.evidenceMode = 'ANDROID_TEST_INJECTION',
  });
  final SecureStorageService storage;
  final RetentionProbeApi api;
  final void Function(Map<String, dynamic>) onReceipt;
  final String evidenceMode;
  final String runId = const Uuid().v4();
  static const _restartPointerKey = 'v1015_r1_probe:last_failed_delete';
  static const _object = 'probe-authorized-conversation-collection';

  void _receipt(String stage, bool passed, [Map<String, dynamic>? details]) {
    onReceipt({
      'probe': 'V1015_R1_RETENTION',
      'mode': evidenceMode,
      'REAL_PHYSICAL_ELAPSED': 'NOT_CLAIMED',
      'run_id': runId,
      'stage': stage,
      'passed': passed,
      ...?details,
    });
    if (!passed) throw RetentionProbeFailure(stage);
  }

  Future<void> run() async {
    try {
      await _account('A', '19900001511', failDelete: false);
      await _account('B', '19900001512', failDelete: true);
      _receipt('COMPLETE', true);
    } catch (error) {
      onReceipt({
        'probe': 'V1015_R1_RETENTION',
        'mode': evidenceMode,
        'REAL_PHYSICAL_ELAPSED': 'NOT_CLAIMED',
        'run_id': runId,
        'stage': 'STOPPED',
        'passed': false,
        'reason': error is RetentionProbeFailure ? error.code : 'RUNTIME_ERROR',
      });
    } finally {
      api.close();
    }
  }

  Future<void> _account(
    String label,
    String phone, {
    required bool failDelete,
  }) async {
    final device = 'v1015-r1-probe-$runId-$label';
    final login = await api.request(
      'POST',
      '/api/v1/auth/login',
      body: {
        'phone': phone,
        'password': 'V1015R1-Test-Only-Password',
        'device_id': device,
      },
    );
    final user = Map<String, dynamic>.from(login['user'] as Map);
    final retention = Map<String, dynamic>.from(
      login['session_retention'] as Map,
    );
    final userId = user['id'] as int;
    _receipt(
      '${label}_SERVER_BINDING',
      retention['user_id'].toString() == '$userId' &&
          retention['device_id'] == device &&
          retention['session_id'] == login['session_id'],
    );
    final refreshed = await api.request(
      'POST',
      '/api/v1/auth/refresh',
      token: login['refresh_token'] as String,
    );
    final refreshedRetention = Map<String, dynamic>.from(
      refreshed['session_retention'] as Map,
    );
    _receipt(
      '${label}_REFRESH_KEEPS_T0',
      [
        'login_at',
        'online_expires_at',
        'purge_at',
        'device_id',
        'session_id',
      ].every((key) => refreshedRetention[key] == retention[key]),
    );
    // Current server authorization happens before writing any synthetic record.
    await api.request(
      'GET',
      '/api/v1/conversations',
      token: refreshed['access_token'] as String,
    );
    _receipt('${label}_CURRENT_READ_HTTP_200', true);
    final clock = RetentionProbeClock(
      loginAt: DateTime.parse(retention['login_at'] as String).toUtc(),
      serverNow: DateTime.parse(retention['server_now'] as String).toUtc(),
    );
    final namespace = 'v1015_private:a$userId:d${Uri.encodeComponent(device)}';
    final secure = _ProbeStorage(storage, namespace);
    // This independent, native-debug-gated test APK is the authorized caller of
    // the process clock seam; production entry points cannot reach this file.
    // ignore: invalid_use_of_visible_for_testing_member
    final cache = PrivateCacheService.forTesting(
      secure,
      wallNow: clock.wallNow,
      elapsed: () => clock.elapsed,
    );
    _receipt(
      '${label}_ONLINE_LOGIN_ANCHOR',
      await cache.establishLogin(userId: userId, retention: retention),
    );
    const object = _object;
    final objectKey = '$namespace:${Uri.encodeComponent(object)}';
    final manifestKey = '$namespace:manifest';
    _receipt(
      '${label}_SYNTHETIC_SAVE',
      await cache.saveAuthorized(object, {
        'synthetic': true,
        'probe_run': runId,
      }, expectedAccountId: userId),
    );
    _receipt(
      '${label}_NATIVE_STORED',
      await secure.read(objectKey) != null &&
          await secure.read(manifestKey) != null,
    );
    // Same test-only seam, deliberately without restoring an anchor or grants.
    // ignore: invalid_use_of_visible_for_testing_member
    final restarted = PrivateCacheService.forTesting(
      secure,
      wallNow: clock.wallNow,
      elapsed: () => clock.elapsed,
    );
    restarted.enterOffline();
    _receipt(
      '${label}_NEW_INSTANCE_LOCKED',
      !restarted.isUnlocked && await restarted.readOffline(object) == null,
    );
    const millisecond = Duration(milliseconds: 1);
    clock.atAge(const Duration(days: 15) - millisecond);
    _receipt(
      '${label}_D15_MINUS_ONLINE_READ',
      await cache.readOnlineAuthorized(object) != null,
    );
    clock.atAge(const Duration(days: 15));
    _receipt(
      '${label}_D15_ONLINE_DENIED',
      await cache.readOnlineAuthorized(object) == null,
    );
    clock.atAge(const Duration(days: 15) + millisecond);
    _receipt(
      '${label}_D15_PLUS_ONLINE_DENIED',
      await cache.readOnlineAuthorized(object) == null,
    );
    cache.enterOffline();
    _receipt(
      '${label}_D15_PLUS_OFFLINE_READ_ONLY',
      await cache.readOffline(object) != null &&
          !await cache.saveAuthorized('forbidden-write', {'synthetic': true}),
    );
    clock.atAge(const Duration(days: 20));
    _receipt(
      '${label}_D20_OFFLINE_READ_ONLY',
      await cache.readOffline(object) != null &&
          !await cache.saveAuthorized('forbidden-write', {'synthetic': true}),
    );
    clock.atAge(const Duration(days: 30) - millisecond);
    _receipt(
      '${label}_D30_MINUS_READ_NOT_DUE',
      await cache.readOffline(object) != null &&
          (await cache.purgeExpired()).status == PrivateCachePurgeStatus.notDue,
    );
    clock.atAge(const Duration(days: 30));
    _receipt(
      '${label}_D30_READ_DENIED',
      await cache.readOffline(object) == null,
    );
    clock.atAge(const Duration(days: 30) + millisecond);
    _receipt(
      '${label}_D30_PLUS_READ_DENIED',
      await cache.readOffline(object) == null,
    );
    final deletesBefore = secure.completedDeletes;
    secure.failObjectDelete = failDelete;
    final purge = await cache.purgeExpired();
    final objectPresent = await secure.read(objectKey) != null;
    final manifestPresent = await secure.read(manifestKey) != null;
    _receipt(
      '${label}_ACTUAL_PURGE_${failDelete ? 'FAILURE' : 'SUCCESS'}',
      !cache.isUnlocked &&
          (failDelete
              ? purge.status == PrivateCachePurgeStatus.failed &&
                    objectPresent &&
                    manifestPresent &&
                    secure.injectedFailures == 1 &&
                    secure.completedDeletes == deletesBefore
              : purge.status == PrivateCachePurgeStatus.completed &&
                    !objectPresent &&
                    !manifestPresent &&
                    purge.deletedObjects == 1 &&
                    secure.completedDeletes - deletesBefore == 2),
      {
        'purge_status': purge.status.name,
        'deleted_objects': purge.deletedObjects,
        'native_delete_completions': secure.completedDeletes - deletesBefore,
        'injected_delete_failures': secure.injectedFailures,
        'native_object_present_after': objectPresent,
        'native_manifest_present_after': manifestPresent,
        'locked': !cache.isUnlocked,
      },
    );
    // Failed-delete ciphertext is intentionally retained for independent review.
    if (failDelete) {
      // Synthetic locator only: no T0, credential, content, or unlock material.
      await storage.write(
        _restartPointerKey,
        jsonEncode({'namespace': namespace, 'object_key': objectKey}),
      );
      _receipt('${label}_RESTART_LOCATOR_SAVED', true);
    }
  }

  Future<void> verifyRestartLock() async {
    try {
      final raw = await storage.read(_restartPointerKey);
      if (raw == null) {
        throw const RetentionProbeFailure('RESTART_LOCATOR_MISSING');
      }
      final pointer = jsonDecode(raw) as Map<String, dynamic>;
      final namespace = pointer['namespace'] as String;
      final key = pointer['object_key'] as String;
      if (!RegExp(
            r'^v1015_private:a[1-9][0-9]*:dv1015-r1-probe-'
            r'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}-B$',
          ).hasMatch(namespace) ||
          key != '$namespace:${Uri.encodeComponent(_object)}') {
        throw const RetentionProbeFailure('RESTART_LOCATOR_REJECTED');
      }
      final secure = _ProbeStorage(storage, namespace);
      final fresh = PrivateCacheService.forStorage(secure);
      final nativeObjectPresent = await secure.read(key) != null;
      fresh.enterOffline();
      final readDenied = await fresh.readOffline(_object) == null;
      _receipt(
        'RESTART_FRESH_SERVICE_LOCKED',
        nativeObjectPresent && readDenied && !fresh.isUnlocked,
        {
          'native_object_present': nativeObjectPresent,
          'offline_read_denied': readDenied,
          'locked': !fresh.isUnlocked,
          'anchor_restored': false,
        },
      );
    } catch (error) {
      onReceipt({
        'probe': 'V1015_R1_RETENTION',
        'mode': evidenceMode,
        'REAL_PHYSICAL_ELAPSED': 'NOT_CLAIMED',
        'run_id': runId,
        'stage': 'RESTART_STOPPED',
        'passed': false,
        'reason': error is RetentionProbeFailure ? error.code : 'RUNTIME_ERROR',
      });
    } finally {
      api.close();
    }
  }
}

class _ProbePage extends StatefulWidget {
  const _ProbePage({required this.allowed});
  final bool allowed;
  @override
  State<_ProbePage> createState() => _ProbePageState();
}

class _ProbePageState extends State<_ProbePage> {
  final _receipts = <String>[];
  final _receiptValues = <Map<String, dynamic>>[];
  bool _started = false;
  void _record(Map<String, dynamic> receipt, {required bool restart}) {
    final line = jsonEncode(receipt);
    debugPrint('V1015_R1_RECEIPT $line');
    _receiptValues.add(receipt);
    try {
      final name = restart
          ? 'v1015-r1-probe-restart.json'
          : 'v1015-r1-probe-receipt.json';
      File(
        '${Directory.systemTemp.path}/$name',
      ).writeAsStringSync(jsonEncode(_receiptValues), flush: true);
    } catch (_) {
      // File IO failure is explicit and never prints an exception/body/path.
      debugPrint('V1015_R1_RECEIPT_FILE_WRITE_FAILED');
      if (mounted) {
        setState(() => _receipts.add('RECEIPT_FILE_WRITE_FAILED'));
      }
    }
    if (mounted) setState(() => _receipts.add(line));
  }

  Future<void> _run({bool restart = false}) async {
    if (_started || !widget.allowed) return;
    setState(() => _started = true);
    final runner = RetentionProbeRunner(
      storage: SecureStorageService(),
      api: LocalRetentionProbeApi(),
      onReceipt: (receipt) => _record(receipt, restart: restart),
    );
    if (restart) {
      await runner.verifyRestartLock();
    } else {
      await runner.run();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('R1 retention: ANDROID_TEST_INJECTION')),
    body: Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            'Process clock injection; not 30 elapsed real days. '
            'Local synthetic accounts only. No system clock change.',
          ),
        ),
        ElevatedButton(
          onPressed: widget.allowed && !_started ? () => _run() : null,
          child: Text(widget.allowed ? 'Run test' : 'PROBE_GATE_REJECTED'),
        ),
        ElevatedButton(
          onPressed: widget.allowed && !_started
              ? () => _run(restart: true)
              : null,
          child: const Text('Verify restart lock'),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: SelectableText(_receipts.join('\n')),
          ),
        ),
      ],
    ),
  );
}

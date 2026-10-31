import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_elitesync_module/features/notification/presentation/providers/notification_provider.dart';

class NotificationPreferencesPage extends ConsumerStatefulWidget {
  const NotificationPreferencesPage({super.key});
  @override
  ConsumerState<NotificationPreferencesPage> createState() =>
      _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState
    extends ConsumerState<NotificationPreferencesPage>
    with WidgetsBindingObserver {
  static const labels = {
    'message': '消息',
    'rtc': '通话',
    'match': '匹配',
    'buddy': '搭子',
    'status': '好友动态',
    'platform_event': '平台活动',
    'safety_case': '本人安全案卷',
    'system': '系统',
  };
  Map<String, bool>? _categories;
  bool _silent = false;
  bool _busy = false;
  PermissionStatus? _permission;
  String? _error;

  String? get _identity => ref.read(sessionProvider).asData?.value.accessToken;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(_load);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() => _categories = null);
      _load();
    }
  }

  Future<void> _load() async {
    if (!mounted) return;
    final identity = _identity;
    if (identity == null) return;
    final p = await Permission.notification.status;
    if (!mounted || identity != _identity) return;
    final reply = await ref
        .read(apiClientProvider)
        .get('/api/v1/notification-preferences');
    if (!mounted || identity != _identity) return;
    setState(() {
      _permission = p;
      if (reply is NetworkSuccess<Map<String, dynamic>>) {
        final c = reply.data['categories'] as Map? ?? {};
        _categories = {for (final key in labels.keys) key: c[key] == true};
        _silent = reply.data['silent'] == true;
        _error = null;
      } else {
        _categories = null;
        _error = '无法验证当前通知设置，请联网重试。';
      }
    });
  }

  Future<void> _save({String? category, bool? enabled, bool? silent}) async {
    if (_busy) return;
    final identity = _identity;
    setState(() => _busy = true);
    final result = await ref
        .read(apiClientProvider)
        .put(
          '/api/v1/notification-preferences',
          body: {
            if (category != null) 'categories': {category: enabled},
            'silent': ?silent,
          },
        );
    if (!mounted || identity != _identity) return;
    setState(() {
      _busy = false;
      _error = result is NetworkSuccess ? null : '保存未完成，请重试。';
    });
    ref.invalidate(notificationListProvider);
    ref.invalidate(notificationUnreadCountProvider);
    await _load();
  }

  Future<void> _requestPermission() async {
    final identity = _identity;
    final result = await Permission.notification.request();
    if (!mounted || identity != _identity) return;
    setState(() => _permission = result);
    // There is no approved provider/token: OS permission never fabricates registration.
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionProvider, (previous, next) {
      if (previous?.asData?.value.accessToken == next.asData?.value.accessToken) return;
      setState(() { _categories = null; _busy = false; _permission = null; _error = null; });
      if (next.asData?.value.isLoggedIn == true) Future.microtask(_load);
    });
    ref.watch(sessionProvider);
    if (_identity == null) {
      return const Scaffold(body: Center(child: Text('请重新登录')));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('通知设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('锁屏通知仅显示“请打开应用查看当前有权通知”。打开后重新验证权限。'),
          ListTile(
            title: const Text('系统通知权限'),
            subtitle: Text(
              _permission?.isGranted == true ? '已允许' : '未允许；消息和安全入口仍可使用',
            ),
            trailing: TextButton(
              onPressed: _requestPermission,
              child: const Text('请求授权'),
            ),
          ),
          const Text('真实推送服务尚未启用，后台和锁屏远端送达未验证。'),
          if (_error != null)
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          if (_categories == null)
            TextButton(onPressed: _load, child: const Text('重新读取设置'))
          else ...[
            SwitchListTile(
              title: const Text('静默提醒'),
              subtitle: const Text('保留站内记录，暂停外部提醒'),
              value: _silent,
              onChanged: _busy ? null : (v) => _save(silent: v),
            ),
            for (final e in labels.entries)
              SwitchListTile(
                title: Text(e.value),
                value: _categories![e.key]!,
                onChanged: _busy
                    ? null
                    : (v) => _save(category: e.key, enabled: v),
              ),
          ],
        ],
      ),
    );
  }
}

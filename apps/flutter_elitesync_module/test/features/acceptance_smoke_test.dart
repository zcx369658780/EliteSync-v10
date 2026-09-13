import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/pages/chat_room_page.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/chat_route_state.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/pages/conversation_list_page.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/widgets/conversation_list_item.dart';
import 'package:flutter_elitesync_module/features/home/presentation/pages/home_page.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class FakeLocalStorageService extends LocalStorageService {
  FakeLocalStorageService([Map<String, Object?>? initialValues]) {
    _values.addAll(initialValues ?? const {});
  }

  final Map<String, Object?> _values = {};

  @override
  Future<bool> setString(String key, String value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<String?> getString(String key) async {
    final value = _values[key];
    return value is String ? value : null;
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool?> getBool(String key) async {
    final value = _values[key];
    return value is bool ? value : null;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<int?> getInt(String key) async {
    final value = _values[key];
    return value is int ? value : null;
  }

  @override
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<Map<String, dynamic>?> getJson(String key) async {
    final value = _values[key];
    return value is Map<String, dynamic> ? value : null;
  }

  @override
  Future<bool> remove(String key) async {
    _values.remove(key);
    return true;
  }
}

Widget _wrap(Widget child, {Iterable<dynamic> overrides = const []}) {
  return ProviderScope(
    overrides: [
      appEnvProvider.overrideWithValue(
        const AppEnv(
          flavor: AppFlavor.dev,
          appName: 'EliteSync Dev',
          apiBaseUrl: 'http://101.133.161.203',
          useMockData: true,
          useMockHome: true,
          useMockMatch: true,
          useMockChat: true,
        ),
      ),
      localStorageProvider.overrideWithValue(FakeLocalStorageService()),
      ...overrides,
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      home: child,
    ),
  );
}

void main() {
  testWidgets('home page renders current slow-date entry', (tester) async {
    await tester.pumpWidget(_wrap(const HomePage()));
    await tester.pumpAndSettle();

    expect(find.text('首页'), findsOneWidget);
    expect(find.text('从这里查看慢约进展。'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('e1-home-primary-match-cta')),
      findsOneWidget,
    );
    expect(find.text('查看慢约进展'), findsOneWidget);
  });

  testWidgets('conversation list page renders mock conversations', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const ConversationListPage()));
    await tester.pumpAndSettle();

    expect(find.text('晨雾'), findsOneWidget);
    expect(find.text('九紫瑶瑶'), findsOneWidget);
    expect(find.byType(ConversationListItem), findsNWidgets(2));
  });

  testWidgets('chat room page renders mock thread and safety menu', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        ChatRoomPage(
          routeState: ChatRouteState.legacyPeer(peerUserId: 1, title: '晨雾'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('晨雾'), findsOneWidget);
    expect(find.text('选择图片 / 视频'), findsWidgets);

    await tester.tap(find.byTooltip('安全'));
    await tester.pumpAndSettle();

    expect(find.text('举报 / 拉黑'), findsOneWidget);
  });
}

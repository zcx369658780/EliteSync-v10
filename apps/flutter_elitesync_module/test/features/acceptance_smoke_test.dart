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
  testWidgets('home page renders the calm state hub', (tester) async {
    await tester.pumpWidget(_wrap(const HomePage()));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('home-area-current-state')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('home-area-next-decision')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('home-primary-next-decision')),
      findsOneWidget,
    );
  });

  testWidgets('conversation list stays closed without message authority', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const ConversationListPage()));
    await tester.pumpAndSettle();

    expect(find.text('消息权限尚未建立'), findsOneWidget);
    expect(find.text('晨雾'), findsNothing);
    expect(find.text('九紫瑶瑶'), findsNothing);
    expect(find.byType(ConversationListItem), findsNothing);
  });

  testWidgets('legacy peer route stays closed without message authority', (
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

    expect(find.text('消息权限尚未建立'), findsOneWidget);
    expect(find.text('晨雾'), findsNothing);
    expect(find.text('选择图片 / 视频'), findsNothing);
    expect(find.byTooltip('安全'), findsNothing);
  });
}

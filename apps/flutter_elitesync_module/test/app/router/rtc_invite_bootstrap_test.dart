import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/app/router/rtc_invite_coordinator.dart';
import 'package:flutter_elitesync_module/features/notification/domain/entities/notification_item_entity.dart';
import 'package:flutter_elitesync_module/features/notification/presentation/providers/notification_provider.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/entities/rtc_session_entity.dart';
import 'package:flutter_elitesync_module/features/rtc/presentation/providers/rtc_providers.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestSession extends SessionNotifier {
  @override
  Future<SessionState> build() async =>
      const SessionState(status: AuthStatus.unauthenticated);

  void login() => state = const AsyncData(
    SessionState(
      status: AuthStatus.authenticated,
      user: UserSummary(id: 3, phone: 'fictional-test'),
    ),
  );

  void logout() =>
      state = const AsyncData(SessionState(status: AuthStatus.unauthenticated));
}

Future<void> _mount(WidgetTester tester, ProviderContainer container) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: Consumer(
        builder: (_, ref, child) {
          ref.watch(rtcInviteBootstrapProvider);
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  await tester.pump();
}

Future<void> _close(WidgetTester tester, ProviderContainer container) async {
  await tester.pumpWidget(const SizedBox.shrink());
  container.dispose();
  await tester.pump(const Duration(seconds: 9));
}

void main() {
  testWidgets('cold login starts polling without a process restart', (
    tester,
  ) async {
    var calls = 0;
    var notifications = 0;
    final container = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith(_TestSession.new),
        rtcCallsProvider.overrideWith((ref) async {
          calls++;
          return <RtcSessionEntity>[];
        }),
        notificationListProvider.overrideWith((ref) async {
          notifications++;
          return <NotificationItemEntity>[];
        }),
      ],
    );
    await _mount(tester, container);
    await tester.pump(const Duration(seconds: 4));
    expect(calls, 0);
    expect(notifications, 0);
    (container.read(sessionProvider.notifier) as _TestSession).login();
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(calls, 1);
    expect(notifications, 1);
    await _close(tester, container);
  });

  testWidgets('a stuck notification future releases the next call scan', (
    tester,
  ) async {
    var calls = 0;
    final pending = Completer<List<NotificationItemEntity>>();
    final container = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith(_TestSession.new),
        rtcCallsProvider.overrideWith((ref) async {
          calls++;
          return <RtcSessionEntity>[];
        }),
        notificationListProvider.overrideWith((ref) => pending.future),
      ],
    );
    await _mount(tester, container);
    (container.read(sessionProvider.notifier) as _TestSession).login();
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(calls, 1);
    await tester.pump(const Duration(seconds: 8));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(calls, greaterThan(1));
    await _close(tester, container);
  });

  testWidgets('an old signed-out scan cannot continue into notifications', (
    tester,
  ) async {
    final pending = Completer<List<RtcSessionEntity>>();
    var notifications = 0;
    final container = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith(_TestSession.new),
        rtcCallsProvider.overrideWith((ref) => pending.future),
        notificationListProvider.overrideWith((ref) async {
          notifications++;
          return <NotificationItemEntity>[];
        }),
      ],
    );
    await _mount(tester, container);
    final session = container.read(sessionProvider.notifier) as _TestSession;
    session.login();
    await tester.pump(const Duration(seconds: 2));
    session.logout();
    pending.complete(<RtcSessionEntity>[]);
    await tester.pump();
    expect(notifications, 0);
    await _close(tester, container);
  });
}

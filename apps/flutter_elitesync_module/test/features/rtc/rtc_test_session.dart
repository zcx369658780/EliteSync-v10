import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';

class RtcTestSession extends SessionNotifier {
  static SessionState member(int id) => SessionState(
    status: AuthStatus.authenticated,
    accessToken: 'rtc-fixture-$id',
    user: UserSummary(id: id, phone: ''),
  );
  @override
  Future<SessionState> build() async => member(1);
  void change(int id) => state = AsyncData(member(id));
  void logout() =>
      state = const AsyncData(SessionState(status: AuthStatus.unauthenticated));
}

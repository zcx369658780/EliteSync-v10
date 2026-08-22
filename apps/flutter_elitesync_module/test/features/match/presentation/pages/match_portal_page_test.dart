import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_round_projection.dart';
import 'package:flutter_elitesync_module/features/match/presentation/pages/match_portal_page.dart';
import 'package:flutter_elitesync_module/features/match/presentation/providers/match_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

void main() {
  testWidgets('ordinary Match portal always selects canonical projection', (
    tester,
  ) async {
    final now = DateTime.now().toUtc();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvProvider.overrideWithValue(
            const AppEnv(
              flavor: AppFlavor.prod,
              appName: 'test',
              apiBaseUrl: 'http://127.0.0.1/',
              useMockData: false,
              useMockMatch: false,
              useMatchRoundContract: false,
            ),
          ),
          matchRoundProjectionProvider.overrideWith(
            (ref) async => MatchRoundProjection(
              state: MatchRoundBusinessState.noRound,
              serverTime: now,
              receivedAt: now,
              contractVersion: 'match_round_v2',
              retryEligible: false,
              userAction: 'wait_next_round',
              projectionVersion: 1,
              updatedAt: now,
            ),
          ),
          matchCountdownProvider.overrideWith(
            (ref) => throw StateError('legacy countdown must be unreachable'),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MatchPortalPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('当前没有进行中的慢约会'), findsOneWidget);
    expect(find.text('本周慢约会倒计时'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

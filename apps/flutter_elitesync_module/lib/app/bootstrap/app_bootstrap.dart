import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/app/app.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/router/rtc_invite_coordinator.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

Future<void> runEliteSyncApp(
  AppEnv env, {
  LocalStorageService? localStorage,
  void Function(Widget)? launch,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  // CACHE-01 prevents old values from being shown if this attempt fails.
  await (localStorage ?? LocalStorageService())
      .tryPurgeLegacyPrivateChatCache();
  (launch ?? runApp)(
    ProviderScope(
      overrides: [appEnvProvider.overrideWithValue(env)],
      child: Consumer(
        builder: (context, ref, child) {
          if (env.useLiveKitRtc) {
            ref.watch(rtcInviteBootstrapProvider);
          }
          return child ?? const SizedBox.shrink();
        },
        child: const EliteSyncApp(),
      ),
    ),
  );
}

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/design_system/components/feedback/app_confirm_dialog.dart';
import 'package:flutter_elitesync_module/design_system/components/feedback/app_feedback.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/pending_logout_store.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

Future<void> confirmAccountLogout(BuildContext context, WidgetRef ref) async {
  final notifier = ref.read(sessionProvider.notifier);
  final originalIntent = notifier.currentAuthenticationIntent;
  final originalToken = ref.read(sessionProvider).asData?.value.accessToken;
  final confirmed = await AppConfirmDialog.show(
    context,
    title: '退出登录',
    message: '退出后将返回登录页，需要重新输入账号和密码。',
    confirmLabel: '退出',
    cancelLabel: '取消',
    destructive: true,
  );
  if (!confirmed || !context.mounted) return;
  final token = ref.read(sessionProvider).asData?.value.accessToken;
  if (token != originalToken ||
      !notifier.isCurrentAuthentication(originalIntent)) {
    return;
  }
  final revocationCredential =
      ref.read(sessionProvider).asData?.value.refreshToken ?? token;
  final secure = ref.read(secureStorageProvider);
  final client = ref.read(restrictedAccountClientProvider);
  final container = ProviderScope.containerOf(context, listen: false);
  try {
    if (revocationCredential != null) {
      await PendingLogoutStore.add(secure, revocationCredential);
    }
  } catch (_) {
    if (context.mounted) {
      AppFeedback.showError(context, '无法安全保存待撤销凭据，尚未退出。请重试。');
    }
    return;
  }
  if (!notifier.isCurrentAuthentication(originalIntent) ||
      container.read(sessionProvider).asData?.value.accessToken != token) {
    return;
  }
  final localLogout = notifier.setUnauthenticated(
    notice: '本机已退出；服务端撤销尚未确认，正在后台尝试。可在账号安全中重试未完成撤销。',
    rejectedToken: token,
  );
  final logoutIntent = notifier.currentAuthenticationIntent;
  await localLogout;
  // Capture all dependencies before navigation. Background work must never
  // read a disposed widget ref or inherit a later account's credentials.
  unawaited(() async {
    if (revocationCredential == null) return;
    try {
      final result = await client.post(
        '/api/v1/auth/logout',
        options: Options(
          headers: {'Authorization': 'Bearer $revocationCredential'},
        ),
      );
      if (result is NetworkSuccess<Map<String, dynamic>> &&
          result.data['ok'] == true &&
          result.data['status'] == 'SESSION_REVOKED') {
        await PendingLogoutStore.remove(secure, revocationCredential);
        notifier.confirmServerLogout(logoutIntent);
      }
    } catch (_) {
      /* The secure queue remains available for recovery. */
    }
  }());
  unawaited(() async {
    try {
      const channel = MethodChannel('elitesync/bootstrap');
      await channel.invokeMethod<void>('clearBootstrap');
    } catch (_) {}
  }());
  if (context.mounted &&
      container.read(sessionProvider).asData?.value.isLoggedIn != true) {
    context.go(AppRouteNames.login);
  }
}

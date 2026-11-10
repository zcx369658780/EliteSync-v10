import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class RtcPermissionService {
  Future<bool> ensureVoiceCallPermission();
  Future<bool> openSettings();
  Future<bool> hasVoiceCallPermission();
}

class PermissionHandlerRtcPermissionService implements RtcPermissionService {
  const PermissionHandlerRtcPermissionService();

  @override
  Future<bool> ensureVoiceCallPermission() async {
    final currentStatus = await Permission.microphone.status;
    if (currentStatus.isGranted) {
      return true;
    }
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      return true;
    }
    final refreshedStatus = await Permission.microphone.status;
    return refreshedStatus.isGranted;
  }

  Future<bool> ensureCameraPermission() async {
    final currentStatus = await Permission.camera.status;
    if (currentStatus.isGranted) return true;
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  @override
  Future<bool> openSettings() => openAppSettings();

  @override
  Future<bool> hasVoiceCallPermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }
}

final rtcPermissionServiceProvider = Provider<RtcPermissionService>((ref) {
  return const PermissionHandlerRtcPermissionService();
});

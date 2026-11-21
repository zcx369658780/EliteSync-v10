import 'package:flutter_elitesync_module/core/storage/secure_storage_service.dart';
import 'package:flutter_elitesync_module/core/storage/private_cache_service.dart';
class SyntheticPrivateStore extends SecureStorageService {
  final values=<String,String>{};
  @override Future<String?> read(String key) async=>values[key];
  @override Future<void> write(String key,String value) async { values[key]=value; }
  @override Future<void> delete(String key) async { values.remove(key); }
}
Future<SyntheticPrivateStore> syntheticPrivateLogin() async {
 final secure=SyntheticPrivateStore();final now=DateTime.now().toUtc();
 await PrivateCacheService.forStorage(secure).establishLogin(userId:1,retention:{
 'user_id':1,'device_id':'synthetic-widget-device','session_id':1,
 'login_at':now.toIso8601String(),'server_now':now.toIso8601String(),
 'online_expires_at':now.add(const Duration(days:15)).toIso8601String(),
 'purge_at':now.add(const Duration(days:30)).toIso8601String()});
 return secure;
}

Map<String, dynamic> syntheticOfflineTextGrant(String roomKey, {int peerId=2}) {
  final now = DateTime.now().toUtc();
  return {
    'scope': 'conversation_text_v1',
    'account_id': 1,
    'peer_id': peerId,
    'session_id': '1',
    'device_id': 'synthetic-widget-device',
    'room_key': roomKey,
    'issued_at': now.toIso8601String(),
    'expires_at': now.add(const Duration(hours: 24)).toIso8601String(),
  };
}

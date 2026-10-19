import 'dart:convert';
import 'package:flutter_elitesync_module/core/storage/secure_storage_service.dart';

/// Serialized read/modify/write preserves pending families across account changes.
class PendingLogoutStore {
  static Future<void> _mutation = Future.value();
  static Future<T> _locked<T>(Future<T> Function() work) {
    final next = _mutation.then((_) => work());
    _mutation = next.then<void>((_) {}, onError: (Object _) {});
    return next;
  }

  static Future<List<String>> _read(SecureStorageService storage) async {
    final raw = await storage.read('pending_logout_credentials');
    final values = raw == null
        ? <String>[]
        : (jsonDecode(raw) as List).cast<String>();
    final legacy = await storage.read('pending_logout_token');
    if (legacy != null && !values.contains(legacy)) values.add(legacy);
    return values;
  }

  static Future<List<String>> read(SecureStorageService storage) =>
      _locked(() => _read(storage));
  static Future<void> add(SecureStorageService storage, String token) =>
      _locked(() async {
        final values = await _read(storage);
        if (!values.contains(token)) values.add(token);
        await storage.write('pending_logout_credentials', jsonEncode(values));
        await storage.delete('pending_logout_token');
      });
  static Future<void> remove(SecureStorageService storage, String token) =>
      _locked(() async {
        final values = (await _read(storage))..remove(token);
        await storage.write('pending_logout_credentials', jsonEncode(values));
        await storage.delete('pending_logout_token');
      });
}

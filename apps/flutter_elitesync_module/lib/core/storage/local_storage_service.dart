import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/storage/secure_storage_service.dart';
import 'package:flutter_elitesync_module/core/storage/private_cache_service.dart';

class LocalStorageService {
  LocalStorageService({SecureStorageService? secureStorage})
    : _privateCache = secureStorage == null
          ? null
          : PrivateCacheService.forStorage(secureStorage);

  final PrivateCacheService? _privateCache;
  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<bool> setString(String key, String value) async {
    if (CacheKeys.isPrivate(key)) {
      return await _privateCache?.saveAuthorized('preference:$key', {
            'text': value,
          }) ??
          false;
    }
    final prefs = await _prefs;
    return prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    if (CacheKeys.isPrivate(key)) {
      final cache = _privateCache;
      if (cache == null) return null;
      final value = cache.isOffline
          ? await cache.readOffline('preference:$key')
          : await cache.readOnlineAuthorized('preference:$key');
      return value?['text'] as String?;
    }
    final prefs = await _prefs;
    return prefs.getString(key);
  }

  Future<bool> setBool(String key, bool value) async {
    if (CacheKeys.isPrivate(key)) return false;
    final prefs = await _prefs;
    return prefs.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    if (CacheKeys.isPrivate(key)) return null;
    final prefs = await _prefs;
    return prefs.getBool(key);
  }

  Future<bool> setInt(String key, int value) async {
    if (CacheKeys.isPrivate(key)) return false;
    final prefs = await _prefs;
    return prefs.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    if (CacheKeys.isPrivate(key)) return null;
    final prefs = await _prefs;
    return prefs.getInt(key);
  }

  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    final encoded = jsonEncode(value);
    return setString(key, encoded);
  }

  Future<Map<String, dynamic>?> getJson(String key) async {
    final raw = await getString(key);
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return null;
  }

  Future<bool> remove(String key) async {
    if (CacheKeys.isPrivate(key)) {
      await _privateCache?.removeObject('preference:$key');
    }
    final prefs = await _prefs;
    return prefs.remove(key);
  }

  /// Finite, name-only cleanup of the identified old unencrypted private keys.
  /// No old private value is read or migrated into a newly logged-in account.
  Future<bool> purgeLegacyPrivateCache() async {
    try {
      for (final key in (await getKeys()).where(CacheKeys.isPrivate).toList()) {
        if (!await remove(key) || (await getKeys()).contains(key)) return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Set<String>> getKeys() async {
    final prefs = await _prefs;
    return prefs.getKeys();
  }

  /// Removes only the identified legacy plaintext chat keys. No values are read.
  Future<void> purgeLegacyPrivateChatCache() async {
    late final Set<String> keys;
    try {
      keys = await getKeys();
    } catch (_) {
      throw StateError('Legacy private cache cleanup failed');
    }
    final targets = keys
        .where(
          (key) =>
              key.startsWith(CacheKeys.chatDraftPrefix) ||
              key == CacheKeys.messagesConversationSnapshot ||
              key == CacheKeys.messagesSearchHistory,
        )
        .toList();
    var failed = false;
    for (final key in targets) {
      try {
        if (!await remove(key)) failed = true;
      } catch (_) {
        failed = true;
      }
    }
    if (failed) throw StateError('Legacy private cache cleanup failed');
  }

  /// Reports a finite failure without blocking an existing account transition.
  Future<bool> tryPurgeLegacyPrivateChatCache() async {
    try {
      await purgeLegacyPrivateChatCache();
      return true;
    } catch (_) {
      debugPrint('Legacy private cache cleanup failed; retry at next boundary');
      return false;
    }
  }

  Future<bool> clear() async {
    final prefs = await _prefs;
    return prefs.clear();
  }
}

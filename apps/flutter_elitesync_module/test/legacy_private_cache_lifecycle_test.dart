import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/core/storage/secure_storage_service.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

class _SecureStore extends SecureStorageService {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }
}

class _FailingCleanupStore extends LocalStorageService {
  @override
  Future<void> purgeLegacyPrivateChatCache() async {
    throw StateError('synthetic cleanup failure');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('direct setUnauthenticated purges identified legacy values', () async {
    SharedPreferences.setMockInitialValues({
      '${CacheKeys.chatDraftPrefix}peer': 'synthetic',
      CacheKeys.messagesConversationSnapshot: 'synthetic',
      CacheKeys.messagesSelectedTab: 2,
    });
    final secure = _SecureStore();
    secure.values[CacheKeys.accessToken] = 'synthetic token';
    final container = ProviderContainer(
      overrides: [
        secureStorageProvider.overrideWithValue(secure),
        localStorageProvider.overrideWithValue(LocalStorageService()),
      ],
    );
    addTearDown(container.dispose);
    await container.read(sessionProvider.future);
    await container.read(sessionProvider.notifier).setUnauthenticated();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('${CacheKeys.chatDraftPrefix}peer'), isFalse);
    expect(prefs.containsKey(CacheKeys.messagesConversationSnapshot), isFalse);
    expect(prefs.getInt(CacheKeys.messagesSelectedTab), 2);
    expect(secure.values.containsKey(CacheKeys.accessToken), isFalse);
  });

  test('direct setAuthenticated purges before session replacement', () async {
    SharedPreferences.setMockInitialValues({
      '${CacheKeys.chatDraftPrefix}conversation': 'synthetic',
      CacheKeys.messagesSearchHistory: 'synthetic',
    });
    final secure = _SecureStore();
    final container = ProviderContainer(
      overrides: [
        secureStorageProvider.overrideWithValue(secure),
        localStorageProvider.overrideWithValue(LocalStorageService()),
      ],
    );
    addTearDown(container.dispose);
    await container.read(sessionProvider.future);
    await container
        .read(sessionProvider.notifier)
        .setAuthenticated(accessToken: 'synthetic token');
    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.containsKey('${CacheKeys.chatDraftPrefix}conversation'),
      isFalse,
    );
    expect(prefs.containsKey(CacheKeys.messagesSearchHistory), isFalse);
    expect(secure.values[CacheKeys.accessToken], 'synthetic token');
  });

  test('failed cleanup does not prevent direct session invalidation', () async {
    SharedPreferences.setMockInitialValues({});
    final secure = _SecureStore();
    secure.values[CacheKeys.accessToken] = 'synthetic token';
    final container = ProviderContainer(
      overrides: [
        secureStorageProvider.overrideWithValue(secure),
        localStorageProvider.overrideWithValue(_FailingCleanupStore()),
      ],
    );
    addTearDown(container.dispose);
    await container.read(sessionProvider.future);
    await container.read(sessionProvider.notifier).setUnauthenticated();
    expect(secure.values.containsKey(CacheKeys.accessToken), isFalse);
    expect(container.read(sessionProvider).value?.isLoggedIn, isFalse);
  });

  test('failed cleanup does not block direct session replacement', () async {
    SharedPreferences.setMockInitialValues({});
    final secure = _SecureStore();
    final container = ProviderContainer(
      overrides: [
        secureStorageProvider.overrideWithValue(secure),
        localStorageProvider.overrideWithValue(_FailingCleanupStore()),
      ],
    );
    addTearDown(container.dispose);
    await container.read(sessionProvider.future);
    await container
        .read(sessionProvider.notifier)
        .setAuthenticated(accessToken: 'new synthetic token');
    expect(secure.values[CacheKeys.accessToken], 'new synthetic token');
    expect(container.read(sessionProvider).value?.isLoggedIn, isTrue);
  });
}

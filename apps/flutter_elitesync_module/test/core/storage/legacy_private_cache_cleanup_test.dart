import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';

class _FailOnceStorage extends LocalStorageService {
  _FailOnceStorage(this.failedKey);

  final String failedKey;
  bool shouldFail = true;

  @override
  Future<bool> remove(String key) async {
    if (key == failedKey && shouldFail) {
      shouldFail = false;
      return false;
    }
    return super.remove(key);
  }
}

class _ThrowOnceStorage extends LocalStorageService {
  bool shouldThrow = true;

  @override
  Future<bool> remove(String key) async {
    if (shouldThrow) {
      shouldThrow = false;
      throw StateError('synthetic remove failure');
    }
    return super.remove(key);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('purges exact legacy keys and preserves unrelated values', () async {
    SharedPreferences.setMockInitialValues({
      '${CacheKeys.chatDraftPrefix}peer_1': 'synthetic draft',
      '${CacheKeys.chatDraftPrefix}conversation_2': 42,
      CacheKeys.chatDraftPrefix: false,
      CacheKeys.messagesConversationSnapshot: ['malformed', 'legacy'],
      CacheKeys.messagesSearchHistory: 7,
      'not_${CacheKeys.chatDraftPrefix}peer_1': 'keep',
      CacheKeys.lastKnownProfile: 'profile sentinel',
      CacheKeys.accessToken: 'token sentinel',
      CacheKeys.messagesSelectedTab: 3,
      CacheKeys.homeFeedSnapshot: 'other cache',
    });
    final storage = LocalStorageService();
    await storage.purgeLegacyPrivateChatCache();
    final prefs = await SharedPreferences.getInstance();
    for (final key in [
      '${CacheKeys.chatDraftPrefix}peer_1',
      '${CacheKeys.chatDraftPrefix}conversation_2',
      CacheKeys.chatDraftPrefix,
      CacheKeys.messagesConversationSnapshot,
      CacheKeys.messagesSearchHistory,
    ]) {
      expect(prefs.containsKey(key), isFalse);
    }
    expect(prefs.getString('not_${CacheKeys.chatDraftPrefix}peer_1'), 'keep');
    expect(prefs.getString(CacheKeys.lastKnownProfile), 'profile sentinel');
    expect(prefs.getString(CacheKeys.accessToken), 'token sentinel');
    expect(prefs.getInt(CacheKeys.messagesSelectedTab), 3);
    expect(prefs.getString(CacheKeys.homeFeedSnapshot), 'other cache');
    await storage.purgeLegacyPrivateChatCache();
  });

  test('empty storage and repeated calls are safe', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService();
    await storage.purgeLegacyPrivateChatCache();
    await storage.purgeLegacyPrivateChatCache();
    expect((await SharedPreferences.getInstance()).getKeys(), isEmpty);
  });

  test('a false removal reports failure and retries remaining key', () async {
    SharedPreferences.setMockInitialValues({
      CacheKeys.messagesConversationSnapshot: 'synthetic',
      '${CacheKeys.chatDraftPrefix}peer': 'synthetic',
    });
    final storage = _FailOnceStorage(CacheKeys.messagesConversationSnapshot);
    expect(await storage.tryPurgeLegacyPrivateChatCache(), isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey(CacheKeys.messagesConversationSnapshot), isTrue);
    expect(await storage.tryPurgeLegacyPrivateChatCache(), isTrue);
    expect(prefs.containsKey(CacheKeys.messagesConversationSnapshot), isFalse);
    expect(prefs.containsKey('${CacheKeys.chatDraftPrefix}peer'), isFalse);
  });

  test(
    'a removal exception reports failure without exposing the key',
    () async {
      SharedPreferences.setMockInitialValues({
        '${CacheKeys.chatDraftPrefix}conversation': 17,
      });
      final storage = _ThrowOnceStorage();
      await expectLater(
        storage.purgeLegacyPrivateChatCache(),
        throwsA(
          predicate(
            (error) =>
                error is StateError &&
                !error.toString().contains('conversation') &&
                !error.toString().contains('synthetic remove failure'),
          ),
        ),
      );
      await storage.purgeLegacyPrivateChatCache();
      expect(
        (await SharedPreferences.getInstance()).containsKey(
          '${CacheKeys.chatDraftPrefix}conversation',
        ),
        isFalse,
      );
    },
  );
}

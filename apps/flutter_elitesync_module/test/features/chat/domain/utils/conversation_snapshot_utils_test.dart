import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/conversation_entity.dart';
import 'package:flutter_elitesync_module/features/chat/domain/utils/conversation_snapshot_utils.dart';
import 'package:flutter_elitesync_module/features/chat/domain/utils/message_visibility_utils.dart';

void main() {
  test('sanitizeConversationSnapshot drops non-numeric ids in prod mode', () {
    const items = [
      ConversationEntity(
        id: 'c001',
        name: '晨雾',
        lastMessage: '图片消息',
        lastTime: '10:18',
        unread: 2,
      ),
      ConversationEntity(
        id: '38',
        name: '九紫瑶瑶',
        lastMessage: '你好',
        lastTime: '昨天',
        unread: 0,
      ),
    ];

    final sanitized = sanitizeConversationSnapshot(items, allowMockIds: false);

    expect(sanitized, hasLength(1));
    expect(sanitized.single.id, '38');
  });

  test('sanitizeConversationSnapshot keeps mock ids in mock mode', () {
    const items = [
      ConversationEntity(
        id: 'c001',
        name: '晨雾',
        lastMessage: '图片消息',
        lastTime: '10:18',
        unread: 2,
      ),
      ConversationEntity(
        id: '38',
        name: '九紫瑶瑶',
        lastMessage: '你好',
        lastTime: '昨天',
        unread: 0,
      ),
    ];

    final sanitized = sanitizeConversationSnapshot(items, allowMockIds: true);

    expect(sanitized, hasLength(2));
  });

  test('snapshot round trip preserves stored and eligible typed identity', () {
    const stored = ConversationEntity(
      id: '23',
      name: 'Stored',
      lastMessage: 'hello',
      lastTime: 'now',
      unread: 1,
      entryKind: 'stored_conversation',
      conversationId: 41,
      peerUserId: 23,
      matchId: 7,
    );
    const eligible = ConversationEntity(
      id: '24',
      name: 'Eligible',
      lastMessage: '',
      lastTime: '',
      unread: 0,
      entryKind: 'eligible_match',
      peerUserId: 24,
      matchId: 8,
    );

    final restoredStored = decodeConversationSnapshotItem(
      encodeConversationSnapshotItem(stored),
    );
    final restoredEligible = decodeConversationSnapshotItem(
      encodeConversationSnapshotItem(eligible),
    );

    expect(restoredStored.entryKind, 'stored_conversation');
    expect(restoredStored.conversationId, 41);
    expect(restoredStored.peerUserId, 23);
    expect(restoredStored.matchId, 7);
    expect(restoredEligible.entryKind, 'eligible_match');
    expect(restoredEligible.conversationId, isNull);
    expect(restoredEligible.peerUserId, 24);
    expect(restoredEligible.matchId, 8);
  });

  test('old snapshot falls back to explicit legacy peer identity', () {
    final restored = decodeConversationSnapshotItem({
      'id': '23',
      'name': 'Legacy',
      'lastMessage': '',
      'lastTime': '',
      'unread': 0,
    });

    expect(restored.entryKind, 'legacy_peer');
    expect(restored.conversationId, isNull);
    expect(restored.peerUserId, 23);
    expect(restored.matchId, isNull);
  });

  test('displayChatPreviewText neutralizes exact engineering messages', () {
    expect(displayChatPreviewText('556'), '示例消息');
    expect(displayChatPreviewText('我也喜欢慢节奏散步。'), '我也喜欢慢节奏散步。');
  });
}

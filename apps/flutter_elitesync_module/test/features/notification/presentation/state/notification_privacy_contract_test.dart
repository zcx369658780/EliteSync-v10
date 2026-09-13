import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/features/notification/domain/entities/notification_item_entity.dart';
import 'package:flutter_elitesync_module/features/notification/presentation/state/notification_privacy_contract.dart';

void main() {
  const privateItem = NotificationItemEntity(
    id: 1,
    kind: 'message',
    title: 'Synthetic peer name',
    body: 'Synthetic private message',
    payload: {'candidate_id': 42, 'match_result': 'synthetic'},
    routeName: 'chat_room',
    routeArgs: {'conversation_id': 9},
    isRead: false,
    createdAt: '2026-09-13T00:00:00Z',
  );

  test('external notification preview is generic regardless of payload', () {
    final preview = NotificationPrivacyContract.externalPreviewFor(privateItem);

    expect(preview.audience, NotificationPresentationAudience.external);
    expect(preview.title, 'EliteSync 有新提醒');
    expect(preview.body, '打开应用查看详情');
    expect(preview.title, isNot(contains('peer')));
    expect(preview.body, isNot(contains('private message')));
  });

  test('in-app list also fails closed without owning-surface authority', () {
    final preview = NotificationPrivacyContract.inAppPreviewFor(privateItem);

    expect(preview.audience, NotificationPresentationAudience.inApp);
    expect(preview.title, '有一条新提醒');
    expect(preview.body, contains('重新检查访问权限'));
    expect(preview.title, isNot(privateItem.title));
    expect(preview.body, isNot(privateItem.body));
  });

  test('external forbidden information registry is complete', () {
    expect(
      NotificationPrivacyContract.forbiddenExternalInformation,
      hasLength(7),
    );
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/features/notification/domain/entities/notification_item_entity.dart';
import 'package:flutter_elitesync_module/features/notification/presentation/state/notification_privacy_contract.dart';

const _id = '00000000-0000-4000-8000-000000000014';

NotificationItemEntity _item(String kind, Map<String, dynamic> payload) =>
    NotificationItemEntity(
      id: 14,
      kind: kind,
      title: 'PRIVATE_SAFETY_OR_EVENT_TITLE',
      body: 'PRIVATE_FINDING_OR_EVENT_BODY',
      payload: payload,
      routeName: 'settings',
      routeArgs: const {},
      isRead: false,
      createdAt: '2026-10-21T00:00:00Z',
    );

void main() {
  for (final kind in ['platform_event', 'safety_case']) {
    final key = kind == 'platform_event'
        ? 'platform_event_id'
        : 'safety_case_id';
    test('$kind locates only its own UUID key and keeps previews generic', () {
      final item = _item(kind, {key: _id, 'body': 'PRIVATE_EXTRA'});
      expect(
        NotificationPrivacyContract.isPlatformControlledKind(kind),
        isTrue,
      );
      expect(NotificationPrivacyContract.platformControlledTarget(item), _id);
      final external = NotificationPrivacyContract.externalPreviewFor(item);
      final inside = NotificationPrivacyContract.inAppPreviewFor(item);
      expect(external.title, 'EliteSync 有新提醒');
      expect(external.body, '打开应用查看详情');
      expect(inside.title, '有一条新提醒');
      expect(inside.body, contains('重新检查访问权限'));
      expect(inside.body, isNot(contains('PRIVATE')));
      expect(inside.title, isNot(contains('Safety')));
    });
    test('$kind rejects missing, numeric, URL and path-like locators', () {
      for (final value in [
        null,
        14,
        '14',
        '../settings',
        'https://invalid/$_id',
      ]) {
        expect(
          NotificationPrivacyContract.platformControlledTarget(
            _item(kind, {key: value}),
          ),
          isNull,
        );
      }
      expect(
        NotificationPrivacyContract.platformControlledTarget(
          _item(kind, {'buddy_activity_id': _id}),
        ),
        isNull,
      );
    });
  }
  test(
    'unrelated notification kinds are outside this platform locator contract',
    () {
      for (final kind in ['buddy', 'status_comment', 'message', 'unknown']) {
        expect(
          NotificationPrivacyContract.isPlatformControlledKind(kind),
          isFalse,
        );
        expect(
          NotificationPrivacyContract.platformControlledTarget(
            _item(kind, {'platform_event_id': _id}),
          ),
          isNull,
        );
      }
    },
  );
}

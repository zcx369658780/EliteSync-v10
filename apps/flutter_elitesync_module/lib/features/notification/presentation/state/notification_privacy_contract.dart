import 'package:flutter_elitesync_module/features/notification/domain/entities/notification_item_entity.dart';

enum NotificationPresentationAudience { external, inApp }

class NotificationPrivacyPresentation {
  const NotificationPrivacyPresentation({
    required this.audience,
    required this.title,
    required this.body,
    required this.categoryLabel,
    required this.actionLabel,
    required this.routeHint,
  });

  final NotificationPresentationAudience audience;
  final String title;
  final String body;
  final String categoryLabel;
  final String actionLabel;
  final String routeHint;
}

abstract final class NotificationPrivacyContract {
  static const externalDefault = NotificationPrivacyPresentation(
    audience: NotificationPresentationAudience.external,
    title: 'EliteSync 有新提醒',
    body: '打开应用查看详情',
    categoryLabel: '新提醒',
    actionLabel: '打开应用',
    routeHint: '详情仅在应用内按访问权限显示。',
  );

  static const inAppFailClosed = NotificationPrivacyPresentation(
    audience: NotificationPresentationAudience.inApp,
    title: '有一条新提醒',
    body: '为保护隐私，内容将在所属页面重新检查访问权限后显示。',
    categoryLabel: '隐私保护提醒',
    actionLabel: '打开所属页面',
    routeHint: '所属页面会重新检查当前访问权限。',
  );

  static const forbiddenExternalInformation = <String>[
    'peer identity',
    'candidate identity',
    'message text',
    'Match result',
    'Product Connection state',
    'Safety or report information',
    'private Profile or Showcase content',
  ];

  static NotificationPrivacyPresentation externalPreviewFor(
    NotificationItemEntity _,
  ) => externalDefault;

  static NotificationPrivacyPresentation inAppPreviewFor(
    NotificationItemEntity _,
  ) => inAppFailClosed;
}

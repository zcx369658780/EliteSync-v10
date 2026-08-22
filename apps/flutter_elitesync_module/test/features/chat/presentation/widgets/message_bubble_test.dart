import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/message_attachment_entity.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/widgets/message_bubble.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

void main() {
  testWidgets('historical text survives an adjacent image decode failure', (
    tester,
  ) async {
    final tempDirectory = Directory.systemTemp.createTempSync(
      'elitesync-message-bubble-test-',
    );
    addTearDown(() => tempDirectory.deleteSync(recursive: true));
    final missingImage = File(
      '${tempDirectory.path}${Platform.pathSeparator}missing-history-image.jpg',
    );
    expect(missingImage.existsSync(), isFalse);

    final message = MessageEntity(
      id: 'historical-1',
      mine: false,
      text: '这条历史文字必须继续可读',
      time: '2026-08-01T10:00:00Z',
      attachments: [
        MessageAttachmentEntity(
          id: 'missing-image',
          attachmentType: 'image',
          mediaAssetId: '77',
          mediaType: 'image/jpeg',
          publicUrl: missingImage.uri.toString(),
          status: 'ready',
          mimeType: 'image/jpeg',
          sizeBytes: 0,
          width: 800,
          height: 600,
          durationMs: null,
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvProvider.overrideWithValue(
            const AppEnv(
              flavor: AppFlavor.prod,
              appName: 'EliteSync',
              apiBaseUrl: 'http://localhost/',
              useMockData: false,
            ),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: MessageBubble(message: message)),
        ),
      ),
    );

    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MessageBubble), findsOneWidget);
    expect(find.text('这条历史文字必须继续可读'), findsOneWidget);
    expect(find.text('图片加载失败'), findsOneWidget);
  });

  testWidgets('MessageBubble renders image attachment card', (tester) async {
    const message = MessageEntity(
      id: '1',
      mine: false,
      text: '看看这张图',
      time: '刚刚',
      attachments: [
        MessageAttachmentEntity(
          id: '10',
          attachmentType: 'image',
          mediaAssetId: '99',
          mediaType: 'image',
          publicUrl: 'https://cdn.example.test/chat/a.jpg',
          status: 'ready',
          mimeType: 'image/jpeg',
          sizeBytes: 1024,
          width: 800,
          height: 600,
          durationMs: null,
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvProvider.overrideWithValue(
            const AppEnv(
              flavor: AppFlavor.prod,
              appName: 'EliteSync',
              apiBaseUrl: 'http://101.133.161.203/',
              useMockData: false,
            ),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: MessageBubble(message: message)),
        ),
      ),
    );

    expect(find.text('看看这张图'), findsOneWidget);
    expect(find.text('图片消息'), findsOneWidget);
    final image = tester.widget<Image>(find.byType(Image));
    final provider = image.image;
    expect(provider, isA<ResizeImage>());
    final resizedProvider = provider as ResizeImage;
    expect(resizedProvider.width, 720);
    expect(resizedProvider.height, 720);
    expect(image.loadingBuilder, isNotNull);
    expect(image.gaplessPlayback, isTrue);
  });

  testWidgets('MessageBubble renders video attachment card', (tester) async {
    const message = MessageEntity(
      id: '2',
      mine: true,
      text: '',
      time: '刚刚',
      attachments: [
        MessageAttachmentEntity(
          id: '11',
          attachmentType: 'video',
          mediaAssetId: '100',
          mediaType: 'video',
          publicUrl: 'https://cdn.example.test/chat/a.mp4',
          status: 'ready',
          mimeType: 'video/mp4',
          sizeBytes: 2048,
          width: 1280,
          height: 720,
          durationMs: 65000,
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvProvider.overrideWithValue(
            const AppEnv(
              flavor: AppFlavor.prod,
              appName: 'EliteSync',
              apiBaseUrl: 'http://101.133.161.203/',
              useMockData: false,
            ),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: MessageBubble(message: message)),
        ),
      ),
    );

    expect(find.text('视频消息'), findsOneWidget);
    expect(find.text('1:05'), findsOneWidget);
  });
}

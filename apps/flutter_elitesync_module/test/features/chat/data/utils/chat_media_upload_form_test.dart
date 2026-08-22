import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/features/chat/data/utils/chat_media_upload_form.dart';

void main() {
  test('inferChatUploadMimeType maps common video extensions', () {
    expect(
      inferChatUploadMimeType(mediaType: 'video', fileName: 'clip.mp4'),
      'video/mp4',
    );
    expect(
      inferChatUploadMimeType(mediaType: 'video', fileName: 'clip.MOV'),
      'video/quicktime',
    );
    expect(
      inferChatUploadMimeType(mediaType: 'video', fileName: 'clip.webm'),
      'video/webm',
    );
  });

  test('inferChatUploadMimeType maps common image extensions', () {
    expect(
      inferChatUploadMimeType(mediaType: 'image', fileName: 'photo.jpeg'),
      'image/jpeg',
    );
    expect(
      inferChatUploadMimeType(mediaType: 'image', fileName: 'photo.png'),
      'image/png',
    );
    expect(
      inferChatUploadMimeType(mediaType: 'image', fileName: 'photo.webp'),
      'image/webp',
    );
  });

  test(
    'buildChatMediaUploadForm sends explicit mime_type for videos',
    () async {
      final tempDir = await Directory.systemTemp.createTemp('chat-video-form-');
      addTearDown(() => tempDir.delete(recursive: true));
      final file = File('${tempDir.path}${Platform.pathSeparator}clip.mp4');
      await file.writeAsBytes(<int>[0, 0, 0, 24, 102, 116, 121, 112]);

      final form = await buildChatMediaUploadForm(
        mediaType: 'video',
        filePath: file.path,
        fileName: 'clip.mp4',
        metadata: const {'source_page': 'chat_room', 'media_kind': 'video'},
      );

      final fields = Map<String, String>.fromEntries(form.fields);
      expect(fields['media_type'], 'video');
      expect(fields['original_name'], 'clip.mp4');
      expect(fields['mime_type'], 'video/mp4');
      expect(form.files.single.key, 'file');
      expect(form.files.single.value.filename, 'clip.mp4');
    },
  );
}

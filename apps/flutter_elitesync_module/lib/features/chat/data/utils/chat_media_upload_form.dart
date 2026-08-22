import 'package:dio/dio.dart';

String inferChatUploadMimeType({
  required String mediaType,
  required String fileName,
}) {
  final normalizedMediaType = mediaType.trim().toLowerCase();
  final extension = _extensionOf(fileName);

  if (normalizedMediaType == 'video') {
    return switch (extension) {
      'mov' => 'video/quicktime',
      'm4v' => 'video/x-m4v',
      'webm' => 'video/webm',
      '3gp' || '3gpp' => 'video/3gpp',
      _ => 'video/mp4',
    };
  }

  if (normalizedMediaType == 'image') {
    return switch (extension) {
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      'heic' => 'image/heic',
      'heif' => 'image/heif',
      _ => 'image/jpeg',
    };
  }

  return 'application/octet-stream';
}

Future<FormData> buildChatMediaUploadForm({
  required String mediaType,
  required String filePath,
  required String fileName,
  Map<String, dynamic> metadata = const <String, dynamic>{},
}) async {
  final mimeType = inferChatUploadMimeType(
    mediaType: mediaType,
    fileName: fileName,
  );

  return FormData.fromMap({
    'media_type': mediaType,
    'original_name': fileName,
    'mime_type': mimeType,
    'file': await MultipartFile.fromFile(filePath, filename: fileName),
    'metadata': metadata,
  });
}

String _extensionOf(String fileName) {
  final sanitized = fileName.split(RegExp(r'[\\/]+')).last.trim().toLowerCase();
  final dot = sanitized.lastIndexOf('.');
  if (dot < 0 || dot == sanitized.length - 1) {
    return '';
  }
  return sanitized.substring(dot + 1);
}

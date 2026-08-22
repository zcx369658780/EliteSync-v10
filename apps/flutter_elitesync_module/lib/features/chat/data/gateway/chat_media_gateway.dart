import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/features/chat/data/utils/chat_media_upload_form.dart';
import 'package:image_picker/image_picker.dart';

enum ChatAttachmentKind { image, video }

extension ChatAttachmentKindX on ChatAttachmentKind {
  String get label => switch (this) {
    ChatAttachmentKind.image => '图片',
    ChatAttachmentKind.video => '视频',
  };

  String get mediaType => switch (this) {
    ChatAttachmentKind.image => 'image',
    ChatAttachmentKind.video => 'video',
  };
}

class ChatPickedMedia {
  const ChatPickedMedia({required this.path, required this.name});

  final String path;
  final String name;
}

class ChatMediaUploadResponse {
  const ChatMediaUploadResponse({
    required this.assetId,
    required this.publicUrl,
    required this.status,
  });

  final int? assetId;
  final String? publicUrl;
  final String? status;
}

abstract interface class ChatMediaGateway {
  Future<ChatPickedMedia?> pick(ChatAttachmentKind kind);

  Future<ChatMediaUploadResponse> upload(
    ChatAttachmentKind kind,
    ChatPickedMedia media,
  );
}

class PlatformChatMediaGateway implements ChatMediaGateway {
  PlatformChatMediaGateway({
    required ApiClient apiClient,
    ImagePicker? imagePicker,
  }) : _apiClient = apiClient,
       _imagePicker = imagePicker ?? ImagePicker();

  final ApiClient _apiClient;
  final ImagePicker _imagePicker;

  @override
  Future<ChatPickedMedia?> pick(ChatAttachmentKind kind) async {
    final picked = switch (kind) {
      ChatAttachmentKind.image => await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 88,
      ),
      ChatAttachmentKind.video => await _imagePicker.pickVideo(
        source: ImageSource.gallery,
      ),
    };
    if (picked == null) return null;
    final fallbackName = kind == ChatAttachmentKind.video
        ? 'video.mp4'
        : 'image.jpg';
    return ChatPickedMedia(
      path: picked.path,
      name: picked.name.isEmpty ? fallbackName : picked.name,
    );
  }

  @override
  Future<ChatMediaUploadResponse> upload(
    ChatAttachmentKind kind,
    ChatPickedMedia media,
  ) async {
    final form = await buildChatMediaUploadForm(
      mediaType: kind.mediaType,
      filePath: media.path,
      fileName: media.name,
      metadata: {'source_page': 'chat_room', 'media_kind': kind.mediaType},
    );
    final result = await _apiClient.post('/api/v1/media', body: form);
    if (result is! NetworkSuccess<Map<String, dynamic>>) {
      throw const ChatMediaGatewayException();
    }
    final asset = result.data['asset'];
    if (asset is! Map<String, dynamic>) {
      throw const ChatMediaGatewayException();
    }
    return ChatMediaUploadResponse(
      assetId: (asset['id'] as num?)?.toInt(),
      publicUrl: asset['public_url']?.toString(),
      status: asset['status']?.toString(),
    );
  }
}

class ChatMediaGatewayException implements Exception {
  const ChatMediaGatewayException();

  @override
  String toString() => 'ChatMediaGatewayException';
}

enum ChatMediaResponseDisposition { ready, processing, failed }

class ChatMediaResponseContract {
  const ChatMediaResponseContract({
    required this.disposition,
    required this.normalizedStatus,
    required this.errorCode,
  });

  final ChatMediaResponseDisposition disposition;
  final String normalizedStatus;
  final String? errorCode;

  static ChatMediaResponseContract evaluate(ChatMediaUploadResponse response) {
    final status = (response.status ?? '').trim().toLowerCase();
    if (status == 'pending' ||
        status == 'uploading' ||
        status == 'processing') {
      return ChatMediaResponseContract(
        disposition: ChatMediaResponseDisposition.processing,
        normalizedStatus: status,
        errorCode: null,
      );
    }
    if (status == 'uploaded' || status == 'ready') {
      final publicUrl = (response.publicUrl ?? '').trim();
      if ((response.assetId ?? 0) > 0 && publicUrl.isNotEmpty) {
        return ChatMediaResponseContract(
          disposition: ChatMediaResponseDisposition.ready,
          normalizedStatus: status,
          errorCode: null,
        );
      }
      return const ChatMediaResponseContract(
        disposition: ChatMediaResponseDisposition.failed,
        normalizedStatus: 'failed',
        errorCode: 'invalid_response',
      );
    }
    return ChatMediaResponseContract(
      disposition: ChatMediaResponseDisposition.failed,
      normalizedStatus: status.isEmpty ? 'failed' : status,
      errorCode: status == 'failed' ? 'failed_status' : 'unsupported_status',
    );
  }
}

abstract interface class ChatAttachmentTelemetry {
  void pickerOpened(ChatAttachmentKind kind);

  void uploadStarted(ChatAttachmentKind kind);

  void uploadSucceeded(ChatAttachmentKind kind, int assetId);

  void uploadFailed(ChatAttachmentKind kind, String errorCode);
}

import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/telemetry/frontend_telemetry.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/feedback/app_feedback.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_empty_state.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/chat_route_state.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/chat_send_attempt.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/chat_send_failure.dart';
import 'package:flutter_elitesync_module/features/chat/domain/utils/chat_message_reconciliation.dart';
import 'package:flutter_elitesync_module/features/chat/domain/utils/chat_route_adoption.dart';
import 'package:flutter_elitesync_module/features/chat/domain/utils/message_visibility_utils.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/message_attachment_entity.dart';
import 'package:flutter_elitesync_module/features/chat/data/gateway/chat_media_gateway.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/providers/chat_providers.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/widgets/connection_status_banner.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/widgets/attachment_upload_card.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/widgets/chat_opening_suggestion_card.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/widgets/icebreaker_card.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/widgets/message_bubble.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/widgets/message_input_bar.dart';
import 'package:flutter_elitesync_module/features/moderation/presentation/providers/moderation_provider.dart';
import 'package:flutter_elitesync_module/features/moderation/presentation/widgets/report_block_sheet.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/utils/profile_display_sanitizer.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/services/rtc_permission_service.dart';
import 'package:flutter_elitesync_module/features/rtc/presentation/providers/rtc_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/performance_mode_provider.dart';
import 'package:flutter_elitesync_module/shared/widgets/a5_relationship_understanding_card.dart';

class ChatRoomPage extends ConsumerStatefulWidget {
  const ChatRoomPage({
    super.key,
    required this.routeState,
    this.mediaGateway,
    this.attachmentTelemetry,
  });

  final ChatRouteState routeState;
  final ChatMediaGateway? mediaGateway;
  final ChatAttachmentTelemetry? attachmentTelemetry;

  @override
  ConsumerState<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends ConsumerState<ChatRoomPage> {
  final _controller = TextEditingController();
  final _listController = ScrollController();
  final List<MessageEntity> _localMessages = <MessageEntity>[];
  late ChatRouteState _routeState;
  late final LocalStorageService _localStorage;
  ChatMediaGateway? _defaultMediaGateway;
  ChatAttachmentTelemetry? _defaultAttachmentTelemetry;
  Timer? _draftSaveDebounce;
  Timer? _realtimeRefreshTimer;
  StreamSubscription<MessageEntity>? _realtimeSubscription;
  bool _sending = false;
  ChatSendAttempt? _failedAttempt;
  bool _sameKeyRetryBlocked = false;
  int _lastMergedCount = 0;
  String? _selectedImagePath;
  String? _selectedImageName;
  String? _selectedImagePreviewUrl;
  int? _selectedAttachmentId;
  String? _selectedAttachmentStatus;
  String? _attachmentError;
  ChatAttachmentKind _selectedAttachmentKind = ChatAttachmentKind.image;
  AttachmentUploadStage _attachmentStage = AttachmentUploadStage.pending;

  String get _draftKey =>
      '${CacheKeys.chatDraftPrefix}${_routeState.stableKey}';
  ChatMessagesRequest get _messagesRequest =>
      ChatMessagesRequest.fromRoute(_routeState);
  int get _peerId => chatPeerUserIdForOperations(_routeState);
  String get _peerIdString => _peerId.toString();
  bool get _isConversationIdSupported => _routeState.peerUserId > 0;
  String get _displayTitle => sanitizeProfileDisplayName(_routeState.title);

  @override
  void initState() {
    super.initState();
    _routeState = widget.routeState;
    _localStorage = ref.read(localStorageProvider);
    _controller.addListener(_onDraftChanged);
    _loadDraft();
    _startRealtimeSync();
  }

  ChatMediaGateway get _mediaGateway =>
      widget.mediaGateway ??
      (_defaultMediaGateway ??= PlatformChatMediaGateway(
        apiClient: ref.read(apiClientProvider),
      ));

  ChatAttachmentTelemetry get _attachmentTelemetry =>
      widget.attachmentTelemetry ??
      (_defaultAttachmentTelemetry ??= _FrontendChatAttachmentTelemetry(
        ref.read(frontendTelemetryProvider),
      ));

  @override
  void didUpdateWidget(covariant ChatRoomPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.routeState != widget.routeState) {
      _stopRealtimeSync();
      _routeState = widget.routeState;
      _startRealtimeSync();
    }
  }

  @override
  void dispose() {
    _draftSaveDebounce?.cancel();
    _stopRealtimeSync();
    _persistDraftNow();
    _controller.removeListener(_onDraftChanged);
    _controller.dispose();
    _listController.dispose();
    super.dispose();
  }

  Future<void> _loadDraft() async {
    final draft = await _localStorage.getString(_draftKey);
    if (!mounted || draft == null || draft.isEmpty) return;
    _controller.text = draft;
    _controller.selection = TextSelection.collapsed(offset: draft.length);
  }

  void _onDraftChanged() {
    _draftSaveDebounce?.cancel();
    _draftSaveDebounce = Timer(
      const Duration(milliseconds: 220),
      _persistDraftNow,
    );
  }

  Future<void> _persistDraftNow() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      await _localStorage.remove(_draftKey);
      return;
    }
    await _localStorage.setString(_draftKey, text);
  }

  void _scheduleScrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_listController.hasClients) return;
      final liteMode =
          ref.read(performanceLiteModeProvider).asData?.value ?? false;
      final max = _listController.position.maxScrollExtent;
      if (liteMode) {
        _listController.jumpTo(max);
      } else {
        _listController.animateTo(
          max,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _startRealtimeSync() {
    if (!_isConversationIdSupported) return;
    _realtimeSubscription = ref
        .read(observeMessagesUseCaseProvider)
        .call(_peerIdString)
        .listen(
          (_) {
            if (!mounted) return;
            ref.invalidate(chatRoomMessagesProvider(_messagesRequest));
            ref.invalidate(conversationListProvider);
            _scheduleScrollToBottom();
          },
          onError: (_) {
            // Keep the fallback polling timer running; the next tick will refresh.
          },
        );
    _realtimeRefreshTimer?.cancel();
    _realtimeRefreshTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!mounted) return;
      ref.invalidate(chatRoomMessagesProvider(_messagesRequest));
      ref.invalidate(conversationListProvider);
    });
  }

  void _stopRealtimeSync() {
    _realtimeRefreshTimer?.cancel();
    _realtimeRefreshTimer = null;
    _realtimeSubscription?.cancel();
    _realtimeSubscription = null;
  }

  Future<void> _sendMessage() async {
    if (!_isConversationIdSupported) {
      AppFeedback.showError(context, '当前会话暂时无法打开，请返回消息列表重新选择后重试');
      return;
    }
    final text = _controller.text.trim();
    final hasReadyAttachment =
        _attachmentStage == AttachmentUploadStage.ready &&
        _selectedAttachmentId != null;
    if (_sending || (text.isEmpty && !hasReadyAttachment)) return;

    final attachmentIds = hasReadyAttachment
        ? <int>[_selectedAttachmentId!]
        : <int>[];
    final retry = _failedAttempt;
    final isSameAttempt =
        retry?.hasSamePayload(
          peerUserId: _peerId,
          content: text,
          attachmentIds: attachmentIds,
        ) ??
        false;
    if (isSameAttempt && _sameKeyRetryBlocked) {
      AppFeedback.showError(context, '消息内容与原发送请求冲突，请修改内容或附件后重新发送');
      return;
    }
    final attempt = isSameAttempt
        ? retry!
        : ChatSendAttempt.create(
            peerUserId: _peerId,
            content: text,
            attachmentIds: attachmentIds,
          );
    final selectedMediaType = _selectedAttachmentKind.mediaType;
    final optimistic = MessageEntity(
      id: attempt.localMessageId,
      mine: true,
      text: attempt.content,
      time: '刚刚',
      clientMessageId: attempt.clientMessageId,
      attachments: hasReadyAttachment
          ? [
              MessageAttachmentEntity(
                id: 'local-$_selectedAttachmentId',
                attachmentType: selectedMediaType,
                mediaAssetId: '$_selectedAttachmentId',
                mediaType: selectedMediaType,
                publicUrl: _selectedImagePreviewUrl ?? '',
                status: _selectedAttachmentStatus ?? 'ready',
                mimeType: selectedMediaType == 'video' ? 'video/*' : 'image/*',
                sizeBytes: 0,
                width: null,
                height: null,
                durationMs: null,
              ),
            ]
          : const [],
    );
    _controller.clear();
    await _localStorage.remove(_draftKey);
    setState(() {
      _localMessages.add(optimistic);
      _sending = true;
      if (!isSameAttempt) {
        _failedAttempt = null;
        _sameKeyRetryBlocked = false;
      }
    });
    _scheduleScrollToBottom();
    try {
      final previousRouteState = _routeState;
      final result = await ref
          .read(sendMessageUseCaseProvider)
          .call(
            attempt.peerUserId.toString(),
            attempt.content,
            attachmentIds: attempt.attachmentIds,
            clientMessageId: attempt.clientMessageId,
          );
      final reconciled = result.message.clientMessageId == null
          ? MessageEntity(
              id: result.message.id,
              mine: result.message.mine,
              text: result.message.text,
              time: result.message.time,
              attachments: result.message.attachments,
              clientMessageId: attempt.clientMessageId,
            )
          : result.message;
      final adopted = resolveChatRouteAfterSend(
        _routeState,
        result.conversationId,
      );
      if (!mounted) return;
      setState(() {
        _localMessages.removeWhere(
          (message) =>
              message.clientMessageId == attempt.clientMessageId ||
              message.id == result.serverMessageId.toString(),
        );
        _localMessages.add(reconciled);
        _failedAttempt = null;
        _sameKeyRetryBlocked = false;
        _routeState = adopted;
      });
      ref.invalidate(
        chatRoomMessagesProvider(
          ChatMessagesRequest.fromRoute(previousRouteState),
        ),
      );
      ref.invalidate(
        chatRoomMessagesProvider(ChatMessagesRequest.fromRoute(adopted)),
      );
      ref.invalidate(conversationListProvider);
      if (adopted != previousRouteState) {
        GoRouter.maybeOf(
          context,
        )?.replace('/chat/${adopted.canonicalSegment}', extra: adopted);
      }
      if (attachmentIds.isNotEmpty) {
        final telemetry = ref.read(frontendTelemetryProvider);
        if (_selectedAttachmentKind == ChatAttachmentKind.video) {
          telemetry.chatVideoMessageSent(
            sourcePage: 'chat_room',
            attachmentCount: attachmentIds.length,
          );
        } else {
          telemetry.chatImageMessageSent(
            sourcePage: 'chat_room',
            attachmentCount: attachmentIds.length,
          );
        }
      }
      if (hasReadyAttachment) {
        _clearAttachmentDraft();
      }
    } catch (error) {
      if (!mounted) return;
      final failure = error is ChatSendFailure ? error : null;
      setState(() {
        _localMessages.removeWhere((m) => m.id == optimistic.id);
        _failedAttempt = attempt;
        _sameKeyRetryBlocked = failure?.isPayloadMismatch ?? false;
      });
      _controller.text = attempt.content;
      _controller.selection = TextSelection.collapsed(
        offset: attempt.content.length,
      );
      AppFeedback.showError(
        context,
        failure?.isPayloadMismatch ?? false
            ? '消息内容与原发送请求冲突，请修改内容或附件后重新发送'
            : failure?.isConversationIdentityConflict ?? false
            ? '会话身份校验失败，未切换当前会话，请刷新后重试'
            : '发送失败，已恢复输入框，请稍后重试',
      );
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  void _clearAttachmentDraft() {
    setState(() {
      _selectedImagePath = null;
      _selectedImageName = null;
      _selectedImagePreviewUrl = null;
      _selectedAttachmentId = null;
      _selectedAttachmentStatus = null;
      _attachmentError = null;
      _selectedAttachmentKind = ChatAttachmentKind.image;
      _attachmentStage = AttachmentUploadStage.pending;
    });
  }

  Future<void> _pickAndUploadImage() async {
    await _pickAndUploadMedia(ChatAttachmentKind.image);
  }

  Future<void> _pickAndUploadVideo() async {
    await _pickAndUploadMedia(ChatAttachmentKind.video);
  }

  Future<void> _openAttachmentPicker() async {
    if (_sending || _attachmentStage == AttachmentUploadStage.uploading) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) {
        final t = context.appTokens;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            t.spacing.pageHorizontal,
            0,
            t.spacing.pageHorizontal,
            t.spacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('选择图片'),
                subtitle: const Text('发送图片附件'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickAndUploadImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam_outlined),
                title: const Text('选择视频'),
                subtitle: const Text('发送单视频消息'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickAndUploadVideo();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _startVoiceCall() async {
    final peerId = _peerId;
    if (peerId <= 0) {
      AppFeedback.showError(context, '当前会话无法发起通话');
      return;
    }
    final router = GoRouter.of(context);
    final confirmed = await _confirmVoiceRhythm();
    if (!confirmed) return;

    final permissionService = ref.read(rtcPermissionServiceProvider);
    if (!await permissionService.hasVoiceCallPermission()) {
      final granted =
          await router.push<bool>(
            '${AppRouteNames.rtcPermission}?title=${Uri.encodeComponent('通话权限')}',
          ) ??
          false;
      if (!granted && !await permissionService.hasVoiceCallPermission()) {
        return;
      }
    }

    final telemetry = ref.read(frontendTelemetryProvider);
    telemetry.rtcCallEntryOpened(sourcePage: 'chat_room');

    try {
      final session = await ref
          .read(rtcRemoteDataSourceProvider)
          .createCall(peerUserId: peerId, mode: 'voice');
      telemetry.rtcCallStatusChanged(
        sourcePage: 'chat_room',
        callId: session.id,
        status: session.status,
      );
      if (!mounted) return;
      final target = session.isTerminal
          ? '${AppRouteNames.rtcCallResult}/${session.id}'
          : '${AppRouteNames.rtcCall}/${session.id}';
      router.push(
        target,
        extra: session.title.isNotEmpty
            ? sanitizeProfileDisplayName(session.title)
            : _displayTitle,
      );
    } catch (e) {
      final message = e.toString().toLowerCase();
      if (message.contains('permission') ||
          message.contains('授权') ||
          message.contains('权限')) {
        if (!mounted) return;
        final granted =
            await router.push<bool>(
              '${AppRouteNames.rtcPermission}?title=${Uri.encodeComponent('通话权限')}',
            ) ??
            false;
        if (granted || await permissionService.hasVoiceCallPermission()) {
          await _startVoiceCall();
          return;
        }
      }
      if (!mounted) return;
      AppFeedback.showError(context, '暂时无法开始语音，请稍后重试');
    }
  }

  Future<bool> _confirmVoiceRhythm() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final t = dialogContext.appTokens;
        return AlertDialog(
          title: const Text('语音前先确认节奏'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _VoiceRhythmLine(
                icon: Icons.chat_bubble_outline_rounded,
                text: '如果刚开始认识，先用文字接住对方回应会更低压。',
                color: t.brandPrimary,
              ),
              SizedBox(height: t.spacing.xs),
              _VoiceRhythmLine(
                icon: Icons.favorite_outline_rounded,
                text: '当你们已经围绕共同点聊开，再切到语音会更自然。',
                color: t.brandPrimary,
              ),
              SizedBox(height: t.spacing.xs),
              _VoiceRhythmLine(
                icon: Icons.call_outlined,
                text: '现在发起语音邀请，不会自动发送文字消息。',
                color: t.brandPrimary,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('继续文字'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('现在语音'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _pickAndUploadMedia(ChatAttachmentKind kind) async {
    if (_sending || _attachmentStage == AttachmentUploadStage.uploading) return;
    _selectedAttachmentKind = kind;
    _attachmentTelemetry.pickerOpened(kind);

    ChatPickedMedia? picked;
    try {
      picked = await _mediaGateway.pick(kind);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _selectedImagePath = null;
        _selectedImageName = null;
        _selectedImagePreviewUrl = null;
        _selectedAttachmentId = null;
        _selectedAttachmentStatus = 'failed';
        _attachmentStage = AttachmentUploadStage.failed;
        _attachmentError = null;
      });
      _attachmentTelemetry.uploadFailed(kind, 'picker_error');
      AppFeedback.showError(context, '${kind.label}选择失败，请重新选择');
      return;
    }
    if (picked == null) {
      if (mounted) _clearAttachmentDraft();
      return;
    }
    final selected = picked;

    setState(() {
      _selectedImagePath = selected.path;
      _selectedImageName = selected.name;
      _selectedImagePreviewUrl = null;
      _selectedAttachmentId = null;
      _selectedAttachmentStatus = null;
      _attachmentStage = AttachmentUploadStage.uploading;
      _attachmentError = null;
    });
    _attachmentTelemetry.uploadStarted(kind);

    try {
      final response = await _mediaGateway.upload(kind, selected);
      final contract = ChatMediaResponseContract.evaluate(response);
      if (!mounted) return;
      switch (contract.disposition) {
        case ChatMediaResponseDisposition.ready:
          final assetId = response.assetId!;
          setState(() {
            _selectedAttachmentId = assetId;
            _selectedAttachmentStatus = contract.normalizedStatus;
            _selectedImagePreviewUrl = response.publicUrl!.trim();
            _attachmentStage = AttachmentUploadStage.ready;
          });
          _attachmentTelemetry.uploadSucceeded(kind, assetId);
          AppFeedback.showSuccess(context, '${kind.label}已准备好，可以发送');
        case ChatMediaResponseDisposition.processing:
          setState(() {
            _selectedAttachmentId = null;
            _selectedImagePreviewUrl = null;
            _selectedAttachmentStatus = contract.normalizedStatus;
            _attachmentStage = AttachmentUploadStage.processing;
            _attachmentError = '${kind.label}正在处理，完成前不能发送。';
          });
        case ChatMediaResponseDisposition.failed:
          _setAttachmentFailure(
            kind,
            errorCode: contract.errorCode ?? 'invalid_response',
          );
      }
    } catch (_) {
      if (!mounted) return;
      _setAttachmentFailure(kind, errorCode: 'upload_failed');
    }
  }

  void _setAttachmentFailure(
    ChatAttachmentKind kind, {
    required String errorCode,
  }) {
    setState(() {
      _selectedAttachmentId = null;
      _selectedImagePreviewUrl = null;
      _selectedAttachmentStatus = 'failed';
      _attachmentStage = AttachmentUploadStage.failed;
      _attachmentError = '${kind.label}上传失败，请重新选择。';
    });
    _attachmentTelemetry.uploadFailed(kind, errorCode);
    AppFeedback.showError(context, '${kind.label}上传失败，请重新选择');
  }

  Future<void> _openModerationSheet() async {
    final peerId = _peerId;
    if (peerId <= 0) {
      AppFeedback.showError(context, '当前会话对象无效');
      return;
    }
    final remote = ref.read(moderationRemoteDataSourceProvider);
    await ReportBlockSheet.show(
      context,
      targetName: _displayTitle,
      onReport: ({required String reasonCode, String? detail}) async {
        await remote.reportUser(
          targetUserId: peerId,
          category: 'user',
          reasonCode: reasonCode,
          sourcePage: 'chat_room',
          detail: detail,
        );
      },
      onBlock: () async {
        await remote.blockUser(
          blockedUserId: peerId,
          sourcePage: 'chat_room',
          reasonCode: 'chat_menu',
          detail: 'from_chat_room',
        );
      },
    );
  }

  void _applyIcebreakerSuggestion(String prompt) {
    final text = prompt.trim();
    if (text.isEmpty) return;
    setState(() {
      _controller.text = text;
      _controller.selection = TextSelection.collapsed(offset: text.length);
    });
    FocusScope.of(context).unfocus();
  }

  Widget _buildAttachmentDraftCard() {
    if (_selectedImagePath == null) return const SizedBox.shrink();
    final t = context.appTokens;
    final file = File(_selectedImagePath!);
    final isVideo = _selectedAttachmentKind == ChatAttachmentKind.video;
    final label = switch (_attachmentStage) {
      AttachmentUploadStage.pending => '待上传',
      AttachmentUploadStage.uploading => '正在上传',
      AttachmentUploadStage.processing => '正在处理',
      AttachmentUploadStage.failed => '上传失败',
      AttachmentUploadStage.ready => '可以发送',
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(t.radius.lg),
        border: Border.all(color: t.overlay.withValues(alpha: 0.75)),
      ),
      child: Padding(
        padding: EdgeInsets.all(t.spacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(t.radius.md),
              child: SizedBox(
                width: 68,
                height: 68,
                child: isVideo
                    ? ColoredBox(
                        color: Colors.black12,
                        child: Center(
                          child: Icon(
                            Icons.videocam_outlined,
                            color: t.textSecondary,
                          ),
                        ),
                      )
                    : Image.file(
                        file,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const ColoredBox(
                              color: Colors.black12,
                              child: Icon(Icons.broken_image_outlined),
                            ),
                      ),
              ),
            ),
            SizedBox(width: t.spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedImageName ?? '已选择${isVideo ? '视频' : '图片'}',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: t.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: t.secondarySurface,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(label),
                      ),
                    ],
                  ),
                  SizedBox(height: t.spacing.xxs),
                  Text(
                    _attachmentError ??
                        switch (_attachmentStage) {
                          AttachmentUploadStage.pending =>
                            '已选择${isVideo ? '视频' : '图片'}，等待上传。',
                          AttachmentUploadStage.uploading =>
                            '${isVideo ? '视频' : '图片'}正在上传。',
                          AttachmentUploadStage.processing =>
                            '${isVideo ? '视频' : '图片'}正在处理。',
                          AttachmentUploadStage.failed => '上传失败，可重试或重新选择。',
                          AttachmentUploadStage.ready =>
                            '${isVideo ? '视频' : '图片'}已可发送。',
                        },
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
                  ),
                  SizedBox(height: t.spacing.xs),
                  Wrap(
                    spacing: t.spacing.xs,
                    runSpacing: t.spacing.xs,
                    children: [
                      AppSecondaryButton(
                        label: '重新选择',
                        onPressed:
                            _selectedAttachmentKind == ChatAttachmentKind.video
                            ? _pickAndUploadVideo
                            : _pickAndUploadImage,
                      ),
                      AppSecondaryButton(
                        label: '清除',
                        onPressed: _clearAttachmentDraft,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<IcebreakerSuggestion> _icebreakerSuggestions() {
    return const [
      IcebreakerSuggestion(
        label: '继续聊：从周末聊起',
        lane: '继续聊',
        source: '关系摘要 / 共同点',
        description: '适合刚有回应时继续放轻节奏，不抢结论。',
        icon: Icons.forum_outlined,
        prompt: '先从最近一次让你放松的周末安排聊起，你通常会怎么度过？',
      ),
      IcebreakerSuggestion(
        label: '继续聊：问最近状态',
        lane: '继续聊',
        source: '最近互动',
        description: '适合把聊天从问候推进到真实近况。',
        icon: Icons.waving_hand_outlined,
        prompt: '你最近最想投入的一件事是什么？',
      ),
      IcebreakerSuggestion(
        label: '回聊：接住话题',
        lane: '回聊',
        source: '最近互动',
        description: '适合对方已经给出信息时，先接住再追问。',
        icon: Icons.reply_rounded,
        prompt: '你刚刚提到的那个点挺有意思，能多说一点吗？',
      ),
      IcebreakerSuggestion(
        label: '回聊：从共同点延展',
        lane: '回聊',
        source: '匹配解释 / 共同点',
        description: '适合把匹配解释里的共同点转成自然追问。',
        icon: Icons.join_inner_rounded,
        prompt: '我们好像有个相近的地方：都更重视相处里的真实感。你会怎么理解这种感觉？',
      ),
      IcebreakerSuggestion(
        label: '稍后再聊：低压回归',
        lane: '稍后再聊',
        source: '稍后再聊候选位',
        description: '适合隔了一段时间后重新接起，不制造压力。',
        icon: Icons.schedule_rounded,
        prompt: '刚刚那段我想了一下，还是挺想听听你的看法。如果你愿意，我们可以从一个轻松的问题重新聊起。',
      ),
      IcebreakerSuggestion(
        label: '冷场恢复：共鸣接起',
        lane: '冷场恢复',
        source: '冷场恢复候选位',
        description: '适合聊天中断后，先表达理解，再轻轻追问。',
        icon: Icons.volunteer_activism_outlined,
        prompt: '我刚刚想到你说的那句话，其实挺能理解。你当时最在意的是哪一部分？',
      ),
      IcebreakerSuggestion(
        label: '冷场恢复：周末安排',
        lane: '冷场恢复',
        source: '状态内容 / 生活节奏',
        description: '适合话题停住时，用低压生活问题重新打开。',
        icon: Icons.weekend_outlined,
        prompt: '这个周末你更想安静待着，还是想出去走走？我有点好奇你的放松方式。',
      ),
    ];
  }

  List<ChatOpeningSuggestion> _openingSuggestions() {
    return const [
      ChatOpeningSuggestion(
        title: '从共同点开始',
        tag: '共同点',
        description: '适合刚进入会话时，先把关系摘要转成轻一点的开场。',
        icon: Icons.forum_outlined,
        prompt: '我看到我们有些相近的地方，想从一个轻松的问题开始：你最近最愿意投入的一件事是什么？',
      ),
      ChatOpeningSuggestion(
        title: '换个更自然的说法',
        tag: '改写',
        description: '适合已经想好方向，但希望语气更像真实聊天。',
        icon: Icons.tune_rounded,
        prompt: '刚刚那句话我想换个轻松点的问法：你平时更喜欢怎么慢慢认识一个人？',
      ),
      ChatOpeningSuggestion(
        title: '低压问候建议',
        tag: '问候',
        description: '适合首聊或隔了一段时间后重新开口，不给对方压力。',
        icon: Icons.waving_hand_outlined,
        prompt: '嗨，今天过得怎么样？不用急着回，我只是想先从一个轻松的问候开始。',
      ),
      ChatOpeningSuggestion(
        title: '不要太急',
        tag: '节奏',
        description: '适合提醒自己先接住回应，再决定是否继续推进话题。',
        icon: Icons.spa_outlined,
        prompt: '我不想聊得太急。我们可以先从最近让你放松的一件小事聊起。',
      ),
    ];
  }

  List<Widget> _buildConversationHeader(dynamic t) {
    return [
      Padding(
        padding: EdgeInsets.fromLTRB(
          t.spacing.pageHorizontal,
          t.spacing.sm,
          t.spacing.pageHorizontal,
          t.spacing.sm,
        ),
        child: SectionReveal(
          child: _ConversationContextHeader(
            title: _displayTitle,
            onVoiceRhythmTap: _confirmVoiceRhythm,
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(
          t.spacing.pageHorizontal,
          t.spacing.xs,
          t.spacing.pageHorizontal,
          t.spacing.xs,
        ),
        child: const A5RelationshipUnderstandingCard(
          title: '今天适合怎样表达',
          subtitle: '把关系解释转成可编辑、低压力的聊天动作',
          icon: Icons.auto_awesome_outlined,
          summary: '聊天里的解释只用来降低开口压力：先确认共同点和回应节奏，再决定是否继续深入。',
          dimensions: [
            A5UnderstandingDimension(
              title: '共同点',
              label: '从哪里开始',
              body: '先接住匹配理由、共同兴趣或搭子活动里的一个具体点。',
            ),
            A5UnderstandingDimension(
              title: '节奏',
              label: '慢一点',
              body: '首聊用短句和开放问题，等对方回应后再推进。',
            ),
            A5UnderstandingDimension(
              title: '边界',
              label: '手动确认',
              body: '建议只写入草稿，发送仍由你自己决定。',
            ),
          ],
          suggestions: ['先问一个轻松具体的问题。', '把解释改写成真实感受。'],
          avoidances: ['避免连续长消息或催促回复。', '避免把星盘/匹配提示说成确定结论。'],
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(
          t.spacing.pageHorizontal,
          t.spacing.xs,
          t.spacing.pageHorizontal,
          t.spacing.xs,
        ),
        child: AppInfoSectionCard(
          title: '关系节奏提示',
          subtitle: '为什么可以聊、从哪里开始、先不要太急',
          leadingIcon: Icons.favorite_border_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ChatRhythmLine(
                icon: Icons.join_inner_rounded,
                text: '可以先从匹配理由、共同兴趣或搭子活动里的一个具体点开始。',
                color: t.brandPrimary,
              ),
              SizedBox(height: t.spacing.xs),
              _ChatRhythmLine(
                icon: Icons.edit_note_rounded,
                text: '下面的建议只会填入可编辑草稿，仍需你手动确认发送。',
                color: t.brandPrimary,
              ),
              SizedBox(height: t.spacing.xs),
              _ChatRhythmLine(
                icon: Icons.spa_outlined,
                text: '如果对方还没进入状态，先接住回应，不催促、不替对方下判断。',
                color: t.brandPrimary,
              ),
            ],
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(
          t.spacing.pageHorizontal,
          0,
          t.spacing.pageHorizontal,
          t.spacing.xs,
        ),
        child: AppInfoSectionCard(
          title: '冷场恢复建议',
          subtitle: '低压续一下，不制造焦虑',
          leadingIcon: Icons.volunteer_activism_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ChatRhythmLine(
                icon: Icons.chat_bubble_outline_rounded,
                text: '可以说：刚刚那个话题我又想了一下，想听听你怎么看。',
                color: t.brandPrimary,
              ),
              SizedBox(height: t.spacing.xs),
              _ChatRhythmLine(
                icon: Icons.weekend_outlined,
                text: '也可以换成轻问题：这个周末你更想安静待着，还是出去走走？',
                color: t.brandPrimary,
              ),
              SizedBox(height: t.spacing.xs),
              _ChatRhythmLine(
                icon: Icons.lock_outline_rounded,
                text: '不会读取私密聊天、不会自动发送，也不会写入资料或关系状态。',
                color: t.brandPrimary,
              ),
            ],
          ),
        ),
      ),
      SizedBox(height: t.spacing.xs),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: t.spacing.pageHorizontal),
        child: IcebreakerCard(
          suggestions: _icebreakerSuggestions(),
          onSuggestionTap: _applyIcebreakerSuggestion,
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(
          t.spacing.pageHorizontal,
          t.spacing.xs,
          t.spacing.pageHorizontal,
          t.spacing.xs,
        ),
        child: ChatOpeningSuggestionCard(
          suggestions: _openingSuggestions(),
          onDraftSelected: _applyIcebreakerSuggestion,
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(
          t.spacing.pageHorizontal,
          t.spacing.xs,
          t.spacing.pageHorizontal,
          t.spacing.xs,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '如需补充图片或视频，可在发送前先选择附件。',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
              ),
            ),
            const SizedBox(width: 8),
            AppSecondaryButton(
              label: '选择图片 / 视频',
              onPressed: _openAttachmentPicker,
            ),
          ],
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(
          t.spacing.pageHorizontal,
          t.spacing.xs,
          t.spacing.pageHorizontal,
          t.spacing.xs,
        ),
        child: _buildAttachmentDraftCard(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConversationIdSupported) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_displayTitle),
          leading: BackButton(
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.chat_bubble_outline_rounded, size: 48),
                const SizedBox(height: 16),
                Text(
                  '当前会话暂时无法打开',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  '可以返回消息列表，重新选择已经确认的慢约会对话。',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('返回会话列表'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final async = ref.watch(chatRoomMessagesProvider(_messagesRequest));
    final connection = ref.watch(chatConnectionProvider);
    final t = context.appTokens;

    return Scaffold(
      appBar: AppTopBar(
        title: _displayTitle,
        mode: AppTopBarMode.backTitle,
        actions: [
          IconButton(
            tooltip: '刷新消息',
            onPressed: () =>
                ref.invalidate(chatRoomMessagesProvider(_messagesRequest)),
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: '语音通话',
            onPressed: _startVoiceCall,
            icon: const Icon(Icons.call_outlined),
          ),
          PopupMenuButton<String>(
            tooltip: '安全',
            onSelected: (value) async {
              if (value == 'moderation') {
                await _openModerationSheet();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'moderation',
                child: ListTile(
                  dense: true,
                  leading: Icon(Icons.shield_outlined),
                  title: Text('举报 / 拉黑'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          ConnectionStatusBanner(status: connection),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: t.spacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '消息加载失败',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: t.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      SizedBox(height: t.spacing.xs),
                      Text(
                        '暂时无法加载消息。你可以先重试，或返回消息列表后继续编辑草稿。',
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
                      ),
                      SizedBox(height: t.spacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: AppSecondaryButton(
                              label: '返回会话列表',
                              fullWidth: true,
                              onPressed: () => Navigator.of(context).maybePop(),
                            ),
                          ),
                          SizedBox(width: t.spacing.sm),
                          Expanded(
                            child: AppSecondaryButton(
                              label: '重试',
                              fullWidth: true,
                              onPressed: () => ref.invalidate(
                                chatRoomMessagesProvider(_messagesRequest),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              data: (initialMessages) {
                final visibleInitial = sanitizeVisibleChatMessages(
                  initialMessages,
                );
                final visibleLocal = sanitizeVisibleChatMessages(
                  _localMessages,
                );
                final merged = reconcileChatMessages(
                  remote: visibleInitial,
                  local: visibleLocal,
                );
                if (merged.isEmpty) {
                  return ListView(
                    children: [
                      ..._buildConversationHeader(t),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: t.spacing.pageHorizontal,
                          vertical: t.spacing.lg,
                        ),
                        child: AppEmptyState(
                          title: '还没有消息',
                          description: '这段对话来自本轮慢约会。可以先写一条轻问候，编辑好后再决定是否发送。',
                          actionLabel: '返回会话列表',
                          onAction: () => Navigator.of(context).maybePop(),
                        ),
                      ),
                    ],
                  );
                }
                if (merged.length != _lastMergedCount) {
                  _lastMergedCount = merged.length;
                  _scheduleScrollToBottom();
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(chatRoomMessagesProvider(_messagesRequest));
                    await ref.read(
                      chatRoomMessagesProvider(_messagesRequest).future,
                    );
                  },
                  child: ListView(
                    controller: _listController,
                    padding: EdgeInsets.only(bottom: t.spacing.sm),
                    children: [
                      ..._buildConversationHeader(t),
                      ...merged.map(
                        (message) => Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: t.spacing.pageHorizontal,
                          ),
                          child: RepaintBoundary(
                            child: MessageBubble(message: message),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              t.spacing.pageHorizontal,
              t.spacing.xs,
              t.spacing.pageHorizontal,
              t.spacing.xs,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: t.surface.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(t.radius.lg),
                border: Border.all(color: t.overlay.withValues(alpha: 0.75)),
              ),
              child: MessageInputBar(
                controller: _controller,
                sending: _sending,
                onSend: _sendMessage,
                onAttach: _openAttachmentPicker,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FrontendChatAttachmentTelemetry implements ChatAttachmentTelemetry {
  const _FrontendChatAttachmentTelemetry(this._telemetry);

  final FrontendTelemetry _telemetry;

  @override
  void pickerOpened(ChatAttachmentKind kind) {
    if (kind == ChatAttachmentKind.video) {
      _telemetry.chatVideoPickerOpened(sourcePage: 'chat_room');
    } else {
      _telemetry.chatImagePickerOpened(sourcePage: 'chat_room');
    }
  }

  @override
  void uploadStarted(ChatAttachmentKind kind) {
    if (kind == ChatAttachmentKind.video) {
      _telemetry.chatVideoUploadStarted(sourcePage: 'chat_room');
    } else {
      _telemetry.chatImageUploadStarted(sourcePage: 'chat_room');
    }
  }

  @override
  void uploadSucceeded(ChatAttachmentKind kind, int assetId) {
    if (kind == ChatAttachmentKind.video) {
      _telemetry.chatVideoUploadSucceeded(
        sourcePage: 'chat_room',
        assetId: assetId,
      );
    } else {
      _telemetry.chatImageUploadSucceeded(
        sourcePage: 'chat_room',
        assetId: assetId,
      );
    }
  }

  @override
  void uploadFailed(ChatAttachmentKind kind, String errorCode) {
    if (kind == ChatAttachmentKind.video) {
      _telemetry.chatVideoUploadFailed(
        sourcePage: 'chat_room',
        errorCode: errorCode,
      );
    } else {
      _telemetry.chatImageUploadFailed(
        sourcePage: 'chat_room',
        errorCode: errorCode,
      );
    }
  }
}

class _ConversationContextHeader extends StatelessWidget {
  const _ConversationContextHeader({
    required this.title,
    required this.onVoiceRhythmTap,
  });

  final String title;
  final VoidCallback onVoiceRhythmTap;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(t.radius.lg),
        border: Border.all(color: t.overlay.withValues(alpha: 0.68)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(t.spacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(t.radius.md),
                    color: t.brandPrimary.withValues(alpha: 0.12),
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: t.brandPrimary,
                    size: 21,
                  ),
                ),
                SizedBox(width: t.spacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '本轮慢约会对话',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: t.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: t.spacing.xxs),
                      Text(
                        '正在和 $title 慢慢聊',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: t.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: t.spacing.sm),
            Text(
              '这段对话来自你已经确认的慢约会。建议只进入草稿，发送仍由你手动确认。',
              style: theme.textTheme.bodySmall?.copyWith(
                color: t.textSecondary,
                height: 1.42,
              ),
            ),
            SizedBox(height: t.spacing.xs),
            Wrap(
              spacing: t.spacing.xs,
              runSpacing: t.spacing.xs,
              children: const [
                AppChoiceChip(
                  label: '手动发送',
                  selected: true,
                  leading: Icon(Icons.check_circle_outline_rounded),
                ),
                AppChoiceChip(
                  label: '可编辑草稿',
                  selected: true,
                  leading: Icon(Icons.edit_note_rounded),
                ),
                AppChoiceChip(
                  label: '不自动发送',
                  selected: true,
                  leading: Icon(Icons.lock_outline_rounded),
                ),
              ],
            ),
            SizedBox(height: t.spacing.xs),
            Row(
              children: [
                Icon(Icons.call_outlined, color: t.brandPrimary, size: 18),
                SizedBox(width: t.spacing.xs),
                Expanded(
                  child: Text(
                    '语音节奏',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                AppSecondaryButton(
                  label: '查看语音前提示',
                  onPressed: onVoiceRhythmTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VoiceRhythmLine extends StatelessWidget {
  const _VoiceRhythmLine({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _ChatRhythmLine extends StatelessWidget {
  const _ChatRhythmLine({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4),
          ),
        ),
      ],
    );
  }
}

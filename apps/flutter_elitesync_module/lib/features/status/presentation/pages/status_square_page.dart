import 'package:flutter_elitesync_module/design_system/components/layout/ui_s3_canvas.dart';
import 'dart:io';

import 'package:flutter_elitesync_module/features/profile/presentation/pages/data_rights_page.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/telemetry/frontend_telemetry.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/components/fields/app_text_field.dart';
import 'package:flutter_elitesync_module/design_system/components/feedback/app_confirm_dialog.dart';
import 'package:flutter_elitesync_module/design_system/components/feedback/app_feedback.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_empty_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter_elitesync_module/features/status/domain/entities/status_post_entity.dart';
import 'package:flutter_elitesync_module/features/status/presentation/providers/status_posts_provider.dart';
import 'package:flutter_elitesync_module/features/status/presentation/widgets/status_post_card.dart';
import 'package:flutter_elitesync_module/features/status/presentation/widgets/status_report_sheet.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/auth_interceptor.dart';
import 'status_favorites_page.dart';

enum _CoverUploadStage { idle, uploading, processing, ready, failed }

class StatusSquarePage extends ConsumerStatefulWidget {
  const StatusSquarePage({super.key, this.publishOnly = false});
  final bool publishOnly;

  @override
  ConsumerState<StatusSquarePage> createState() => _StatusSquarePageState();
}

class _StatusSquarePageState extends ConsumerState<StatusSquarePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final ScrollController _feedScroll = ScrollController();
  String _audience = 'FRIENDS';
  String? _commentPolicy;
  bool _submitting = false;
  bool _prefilledLocation = false;
  bool _feedUnavailable = false;
  String _coverMediaType = 'image';
  String? _coverImagePath;
  String? _coverImageName;
  int? _coverMediaAssetId;
  String? _coverUploadError;
  _CoverUploadStage _coverStage = _CoverUploadStage.idle;

  void _refreshPosts({bool firstPage = false}) {
    if (!mounted) return;
    setState(() => _feedUnavailable = false);
    if (firstPage) ref.read(statusPageCursorProvider.notifier).firstPage();
    ref.invalidate(statusPostPageProvider);
    ref.invalidate(statusPostsProvider);
  }

  void _clearLocalAuthority() {
    _titleController.clear();
    _bodyController.clear();
    _locationController.clear();
    _clearCoverImage();
    setState(() {
      _audience = 'FRIENDS';
      _commentPolicy = null;
      _submitting = false;
      _prefilledLocation = false;
      _feedUnavailable = false;
    });
  }

  @override
  void dispose() {
    _feedScroll.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _openPostDetail(StatusPostEntity post) async {
    final session = ref.read(sessionProvider).asData?.value;
    final epoch = ref.read(relationshipAuthorityEpochProvider);
    final cursor = ref.read(statusPageCursorProvider);
    final offset = _feedScroll.hasClients ? _feedScroll.offset : 0.0;
    await context.push('${AppRouteNames.statusDetail}/${post.id}');
    if (!mounted || offset == 0) return;
    try {
      await ref.read(statusPostPageProvider.future);
    } catch (_) {
      return;
    }
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          !_feedScroll.hasClients ||
          !identical(session, ref.read(sessionProvider).asData?.value) ||
          ref.read(relationshipAuthorityEpochProvider) != epoch ||
          ref.read(statusPageCursorProvider) != cursor) {
        return;
      }
      final position = _feedScroll.position;
      position.jumpTo(offset.clamp(0.0, position.maxScrollExtent));
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  Future<void> _publish({bool checkOnly = false}) async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    final session = ref.read(sessionProvider).asData?.value;
    final userId = session?.user?.id;
    if (session?.isLoggedIn != true || userId == null) return;
    final token = session?.accessToken;
    final epoch = ref.read(relationshipAuthorityEpochProvider);
    bool current() =>
        token == ref.read(sessionProvider).asData?.value.accessToken &&
        epoch == ref.read(relationshipAuthorityEpochProvider);
    setState(() => _submitting = true);
    final target = _audience;
    final comments = _commentPolicy;
    final cover = _coverStage == _CoverUploadStage.ready
        ? _coverMediaAssetId
        : null;
    final location = _locationController.text.trim();
    final storage = ref.read(localStorageProvider);
    final remote = ref.read(statusRemoteDataSourceProvider);
    // Store only the opaque command identifier. The draft is never persisted here.
    final storageKey = 'status_publication_pending_v2_$userId';
    try {
      final pending = await storage.getString(storageKey);
      if (!mounted || !current()) return;
      if (pending != null) {
        final outcome = await remote.publicationResult(pending);
        if (!mounted || !current()) return;
        if (outcome == 'APPLIED' || outcome == 'UNAVAILABLE') {
          if (!await storage.remove(storageKey)) {
            throw StateError('receipt storage');
          }
          if (!mounted || !current()) return;
          if (outcome == 'APPLIED') {
            _finishPublication();
          } else {
            AppFeedback.showInfo(context, '原请求已处理，作品当前不可读取。请刷新后再继续。');
          }
          return;
        }
        if (outcome != 'NOT_APPLIED') {
          AppFeedback.showInfo(context, '发布结果仍无法核实，请稍后核对。');
          return;
        }
      }
      if (checkOnly) {
        AppFeedback.showInfo(
          context,
          pending == null ? '当前没有待核对的发布。' : '服务端尚未记录原请求，可确认后继续。',
        );
        return;
      }
      if (title.isEmpty || body.isEmpty) {
        AppFeedback.showInfo(context, '请先填写标题和内容');
        return;
      }
      if (_coverStage == _CoverUploadStage.uploading) {
        AppFeedback.showInfo(context, '媒体正在上传，请稍后再发布');
        return;
      }
      if (_coverImagePath != null && _coverStage != _CoverUploadStage.ready) {
        AppFeedback.showInfo(context, '媒体尚未就绪，请重试或清除后再发布');
        return;
      }

      final policy = comments ?? (target == 'SELF' ? 'OFF' : 'FRIENDS_ONLY');
      final confirmed = pending != null || target == 'PUBLIC_AUTHENTICATED'
          ? await AppConfirmDialog.show(
              context,
              title: pending == null ? '确认向登录用户发布' : '确认继续原发布请求',
              message: [
                '作品：${statusAudienceLabel(target)}',
                '评论：${statusCommentPolicyLabel(policy)}',
                if (cover != null && target == 'PUBLIC_AUTHENTICATED')
                  '封面仍只向当前双向好友开放。',
              ].join('\n'),
              confirmLabel: '确认发布',
              cancelLabel: '取消',
            )
          : true;
      if (!confirmed || !mounted || !current()) return;
      final key = pending ?? const Uuid().v4();
      if (pending == null && !await storage.setString(storageKey, key)) {
        throw StateError('receipt storage');
      }
      if (!mounted || !current()) return;
      final item = await remote.createStatusPost(
        title: title,
        body: body,
        locationName: location.isEmpty ? null : location,
        visibility: 'private',
        audience: target,
        commentPolicy: comments,
        requestKey: key,
        confirm: confirmed,
        coverMediaAssetId: cover,
      );
      if (!mounted || !current()) return;
      if (item.id <= 0 || !await storage.remove(storageKey)) {
        throw StateError('receipt unavailable');
      }
      if (!mounted || !current()) return;
      ref
          .read(frontendTelemetryProvider)
          .statusPostPublished(sourcePage: 'status_square', postId: item.id);
      _finishPublication();
    } catch (_) {
      if (!mounted || !current()) return;
      _refreshPosts(firstPage: true);
      AppFeedback.showInfo(context, '发布结果尚未确认。再次操作会先核对原请求，不会自动重发。');
    } finally {
      if (mounted && current()) setState(() => _submitting = false);
    }
  }

  void _finishPublication() {
    _titleController.clear();
    _bodyController.clear();
    _clearCoverImage();
    _refreshPosts(firstPage: true);
    ref.read(relationshipAuthorityEpochProvider.notifier).invalidate();
    AppFeedback.showSuccess(context, '作品已发布');
  }

  Future<void> _deletePost(StatusPostEntity post) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: '撤下作品',
      message: '确认撤下这条作品吗？撤下后当前受众将无法读取。',
      confirmLabel: '撤下',
      cancelLabel: '取消',
      destructive: true,
    );
    if (!confirmed) return;
    try {
      await ref.read(statusRemoteDataSourceProvider).deleteStatusPost(post.id);
      _refreshPosts();
      if (!mounted) return;
      AppFeedback.showSuccess(context, '作品已撤下');
    } catch (e) {
      if (!mounted) return;
      AppFeedback.showError(context, '撤下失败：$e');
    }
  }

  Future<void> _changeAudience(StatusPostEntity post) async {
    final token = ref.read(sessionProvider).asData?.value.accessToken;
    final epoch = ref.read(relationshipAuthorityEpochProvider);
    bool current() =>
        token == ref.read(sessionProvider).asData?.value.accessToken &&
        epoch == ref.read(relationshipAuthorityEpochProvider);
    var audience = post.audience;
    String? policy;
    final choice = await showDialog<(String, String?)>(
      context: context,
      builder: (dialog) => StatefulBuilder(
        builder: (context, update) {
          return AlertDialog(
            title: const Text('修改作品受众和评论'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  isExpanded: true,
                  value: audience,
                  items: [
                    for (final value in [
                      'SELF',
                      'FRIENDS',
                      'PUBLIC_AUTHENTICATED',
                    ])
                      DropdownMenuItem(
                        value: value,
                        child: Text(statusAudienceLabel(value)),
                      ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    update(() {
                      audience = value;
                      if (value == 'SELF' && policy != 'OFF') policy = null;
                    });
                  },
                ),
                DropdownButton<String>(
                  isExpanded: true,
                  value: policy ?? 'KEEP',
                  items: [
                    const DropdownMenuItem(
                      value: 'KEEP',
                      child: Text('按当前评论设置预览'),
                    ),
                    for (final value in [
                      'OFF',
                      if (audience != 'SELF') ...[
                        'FRIENDS_ONLY',
                        'ALL_ELIGIBLE',
                      ],
                    ])
                      DropdownMenuItem(
                        value: value,
                        child: Text(statusCommentPolicyLabel(value)),
                      ),
                  ],
                  onChanged: (value) =>
                      update(() => policy = value == 'KEEP' ? null : value),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialog),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialog, (audience, policy)),
                child: const Text('查看影响'),
              ),
            ],
          );
        },
      ),
    );
    if (choice == null || !mounted || !current()) return;
    final remote = ref.read(statusRemoteDataSourceProvider);
    try {
      final preview = await remote.previewAudience(
        post.id,
        choice.$1,
        commentPolicy: choice.$2,
      );
      if (!mounted || !current()) return;
      final confirm = await AppConfirmDialog.show(
        context,
        title: '确认作品权限',
        message: [
          '作品：${statusAudienceLabel(choice.$1)}',
          '评论：${statusCommentPolicyLabel(preview.commentPolicy)}',
          '历史评论保留原受众限制。',
          if (preview.coverOwnerOnly)
            '封面仅自己可见。'
          else if (preview.keepsCoverAudience)
            '封面保留原受众上限。',
        ].join('\n'),
        confirmLabel: '保存',
        cancelLabel: '取消',
      );
      if (!confirm || !mounted || !current()) return;
      await remote.updateAudience(
        post.id,
        choice.$1,
        revision: preview.revision,
        commentPolicy: choice.$2,
      );
      if (!mounted || !current()) return;
      ref.read(relationshipAuthorityEpochProvider.notifier).invalidate();
      AppFeedback.showSuccess(context, '作品权限已保存');
    } catch (_) {
      if (!mounted || !current()) return;
      ref.read(relationshipAuthorityEpochProvider.notifier).invalidate();
      AppFeedback.showInfo(context, '结果尚未确认，正在重新读取当前作品权限。');
    }
  }

  Future<void> _toggleLike(StatusPostEntity post) async {
    try {
      final remote = ref.read(statusRemoteDataSourceProvider);
      if (post.likedByViewer) {
        await remote.unlikeStatusPost(post.id);
      } else {
        await remote.likeStatusPost(post.id);
      }
      ref
          .read(frontendTelemetryProvider)
          .statusPostLiked(
            sourcePage: 'status_square',
            postId: post.id,
            liked: !post.likedByViewer,
          );
      _refreshPosts();
    } catch (e) {
      if (!mounted) return;
      AppFeedback.showError(context, '操作失败：$e');
    }
  }

  Future<void> _reportPost(StatusPostEntity post) async {
    final remote = ref.read(statusRemoteDataSourceProvider);
    await StatusReportSheet.show(
      context,
      targetName: post.displayAuthorName,
      onSubmit: ({required String reasonCode, String? detail}) async {
        await remote.reportStatusPost(
          postId: post.id,
          reasonCode: reasonCode,
          detail: detail,
        );
        ref
            .read(frontendTelemetryProvider)
            .statusPostReported(sourcePage: 'status_square', postId: post.id);
      },
    );
  }

  Future<void> _openAuthor(StatusPostEntity post) async {
    ref
        .read(frontendTelemetryProvider)
        .statusAuthorOpened(sourcePage: 'status_square', userId: post.authorId);
    if (!mounted) return;
    await context.push(
      '${AppRouteNames.statusAuthor}/${post.authorId}?name=${Uri.encodeComponent(post.displayAuthorName)}',
    );
  }

  Future<void> _savePostForLater(StatusPostEntity post) async {
    final token = ref.read(sessionProvider).asData?.value.accessToken;
    final epoch = ref.read(relationshipAuthorityEpochProvider);
    bool current() =>
        mounted &&
        token == ref.read(sessionProvider).asData?.value.accessToken &&
        epoch == ref.read(relationshipAuthorityEpochProvider);
    try {
      await ref.read(relationshipApiProvider).call(
        'PUT',
        '/status/posts/${post.id}/favorite',
        {'favorited': !post.favoritedByViewer},
      );
      if (current()) _refreshPosts();
    } catch (error) {
      if (mounted && current()) {
        if (error is RelationshipFailure &&
            const [401, 403, 404].contains(error.statusCode)) {
          setState(() => _feedUnavailable = true);
          ref.invalidate(statusPostPageProvider);
          ref.invalidate(statusPostsProvider);
          AppFeedback.showInfo(context, '当前动态已不可用，旧内容已清除。');
        } else {
          AppFeedback.showError(context, '收藏状态未确认，可按原操作重试：$error');
        }
      }
    }
  }

  Future<void> _openLowPressureChatPath(StatusPostEntity post) async {
    final token = ref.read(sessionProvider).asData?.value.accessToken;
    final epoch = ref.read(relationshipAuthorityEpochProvider);
    bool current() =>
        mounted &&
        token == ref.read(sessionProvider).asData?.value.accessToken &&
        epoch == ref.read(relationshipAuthorityEpochProvider);
    try {
      final result = await ref
          .read(relationshipApiProvider)
          .call('GET', '/connections/${post.authorId}');
      if (!mounted || !current()) return;
      await context.push(
        result['gates']?['live_read_allowed'] == true
            ? '/live-chat/${post.authorId}'
            : '/social/friends/${post.authorId}',
      );
    } catch (error) {
      if (mounted && current()) {
        AppFeedback.showError(context, '当前联系入口不可用：$error');
      }
    }
  }

  Future<void> _pickAndUploadCoverImage({bool video = false}) async {
    if (_submitting || _coverStage == _CoverUploadStage.uploading) return;
    final token = ref.read(sessionProvider).asData?.value.accessToken;
    bool current() =>
        mounted && token == ref.read(sessionProvider).asData?.value.accessToken;
    ref
        .read(frontendTelemetryProvider)
        .statusImagePickerOpened(sourcePage: 'status_square');
    final XFile? picked;
    try {
      picked = video
          ? await _imagePicker.pickVideo(source: ImageSource.gallery)
          : await _imagePicker.pickImage(
              source: ImageSource.gallery,
              imageQuality: 88,
            );
    } catch (_) {
      if (mounted && current()) {
        AppFeedback.showError(context, '无法打开媒体选择器，请重试');
      }
      return;
    }
    final selected = picked;
    if (selected == null || !current()) return;

    setState(() {
      _coverMediaType = video ? 'video' : 'image';
      _coverImagePath = selected.path;
      _coverImageName = selected.name.isNotEmpty
          ? selected.name
          : (video ? 'status.mp4' : 'status.jpg');
      _coverStage = _CoverUploadStage.uploading;
      _coverUploadError = null;
    });
    ref
        .read(frontendTelemetryProvider)
        .statusImageUploadStarted(sourcePage: 'status_square');

    try {
      final api = ref.read(apiClientProvider);
      final form = FormData.fromMap({
        'media_type': _coverMediaType,
        'original_name': _coverImageName,
        'file': await MultipartFile.fromFile(
          selected.path,
          filename: _coverImageName,
        ),
        'metadata': {'source_page': 'status_square'},
      });
      final result = await api.post(
        '/api/v1/media',
        body: form,
        options: Options(extra: {requestSessionGuardKey: current}),
      );
      if (!current()) return;
      if (result is! NetworkSuccess<Map<String, dynamic>>) {
        throw Exception(
          (result as NetworkFailure<Map<String, dynamic>>).message,
        );
      }
      final asset = result.data['asset'];
      if (asset is! Map<String, dynamic>) {
        throw Exception('media upload did not return an asset');
      }
      final assetId = (asset['id'] as num?)?.toInt() ?? 0;
      final status = (asset['status'] ?? '').toString();
      if (assetId <= 0 ||
          !const ['uploaded', 'ready'].contains(status) ||
          (video && status != 'ready')) {
        throw Exception('媒体尚未准备好，请重新选择后重试');
      }
      if (!current()) return;
      setState(() {
        _coverMediaAssetId = assetId > 0 ? assetId : null;
        _coverStage = status == 'processing'
            ? _CoverUploadStage.processing
            : _CoverUploadStage.ready;
        _coverUploadError = null;
      });
      ref
          .read(frontendTelemetryProvider)
          .statusImageUploadSucceeded(
            sourcePage: 'status_square',
            assetId: assetId,
          );
      if (!mounted) return;
      AppFeedback.showSuccess(context, '媒体已准备好，可以发布状态');
    } catch (e) {
      if (!current()) return;
      setState(() {
        _coverMediaAssetId = null;
        _coverStage = _CoverUploadStage.failed;
        _coverUploadError = e.toString();
      });
      ref
          .read(frontendTelemetryProvider)
          .statusImageUploadFailed(
            sourcePage: 'status_square',
            errorCode: 'upload_failed',
          );
      if (!mounted) return;
      AppFeedback.showError(context, '媒体上传失败，请重新选择后重试');
    }
  }

  void _clearCoverImage() {
    setState(() {
      _coverMediaType = 'image';
      _coverImagePath = null;
      _coverImageName = null;
      _coverMediaAssetId = null;
      _coverUploadError = null;
      _coverStage = _CoverUploadStage.idle;
    });
  }

  Widget _buildCoverPreview(BuildContext context) {
    final t = context.appTokens;
    final label = switch (_coverStage) {
      _CoverUploadStage.uploading => '上传中',
      _CoverUploadStage.processing => '处理中',
      _CoverUploadStage.failed => '失败',
      _CoverUploadStage.ready => '已完成',
      _CoverUploadStage.idle => '待选择',
    };
    final detail =
        _coverUploadError ??
        switch (_coverStage) {
          _CoverUploadStage.uploading => '封面正在准备中。',
          _CoverUploadStage.processing => '媒体正在处理中，请稍后再试。',
          _CoverUploadStage.failed => '封面上传失败，可重试或重新选择。',
          _CoverUploadStage.ready => '封面已可用于状态发布。',
          _CoverUploadStage.idle => '图片或视频二选一。视频MP4/H.264，最长30秒，最大25 MiB。',
        };

    return AppInfoSectionCard(
      title: '动态媒体',
      subtitle: '选择一张图片或一个视频，上传完成后发布',
      leadingIcon: Icons.photo_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_coverImagePath != null && _coverMediaType == 'video')
            ListTile(
              leading: const Icon(Icons.movie_outlined),
              title: Text(_coverImageName ?? '视频'),
              subtitle: const Text('MP4 · H.264 · 最长30秒 · 最大25 MiB'),
            )
          else if (_coverImagePath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(t.radius.lg),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.file(
                  File(_coverImagePath!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: t.surface,
                    alignment: Alignment.center,
                    child: const Text('图片预览失败'),
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(t.spacing.lg),
              decoration: BoxDecoration(
                color: t.surface.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(t.radius.lg),
                border: Border.all(color: t.overlay.withValues(alpha: 0.22)),
              ),
              child: Column(
                children: [
                  Icon(Icons.image_outlined, color: t.textSecondary),
                  SizedBox(height: t.spacing.xs),
                  Text(
                    '暂未选择图片或视频',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: t.textSecondary),
                  ),
                ],
              ),
            ),
          SizedBox(height: t.spacing.sm),
          Row(
            children: [
              AppChoiceChip(label: label, selected: true),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  detail,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
                ),
              ),
            ],
          ),
          SizedBox(height: t.spacing.sm),
          Wrap(
            spacing: t.spacing.xs,
            runSpacing: t.spacing.xs,
            children: [
              FilledButton.icon(
                onPressed:
                    _submitting || _coverStage == _CoverUploadStage.uploading
                    ? null
                    : () => _pickAndUploadCoverImage(),
                icon: _coverStage == _CoverUploadStage.uploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.photo_library_outlined),
                label: Text(
                  _coverStage == _CoverUploadStage.uploading
                      ? '上传中...'
                      : '选择图片',
                ),
              ),
              OutlinedButton.icon(
                onPressed:
                    _submitting || _coverStage == _CoverUploadStage.uploading
                    ? null
                    : () => _pickAndUploadCoverImage(video: true),
                icon: const Icon(Icons.video_library_outlined),
                label: const Text('选择视频'),
              ),
              OutlinedButton(
                onPressed:
                    _submitting ||
                        _coverStage == _CoverUploadStage.uploading ||
                        _coverImagePath == null
                    ? null
                    : _clearCoverImage,
                child: const Text('清除媒体'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionProvider, (previous, next) {
      if (previous?.asData?.value.accessToken ==
          next.asData?.value.accessToken) {
        return;
      }
      _clearLocalAuthority();
    });
    ref.listen(relationshipAuthorityEpochProvider, (previous, next) {
      // Peer authority refresh clears/reloads the feed through its providers.
      // An unpublished, owner-only draft and upload keep their session guard.
      if (previous != next) {
        setState(() {
          _feedUnavailable = false;
          _submitting = false;
        });
      }
    });
    final t = context.appTokens;
    final postsAsync = ref.watch(statusPostPageProvider);
    final pageCursor = ref.watch(statusPageCursorProvider);
    final profileAsync = ref.watch(profileProvider);

    final prefillIdentity = ref.read(sessionProvider).asData?.value.accessToken;
    final prefillEpoch = ref.read(relationshipAuthorityEpochProvider);
    if (!profileAsync.isLoading) {
      profileAsync.whenData((state) {
        final city = state.summary?.city.trim() ?? '';
        if (!_prefilledLocation &&
            city.isNotEmpty &&
            _locationController.text.trim().isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted ||
                _prefilledLocation ||
                prefillIdentity !=
                    ref.read(sessionProvider).asData?.value.accessToken ||
                prefillEpoch != ref.read(relationshipAuthorityEpochProvider)) {
              return;
            }
            if (_locationController.text.trim().isEmpty) {
              _locationController.text = city;
            }
            _prefilledLocation = true;
          });
        }
      });
    }

    return AppScaffold(
      backdrop: widget.publishOnly ? UiS3Backdrop.quiet : UiS3Backdrop.reading,
      showEmptyArt:
          !widget.publishOnly &&
          !_feedUnavailable &&
          postsAsync.asData?.value.items.isEmpty == true,
      appBar: AppTopBar(
        title: widget.publishOnly
            ? '发布动态'
            : UiS3Design.enabled
            ? '好友动态'
            : '好友可见社区',
        mode: AppTopBarMode.backTitle,
        actions: [
          if (UiS3Design.enabled && !widget.publishOnly)
            IconButton(
              tooltip: '发布动态',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) => const StatusSquarePage(publishOnly: true),
                ),
              ),
            ),
          if (!widget.publishOnly) ...[
            IconButton(
              tooltip: '我的收藏',
              icon: const Icon(Icons.bookmarks_outlined),
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const StatusFavoritesPage(),
                  ),
                );
                if (mounted) _refreshPosts();
              },
            ),
            IconButton(
              onPressed: () => _refreshPosts(firstPage: true),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshPosts(firstPage: true);
          await ref.read(statusPostPageProvider.future);
        },
        child: ListView(
          key: PageStorageKey(
            widget.publishOnly ? 'status-publish' : 'status-feed',
          ),
          padding: EdgeInsets.fromLTRB(0, t.spacing.sm, 0, t.spacing.huge),
          children: [
            if (!UiS3Design.enabled) ...[
              AppInfoSectionCard(
                title: '谁能看见',
                subtitle: '受众仅自己或双向好友，展示与治理分开',
                leadingIcon: Icons.layers_outlined,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _TierChip(label: '好友层', description: '双向好友可见'),
                    _TierChip(label: '私密层', description: '仅自己可见'),
                  ],
                ),
              ),
              SizedBox(height: t.spacing.md),
            ],
            if (widget.publishOnly || !UiS3Design.enabled)
              AppInfoSectionCard(
                title: '发布动态',
                subtitle: '默认向双向好友发布，评论也仅向双向好友开放',
                leadingIcon: Icons.publish_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      controller: _titleController,
                      label: '标题',
                      hint: '例如：今晚想找个人散步',
                      maxLength: 40,
                    ),
                    SizedBox(height: t.spacing.sm),
                    AppTextField(
                      controller: _bodyController,
                      label: '内容',
                      hint: '写下一个轻松、自然的状态',
                      maxLength: 240,
                      minLines: 3,
                      maxLines: 5,
                    ),
                    SizedBox(height: t.spacing.sm),
                    AppTextField(
                      controller: _locationController,
                      label: '城市（可留空）',
                      hint: '只写城市，不填写精确地址或联系方式',
                      maxLength: 60,
                    ),
                    SizedBox(height: t.spacing.sm),
                    Wrap(
                      spacing: t.spacing.xs,
                      runSpacing: t.spacing.xs,
                      children: [
                        AppChoiceChip(
                          label: '双向好友',
                          selected: _audience == 'FRIENDS',
                          onTap: () => setState(() => _audience = 'FRIENDS'),
                        ),
                        AppChoiceChip(
                          label: '仅自己',
                          selected: _audience == 'SELF',
                          onTap: () => setState(() {
                            _audience = 'SELF';
                            if (_commentPolicy != 'OFF') _commentPolicy = null;
                          }),
                        ),
                        AppChoiceChip(
                          label: '登录用户',
                          selected: _audience == 'PUBLIC_AUTHENTICATED',
                          onTap: () => setState(
                            () => _audience = 'PUBLIC_AUTHENTICATED',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: t.spacing.sm),
                    DropdownButton<String>(
                      value: _commentPolicy ?? 'DEFAULT',
                      isExpanded: true,
                      items: [
                        DropdownMenuItem(
                          value: 'DEFAULT',
                          child: Text(
                            _audience == 'SELF' ? '默认关闭评论' : '默认仅双向好友可评论',
                          ),
                        ),
                        for (final value in [
                          'OFF',
                          if (_audience != 'SELF') ...[
                            'FRIENDS_ONLY',
                            'ALL_ELIGIBLE',
                          ],
                        ])
                          DropdownMenuItem(
                            value: value,
                            child: Text(statusCommentPolicyLabel(value)),
                          ),
                      ],
                      onChanged: _submitting
                          ? null
                          : (value) => setState(
                              () => _commentPolicy = value == 'DEFAULT'
                                  ? null
                                  : value,
                            ),
                    ),
                    _buildCoverPreview(context),
                    SizedBox(height: t.spacing.sm),
                    FilledButton.icon(
                      onPressed: _submitting ? null : _publish,
                      icon: _submitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send_rounded),
                      label: Text(_submitting ? '发布中...' : '发布状态'),
                    ),
                    TextButton(
                      onPressed: _submitting
                          ? null
                          : () => _publish(checkOnly: true),
                      child: const Text('核对上次发布'),
                    ),
                  ],
                ),
              ),
            SizedBox(height: t.spacing.md),
            if (!widget.publishOnly)
              AppInfoSectionCard(
                title: '近期动态',
                subtitle: '显示你有权限阅读的作品',
                leadingIcon: Icons.dynamic_feed_rounded,
                child: postsAsync.when(
                  skipLoadingOnReload: false,
                  skipLoadingOnRefresh: false,
                  loading: () => const AppLoadingSkeleton(lines: 5),
                  error: (e, _) => AppErrorState(
                    title: _feedUnavailable ? '当前动态已不可用' : '好友动态读取未完成',
                    description: _feedUnavailable
                        ? '旧内容已清除，请读取当前有权动态。'
                        : '网络或当前受众授权尚未完成，请刷新后重试。',
                    retryLabel: _feedUnavailable ? '读取当前动态' : '重新加载当前页',
                    onRetry: _refreshPosts,
                  ),
                  data: (page) {
                    if (_feedUnavailable) {
                      return AppEmptyState(
                        title: '当前动态已不可用',
                        description: '已清除旧内容，请读取当前有权动态。',
                        actionLabel: '读取当前动态',
                        onAction: () => _refreshPosts(firstPage: true),
                      );
                    }
                    final posts = page.items;
                    if (posts.isEmpty) {
                      return Column(
                        children: [
                          AppEmptyState(
                            title: '当前没有有权读取的动态',
                            description: '仅显示本人或当前好友明确分享的内容；空页不代表可查看陌生人。',
                            actionLabel: '返回首页',
                            onAction: () => context.go(AppRouteNames.home),
                          ),
                          if (pageCursor != null)
                            OutlinedButton(
                              key: const Key('community-first-page'),
                              onPressed: () => _refreshPosts(firstPage: true),
                              child: const Text('返回社区首屏'),
                            ),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        for (final post in posts)
                          Padding(
                            padding: EdgeInsets.only(bottom: t.spacing.sm),
                            child: StatusPostCard(
                              post: post,
                              onOpenDetail: UiS3Design.enabled
                                  ? () => _openPostDetail(post)
                                  : null,
                              onTapAuthor: () => _openAuthor(post),
                              onContinueUnderstand: () => _openAuthor(post),
                              onViewProfile: () => _openAuthor(post),
                              onSaveForLater: () => _savePostForLater(post),
                              onLowPressureChat: () =>
                                  _openLowPressureChatPath(post),
                              onLikeToggle: () => _toggleLike(post),
                              onReport: post.canDelete
                                  ? null
                                  : () => _reportPost(post),
                              onChangeAudience: post.canDelete
                                  ? () => _changeAudience(post)
                                  : null,
                              onRequestDataDeletion: post.canDelete
                                  ? () => openObjectDataRights(
                                      context,
                                      'work',
                                      post.id.toString(),
                                    )
                                  : null,
                              onDelete: post.canDelete
                                  ? () => _deletePost(post)
                                  : null,
                            ),
                          ),
                        Wrap(
                          spacing: 8,
                          children: [
                            if (pageCursor != null)
                              OutlinedButton(
                                key: const Key('community-first-page'),
                                onPressed: () => _refreshPosts(firstPage: true),
                                child: const Text('返回社区首屏'),
                              ),
                            if (page.hasMore && page.nextCursor != null)
                              OutlinedButton(
                                key: const Key('community-next-page'),
                                onPressed: () => ref
                                    .read(statusPageCursorProvider.notifier)
                                    .nextPage(page.nextCursor!),
                                child: const Text('加载下一页（替换当前页）'),
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TierChip extends StatelessWidget {
  const _TierChip({required this.label, required this.description});

  final String label;
  final String description;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: t.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(t.radius.lg),
        border: Border.all(color: t.overlay.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: t.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: t.textSecondary),
          ),
        ],
      ),
    );
  }
}

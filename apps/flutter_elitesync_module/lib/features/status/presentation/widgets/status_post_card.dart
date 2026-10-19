import 'dart:async';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_tag.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/status/domain/entities/status_post_entity.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';

class StatusPostCard extends ConsumerWidget {
  const StatusPostCard({
    super.key,
    required this.post,
    this.onTapAuthor,
    this.onLikeToggle,
    this.onReport,
    this.onDelete,
    this.onChangeAudience,
    this.onContinueUnderstand,
    this.onViewProfile,
    this.onSaveForLater,
    this.onLowPressureChat,
    this.compact = false,
  });

  final StatusPostEntity post;
  final VoidCallback? onTapAuthor;
  final VoidCallback? onLikeToggle;
  final VoidCallback? onReport;
  final VoidCallback? onDelete;
  final VoidCallback? onChangeAudience;
  final VoidCallback? onContinueUnderstand;
  final VoidCallback? onViewProfile;
  final VoidCallback? onSaveForLater;
  final VoidCallback? onLowPressureChat;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.appTokens;
    final time = _formatStatusDate(post.createdAt);
    final showActions =
        onLikeToggle != null ||
        onReport != null ||
        onDelete != null ||
        onChangeAudience != null;
    final showReturnflowActions =
        onContinueUnderstand != null ||
        onViewProfile != null ||
        onSaveForLater != null ||
        onLowPressureChat != null;
    final coverAssetId = post.coverMediaAssetId;
    final displayTitle = _displayStatusText(post.title);
    final displayBody = _displayStatusText(post.body);
    final displayLocation = _displayStatusLocation(post.locationName);

    return Material(
      color: Colors.transparent,
      child: AppInfoSectionCard(
        title: displayTitle,
        subtitle: '${post.displayAuthorName} · $displayLocation · $time',
        leadingIcon: Icons.waving_hand_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppTag(
                  label: post.visibilityLabel,
                  variant: AppTagVariant.neutral,
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: onTapAuthor,
                  borderRadius: BorderRadius.circular(t.radius.md),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    child: Text(
                      post.displayAuthorName,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  post.authorLayerLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: t.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${post.likesCount} 喜欢',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: t.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (coverAssetId != null && coverAssetId > 0) ...[
              SizedBox(height: t.spacing.sm),
              AuthenticatedStatusImage(assetId: coverAssetId),
            ],
            SizedBox(height: t.spacing.sm),
            Text(
              displayBody,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: t.textPrimary,
                height: 1.45,
              ),
            ),
            if (!compact) ...[
              SizedBox(height: t.spacing.sm),
              Text(
                '仅展示轻量动态信息，不改写资料或匹配结果。',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: t.textSecondary),
              ),
            ],
            if (showReturnflowActions) ...[
              SizedBox(height: t.spacing.sm),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(t.spacing.sm),
                decoration: BoxDecoration(
                  color: t.secondarySurface.withValues(alpha: 0.54),
                  borderRadius: BorderRadius.circular(t.radius.md),
                  border: Border.all(color: t.overlay.withValues(alpha: 0.42)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '低压关系动作',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '先了解、再决定是否聊天；这些动作不会自动发送消息。',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: t.textSecondary,
                        height: 1.35,
                      ),
                    ),
                    SizedBox(height: t.spacing.xs),
                    Wrap(
                      spacing: t.spacing.xs,
                      runSpacing: t.spacing.xs,
                      children: [
                        if (onContinueUnderstand != null)
                          OutlinedButton.icon(
                            onPressed: onContinueUnderstand,
                            icon: const Icon(Icons.explore_outlined),
                            label: const Text('继续了解'),
                          ),
                        if (onViewProfile != null)
                          OutlinedButton.icon(
                            onPressed: onViewProfile,
                            icon: const Icon(Icons.person_search_outlined),
                            label: const Text('看看资料'),
                          ),
                        if (onSaveForLater != null)
                          OutlinedButton.icon(
                            onPressed: onSaveForLater,
                            icon: const Icon(Icons.bookmark_border_rounded),
                            label: const Text('稍后再聊'),
                          ),
                        if (onLowPressureChat != null)
                          OutlinedButton.icon(
                            onPressed: onLowPressureChat,
                            icon: const Icon(Icons.chat_bubble_outline_rounded),
                            label: const Text('低压私聊'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            if (showActions) ...[
              SizedBox(height: t.spacing.sm),
              Wrap(
                spacing: t.spacing.xs,
                runSpacing: t.spacing.xs,
                children: [
                  if (onLikeToggle != null)
                    OutlinedButton.icon(
                      onPressed: onLikeToggle,
                      icon: Icon(
                        post.likedByViewer
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                      ),
                      label: Text(post.likedByViewer ? '取消喜欢' : '喜欢'),
                    ),
                  if (onReport != null)
                    OutlinedButton.icon(
                      onPressed: onReport,
                      icon: const Icon(Icons.flag_outlined),
                      label: const Text('举报'),
                    ),
                  if (onChangeAudience != null)
                    TextButton(
                      onPressed: onChangeAudience,
                      child: const Text('修改受众'),
                    ),
                  if (onDelete != null)
                    OutlinedButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('删除'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _displayStatusText(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return '示例内容';
  if (_looksLikeStatusTestNoise(trimmed)) {
    return '示例内容';
  }
  final lower = trimmed.toLowerCase();
  if (lower == 'test' ||
      lower.contains('codex test') ||
      trimmed.contains('新消息测试')) {
    return '示例内容';
  }
  return value;
}

String _displayStatusLocation(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return '同城';
  if (_looksLikeStatusTestNoise(trimmed)) return '同城';
  final lower = trimmed.toLowerCase();
  if (lower.contains('test') || trimmed.contains('教师食堂')) return '同城';
  return trimmed;
}

bool _looksLikeStatusTestNoise(String value) {
  if (RegExp(r'^\d{3,}$').hasMatch(value)) return true;
  if (RegExp(r'^\d{3,}').hasMatch(value) && value.contains('教师食堂')) {
    return true;
  }
  return false;
}

String _formatStatusDate(DateTime value) {
  final local = value.toLocal();
  return '${local.year}年${local.month}月${local.day}日';
}

class AuthenticatedStatusImage extends ConsumerStatefulWidget {
  const AuthenticatedStatusImage({super.key, required this.assetId});
  final int assetId;
  @override
  ConsumerState<AuthenticatedStatusImage> createState() =>
      _AuthenticatedStatusImageState();
}

class _AuthenticatedStatusImageState
    extends ConsumerState<AuthenticatedStatusImage> {
  MemoryImage? _image;
  CancelToken? _cancel;
  int _generation = 0;
  bool _loading = false;
  late final ProviderSubscription<AsyncValue<SessionState>>
  _sessionSubscription;
  late final ProviderSubscription<int> _authoritySubscription;

  void _clear() {
    _generation++;
    _cancel?.cancel('Private media authority changed');
    _cancel = null;
    final old = _image;
    _image = null;
    if (old != null) unawaited(old.evict());
  }

  @override
  void initState() {
    super.initState();
    _sessionSubscription = ref.listenManual(
      sessionProvider,
      (_, next) => _reload(),
    );
    _authoritySubscription = ref.listenManual(
      relationshipAuthorityEpochProvider,
      (_, next) => _reload(),
    );
    Future.microtask(_reload);
  }

  Future<void> _reload() async {
    if (!mounted) return;
    _clear();
    final generation = _generation;
    final session = ref.read(sessionProvider).asData?.value;
    final epoch = ref.read(relationshipAuthorityEpochProvider);
    final token = session?.accessToken;
    final eligible =
        session?.isLoggedIn == true &&
        token != null &&
        token.isNotEmpty &&
        widget.assetId > 0;
    setState(() => _loading = eligible);
    if (!eligible) return;
    bool current() =>
        mounted &&
        generation == _generation &&
        identical(session, ref.read(sessionProvider).asData?.value) &&
        epoch == ref.read(relationshipAuthorityEpochProvider);
    final cancel = CancelToken();
    _cancel = cancel;
    try {
      final response = await ref
          .read(dioProvider)
          .get<List<int>>(
            '/api/v1/media/${widget.assetId}/content',
            cancelToken: cancel,
            options: Options(
              responseType: ResponseType.bytes,
              followRedirects: false,
              headers: {'Authorization': 'Bearer $token'},
              extra: {requestSessionGuardKey: current},
            ),
          );
      if (!current()) return;
      final bytes = response.data;
      if (response.statusCode != 200 || bytes == null || bytes.isEmpty) {
        throw StateError('Private image unavailable');
      }
      setState(() => _image = MemoryImage(Uint8List.fromList(bytes)));
    } catch (_) {
      if (current()) setState(() => _image = null);
    } finally {
      if (current()) setState(() => _loading = false);
    }
  }

  @override
  void didUpdateWidget(AuthenticatedStatusImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetId != widget.assetId) _reload();
  }

  @override
  void dispose() {
    _sessionSubscription.close();
    _authoritySubscription.close();
    _clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return ClipRRect(
      borderRadius: BorderRadius.circular(t.radius.lg),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: ColoredBox(
          color: t.surface,
          child: _image == null
              ? Center(child: Text(_loading ? '图片加载中' : '图片暂不可用'))
              : Image(
                  key: ValueKey('private-status-image-$_generation'),
                  image: _image!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.broken_image_outlined),
                        const SizedBox(height: 8),
                        Text(
                          '图片加载失败',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: t.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

/// Displays up to six parent-provided, authenticated photo widgets.
/// The parent owns selection, upload, ordering, removal and authorization.
class ShowcasePhotoEditor extends StatelessWidget {
  const ShowcasePhotoEditor({
    super.key,
    required this.photos,
    required this.busy,
    required this.onAdd,
    required this.onRemove,
    required this.onMoveEarlier,
    required this.onMoveLater,
  }) : assert(photos.length <= 6);

  final List<Widget> photos;
  final bool busy;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final ValueChanged<int> onMoveEarlier;
  final ValueChanged<int> onMoveLater;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('展示照片', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: t.spacing.xs),
        Text(
          photos.isEmpty ? '尚未添加照片，最多可添加 6 张。' : '最多可添加 6 张。',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        SizedBox(height: t.spacing.sm),
        Wrap(
          spacing: t.spacing.sm,
          runSpacing: t.spacing.sm,
          children: [
            for (var index = 0; index < photos.length; index++)
              SizedBox(
                width: 144,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Semantics(
                      label: '第 ${index + 1} 张展示照片',
                      image: true,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(t.radius.md),
                        child: SizedBox.square(
                          dimension: 144,
                          child: photos[index],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          tooltip: '前移第 ${index + 1} 张照片',
                          onPressed: busy || index == 0
                              ? null
                              : () => onMoveEarlier(index),
                          icon: const Icon(Icons.arrow_back),
                        ),
                        IconButton(
                          tooltip: '后移第 ${index + 1} 张照片',
                          onPressed: busy || index == photos.length - 1
                              ? null
                              : () => onMoveLater(index),
                          icon: const Icon(Icons.arrow_forward),
                        ),
                        IconButton(
                          tooltip: '移除第 ${index + 1} 张照片',
                          onPressed: busy ? null : () => onRemove(index),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
        SizedBox(height: t.spacing.sm),
        OutlinedButton.icon(
          onPressed: busy || photos.length >= 6 ? null : onAdd,
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: const Text('添加照片'),
        ),
      ],
    );
  }
}

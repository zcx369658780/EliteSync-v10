import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

class MessageInputBar extends StatelessWidget {
  const MessageInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    required this.sending,
    this.onAttach,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool sending;
  final VoidCallback? onAttach;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: t.spacing.xs,
          vertical: t.spacing.xxs,
        ),
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            final canSend = !sending && value.text.trim().isNotEmpty;
            return Row(
              children: [
                IconButton(
                  tooltip: '添加图片或视频',
                  onPressed: sending ? null : onAttach,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: '写一句轻问候，确认后手动发送',
                      isDense: true,
                      filled: true,
                      fillColor: t.secondarySurface.withValues(alpha: 0.62),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(t.radius.md),
                        borderSide: BorderSide(
                          color: t.overlay.withValues(alpha: 0.5),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(t.radius.md),
                        borderSide: BorderSide(
                          color: t.overlay.withValues(alpha: 0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(t.radius.md),
                        borderSide: BorderSide(color: t.brandPrimary),
                      ),
                    ),
                  ),
                ),
                Tooltip(
                  message: sending ? '发送中' : '手动发送',
                  child: IconButton.filledTonal(
                    onPressed: canSend ? onSend : null,
                    icon: sending
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: t.brandPrimary,
                            ),
                          )
                        : const Icon(Icons.send_rounded),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

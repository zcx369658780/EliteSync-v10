import 'package:flutter/material.dart';

enum AppSecondaryButtonStyle { soft, outline }

class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.fullWidth = false,
    this.style = AppSecondaryButtonStyle.soft,
    this.prefixIcon,
    this.suffixIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;
  final AppSecondaryButtonStyle style;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  bool get _enabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
        ] else if (prefixIcon != null) ...[
          prefixIcon!,
          const SizedBox(width: 8),
        ],
        Flexible(child: Text(label, textAlign: TextAlign.center)),
        if (!isLoading && suffixIcon != null) ...[
          const SizedBox(width: 8),
          suffixIcon!,
        ],
      ],
    );
    final Widget button = style == AppSecondaryButtonStyle.outline
        ? OutlinedButton(onPressed: _enabled ? onPressed : null, child: content)
        : FilledButton.tonal(
            onPressed: _enabled ? onPressed : null,
            child: content,
          );
    return SizedBox(width: fullWidth ? double.infinity : null, child: button);
  }
}

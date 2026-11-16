import 'package:flutter/material.dart';
import 'app_theme_extensions.dart';

ButtonStyle appOptionButtonStyle(ThemeData theme, {required bool selected}) {
  final tokens = theme.extension<AppThemeTokens>();
  final scheme = theme.colorScheme;
  return ButtonStyle(
    minimumSize: const WidgetStatePropertyAll(Size(48, 52)),
    foregroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return tokens?.textSecondary ?? scheme.onSurfaceVariant;
      }
      return selected ? scheme.onPrimaryContainer : scheme.primary;
    }),
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return tokens?.secondarySurface ?? scheme.surfaceContainerHighest;
      }
      return selected
          ? scheme.primaryContainer
          : tokens?.surface ?? scheme.surface;
    }),
    side: WidgetStateProperty.resolveWith(
      (states) => BorderSide(
        color: states.contains(WidgetState.disabled)
            ? tokens?.textSecondary ?? scheme.onSurfaceVariant
            : scheme.primary,
        width: selected || states.contains(WidgetState.focused) ? 2 : 1,
      ),
    ),
  );
}

ButtonStyle appDestructiveButtonStyle(ThemeData theme) {
  final tokens = theme.extension<AppThemeTokens>();
  return ButtonStyle(
    foregroundColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.disabled)
          ? tokens?.textSecondary ?? theme.colorScheme.onSurfaceVariant
          : theme.colorScheme.error,
    ),
    backgroundColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.disabled)
          ? tokens?.secondarySurface ??
                theme.colorScheme.surfaceContainerHighest
          : tokens?.surface ?? theme.colorScheme.surface,
    ),
    overlayColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.disabled)
          ? Colors.transparent
          : states.contains(WidgetState.pressed) ||
                states.contains(WidgetState.focused) ||
                states.contains(WidgetState.hovered)
          ? theme.colorScheme.error.withValues(alpha: .06)
          : Colors.transparent,
    ),
    side: WidgetStateProperty.resolveWith(
      (states) =>
          states.contains(WidgetState.focused) &&
              !states.contains(WidgetState.disabled)
          ? BorderSide(color: theme.colorScheme.error, width: 2)
          : BorderSide.none,
    ),
  );
}

ThemeData applyAppComponentTheme(ThemeData theme) {
  final tokens = theme.extension<AppThemeTokens>()!;
  final scheme = theme.colorScheme;
  final shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(tokens.radius.md),
  );
  final actions = ButtonStyle(
    minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    ),
    shape: WidgetStatePropertyAll(shape),
    textStyle: WidgetStatePropertyAll(theme.textTheme.titleSmall),
    overlayColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.disabled)
          ? Colors.transparent
          : states.contains(WidgetState.pressed) ||
                states.contains(WidgetState.focused) ||
                states.contains(WidgetState.hovered)
          ? scheme.primary.withValues(alpha: .06)
          : Colors.transparent,
    ),
    side: WidgetStateProperty.resolveWith(
      (states) =>
          states.contains(WidgetState.focused) &&
              !states.contains(WidgetState.disabled)
          ? BorderSide(
              color: states.contains(WidgetState.selected)
                  ? scheme.onPrimaryContainer
                  : scheme.onPrimary,
              width: 2,
            )
          : BorderSide.none,
    ),
  );
  final secondary = appOptionButtonStyle(theme, selected: false).merge(actions);
  final primary = actions.copyWith(
    foregroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) return tokens.textSecondary;
      return states.contains(WidgetState.selected)
          ? scheme.onPrimaryContainer
          : scheme.onPrimary;
    }),
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) return tokens.secondarySurface;
      return states.contains(WidgetState.selected)
          ? scheme.primaryContainer
          : scheme.primary;
    }),
    overlayColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.disabled)
          ? Colors.transparent
          : states.contains(WidgetState.pressed) ||
                states.contains(WidgetState.focused) ||
                states.contains(WidgetState.hovered)
          ? scheme.onPrimary.withValues(alpha: .06)
          : Colors.transparent,
    ),
  );
  return theme.copyWith(
    materialTapTargetSize: MaterialTapTargetSize.padded,
    filledButtonTheme: FilledButtonThemeData(style: primary),
    outlinedButtonTheme: OutlinedButtonThemeData(style: secondary),
    textButtonTheme: TextButtonThemeData(
      style: secondary.copyWith(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? tokens.secondarySurface
              : Colors.transparent,
        ),
        side: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.focused) &&
                  !states.contains(WidgetState.disabled)
              ? BorderSide(color: scheme.primary, width: 2)
              : BorderSide.none,
        ),
      ),
    ),
    iconButtonTheme: const IconButtonThemeData(
      style: ButtonStyle(minimumSize: WidgetStatePropertyAll(Size(48, 48))),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: tokens.pageBackground,
      foregroundColor: tokens.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: tokens.surface,
      contentPadding: const EdgeInsets.all(16),
      helperMaxLines: 5,
      errorMaxLines: 5,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        borderSide: BorderSide(color: tokens.browseBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        borderSide: BorderSide(color: tokens.brandPrimary, width: 2),
      ),
    ),
    expansionTileTheme: ExpansionTileThemeData(
      textColor: tokens.textPrimary,
      collapsedTextColor: tokens.textPrimary,
      iconColor: tokens.brandPrimary,
      collapsedIconColor: tokens.textSecondary,
    ),
  );
}

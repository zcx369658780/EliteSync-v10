import 'package:flutter/material.dart';
import 'app_theme_extensions.dart';

ThemeData applyAppComponentTheme(ThemeData theme) {
  final tokens = theme.extension<AppThemeTokens>()!;
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
  );
  return theme.copyWith(
    materialTapTargetSize: MaterialTapTargetSize.padded,
    filledButtonTheme: FilledButtonThemeData(style: actions),
    outlinedButtonTheme: OutlinedButtonThemeData(style: actions),
    textButtonTheme: TextButtonThemeData(style: actions),
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

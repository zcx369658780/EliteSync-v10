import 'package:flutter/material.dart';
import '../components/layout/ui_s3_canvas.dart';
import 'app_component_theme.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/design_system/tokens/app_colors.dart';
import 'package:flutter_elitesync_module/design_system/tokens/app_motion.dart';
import 'package:flutter_elitesync_module/design_system/tokens/app_radius.dart';
import 'package:flutter_elitesync_module/design_system/tokens/app_spacing.dart';
import 'package:flutter_elitesync_module/design_system/tokens/app_typography.dart';

ThemeData buildLightTheme() {
  const uiS3 = UiS3Design.enabled;
  final base = UiS3Backdrop.base;
  final ink = uiS3 ? UiS3Design.ink : AppColors.textPrimaryLight;
  final secondary = uiS3 ? UiS3Design.secondary : AppColors.textSecondaryLight;
  final brand = uiS3 ? UiS3Design.accent : const Color(0xFF245FB8);
  final canvas = uiS3 ? base.canvas : AppColors.lightBg;
  final surface = uiS3 ? base.surface : AppColors.lightSurface;
  final zone = uiS3 ? base.zone : const Color(0xFFE7EDF8);
  final colorScheme = ColorScheme.light(
    primary: brand,
    onPrimary: Colors.white,
    primaryContainer: zone,
    onPrimaryContainer: uiS3 ? ink : const Color(0xFF183F7A),
    secondary: uiS3 ? secondary : AppColors.brandSecondary,
    surface: surface,
    onSurface: ink,
    onSurfaceVariant: secondary,
    error: Color(0xFFB42318),
    onError: Colors.white,
  );

  final tokens = AppThemeTokens(
    pageBackground: canvas,
    surface: surface,
    secondarySurface: uiS3 ? zone : AppColors.lightSecondarySurface,
    card: surface,
    overlay: zone,
    browseBackground: uiS3 ? canvas : AppColors.browseBg,
    browseSurface: uiS3 ? surface : AppColors.browseSurface,
    browseChip: uiS3 ? zone : AppColors.browseChip,
    browseNav: uiS3 ? surface : AppColors.browseNav,
    browseBorder: uiS3 ? UiS3Design.divider : AppColors.browseBorder,
    textPrimary: ink,
    textSecondary: secondary,
    textTertiary: Color(0xFF667085),
    brandPrimary: brand,
    brandSecondary: uiS3 ? secondary : const Color(0xFF6255C4),
    brandAccent: AppColors.brandAccent,
    success: Color(0xFF12734D),
    warning: Color(0xFF855000),
    error: Color(0xFFB42318),
    info: brand,
    spacing: const AppSpacingTokens(
      xxs: AppSpacing.xxs,
      xs: AppSpacing.xs,
      sm: AppSpacing.sm,
      md: AppSpacing.md,
      lg: AppSpacing.lg,
      xl: AppSpacing.xl,
      xxl: AppSpacing.xxl,
      xxxl: AppSpacing.xxxl,
      huge: AppSpacing.huge,
      pageHorizontal: AppSpacing.pageHorizontal,
      section: AppSpacing.section,
      sectionLarge: AppSpacing.sectionLarge,
      cardPadding: AppSpacing.cardPadding,
      cardPaddingLarge: AppSpacing.cardPaddingLarge,
    ),
    radius: const AppRadiusTokens(
      xs: AppRadius.xs,
      sm: AppRadius.sm,
      md: AppRadius.md,
      lg: AppRadius.lg,
      xl: AppRadius.xl,
      pill: AppRadius.pill,
    ),
    motionFast: AppMotion.fast,
    motionNormal: AppMotion.normal,
    motionSlow: AppMotion.slow,
  );

  return applyAppComponentTheme(
    ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: canvas,
      textTheme: const TextTheme(
        displayLarge: AppTypography.display32Bold,
        displayMedium: AppTypography.display28Bold,
        headlineLarge: AppTypography.headline24SemiBold,
        headlineMedium: AppTypography.headline20SemiBold,
        titleLarge: AppTypography.title18SemiBold,
        titleMedium: AppTypography.title16SemiBold,
        bodyLarge: AppTypography.body16Regular,
        bodyMedium: AppTypography.body14Regular,
        bodySmall: AppTypography.body12Regular,
        labelSmall: AppTypography.label11Medium,
      ).apply(bodyColor: ink, displayColor: ink),
      extensions: <ThemeExtension<dynamic>>[tokens],
    ),
  );
}

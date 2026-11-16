import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/design_system/theme/light_theme.dart';
import 'package:flutter_elitesync_module/design_system/theme/dark_theme.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_component_theme.dart';

double contrast(Color first, Color second) {
  final a = first.computeLuminance();
  final b = second.computeLuminance();
  return (a > b ? a + .05 : b + .05) / (a > b ? b + .05 : a + .05);
}

void main() {
  for (final brightness in Brightness.values) {
    final theme = brightness == Brightness.light
        ? buildLightTheme()
        : buildDarkTheme();
    test('$brightness button states have explicit readable foregrounds', () {
      var minimumText = double.infinity;
      var minimumBoundary = double.infinity;
      for (final style in [
        theme.filledButtonTheme.style!,
        theme.outlinedButtonTheme.style!,
        theme.textButtonTheme.style!,
        appDestructiveButtonStyle(theme),
        for (final selected in [false, true])
          appOptionButtonStyle(
            theme,
            selected: selected,
          ).merge(theme.outlinedButtonTheme.style!),
      ]) {
        for (final states in <Set<WidgetState>>[
          {},
          {WidgetState.pressed},
          {WidgetState.selected},
          {WidgetState.focused},
          {WidgetState.disabled},
          {WidgetState.selected, WidgetState.pressed},
          {WidgetState.selected, WidgetState.focused},
          {WidgetState.disabled, WidgetState.selected},
          {WidgetState.disabled, WidgetState.pressed},
          {WidgetState.disabled, WidgetState.focused},
        ]) {
          final foreground = style.foregroundColor?.resolve(states);
          final background = style.backgroundColor?.resolve(states);
          expect(foreground, isNotNull, reason: '$states foreground');
          expect(background, isNotNull, reason: '$states background');
          final displayed = Color.alphaBlend(
            style.overlayColor?.resolve(states) ?? Colors.transparent,
            Color.alphaBlend(background!, theme.colorScheme.surface),
          );
          final textContrast = contrast(foreground!, displayed);
          if (textContrast < minimumText) minimumText = textContrast;
          expect(textContrast, greaterThanOrEqualTo(4.5));
          final side = style.side?.resolve(states);
          if (side != null && side.style != BorderStyle.none) {
            final boundaryContrast = contrast(side.color, displayed);
            if (boundaryContrast < minimumBoundary) {
              minimumBoundary = boundaryContrast;
            }
            expect(
              boundaryContrast,
              greaterThanOrEqualTo(3),
              reason: '$states side=$side background=$displayed',
            );
          }
        }
      }
      // Recorded with the test log for the candidate's color specification.
      debugPrint(
        '$brightness minimum text=$minimumText boundary=$minimumBoundary',
      );
    });
    test(
      '$brightness selected option uses a paired container and foreground',
      () {
        final style = appOptionButtonStyle(theme, selected: true);
        expect(
          style.backgroundColor!.resolve({}),
          theme.colorScheme.primaryContainer,
        );
        expect(
          style.foregroundColor!.resolve({}),
          theme.colorScheme.onPrimaryContainer,
        );
        expect(style.side!.resolve({})!.width, 2);
        expect(style.side!.resolve({WidgetState.focused})!.width, 2);
      },
    );
  }
}

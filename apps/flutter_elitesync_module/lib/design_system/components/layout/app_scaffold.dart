import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'ui_s3_canvas.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.contentPadding,
    this.useSafeArea = true,
    this.backdrop = UiS3Backdrop.base,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final EdgeInsetsGeometry? contentPadding;
  final bool useSafeArea;
  final UiS3Backdrop backdrop;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final child = Padding(
      padding:
          contentPadding ??
          EdgeInsets.symmetric(horizontal: t.spacing.pageHorizontal),
      child: body,
    );

    final safeBody = useSafeArea ? SafeArea(child: child) : child;
    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor ?? t.pageBackground,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: UiS3Design.enabled
          ? UiS3Canvas(kind: backdrop, child: safeBody)
          : safeBody,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';

enum UiS3Backdrop {
  base(0xffeff4f5, 0xfff9fbfc, 0xffe4edf0),
  quiet(0xfff4f7f8, 0xfffbfcfd, 0xffe4edf0),
  reading(0xfff4f6f0, 0xfffafbf6, 0xffe7ede2),
  bazi(0xffedf5ef, 0xfff7fbf7, 0xffdcece1, 0xffe6f1e8),
  ziwei(0xffedf2f8, 0xfff7f9fc, 0xffdce6f1, 0xffe5edf6),
  western(0xfff2eff6, 0xfffaf7fc, 0xffe8e0ef, 0xffede6f2),
  buddy(0xffeef5f1, 0xfff8fbf8, 0xffe6f1e8),
  relationship(0xffeff4f5, 0xfff9fbfc, 0xffe4efee);

  const UiS3Backdrop(
    this._canvas,
    this._surface,
    this._zone, [
    this._alternate,
  ]);

  final int _canvas;
  final int _surface;
  final int _zone;
  final int? _alternate;
  Color get canvas => Color(_canvas);
  Color get surface => Color(_surface);
  Color get zone => Color(_zone);
  Color get alternate => Color(_alternate ?? _zone);

  Color surfaceOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Theme.of(context).colorScheme.surfaceContainer
      : surface;
}

abstract final class UiS3Design {
  static const enabled = bool.fromEnvironment('ELITESYNC_V2_FUNCTION_BUILD');
  static const ink = Color(0xff153c3d);
  static const accent = Color(0xff1b5958);
  static const secondary = Color(0xff4e696f);
  static const divider = Color(0xffcbd9de);
  static const art = 'assets/ui_s3/';
}

Widget uiS3Background(
  Widget child, {
  UiS3Backdrop kind = UiS3Backdrop.base,
  bool showBuddyArt = false,
  bool showEmptyArt = false,
}) => UiS3Design.enabled
    ? UiS3Canvas(
        kind: kind,
        showBuddyArt: showBuddyArt,
        showEmptyArt: showEmptyArt,
        child: child,
      )
    : child;

/// Decorative layers are painted inside the viewport, below all controls.
class UiS3Canvas extends StatelessWidget {
  const UiS3Canvas({
    super.key,
    required this.child,
    this.kind = UiS3Backdrop.base,
    this.showBuddyArt = false,
    this.showEmptyArt = false,
  });

  final Widget child;
  final UiS3Backdrop kind;
  final bool showBuddyArt;
  final bool showEmptyArt;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final media = MediaQuery.of(context);
    final restrained =
        media.size.height < 620 ||
        media.viewInsets.bottom > 0 ||
        media.textScaler.scale(16) > 22;
    return ColoredBox(
      color: dark ? Theme.of(context).colorScheme.surface : kind.canvas,
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: ExcludeSemantics(
              child: RepaintBoundary(
                child: CustomPaint(painter: _Geometry(kind, dark, restrained)),
              ),
            ),
          ),
          if ((showBuddyArt || showEmptyArt) && !restrained)
            Positioned(
              right: 20,
              bottom: 24,
              width: 132,
              height: 176,
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: Opacity(
                    opacity: dark ? 0.24 : 0.64,
                    child: ClipRect(
                      child: OverflowBox(
                        alignment: showBuddyArt
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        minWidth: 264,
                        maxWidth: 264,
                        child: Image.asset(
                          '${UiS3Design.art}buddy-and-empty-v2.png',
                          height: 176,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          child,
        ],
      ),
    );
  }
}

class UiS3BrandArt extends StatelessWidget {
  const UiS3BrandArt({super.key, this.aspectRatio = 2.05});
  final double aspectRatio;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: AspectRatio(
      aspectRatio: aspectRatio,
      child: Image.asset(
        '${UiS3Design.art}river.webp',
        fit: BoxFit.cover,
        alignment: Alignment.center,
      ),
    ),
  );
}

class _Geometry extends CustomPainter {
  const _Geometry(this.kind, this.dark, this.restrained);
  final UiS3Backdrop kind;
  final bool dark;
  final bool restrained;

  @override
  void paint(Canvas canvas, Size size) {
    final zone = dark ? kind.zone.withValues(alpha: 0.11) : kind.zone;
    final paint = Paint()..color = zone;
    final right = size.width;
    final height = size.height;
    final structure = Paint()
      ..color = zone.withValues(
        alpha: dark
            ? .13
            : restrained
            ? .44
            : .82,
      );
    final stroke = Paint()
      ..color = zone.withValues(
        alpha: dark
            ? .16
            : restrained
            ? .48
            : .96,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final edge = right * (restrained ? .17 : .36);
    final foot = Path()
      ..moveTo(right - edge, height)
      ..lineTo(right, height * .74)
      ..lineTo(right, height)
      ..close();
    canvas.drawPath(foot, structure);
    if (!restrained) {
      switch (kind) {
        case UiS3Backdrop.bazi:
          for (var i = 1; i <= 4; i++) {
            final x = right - i * 9.0;
            canvas.drawLine(Offset(x, height * .30), Offset(x, height), stroke);
          }
        case UiS3Backdrop.ziwei:
          for (var i = 0; i < 5; i++) {
            final y = height * .67 + i * 18;
            canvas.drawLine(Offset(right - 70, y), Offset(right, y), stroke);
            final x = right - i * 17;
            canvas.drawLine(
              Offset(x, height * .67),
              Offset(x, height * .67 + 72),
              stroke,
            );
          }
        case UiS3Backdrop.western:
          for (final scale in const [.28, .43, .57]) {
            canvas.drawCircle(
              Offset(right, height * .88),
              right * scale,
              stroke,
            );
          }
        case UiS3Backdrop.quiet:
          final axis = Path()
            ..moveTo(right * .76, height)
            ..lineTo(right * .92, height * .78)
            ..lineTo(right, height * .78);
          canvas.drawPath(axis, stroke);
          canvas.drawPath(axis.shift(const Offset(17, 17)), stroke);
        case UiS3Backdrop.relationship:
          final path = Path()
            ..moveTo(0, height * .59)
            ..lineTo(right * .13, height * .67)
            ..lineTo(right * .13, height * .81)
            ..lineTo(right * .29, height)
            ..lineTo(right * .39, height);
          canvas.drawPath(path, stroke);
          for (final stop in [
            Offset(right * .13, height * .67),
            Offset(right * .13, height * .81),
            Offset(right * .29, height),
          ]) {
            canvas.drawRect(
              Rect.fromCenter(center: stop, width: 6, height: 6),
              structure,
            );
          }
        default:
          final bend = Path()
            ..moveTo(0, height * .71)
            ..cubicTo(
              edge * .72,
              height * .79,
              -edge * .3,
              height * .92,
              edge,
              height,
            );
          canvas.drawPath(bend, stroke);
          canvas.drawPath(bend.shift(const Offset(-9, 14)), stroke);
      }
    }

    final corner = math.min(146.0, right * 0.32);
    switch (kind) {
      case UiS3Backdrop.bazi:
        for (var i = 0; i < 4; i++) {
          canvas.drawRect(
            Rect.fromLTWH(right - corner + i * corner / 4, 12, corner / 8, 64),
            paint,
          );
        }
      case UiS3Backdrop.ziwei:
        for (var i = 0; i < 4; i++) {
          canvas.drawRect(
            Rect.fromLTWH(
              right - corner + i * corner / 4,
              i * 12,
              corner / 4 - 2,
              20,
            ),
            paint,
          );
        }
        canvas.drawRect(
          Rect.fromLTWH(right - corner / 2, 46, corner / 2, 20),
          paint,
        );
      case UiS3Backdrop.western:
        final center = Offset(right, 0);
        canvas.drawCircle(center, corner * .55, paint);
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawCircle(center, corner * .76, paint);
      case UiS3Backdrop.relationship:
        final track = Path()
          ..moveTo(right - corner, 32)
          ..lineTo(right - corner * .63, 32)
          ..lineTo(right - corner * .39, 59)
          ..lineTo(right, 59);
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawPath(track, paint);
        paint.style = PaintingStyle.fill;
        for (final node in [
          Offset(right - corner, 32),
          Offset(right - corner * .39, 59),
        ]) {
          final diamond = Path()
            ..moveTo(node.dx, node.dy - 5)
            ..lineTo(node.dx + 5, node.dy)
            ..lineTo(node.dx, node.dy + 5)
            ..lineTo(node.dx - 5, node.dy)
            ..close();
          canvas.drawPath(diamond, paint);
        }
      case UiS3Backdrop.quiet:
      case UiS3Backdrop.reading:
        paint.color = zone.withValues(alpha: dark ? 0.11 : 0.56);
        for (var i = 0; i < 9; i++) {
          final x = right - (i % 3) * 7 - 11;
          final y = (i ~/ 3) * 7.0 + 16;
          canvas.drawCircle(Offset(x, y), 0.8, paint);
        }
        final band = Path()
          ..moveTo(right - 58, 42)
          ..lineTo(right, 0)
          ..lineTo(right, 12)
          ..lineTo(right - 49, 42)
          ..close();
        canvas.drawPath(band, paint);
      case UiS3Backdrop.base:
      case UiS3Backdrop.buddy:
        final diagonal = Path()
          ..moveTo(right - corner, 68)
          ..lineTo(right, 0)
          ..lineTo(right, 28)
          ..lineTo(right - corner * .78, 68)
          ..close();
        canvas.drawPath(diagonal, paint);
    }
  }

  @override
  bool shouldRepaint(_Geometry oldDelegate) =>
      oldDelegate.kind != kind ||
      oldDelegate.dark != dark ||
      oldDelegate.restrained != restrained;
}

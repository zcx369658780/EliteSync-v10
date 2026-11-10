import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'natal_restoration_charts.dart';

/// Geometry uses returned longitudes only; missing coordinates are never filled.
class DynamicChartWheel extends StatelessWidget {
  const DynamicChartWheel({
    super.key,
    required this.first,
    this.second,
    this.aspects = const [],
  });
  final Map<String, dynamic> first;
  final Map<String, dynamic>? second;
  final List<dynamic> aspects;
  @override
  Widget build(BuildContext context) => Semantics(
    label: '双盘轮：蓝色为第一盘，橙色为第二盘；数值详见下方',
    child: AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: _Wheel(
          first,
          second,
          aspects,
          Theme.of(context).colorScheme.onSurface,
        ),
      ),
    ),
  );
}

class _Wheel extends CustomPainter {
  _Wheel(this.first, this.second, this.aspects, this.ink);
  final Map<String, dynamic> first;
  final Map<String, dynamic>? second;
  final List<dynamic> aspects;
  final Color ink;
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero), radius = size.shortestSide * .43;
    Offset at(double longitude, double r) {
      final angle = (180 - longitude) * math.pi / 180;
      return center + Offset(math.cos(angle), -math.sin(angle)) * r;
    }

    final pen = Paint()
      ..style = PaintingStyle.stroke
      ..color = ink.withValues(alpha: .35);
    for (final scale in [1.0, .78, .55]) {
      canvas.drawCircle(center, radius * scale, pen);
    }
    void label(String value, Offset point, Color color, [double font = 10]) {
      final text = TextPainter(
        text: TextSpan(
          text: value,
          style: TextStyle(color: color, fontSize: font),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(canvas, point - Offset(text.width / 2, text.height / 2));
    }

    for (var i = 0; i < 12; i++) {
      canvas.drawLine(at(i * 30, radius * .78), at(i * 30, radius), pen);
      label(
        const [
          '白羊',
          '金牛',
          '双子',
          '巨蟹',
          '狮子',
          '处女',
          '天秤',
          '天蝎',
          '射手',
          '摩羯',
          '水瓶',
          '双鱼',
        ][i],
        at(i * 30 + 15, radius * .91),
        ink,
      );
    }
    void ring(Map<String, dynamic> chart, double scale, Color color) {
      final p = Paint()
        ..color = color.withValues(alpha: .5)
        ..style = PaintingStyle.stroke;
      for (final raw in natalList(chart['houses'])) {
        final h = natalMap(raw), cusp = h['cusp'];
        if (cusp is num) {
          canvas.drawLine(
            at(cusp.toDouble(), radius * (scale - .13)),
            at(cusp.toDouble(), radius * scale),
            p,
          );
          label(
            '${h['number']}',
            at(cusp.toDouble() + 4, radius * (scale - .08)),
            color,
          );
        }
      }
      for (final raw in natalList(chart['planets'])) {
        final body = natalMap(raw), longitude = body['longitude'];
        if (longitude is num) {
          final point = at(longitude.toDouble(), radius * scale);
          canvas.drawCircle(point, 2.5, Paint()..color = color);
          label(
            natalBodyLabel(body['name']),
            at(longitude.toDouble(), radius * (scale - .04)),
            color,
            9,
          );
        }
      }
    }

    ring(first, .76, Colors.blue);
    if (second != null) ring(second!, .53, Colors.deepOrange);
    final a = {
      for (final p in natalList(first['planets']))
        natalMap(p)['name']: natalMap(p)['longitude'],
    };
    final b = {
      for (final p in natalList(second?['planets']))
        natalMap(p)['name']: natalMap(p)['longitude'],
    };
    for (final raw in aspects) {
      final aspect = natalMap(raw);
      final left = a[aspect['first'] ?? aspect['a'] ?? aspect['first_point']];
      final right =
          b[aspect['second'] ?? aspect['b'] ?? aspect['second_point']];
      if (left is num && right is num) {
        canvas.drawLine(
          at(left.toDouble(), radius * .72),
          at(right.toDouble(), radius * .49),
          Paint()..color = Colors.purple.withValues(alpha: .3),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _Wheel old) => true;
}

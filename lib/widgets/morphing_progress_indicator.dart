import 'dart:math' as math;
import 'package:flutter/material.dart';

class MorphingProgress extends StatelessWidget {
  final double value; // 0..1
  final double t; // 0 = circle, 1 = line
  final double radius; // circle radius
  final double stroke;
  final Color color;
  final Color trackColor;
  final String? centerText; // e.g. "72%"
  final TextStyle? centerStyle;

  const MorphingProgress({
    super.key,
    required this.value,
    required this.t,
    this.radius = 50,
    this.stroke = 10,
    required this.color,
    required this.trackColor,
    this.centerText,
    this.centerStyle,
  });

  @override
  Widget build(BuildContext context) {
    // Height collapses from 2R to just the stroke; width expands to full.
    return LayoutBuilder(
      builder: (context, c) {
        final maxW = c.maxWidth.isFinite ? c.maxWidth : radius * 2;
        final h = lerpDouble(radius * 2, stroke + 4, t)!;
        return SizedBox(
          height: h,
          width: double.infinity,
          child: CustomPaint(
            painter: _MorphPainter(
              value: value.clamp(0, 1),
              t: t.clamp(0, 1),
              radius: radius,
              stroke: stroke,
              color: color,
              trackColor: trackColor,
              lineWidth: maxW - 32, // side padding
            ),
            child: Opacity(
              opacity: (1 - t * 1.6).clamp(0, 1), // fade label as it flattens
              child: Center(
                child: centerText == null
                    ? null
                    : Text(centerText!, style: centerStyle),
              ),
            ),
          ),
        );
      },
    );
  }
}

double? lerpDouble(num a, num b, double t) => a + (b - a) * t;

class _MorphPainter extends CustomPainter {
  final double value, t, radius, stroke, lineWidth;
  final Color color, trackColor;

  _MorphPainter({
    required this.value,
    required this.t,
    required this.radius,
    required this.stroke,
    required this.color,
    required this.trackColor,
    required this.lineWidth,
  });

  Offset _point(double u, Size size) {
    // Circle anchored to top-center of the widget so the label stays put.
    final cx = size.width / 2;
    final cy = radius; // circle center
    final theta = -math.pi / 2 + u * 2 * math.pi;
    final circle = Offset(
      cx + radius * math.cos(theta),
      cy + radius * math.sin(theta),
    );
    // Line anchored to horizontal center, vertically centered in collapsed row.
    final lineY = stroke / 2 + 2;
    final left = (size.width - lineWidth) / 2;
    final line = Offset(left + u * lineWidth, lineY);
    return Offset.lerp(circle, line, t)!;
  }

  Path _buildPath(double from, double to, Size size, {int samples = 60}) {
    final path = Path();
    if (to <= from) return path;
    for (int i = 0; i <= samples; i++) {
      final u = from + (to - from) * (i / samples);
      final p = _point(u, size);
      if (i == 0)
        path.moveTo(p.dx, p.dy);
      else
        path.lineTo(p.dx, p.dy);
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = trackColor;
    final fillPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;

    canvas.drawPath(_buildPath(0, 1, size), trackPaint);
    canvas.drawPath(_buildPath(0, value, size), fillPaint);
  }

  @override
  bool shouldRepaint(covariant _MorphPainter old) =>
      old.value != value || old.t != t || old.color != color;
}

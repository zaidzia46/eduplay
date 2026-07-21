import 'dart:math' as math;
import 'package:flutter/material.dart';

class MorphingProgressIndicator extends StatelessWidget {
  const MorphingProgressIndicator({
    super.key,
    required this.percent,
    required this.t,
    this.circleDiameter = 100,
    this.strokeWidth = 10,
    required this.trackColor,
    required this.progressColor,
    this.pointCount = 90,
  });

  final double percent;
  final double t;
  final double circleDiameter;
  final double strokeWidth;
  final Color trackColor;
  final Color progressColor;
  final int pointCount;

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : circleDiameter;
        final height = _lerp(circleDiameter, strokeWidth + 8, t.clamp(0, 1));
        return SizedBox(
          width: double.infinity,
          height: height,
          child: CustomPaint(
            painter: _MorphPainter(
              percent: (percent.clamp(0, 100)) / 100,
              t: t.clamp(0.0, 1.0),
              circleDiameter: circleDiameter,
              strokeWidth: strokeWidth,
              trackColor: trackColor,
              progressColor: progressColor,
              pointCount: pointCount,
            ),
            size: Size(width, height),
          ),
        );
      },
    );
  }
}

class _MorphPainter extends CustomPainter {
  _MorphPainter({
    required this.percent,
    required this.t,
    required this.circleDiameter,
    required this.strokeWidth,
    required this.trackColor,
    required this.progressColor,
    required this.pointCount,
  });

  final double percent;
  final double t;
  final double circleDiameter;
  final double strokeWidth;
  final Color trackColor;
  final Color progressColor;
  final int pointCount;

  @override
  void paint(Canvas canvas, Size size) {
    final circleRadius = circleDiameter / 2 - strokeWidth / 2;
    final circleCenter = Offset(size.width / 2, circleDiameter / 2);

    final lineY = size.height / 2;
    final lineStart = Offset(strokeWidth / 2, lineY);
    final lineEnd = Offset(size.width - strokeWidth / 2, lineY);
    final lineLength = lineEnd.dx - lineStart.dx;

    // Circle starts at 12 o'clock and goes clockwise, matching
    // CircularProgressIndicator's default orientation.
    Offset circlePoint(double frac) {
      final angle = -math.pi / 2 + frac * 2 * math.pi;
      return circleCenter +
          Offset(math.cos(angle), math.sin(angle)) * circleRadius;
    }

    Offset linePoint(double frac) => lineStart + Offset(lineLength * frac, 0);

    Offset morphedPoint(double frac) =>
        Offset.lerp(circlePoint(frac), linePoint(frac), t)!;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Full track: at t=0 this closes into a circle automatically, since
    // frac=0 and frac=1 land on the same point on the circle.
    final trackPath = Path();
    for (int i = 0; i <= pointCount; i++) {
      final p = morphedPoint(i / pointCount);
      i == 0 ? trackPath.moveTo(p.dx, p.dy) : trackPath.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(trackPath, trackPaint);

    final progressSteps = (pointCount * percent).round().clamp(0, pointCount);
    if (progressSteps > 0) {
      final progressPath = Path();
      for (int i = 0; i <= progressSteps; i++) {
        final p = morphedPoint(i / pointCount);
        i == 0
            ? progressPath.moveTo(p.dx, p.dy)
            : progressPath.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(progressPath, progressPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MorphPainter oldDelegate) {
    return oldDelegate.percent != percent ||
        oldDelegate.t != t ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}

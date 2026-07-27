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
    this.showBubble = true,
    this.bubbleColor,
    this.bubbleTextColor = Colors.white,
    this.knobColor = Colors.white,
  });

  final double percent;
  final double t;
  final double circleDiameter;
  final double strokeWidth;
  final Color trackColor;
  final Color progressColor;
  final int pointCount;

  /// Whether to show the little knob + percentage bubble at the leading
  /// edge of the progress fill once the indicator morphs towards its
  /// linear (bar) form.
  final bool showBubble;

  /// Background color of the percentage bubble. Defaults to [progressColor].
  final Color? bubbleColor;
  final Color bubbleTextColor;
  final Color knobColor;

  // Space reserved above the track for the bubble + its tail, once fully
  // revealed (i.e. when the indicator is in its linear form).
  static const double _bubbleReserve = 40;

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : circleDiameter;
        final tClamped = t.clamp(0.0, 1.0);

        // How "revealed" the bubble is. It only starts appearing once the
        // indicator is mostly morphed into a line, so it never competes
        // with the big centered percentage text that fades out earlier.
        final revealT = showBubble
            ? ((tClamped - 0.35) / 0.55).clamp(0.0, 1.0)
            : 0.0;

        final trackHeight = _lerp(circleDiameter, strokeWidth + 8, tClamped);
        final bubbleAreaHeight = _lerp(0, _bubbleReserve, revealT);
        final totalHeight = trackHeight + bubbleAreaHeight;

        return SizedBox(
          width: double.infinity,
          height: totalHeight,
          child: CustomPaint(
            painter: _MorphPainter(
              percent: (percent.clamp(0, 100)) / 100,
              t: tClamped,
              circleDiameter: circleDiameter,
              strokeWidth: strokeWidth,
              trackColor: trackColor,
              progressColor: progressColor,
              pointCount: pointCount,
              trackHeight: trackHeight,
              bubbleAreaHeight: bubbleAreaHeight,
              bubbleOpacity: revealT,
              bubbleColor: bubbleColor ?? progressColor,
              bubbleTextColor: bubbleTextColor,
              knobColor: knobColor,
            ),
            size: Size(width, totalHeight),
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
    required this.trackHeight,
    required this.bubbleAreaHeight,
    required this.bubbleOpacity,
    required this.bubbleColor,
    required this.bubbleTextColor,
    required this.knobColor,
  });

  final double percent;
  final double t;
  final double circleDiameter;
  final double strokeWidth;
  final Color trackColor;
  final Color progressColor;
  final int pointCount;
  final double trackHeight;
  final double bubbleAreaHeight;
  final double bubbleOpacity;
  final Color bubbleColor;
  final Color bubbleTextColor;
  final Color knobColor;

  @override
  void paint(Canvas canvas, Size size) {
    final circleRadius = circleDiameter / 2 - strokeWidth / 2;
    final circleCenter = Offset(size.width / 2, circleDiameter / 2);

    final lineY = trackHeight / 2;
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

    // All the track/progress painting happens in a coordinate space
    // shifted down by `bubbleAreaHeight`, leaving clean headroom above
    // for the knob + bubble.
    canvas.save();
    canvas.translate(0, bubbleAreaHeight);

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
    Offset? progressEnd;
    if (progressSteps > 0) {
      final progressPath = Path();
      for (int i = 0; i <= progressSteps; i++) {
        final p = morphedPoint(i / pointCount);
        i == 0
            ? progressPath.moveTo(p.dx, p.dy)
            : progressPath.lineTo(p.dx, p.dy);
        progressEnd = p;
      }
      canvas.drawPath(progressPath, progressPaint);
    } else {
      progressEnd = morphedPoint(0);
    }

    canvas.restore();

    // Knob + bubble sit at the leading edge of the progress fill, drawn in
    // full canvas coordinates (hence the +bubbleAreaHeight offset).
    if (bubbleOpacity > 0 && progressEnd != null) {
      final knobPoint = progressEnd + Offset(0, bubbleAreaHeight);
      _drawKnobAndBubble(canvas, size, knobPoint);
    }
  }

  void _drawKnobAndBubble(Canvas canvas, Size size, Offset knobPoint) {
    final knobRadius = strokeWidth / 2 + 3;

    // --- knob ---
    final knobFillPaint = Paint()
      ..color = knobColor.withOpacity(bubbleOpacity)
      ..style = PaintingStyle.fill;
    final knobBorderPaint = Paint()
      ..color = progressColor.withOpacity(bubbleOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawShadow(
      Path()..addOval(Rect.fromCircle(center: knobPoint, radius: knobRadius)),
      Colors.black.withOpacity(0.25 * bubbleOpacity),
      2,
      false,
    );
    canvas.drawCircle(knobPoint, knobRadius, knobFillPaint);
    canvas.drawCircle(knobPoint, knobRadius, knobBorderPaint);

    // --- bubble label ---
    final label = '${(percent * 100).round()}%';
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: bubbleTextColor.withOpacity(bubbleOpacity),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    const horizontalPadding = 8.0;
    const verticalPadding = 4.0;
    final bubbleWidth = textPainter.width + horizontalPadding * 2;
    final bubbleHeight = textPainter.height + verticalPadding * 2;
    const tailHeight = 5.0;
    const tailWidth = 8.0;
    const gapAboveKnob = 4.0;

    final bubbleBottom = knobPoint.dy - knobRadius - gapAboveKnob;
    final bubbleTop = bubbleBottom - tailHeight - bubbleHeight;

    var bubbleCenterX = knobPoint.dx;
    final halfBubbleWidth = bubbleWidth / 2;
    bubbleCenterX = bubbleCenterX.clamp(
      halfBubbleWidth,
      size.width - halfBubbleWidth,
    );

    final bubbleRect = Rect.fromLTWH(
      bubbleCenterX - halfBubbleWidth,
      bubbleTop,
      bubbleWidth,
      bubbleHeight,
    );
    final bubbleRRect = RRect.fromRectAndRadius(
      bubbleRect,
      Radius.circular(bubbleHeight / 2),
    );

    final bubblePaint = Paint()..color = bubbleColor.withOpacity(bubbleOpacity);

    final bubblePath = Path()..addRRect(bubbleRRect);

    // Tail, pointing from the bubble down towards the knob.
    final tailPath = Path()
      ..moveTo(knobPoint.dx - tailWidth / 2, bubbleBottom - tailHeight)
      ..lineTo(knobPoint.dx + tailWidth / 2, bubbleBottom - tailHeight)
      ..lineTo(knobPoint.dx, bubbleBottom)
      ..close();

    canvas.drawShadow(
      Path.combine(PathOperation.union, bubblePath, tailPath),
      Colors.black.withOpacity(0.15 * bubbleOpacity),
      2,
      false,
    );
    canvas.drawPath(bubblePath, bubblePaint);
    canvas.drawPath(tailPath, bubblePaint);

    textPainter.paint(
      canvas,
      Offset(
        bubbleRect.center.dx - textPainter.width / 2,
        bubbleRect.center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _MorphPainter oldDelegate) {
    return oldDelegate.percent != percent ||
        oldDelegate.t != t ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.bubbleOpacity != bubbleOpacity ||
        oldDelegate.bubbleAreaHeight != bubbleAreaHeight;
  }
}

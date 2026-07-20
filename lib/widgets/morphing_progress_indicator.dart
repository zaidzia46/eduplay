import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Draws a progress indicator that morphs between a circular ring (t = 0)
/// and a horizontal linear bar (t = 1) by lerping matching points sampled
/// on a circle and on a line.
class MorphingProgressIndicator extends StatelessWidget {
  const MorphingProgressIndicator({
    super.key,
    required this.percent, // 0-100
    required this.t, // 0 = circle, 1 = line
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

    // Colored progress: only the leading fraction of points.
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

/// -----------------------------------------------------------------------
/// Example integration. Assumes `scrollController` is the SAME controller
/// attached to the outer ListView/CustomScrollView that this card lives in.
/// -----------------------------------------------------------------------
class OverallProgressCard extends StatefulWidget {
  const OverallProgressCard({
    super.key,
    required this.stats,
    required this.scrollController,
  });

  final dynamic stats; // replace with your Stats type
  final ScrollController scrollController;

  @override
  State<OverallProgressCard> createState() => _OverallProgressCardState();
}

class _OverallProgressCardState extends State<OverallProgressCard> {
  final ValueNotifier<double> _morphT = ValueNotifier(0);

  // Scroll distance (px) over which the circle fully unrolls into a bar.
  static const double _morphDistance = 140;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    final offset = widget.scrollController.offset.clamp(0.0, _morphDistance);
    _morphT.value = offset / _morphDistance;
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_handleScroll);
    _morphT.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          // border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Overall Progress',
            ), // swap in AppTextStyles.sectionHeader
            const SizedBox(height: 16),
            ValueListenableBuilder<double>(
              valueListenable: _morphT,
              builder: (context, t, _) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    MorphingProgressIndicator(
                      percent: (widget.stats?.overallPercent ?? 0).toDouble(),
                      t: t,
                      circleDiameter: 100,
                      strokeWidth: 10,
                      trackColor: const Color(
                        0xFFE9ECFB,
                      ), // AppColors.primarySurface
                      progressColor: const Color(
                        0xFF5B6EF5,
                      ), // AppColors.primary
                    ),
                    Opacity(
                      opacity: (1 - t * 2).clamp(0.0, 1.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${widget.stats?.overallPercent ?? 0}%'),
                          const Text('Overall'),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class CometGlowBorder extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final double strokeWidth;
  final Duration spinDuration;
  final double arcFraction;
  final Color cometColor;
  final Color trackColor;

  const CometGlowBorder({
    super.key,
    required this.child,
    this.borderRadius = 15,
    this.strokeWidth = 3,
    this.spinDuration = const Duration(milliseconds: 2400),
    this.arcFraction = 0.28,
    this.cometColor = AppColors.primary,
    this.trackColor = AppColors.primaryDark,
  });

  @override
  State<CometGlowBorder> createState() => _CometGlowBorderState();
}

class _CometGlowBorderState extends State<CometGlowBorder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.spinDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          foregroundPainter: _CometBorderPainter(
            t: _controller.value,
            borderRadius: widget.borderRadius,
            strokeWidth: widget.strokeWidth,
            arcFraction: widget.arcFraction,
            cometColor: widget.cometColor,
            trackColor: widget.trackColor,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _CometBorderPainter extends CustomPainter {
  final double t; // 0..1 animation progress, loops
  final double borderRadius;
  final double strokeWidth;
  final double arcFraction;
  final Color cometColor;
  final Color trackColor;

  _CometBorderPainter({
    required this.t,
    required this.borderRadius,
    required this.strokeWidth,
    required this.arcFraction,
    required this.cometColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(borderRadius),
    );
    final fullPath = Path()..addRRect(rrect);
    final metric = fullPath.computeMetrics().first;
    final totalLen = metric.length;

    // 1. Dim base track (the resting ring the comet races around).
    final trackPaint = Paint()
      ..color = trackColor.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(fullPath, trackPaint);

    // 2. Comet arc: extract a moving window of the path.
    final arcLen = totalLen * arcFraction;
    final start = totalLen * t;
    final end = start + arcLen;

    Path cometPath;
    if (end <= totalLen) {
      cometPath = metric.extractPath(start, end);
    } else {
      // Wraps around the start of the path — stitch two segments.
      cometPath = metric.extractPath(start, totalLen);
      cometPath.addPath(metric.extractPath(0, end - totalLen), Offset.zero);
    }

    // Angle used to rotate the sweep gradient so the fade follows the comet.
    final center = rrect.center;
    final headPoint =
        metric.getTangentForOffset(start % totalLen)?.position ?? center;
    final headAngle = math.atan2(
      headPoint.dy - center.dy,
      headPoint.dx - center.dx,
    );

    final gradient = SweepGradient(
      colors: [
        cometColor.withOpacity(0.0),
        cometColor.withOpacity(0.9),
        cometColor,
      ],
      stops: const [0.0, 0.85, 1.0],
      transform: GradientRotation(headAngle - (2 * math.pi * arcFraction)),
    );
    final shaderRect = Rect.fromCircle(
      center: center,
      radius: (size.shortestSide) / 2,
    );

    // 3. Soft glow pass underneath (blurred, wider, softer color).
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 3
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(shaderRect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(cometPath, glowPaint);

    // 4. Sharp comet stroke on top.
    final cometPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(shaderRect);
    canvas.drawPath(cometPath, cometPaint);

    // 5. Bright head dot for extra "hot tip" glow.
    final headGlow = Paint()
      ..color = cometColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(headPoint, strokeWidth * 1.1, headGlow);
    final headCore = Paint()..color = Colors.white.withOpacity(0.85);
    canvas.drawCircle(headPoint, strokeWidth * 0.55, headCore);
  }

  @override
  bool shouldRepaint(covariant _CometBorderPainter oldDelegate) {
    return oldDelegate.t != t;
  }
}

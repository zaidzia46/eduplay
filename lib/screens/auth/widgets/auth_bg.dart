import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, this.child});
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AppColors.white),

        CustomPaint(painter: _EduPlayBackgroundPainter()),

        if (child != null) child!,
      ],
    );
  }
}

class _EduPlayBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ------------------------------------------------------------
    // 1. Main background
    // ------------------------------------------------------------

    final backgroundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primaryLight.withOpacity(0.55),
          AppColors.white,
          AppColors.primaryLight.withOpacity(0.20),
        ],
        stops: const [0.0, 0.48, 1.0],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, backgroundPaint);

    final topLeftCircle = Paint()
      ..shader =
          RadialGradient(
            colors: [AppColors.primaryLight, AppColors.primary],
          ).createShader(
            Rect.fromCircle(
              center: Offset(-w * 0.02, -w * 0.02),
              radius: w * 0.34,
            ),
          );

    canvas.drawCircle(Offset(-w * 0.02, -w * 0.02), w * 0.34, topLeftCircle);

    // ------------------------------------------------------------
    // 3. Soft central glow
    // ------------------------------------------------------------

    final centerGlow = Paint()
      ..shader =
          RadialGradient(
            colors: [
              AppColors.primary.withOpacity(0.12),
              AppColors.primaryLight.withOpacity(0.04),
              Colors.transparent,
            ],
            stops: const [0.0, 0.45, 1.0],
          ).createShader(
            Rect.fromCircle(
              center: Offset(w * 0.50, h * 0.40),
              radius: w * 0.72,
            ),
          );

    canvas.drawCircle(Offset(w * 0.50, h * 0.40), w * 0.72, centerGlow);

    // ------------------------------------------------------------
    // 4. Top-left decorative arc
    // ------------------------------------------------------------

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = AppColors.primary.withOpacity(0.15);

    canvas.drawArc(
      Rect.fromCircle(center: Offset(-w * 0.04, h * 0.14), radius: w * 0.40),
      -math.pi / 2,
      math.pi * 0.85,
      false,
      arcPaint,
    );

    // ------------------------------------------------------------
    // 5. Top-right dot grid
    // ------------------------------------------------------------

    _drawDotGrid(
      canvas,
      origin: Offset(w * 0.84, h * 0.018),
      columns: 5,
      rows: 8,
      spacing: w * 0.027,
      radius: 2.2,
      color: AppColors.primary.withOpacity(0.20),
    );

    // ------------------------------------------------------------
    // 6. Small floating circle — left
    // ------------------------------------------------------------

    final smallCirclePaint = Paint()
      ..color = AppColors.primaryLight.withOpacity(0.35);

    canvas.drawCircle(Offset(w * 0.11, h * 0.27), w * 0.032, smallCirclePaint);

    // ------------------------------------------------------------
    // 7. Right middle circle
    // ------------------------------------------------------------

    final rightCirclePaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              AppColors.white.withOpacity(0.8),
              AppColors.primaryLight.withOpacity(0.35),
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(w * 1.04, h * 0.42),
              radius: w * 0.085,
            ),
          );

    canvas.drawCircle(Offset(w * 1.04, h * 0.42), w * 0.085, rightCirclePaint);

    // ------------------------------------------------------------
    // 8. Bottom-left organic purple shape
    // ------------------------------------------------------------

    final bottomLeftPath = Path();

    bottomLeftPath.moveTo(0, h * 0.68);

    bottomLeftPath.cubicTo(
      w * 0.08,
      h * 0.65,
      w * 0.16,
      h * 0.70,
      w * 0.18,
      h * 0.77,
    );

    bottomLeftPath.cubicTo(w * 0.20, h * 0.84, w * 0.13, h * 0.88, 0, h * 0.84);

    bottomLeftPath.close();

    final bottomLeftPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [AppColors.primaryLight, AppColors.primary],
      ).createShader(Rect.fromLTWH(0, h * 0.65, w * 0.22, h * 0.25));

    canvas.drawPath(bottomLeftPath, bottomLeftPaint);

    // ------------------------------------------------------------
    // 9. Bottom-right giant purple circle
    // ------------------------------------------------------------

    final bottomRightCircle = Paint()
      ..shader =
          RadialGradient(
            center: Alignment.topLeft,
            radius: 1.0,
            colors: [AppColors.primaryLight, AppColors.primary],
          ).createShader(
            Rect.fromCircle(
              center: Offset(w * 1.04, h * 0.94),
              radius: w * 0.27,
            ),
          );

    canvas.drawCircle(Offset(w * 1.04, h * 0.94), w * 0.27, bottomRightCircle);

    // ------------------------------------------------------------
    // 10. Bottom decorative arcs
    // ------------------------------------------------------------

    final bottomArcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = AppColors.primary.withOpacity(0.18);

    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 0.68, h * 1.03), radius: w * 0.40),
      math.pi * 1.05,
      math.pi * 0.75,
      false,
      bottomArcPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 0.82, h * 0.94), radius: w * 0.31),
      math.pi * 0.95,
      math.pi * 0.55,
      false,
      bottomArcPaint,
    );

    // ------------------------------------------------------------
    // 11. Bottom-left dot grid
    // ------------------------------------------------------------

    _drawDotGrid(
      canvas,
      origin: Offset(w * 0.02, h * 0.91),
      columns: 6,
      rows: 6,
      spacing: w * 0.027,
      radius: 2.0,
      color: AppColors.primary.withOpacity(0.18),
    );

    // ------------------------------------------------------------
    // 12. Right-side decorative arc
    // ------------------------------------------------------------

    final rightArcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = AppColors.primary.withOpacity(0.14);

    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 1.08, h * 0.34), radius: w * 0.40),
      math.pi * 0.55,
      math.pi * 0.65,
      false,
      rightArcPaint,
    );
  }

  void _drawDotGrid(
    Canvas canvas, {
    required Offset origin,
    required int columns,
    required int rows,
    required double spacing,
    required double radius,
    required Color color,
  }) {
    final paint = Paint()..color = color;

    for (int row = 0; row < rows; row++) {
      for (int column = 0; column < columns; column++) {
        canvas.drawCircle(
          Offset(origin.dx + column * spacing, origin.dy + row * spacing),
          radius,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

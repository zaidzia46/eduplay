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

        CustomPaint(painter: _SimpleAuthBackgroundPainter()),

        if (child != null) child!,
      ],
    );
  }
}

class _SimpleAuthBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Soft base wash
    final backgroundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primaryLight.withOpacity(0.35),
          AppColors.white,
          AppColors.primary.withOpacity(0.06),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, backgroundPaint);

    // 2. Top-left soft blob
    final topLeftBlob = Paint()
      ..shader =
          RadialGradient(
            colors: [
              AppColors.primary.withOpacity(0.22),
              AppColors.primaryLight.withOpacity(0.10),
              Colors.transparent,
            ],
            stops: const [0.0, 0.45, 1.0],
          ).createShader(
            Rect.fromCircle(
              center: Offset(w * 0.05, h * 0.08),
              radius: w * 0.55,
            ),
          );

    canvas.drawCircle(Offset(w * 0.05, h * 0.08), w * 0.55, topLeftBlob);

    // 3. Bottom-right soft blob
    final bottomRightBlob = Paint()
      ..shader =
          RadialGradient(
            colors: [
              AppColors.primary.withOpacity(0.20),
              AppColors.primaryLight.withOpacity(0.08),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(
            Rect.fromCircle(
              center: Offset(w * 0.92, h * 0.92),
              radius: w * 0.55,
            ),
          );

    canvas.drawCircle(Offset(w * 0.92, h * 0.92), w * 0.55, bottomRightBlob);

    // 4. Tiny accent dot grid (bottom-left only, very subtle)
    _drawDotGrid(
      canvas,
      origin: Offset(w * 0.045, h * 0.74),
      columns: 4,
      rows: 5,
      spacing: w * 0.045,
      radius: 2.2,
      color: AppColors.primary.withOpacity(0.15),
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

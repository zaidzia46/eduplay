import 'package:flutter/material.dart';

class RainbowPainter extends CustomPainter {
  final double progress;

  RainbowPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 20, size.width, size.height);

    final colors = [Colors.purpleAccent, Colors.blue, Colors.yellow];

    for (int i = 0; i < colors.length; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect.deflate(i * 10), 3.14, 3.14 * progress, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant RainbowPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

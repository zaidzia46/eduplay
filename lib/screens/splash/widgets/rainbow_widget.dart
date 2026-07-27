import 'package:flutter/material.dart';

import '../painters/rainbow_painter.dart';

class RainbowWidget extends StatelessWidget {
  final Animation<double> animation;

  const RainbowWidget({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        return Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.57,
                height: 180,
                child: CustomPaint(
                  painter: RainbowPainter(progress: animation.value),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

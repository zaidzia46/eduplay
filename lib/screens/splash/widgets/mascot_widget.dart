import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MascotWidget extends StatelessWidget {
  final Animation<double> animation;

  const MascotWidget({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, child) {
        final progress = animation.value.clamp(0.0, 1.0);

        return Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: Transform.translate(
                offset: Offset(0, 55 * (1 - progress)),
                child: Opacity(opacity: progress, child: child),
              ),
            ),
          ),
        );
      },
      child: SizedBox(
        width: 140,
        height: 140,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Move mascot upward behind logo
            Transform.translate(
              offset: const Offset(0, -35),
              child: Lottie.asset(
                "assets/animations/mascot.json",
                repeat: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

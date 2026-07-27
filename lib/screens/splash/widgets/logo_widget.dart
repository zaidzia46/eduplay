import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final Animation<double> scaleAnimation;
  final Animation<double> opacityAnimation;

  const LogoWidget({
    super.key,
    required this.scaleAnimation,
    required this.opacityAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([scaleAnimation, opacityAnimation]),
      builder: (_, child) {
        return Positioned.fill(
          child: Center(
            child: Transform.scale(
              scale: scaleAnimation.value,
              child: Opacity(
                opacity: opacityAnimation.value.clamp(0.0, 1.0),
                child: child,
              ),
            ),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(shape: BoxShape.circle),
            child: Image.asset("assets/images/logo2.png"),
          ),
        ],
      ),
    );
  }
}

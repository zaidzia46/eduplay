import 'package:eduplay/screens/splash/widgets/rainbow_widget.dart';
import 'package:flutter/material.dart';

import '../splash_controller.dart';
import 'animated_bg.dart';
import 'logo_widget.dart';
import 'mascot_widget.dart';

class SplashScene extends StatelessWidget {
  final SplashController controller;

  const SplashScene({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Stack(
        children: [
          RainbowWidget(animation: controller.rainbowAnimation),
          MascotWidget(animation: controller.mascotAnimation),
          LogoWidget(
            scaleAnimation: controller.logoScaleAnimation,
            opacityAnimation: controller.logoOpacityAnimation,
          ),
        ],
      ),
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';

class TopicBannerBackground extends StatelessWidget {
  final Color startColor;
  final Color endColor;
  final Color starColor;

  const TopicBannerBackground({
    super.key,
    required this.startColor,
    required this.endColor,
    required this.starColor,
  });

  @override
  Widget build(BuildContext context) {
    final random = Random(1);
    const double starsTopPadding = 25;

    return SizedBox(
      height: 120,
      width: double.infinity,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [startColor, endColor],
              ),
            ),
          ),

          // Left hill
          Positioned(
            left: -40,
            bottom: -20,
            child: Container(
              width: 180,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),

          // Right hill
          Positioned(
            right: -80,
            bottom: -40,
            child: Container(
              width: 380,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(200),
              ),
            ),
          ),

          ...List.generate(60, (index) {
            final left = random.nextDouble() * 900;
            final top =
                random.nextDouble() * (100 - starsTopPadding) + starsTopPadding;
            final size = random.nextDouble() * 18 + 6;

            final outlined = random.nextBool();

            return Positioned(
              left: left,
              top: top,
              child: Icon(
                outlined ? Icons.star_border_rounded : Icons.star_rounded,
                color: starColor.withOpacity(random.nextDouble() * 0.5 + 0.5),
                size: size,
              ),
            );
          }),

          // Tiny sparkles
          ...List.generate(15, (index) {
            final left = random.nextDouble() * 900;
            final top = random.nextDouble() * 100;

            return Positioned(
              left: left,
              top: top,
              child: Container(
                width: 3,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

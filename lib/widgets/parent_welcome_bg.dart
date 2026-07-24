import 'package:flutter/material.dart';

class WelcomeBackgroundContainer extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;

  const WelcomeBackgroundContainer({
    super.key,
    required this.child,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:
          borderRadius ??
          BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4B1F8C),
              Color(0xFF7A35C9),
              Color(0xFFE7A23D),
              Color(0xFFF6C544),
            ],
            stops: [0.0, 0.4, 0.78, 1.0],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              left: -70,
              bottom: -80,
              child: _blurCircle(
                200,
                const Color(0xFF3B1770).withOpacity(0.45),
              ),
            ),
            Positioned(
              left: -10,
              bottom: -100,
              child: _blurCircle(
                170,
                const Color(0xFF3B1770).withOpacity(0.35),
              ),
            ),
            Positioned(
              right: -50,
              bottom: -90,
              child: _blurCircle(
                220,
                const Color(0xFFF8D77A).withOpacity(0.25),
              ),
            ),

            child,
          ],
        ),
      ),
    );
  }

  static Widget _blurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

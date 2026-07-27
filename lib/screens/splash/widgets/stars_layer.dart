import 'dart:math';

import 'package:flutter/material.dart';

class StarsLayer extends StatelessWidget {
  const StarsLayer({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final random = Random(42); // Fixed seed so stars don't jump every rebuild

    return Stack(
      children: List.generate(70, (index) {
        final left = random.nextDouble() * size.width;
        final top = random.nextDouble() * size.height;

        final starSize = random.nextDouble() * 3 + 1;

        return Positioned(
          left: left,
          top: top,
          child: _TwinkleStar(
            size: starSize,
            delay: random.nextInt(2000),
            duration: 1200 + random.nextInt(2000),
          ),
        );
      }),
    );
  }
}

class _TwinkleStar extends StatefulWidget {
  final double size;
  final int delay;
  final int duration;

  const _TwinkleStar({
    required this.size,
    required this.delay,
    required this.duration,
  });

  @override
  State<_TwinkleStar> createState() => _TwinkleStarState();
}

class _TwinkleStarState extends State<_TwinkleStar>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.duration),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: .25, end: 1.0).animate(controller),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF4C2),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFF4C2).withOpacity(.8),
              blurRadius: 8,
            ),
          ],
        ),
      ),
    );
  }
}

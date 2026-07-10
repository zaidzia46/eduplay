import 'package:flutter/material.dart';

class GridEntranceAnimation extends StatelessWidget {
  const GridEntranceAnimation({
    super.key,
    required this.controller,
    required this.index,
    required this.child,
    this.offset = const Offset(0.35, 0),
    this.curve = Curves.easeIn,
    this.delay = 0.06,
    this.duration = 0.45,
  });

  final AnimationController controller;
  final int index;
  final Widget child;

  final Offset offset;
  final Curve curve;
  final double delay;
  final double duration;

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(
        index * delay,
        (index * delay + duration).clamp(0.0, 1.0),
        curve: curve,
      ),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: offset,
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}

import 'package:flutter/material.dart';

class StaggeredAnimation extends StatelessWidget {
  const StaggeredAnimation({
    super.key,
    required this.controller,
    required this.index,
    required this.child,
    this.offset = const Offset(0, 0.35),
    this.startDelay = 0.08,
    this.duration = 0.55,
    this.curve = Curves.easeIn,
  });

  final AnimationController controller;
  final int index;
  final Widget child;

  final Offset offset;
  final double startDelay;
  final double duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(
        index * startDelay,
        (index * startDelay + duration).clamp(0.0, 1.0),
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

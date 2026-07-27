import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CloudsLayer extends StatelessWidget {
  const CloudsLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: const [
          _Cloud(top: 70, left: -20, width: 220),
          _Cloud(top: 120, right: -20, width: 180),
        ],
      ),
    );
  }
}

class _Cloud extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double width;

  const _Cloud({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: SizedBox(
        width: width,
        height: width * .55,
        child: Lottie.asset("assets/animations/cloud.json", repeat: true),
      ),
    );
  }
}

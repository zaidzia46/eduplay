import 'dart:ui';

class Particle {
  Offset position;
  Offset velocity;

  double radius;
  double opacity;

  Particle({
    required this.position,
    required this.velocity,
    required this.radius,
    required this.opacity,
  });

  void update() {
    position += velocity;

    opacity -= .02;

    radius *= .98;
  }

  bool get dead => opacity <= 0 || radius <= .5;
}

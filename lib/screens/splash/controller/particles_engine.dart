import 'dart:math';
import 'dart:ui';

import '../models/particles.dart';

class ParticleEngine {
  final random = Random();

  final particles = <Particle>[];

  void emit(Offset position) {
    particles.add(
      Particle(
        position: position,

        velocity: Offset(
          random.nextDouble() * 2 - 1,
          random.nextDouble() * 2 - 1,
        ),

        radius: random.nextDouble() * 3 + 2,

        opacity: 1,
      ),
    );
  }

  void update() {
    for (final particle in particles) {
      particle.update();
    }

    particles.removeWhere((e) => e.dead);
  }
}

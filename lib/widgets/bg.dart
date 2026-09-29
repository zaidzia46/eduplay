import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

/// Reusable gradient background: rich purple → pink wash like the
/// reference, with soft glows and faint playful icons.
/// Wrap any screen's content with it.
class SoftBackground extends StatelessWidget {
  const SoftBackground({
    super.key,
    this.child,
    this.purple,
    this.pink,
    this.icons = defaultIcons,
  });

  final Widget? child;

  final Color? purple;

  final Color? pink;
  final List<IconData> icons;

  static const List<IconData> defaultIcons = [
    Icons.star_rounded,
    Icons.favorite_rounded,
    Icons.auto_awesome_rounded, // sparkle
    Icons.lightbulb_rounded,
    Icons.music_note_rounded,
    Icons.emoji_emotions_rounded,
    Icons.palette_rounded,
    Icons.menu_book_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final p =
        AppColors.primaryDark.withOpacity(0.2) ??
        AppColors.primary.withOpacity(0.2);
    final k =
        AppColors.white.withOpacity(0.2) ??
        const Color(0xFFF472B6).withOpacity(0.2);

    return DecoratedBox(
      decoration: BoxDecoration(
        // Full-bleed diagonal gradient: purple top-left → pink bottom-right,
        // like the reference screenshot.
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [p, Color.lerp(p, k, 0.45)!, k],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Soft glows for depth (lighter blobs, like the reference's haze).
          CustomPaint(
            painter: _GlowPainter(purple: p, pink: k),
          ),
          // Faint white icons floating around the edges.
          CustomPaint(painter: _IconPainter(icons: icons)),
          if (child != null) child!,
        ],
      ),
    );
  }
}

/// Two large soft light blobs (top-right and bottom-left) that give the
/// gradient that airy, cloudy feel from the reference.
class _GlowPainter extends CustomPainter {
  _GlowPainter({required this.purple, required this.pink});

  final Color purple;
  final Color pink;

  @override
  void paint(Canvas canvas, Size size) {
    final glows = [
      // Big soft white haze top-right.
      _Glow(const Offset(0.85, 0.12), 0.55, Colors.white, 0.14),
      // Soft pink bloom bottom-left.
      _Glow(const Offset(0.10, 0.55), 0.50, Colors.white, 0.10),
      // Small warm bloom near the bottom center.
      _Glow(const Offset(0.55, 0.95), 0.40, pink, 0.18),
      // Subtle purple bloom upper-left so the top isn't flat.
      _Glow(const Offset(0.15, 0.08), 0.45, purple, 0.12),
    ];

    for (final g in glows) {
      final center = Offset(
        g.position.dx * size.width,
        g.position.dy * size.height,
      );
      final radius = g.radius * size.longestSide;
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [g.color.withOpacity(g.opacity), g.color.withOpacity(0)],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GlowPainter oldDelegate) =>
      oldDelegate.purple != purple || oldDelegate.pink != pink;
}

class _Glow {
  const _Glow(this.position, this.radius, this.color, this.opacity);

  final Offset position; // fractions of screen size
  final double radius; // fraction of longest side
  final Color color;
  final double opacity;
}

/// White playful icons at low opacity, kept near the edges so
/// screen content stays fully readable in the middle.
class _IconPainter extends CustomPainter {
  _IconPainter({required this.icons});

  final List<IconData> icons;

  @override
  void paint(Canvas canvas, Size size) {
    if (icons.isEmpty) return;

    final specs = [
      _IconSpec(0, const Offset(0.10, 0.18), 30, -0.25, 0.16),
      _IconSpec(1, const Offset(0.88, 0.30), 26, 0.20, 0.18),
      _IconSpec(2, const Offset(0.16, 0.46), 22, 0.15, 0.14),
      _IconSpec(3, const Offset(0.82, 0.62), 24, -0.15, 0.13),
      _IconSpec(4, const Offset(0.08, 0.76), 26, 0.30, 0.14),
      _IconSpec(5, const Offset(0.70, 0.88), 28, -0.10, 0.15),
      _IconSpec(6, const Offset(0.90, 0.82), 20, 0.25, 0.12),
      _IconSpec(7 % icons.length, const Offset(0.30, 0.08), 22, -0.30, 0.13),
    ];

    for (final spec in specs) {
      final icon = icons[spec.index % icons.length];
      final tp = TextPainter(textDirection: TextDirection.ltr);
      tp.text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          fontSize: spec.size,
          color: Colors.white.withOpacity(spec.opacity),
        ),
      );
      tp.layout();

      final pos = Offset(
        spec.position.dx * size.width,
        spec.position.dy * size.height,
      );
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      if (spec.rotation != 0) canvas.rotate(spec.rotation);
      tp.paint(canvas, Offset(-spec.size / 2, -spec.size / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _IconPainter oldDelegate) =>
      oldDelegate.icons != icons;
}

class _IconSpec {
  const _IconSpec(
    this.index,
    this.position,
    this.size,
    this.rotation,
    this.opacity,
  );

  final int index; // which icon from the list
  final Offset position; // fractions of screen size
  final double size;
  final double rotation; // radians
  final double opacity;
}

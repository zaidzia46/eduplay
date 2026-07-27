import 'package:flutter/material.dart';

class ProfileBackground extends StatelessWidget {
  const ProfileBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF4E7FF), Color(0xFFEEDBFF)],
              ),
            ),
          ),

          // Stars
          const Positioned(
            left: 30,
            top: 80,
            child: _Star(Icons.star_rounded, 42, Color(0xFFD6B3FF), .45),
          ),

          const Positioned(
            left: 120,
            top: 130,
            child: _Star(Icons.auto_awesome, 26, Colors.white, .8),
          ),

          const Positioned(
            left: 45,
            top: 280,
            child: _Star(Icons.auto_awesome, 20, Colors.white, .75),
          ),

          const Positioned(
            left: 140,
            bottom: 180,
            child: _Star(Icons.auto_awesome, 34, Color(0xFFD7B2FF), .65),
          ),

          const Positioned(
            left: 35,
            bottom: 70,
            child: _Star(Icons.auto_awesome, 26, Color(0xFFD7B2FF), .55),
          ),

          const Positioned(
            right: 80,
            top: 120,
            child: _Star(Icons.auto_awesome, 22, Colors.white, .8),
          ),

          const Positioned(
            right: 30,
            top: 250,
            child: _Star(Icons.auto_awesome, 36, Colors.white, .75),
          ),

          const Positioned(
            right: 120,
            bottom: 210,
            child: _Star(Icons.auto_awesome, 22, Color(0xFFE8D6FF), .8),
          ),

          const Positioned(
            right: 28,
            bottom: 80,
            child: _Star(Icons.star_rounded, 40, Color(0xFFD6B3FF), .45),
          ),

          const Positioned(
            right: 140,
            bottom: 20,
            child: _Star(Icons.auto_awesome, 34, Colors.white, .9),
          ),

          child,
        ],
      ),
    );
  }
}

class _Star extends StatelessWidget {
  const _Star(this.icon, this.size, this.color, this.opacity);

  final IconData icon;
  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Icon(icon, size: size, color: color),
    );
  }
}

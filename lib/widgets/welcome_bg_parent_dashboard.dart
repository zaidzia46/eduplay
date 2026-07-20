import 'package:eduplay/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../theme/app_colors.dart';

class WelcomeBackground extends StatelessWidget {
  final String welcomeText;
  final String userName;
  final String subtitleText;
  final int childrenCount;
  final int starsCount;
  final String childrenLabel;
  final String starsLabel;

  const WelcomeBackground({
    super.key,
    required this.welcomeText,
    required this.userName,
    required this.subtitleText,
    required this.childrenCount,
    required this.starsCount,
    this.childrenLabel = 'Children',
    this.starsLabel = 'Total Stars',
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAvatar(),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          welcomeText,
                          style: AppTextStyles.bodySecondary.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          userName,
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 90,
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6C544),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitleText,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 18),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _StatCard(
                                icon: Icons.people_alt_rounded,
                                iconColor: const Color(0xFFC98A1B),
                                bgColor: const Color(0xFFFCEBB0),
                                value: '$childrenCount',
                                label: childrenLabel,
                              ),
                              const SizedBox(width: 12),
                              _StatCard(
                                icon: Icons.star_rounded,
                                iconColor: const Color(0xFFC98A1B),
                                bgColor: const Color(0xFFFCEBB0),
                                value: '$starsCount',
                                label: starsLabel,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _buildAvatar() {
    double avatarSize = 65;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: avatarSize / 2,
          backgroundColor: const Color(0xffFFD84E),
          child: ClipOval(
            child: Image.asset(
              'assets/images/pak_mom2.png',
              fit: BoxFit.cover,
              width: avatarSize,
              height: avatarSize,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.person, size: 45, color: AppColors.primary),
            ),
          ),
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF6C544),
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.crown,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 15),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: iconColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: iconColor.withOpacity(0.8),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

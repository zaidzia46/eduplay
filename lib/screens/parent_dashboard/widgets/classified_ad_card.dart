import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class ClassifiedAd {
  final String title;
  final String blurb;
  final IconData icon;
  final Color color;

  const ClassifiedAd({
    required this.title,
    required this.blurb,
    required this.icon,
    required this.color,
  });
}

const List<ClassifiedAd> kClassifiedAds = [
  ClassifiedAd(
    title: "Kids' Coding Camp",
    blurb: 'Weekend robotics & Scratch classes for ages 7–12.',
    icon: Icons.smart_toy_rounded,
    color: AppColors.science,
  ),
  ClassifiedAd(
    title: 'Storybook Bundle',
    blurb: '20 illustrated readers to build early literacy.',
    icon: Icons.menu_book_rounded,
    color: AppColors.artAndCraft,
  ),
  ClassifiedAd(
    title: 'Math Tutor Nearby',
    blurb: 'Certified tutors for primary-grade mathematics.',
    icon: Icons.calculate_rounded,
    color: AppColors.maths,
  ),
];

class ClassifiedAdCard extends StatelessWidget {
  final ClassifiedAd ad;

  const ClassifiedAdCard({super.key, required this.ad});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 76,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ad.color.withOpacity(0.12),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Icon(ad.icon, color: ad.color, size: 34),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary.withOpacity(0.72),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Sponsored',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ad.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h4,
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Text(
                      ad.blurb,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Learn more',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

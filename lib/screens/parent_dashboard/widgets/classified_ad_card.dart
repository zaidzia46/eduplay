import 'package:flutter/material.dart';

import '../../../fns/image_constant.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class ClassifiedAd {
  final String title;
  final String blurb;
  final Image image;
  final Color color;

  const ClassifiedAd({
    required this.title,
    required this.blurb,
    required this.image,
    required this.color,
  });
}

final List<ClassifiedAd> kClassifiedAds = [
  ClassifiedAd(
    title: "Punjab Textbook Curriculum",
    blurb: 'Complete learning content as per Punjab Textbook Board.',
    image: Image.asset('${ImageConstant.pttb}'),
    color: AppColors.science,
  ),
  ClassifiedAd(
    title: 'Grade 4 added for LSG Lahore',
    blurb: 'New learning content for grade 4, aligned with LSG Lahore',
    image: Image.asset('${ImageConstant.LSGLahore}'),
    color: AppColors.maths,
  ),
  ClassifiedAd(
    title: 'Sindh Textbook Curriculum',
    blurb: 'Complete learning content as per Sindh Textbook Board',
    image: Image.asset('${ImageConstant.sttb}'),
    color: AppColors.artAndCraft,
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
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ad.color.withOpacity(0.12),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: ad.image,
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
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

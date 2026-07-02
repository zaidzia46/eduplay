import 'dart:developer';

import 'package:eduplay/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/onboarding_controller.dart';
import '../theme/app_text_styles.dart';
import '../utils/widgets/activity_tracker.dart';

class DashBoard extends StatelessWidget {
  DashBoard({super.key});
  final vm = Get.find<OnboardingViewModel>();

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;
    final bannerWidth = size.width - 24;
    final bannerHeight = bannerWidth * 841 / 1871;
    final topBackgroundHeight = (media.padding.top + 97 + bannerHeight).clamp(
      260.0,
      size.height * 0.45,
    );

    log('Dashboard: ${vm.selectedGender.value}');
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(
            height: topBackgroundHeight,
            decoration: BoxDecoration(
              color: AppColors.primary,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primary, Colors.white],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.yellow,
                          ),
                          child: Center(
                            child: ClipOval(
                              child: Image.asset(
                                vm.selectedGender.value.toLowerCase() == 'male'
                                    ? 'assets/images/boy.png'
                                    : 'assets/images/girl.png',
                                fit: BoxFit.cover,
                                height: 50,
                                width: 50,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi, ${vm.nameController.value.text.capitalize}!',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Ready to learn something amazing today?',
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                                softWrap: true,
                                textAlign: TextAlign.start,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 5),
                        ActivityTracker(
                          num: 123,
                          image: Image(
                            image: AssetImage('assets/images/star.png'),
                            fit: BoxFit.cover,
                            height: 24,
                          ),
                        ),
                        SizedBox(width: 8),
                        ActivityTracker(
                          num: 12,
                          image: Image(
                            image: AssetImage('assets/images/3d-fire.png'),
                            fit: BoxFit.cover,
                            height: 24,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: AspectRatio(
                            aspectRatio: 1871 / 841,
                            child: Image.asset(
                              'assets/images/banner.png',
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        Positioned(
                          left: (size.width * 0.05)
                              .clamp(20.0, 32.0)
                              .toDouble(),
                          bottom: (size.width * 0.055)
                              .clamp(18.0, 30.0)
                              .toDouble(),
                          width: (size.width * 0.26)
                              .clamp(125.0, 170.0)
                              .toDouble(),
                          height: (size.width * 0.065)
                              .clamp(32.0, 40.0)
                              .toDouble(),
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "Start Learning",
                                style: AppTextStyles.buttonMedium.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            'Choose a Subject',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                padding: EdgeInsets.symmetric(vertical: 8),

                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'View all',
                                style: AppTextStyles.label.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

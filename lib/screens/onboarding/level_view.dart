import 'package:eduplay/widgets/level_selector.dart';
import 'package:flutter/material.dart';
import 'package:eduplay/theme/app_text_styles.dart';
import 'package:get/get.dart';

import '../../controller/onboarding_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/progress_bar.dart';

class Level extends StatelessWidget {
  Level({super.key});
  final vm = Get.find<OnboardingViewModel>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: Image.asset(
                'assets/images/level_onboard.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 25,
              left: 0,
              right: 0,
              child: OnboardingProgressBar(
                currentStep: vm.currentStep.value,
                totalSteps: 3,
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height < 900 ? 100 : 180,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  children: [
                    Text(
                      "Pick their learning level",
                      style: AppTextStyles.display,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Choose the option that that best matches their current learning.",
                      style: AppTextStyles.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height < 800
                  ? 10
                  : MediaQuery.of(context).size.height < 1200
                  ? 100
                  : 190,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 20),

                    Row(
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          size: 30,
                          color: AppColors.tertiary,
                        ),
                        SizedBox(width: 5),
                        Text("Learning level", style: AppTextStyles.bodyLarge),
                      ],
                    ),
                    SizedBox(height: 20),
                    LevelSelector(),
                    SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tertiary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text("Next", style: AppTextStyles.buttonLarge),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:eduplay/theme/app_text_styles.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../controller/onboarding_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/age_selector.dart';
import '../../widgets/progress_bar.dart';

class Age extends StatelessWidget {
  Age({super.key});
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
                'assets/images/age_onboard.png',
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
              top: 180,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  children: [
                    Text(
                      "How Old are they?",
                      style: AppTextStyles.display,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Select the age to personalize their journey.",
                      style: AppTextStyles.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 190,
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
                          Icons.calendar_month,
                          size: 30,
                          color: AppColors.secondary,
                        ),
                        SizedBox(width: 5),
                        Text("Age", style: AppTextStyles.bodyLarge),
                      ],
                    ),
                    SizedBox(height: 20),
                    AgeSelector(),
                    SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: vm.goToLevelScreen,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
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

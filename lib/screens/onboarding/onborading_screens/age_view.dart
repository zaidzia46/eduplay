import 'package:flutter/material.dart';
import 'package:eduplay/theme/app_text_styles.dart';
import 'package:get/get.dart';

import '../../../theme/app_colors.dart';
import '../../../widgets/age_selector.dart';
import '../../../widgets/gender_selector.dart';
import '../../../widgets/progress_bar.dart';
import '../onboarding_controller.dart';

class Age extends StatelessWidget {
  Age({super.key});
  final vm = Get.find<OnboardingController>();
  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/age_onboard.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Stack(
              alignment: Alignment.center,
              children: [
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
                  top: h * 0.2,
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
                  top: h * 0.5,
                  left: 0,
                  right: 0,
                  child: SingleChildScrollView(
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
                          GenderSelector(),
                          SizedBox(height: 20),

                          ElevatedButton(
                            onPressed: vm.goToLevelScreen,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                            ),
                            child: Text(
                              "Next",
                              style: AppTextStyles.buttonLarge,
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

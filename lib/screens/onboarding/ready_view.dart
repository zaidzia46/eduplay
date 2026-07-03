import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/onboarding_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/feature_tile.dart';
import '../../widgets/progress_bar.dart';

class ReadyView extends StatelessWidget {
  const ReadyView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<OnboardingController>();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/level_onboard.png', fit: BoxFit.cover),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  OnboardingProgressBar(
                    currentStep: vm.currentStep.value,
                    totalSteps: 3,
                  ),

                  const Spacer(),

                  const SizedBox(height: 16),

                  Text(
                    "You're all set, ${vm.nameController.value.text.capitalize}!",
                    style: AppTextStyles.h1,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  // Subtext
                  Text(
                    'Your learning adventure is ready.\nLet\'s explore, play, and grow together!',
                    style: AppTextStyles.bodyLarge,
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(),

                  // Feature highlight cards
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    child: Column(
                      children: const [
                        FeatureTile(
                          image: Image(
                            image: AssetImage('assets/images/3d-notebook.png'),
                          ),
                          title: 'Learn at your pace',
                          subtitle: 'Fun lessons made just for you',
                        ),
                        SizedBox(height: 12),
                        FeatureTile(
                          image: Image(
                            image: AssetImage('assets/images/3d-trophy.png'),
                          ),
                          title: 'Play & earn rewards',
                          subtitle: 'Stars and badges for every win',
                        ),
                        SizedBox(height: 12),
                        FeatureTile(
                          image: Image(
                            image: AssetImage('assets/images/robot.png'),
                          ),
                          title: 'Your AI buddy',
                          subtitle: 'Always here to help you learn',
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // CTA button
                  ElevatedButton(
                    onPressed: vm.finishOnboarding,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.star, // gold color
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Let's Go!",
                      style: AppTextStyles.buttonLarge,
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:eduplay/theme/app_text_styles.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../controller/onboarding_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../utils/widgets/progress_bar.dart';

class Name extends StatelessWidget {
  Name({super.key});
  final vm = Get.find<OnboardingViewModel>();
  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: Image.asset(
                'assets/images/name_onboard.png',
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
              top: h * 0.2,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  children: [
                    Text(
                      "Who's learning today?",
                      style: AppTextStyles.display,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Let's get started!",
                      style: AppTextStyles.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: h * 0.57,
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
                        Icon(Icons.person, size: 30, color: AppColors.primary),
                        SizedBox(width: 5),
                        Text("Name", style: AppTextStyles.bodyLarge),
                      ],
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: vm.nameController,
                      decoration: InputDecoration(
                        hintText: "Enter name",
                        hintStyle: AppTextStyles.bodySecondary,
                      ),
                    ),
                    SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () {
                        vm.goToAgeScreen();
                      },
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

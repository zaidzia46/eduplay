import 'package:flutter/material.dart';
import 'package:eduplay/theme/app_text_styles.dart';
import 'package:get/get.dart';

import '../../../theme/app_colors.dart';
import '../../../widgets/progress_bar.dart';
import '../onboarding_controller.dart';

class Name extends StatelessWidget {
  Name({super.key});
  final vm = Get.find<OnboardingController>();
  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final h = media.size.height;
    final keyboardInset = media.viewInsets.bottom;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/name_onboard.png', fit: BoxFit.cover),
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
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  top: keyboardInset == 0 ? h * 0.57 : null,
                  bottom: keyboardInset == 0 ? null : keyboardInset + 16,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                              Icons.person,
                              size: 30,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 5),
                            Text("Name", style: AppTextStyles.bodyLarge),
                          ],
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: vm.nameController,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            hintText: "Enter name",
                            hintStyle: AppTextStyles.bodySecondary,
                          ),
                          onSubmitted: (_) {
                            FocusScope.of(context).unfocus();
                          },
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            FocusScope.of(context).unfocus();
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
        ],
      ),
    );
  }
}

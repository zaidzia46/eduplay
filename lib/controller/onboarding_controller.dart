import 'dart:developer';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../routes/app_routes.dart';

class OnboardingController extends GetxController {
  final nameController = TextEditingController();
  var selectedAge = '6'.obs;
  var selectedGender = 'Male'.obs;
  var currentStep = 0.obs;

  // Validation
  bool get isNameValid => nameController.text.trim().isNotEmpty;

  // Navigation
  void goToAgeScreen() {
    if (!isNameValid) {
      Get.snackbar(
        'Oops!',
        'Please enter your name',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    currentStep.value = 1;
    Get.toNamed(AppRoutes.onboardingAge);
  }

  void goToLevelScreen() {
    currentStep.value = 2;
    Get.toNamed(AppRoutes.onboardingReady);
  }

  Future<void> finishOnboarding() async {
    await GetStorage().write('isOnboarded', true);
    // Save to Hive later — for now just navigate
    Get.offAllNamed(AppRoutes.home);
  }

  void gender(String gender) {
    selectedGender.value = gender;
    log(selectedGender.value);
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}

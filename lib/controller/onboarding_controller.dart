import 'dart:developer';

import 'package:eduplay/repositories/standard_repo.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../models/standards.dart';
import '../routes/app_routes.dart';

class OnboardingController extends GetxController {
  StandardRepository _standardRepo = StandardRepository();

  final nameController = TextEditingController();
  var selectedAge = '6'.obs;
  var selectedGender = 'Male'.obs;
  var currentStep = 0.obs;
  var standards = <StandardModel>[].obs;
  var selectedStandardIndex = 0.obs;
  var isStandardLoading = true.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getStandards();
  }

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

  Future<void> getStandards() async {
    try {
      isStandardLoading.value = true;
      errorMessage.value = '';
      standards.value = await _standardRepo.getStandards();
    } catch (e) {
      errorMessage.value = 'Could not load standards';
      log('Error in lessons: $e');
    } finally {
      isStandardLoading.value = false;
    }
  }

  void selectStandard(int index) {
    selectedStandardIndex.value = index;
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
